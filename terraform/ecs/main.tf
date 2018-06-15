terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

provider "aws" {
    region     = "${var.region}"
}

data "aws_ami" "lookup" {
    most_recent = true
    name_regex  = "${var.ami_regexp}"
    owners      = ["amazon"]
    filter {
       name   = "architecture"
       values = ["x86_64"]
    }
    filter {
       name   = "image-type"
       values = ["machine"]
    }
    filter {
       name   = "state"
       values = ["available"]
    }
    filter {
       name   = "virtualization-type"
       values = ["hvm"]
    }
    filter {
       name   = "hypervisor"
       values = ["xen"]
    }
    filter {
       name   = "root-device-type"
       values = ["ebs"]
    }
}

data "template_file" "ecs_cloud_config" {
    template = "${file("${path.module}/files/cloud-config.yml.template")}"
    vars {
        cluster_name = "${aws_ecs_cluster.main.name}"
    }
}

data "template_cloudinit_config" "cloud_config" {
    gzip          = false
    base64_encode = false
    part {
        content_type = "text/cloud-config"
        content      = "${data.template_file.ecs_cloud_config.rendered}"
    }
}

# construct a role that allow ECS instances to interact with load balancers
resource "aws_iam_role" "default_ecs_role" {
    name_prefix = "ecs-role"
    description = "Allows ECS workers to assume required roles"
    assume_role_policy = "${file( "${path.module}/files/trust.json" )}"
}

resource "aws_iam_role_policy" "default_ecs_service_role_policy" {
    name_prefix = "ecs-service-role-${replace(var.project, " ", "-")}-${var.environment}-"
    role = "${aws_iam_role.default_ecs_role.id}"
    policy = "${file( "${path.module}/files/permissions.json" )}"
}

resource "aws_iam_instance_profile" "default_ecs" {
    name_prefix = "ecs-instance-profile-${replace(var.project, " ", "-")}-${var.environment}-"
    role        = "${aws_iam_role.default_ecs_role.name}"
}

