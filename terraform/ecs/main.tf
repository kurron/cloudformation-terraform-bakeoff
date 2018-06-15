terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

provider "aws" {
    region     = "${var.region}"
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