resource "aws_security_group" "ec2_access" {
    name_prefix = "ec2-"
    description = "Controls access to the EC2 instances"
    vpc_id      = "${var.vpc_id}"
    tags {
        Name        = "EC2 Access"
        Project     = "${var.project}"
        Purpose     = "Controls access to the EC2 instances"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "${var.freetext}"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "ec2_ingress_bastion" {
    type                     = "ingress"
    from_port                = 0
    protocol                 = "all"
    security_group_id        = "${aws_security_group.ec2_access.id}"
    source_security_group_id = "${var.bastion_security_group_id}"
    to_port                  = 65535
    description              = "Only allow traffic from the Bastion boxes"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "ec2_ingress_alb" {
    type                     = "ingress"
    from_port                = 0
    protocol                 = "all"
    security_group_id        = "${aws_security_group.ec2_access.id}"
    source_security_group_id = "${aws_security_group.alb_access.id}"
    to_port                  = 65535
    description              = "Only allow traffic from the load balancers"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "ec2_egress" {
    type               = "egress"
    cidr_blocks        = ["0.0.0.0/0"]
    from_port          = 0
    protocol           = "all"
    security_group_id  = "${aws_security_group.ec2_access.id}"
    to_port            = 65535
    description       = "Allow unrestricted egress"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_ecs_cluster" "main" {
    name = "${var.name}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "worker_spot" {
    name_prefix          = "${var.name}-"
    image_id             = "${data.aws_ami.lookup.id}"
    instance_type        = "${var.instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.default_ecs.id}"
    key_name             = "${var.ssh_key_name}"
    security_groups      = ["${aws_security_group.ec2_access.id}"]
    user_data            = "${data.template_cloudinit_config.cloud_config.rendered}"
    enable_monitoring    = true
    ebs_optimized        = "${var.ebs_optimized}"
    spot_price           = "${var.spot_price}"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "worker_spot" {
    name_prefix               = "${var.name}"
    max_size                  = "${var.cluster_max_size}"
    min_size                  = "${var.cluster_min_size}"
    default_cooldown          = "${var.cooldown}"
    launch_configuration      = "${aws_launch_configuration.worker_spot.name}"
    health_check_grace_period = "${var.health_check_grace_period}"
    health_check_type         = "EC2"
    desired_capacity          = "${var.cluster_desired_size}"
    vpc_zone_identifier       = ["${var.ecs_subnet_ids}"]
    termination_policies      = ["ClosestToNextInstanceHour", "OldestInstance", "Default"]
    enabled_metrics           = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
    lifecycle {
        create_before_destroy = true
    }
    tag {
        key                 = "Name"
        value               = "ECS Worker (spot)"
        propagate_at_launch = true
    }
    tag {
        key                 = "Project"
        value               = "${var.project}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Purpose"
        value               = "ECS Worker (spot)"
        propagate_at_launch = true
    }
    tag {
        key                 = "Creator"
        value               = "${var.creator}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Environment"
        value               = "${var.environment}"
        propagate_at_launch = true
    }
    tag {
        key                 = "Freetext"
        value               = "${var.freetext}"
        propagate_at_launch = true
    }
}

resource "aws_autoscaling_schedule" "spot_scale_up" {
    autoscaling_group_name = "${aws_autoscaling_group.worker_spot.name}"
    scheduled_action_name  = "ECS Worker Scale Up (spot)"
    recurrence             = "${var.scale_up_cron}"
    min_size               = "${var.cluster_min_size}"
    max_size               = "${var.cluster_max_size}"
    desired_capacity       = "${var.cluster_desired_size}"
}

resource "aws_autoscaling_schedule" "spot_scale_down" {
    autoscaling_group_name = "${aws_autoscaling_group.worker_spot.name}"
    scheduled_action_name  = "ECS Worker Scale Down (spot)"
    recurrence             = "${var.scale_down_cron}"
    min_size               = "${var.cluster_scaled_down_min_size}"
    max_size               = "${var.cluster_scaled_down_max_size}"
    desired_capacity       = "${var.cluster_scaled_down_desired_size}"
}

resource "aws_security_group" "alb_access" {
    name_prefix = "alb-"
    description = "Controls access to the Application Load Balancer"
    vpc_id      = "${var.vpc_id}"
    tags {
        Name        = "Application Load Balancer Access"
        Project     = "${var.project}"
        Purpose     = "Controls access to the Application Load Balancer"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "${var.freetext}"
    }
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "alb_ingress_insecure" {
    type                     = "ingress"
    from_port                = 80
    protocol                 = "all"
    security_group_id        = "${aws_security_group.alb_access.id}"
    cidr_blocks              = ["0.0.0.0/0"]
    to_port                  = 80
    description              = "Allow HTTP traffic from anywhere."
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_s3_bucket" "access_logs" {
    bucket_prefix = "access-logs-"
    acl           = "private"
    force_destroy = "true"
    region        = "${var.region}"
    tags {
        Name        = "${var.name}"
        Project     = "${var.project}"
        Purpose     = "Holds HTTP access logs for project ${var.project}"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "${var.freetext}"
    }
    lifecycle_rule {
        id = "log-expiration"
        enabled = "true"
        expiration {
            days = "7"
        }
        tags {
            Name        = "${var.name}"
            Project     = "${var.project}"
            Purpose     = "Expire access logs for project ${var.project}"
            Creator     = "${var.creator}"
            Environment = "${var.environment}"
            Freetext    = "${var.freetext}"
        }
    }
}

data "aws_elb_service_account" "main" {}

data "aws_billing_service_account" "main" {}

data "template_file" "alb_permissions" {
    template = "${file("${path.module}/files/permissions.json.template")}"
    vars {
        bucket_name     = "${aws_s3_bucket.access_logs.id}"
        billing_account = "${data.aws_billing_service_account.main.id}"
        service_account = "${data.aws_elb_service_account.main.arn}"
    }
}

resource "aws_s3_bucket_policy" "alb_permissions" {
    bucket = "${aws_s3_bucket.access_logs.id}"
    policy = "${data.template_file.alb_permissions.rendered}"
}

resource "aws_lb" "alb" {
    name_prefix                = "alb-"
    internal                   = "${var.internal == "Yes" ? true : false}"
    load_balancer_type         = "application"
    security_groups            = ["${aws_security_group.alb_access.id}"]
    subnets                    = ["${var.subnet_ids}"]
    idle_timeout               = 60
    enable_deletion_protection = false
    ip_address_type            = "ipv4"
    tags {
        Name        = "${var.name}"
        Project     = "${var.project}"
        Purpose     = "${var.purpose}"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "${var.freetext}"
    }
    timeouts {
        create = "10m"
        update = "10m"
        delete = "10m"
    }
    access_logs {
        bucket  = "${aws_s3_bucket.access_logs.id}"
        enabled = "true"
    }
     depends_on = ["aws_s3_bucket_policy.alb_permissions"]
}

resource "aws_lb_target_group" "default_insecure_target" {
    name_prefix          = "alb-"
    port                 = "80"
    protocol             = "HTTP"
    vpc_id               = "${var.vpc_id}"
    deregistration_delay = 300
    stickiness {
        type            = "lb_cookie"
        cookie_duration = 86400
        enabled         = "true"
    }
    tags {
        Name        = "${var.name}"
        Project     = "${var.project}"
        Purpose     = "Default target for insecure HTTP traffic"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "No instances typically get bound to this target"
    }
}

resource "aws_lb_listener" "insecure_listener" {
    load_balancer_arn = "${aws_lb.alb.arn}"
    port              = "80"
    protocol          = "HTTP"
    default_action {
       target_group_arn = "${aws_lb_target_group.default_insecure_target.arn}"
       type             = "forward"
    }
}
