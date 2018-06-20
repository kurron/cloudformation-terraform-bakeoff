terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

variable "region" {
    type = "string"
    default = "us-east-2"
}

variable "project" {
    type = "string"
    default = "Bake Off"
}

variable "creator" {
    type = "string"
    default = "rkurr@jvmguy.com using Terraform"
}

variable "environment" {
    type = "string"
    default = "development"
}

variable "scale_up_cron" {
    type = "string"
    default = "0 8 * * MON-FRI"
}

variable "scale_down_cron" {
    type = "string"
    default = "0 0 * * SUN-SAT"
}

variable "purpose" {
    type = "string"
    default = "Terraform vs CloudFormation comparison"
}

variable "log_group" {
    type = "string"
    default = "bakeoff"
}

module "vpc" {
    source = "../../vpc"

    region             = "${var.region}"
    name               = "Terraform"
    project            = "${var.project}"
    purpose            = "${var.purpose}"
    creator            = "${var.creator}"
    environment        = "${var.environment}"
    freetext           = "One public and private subnet in each AZ."
    cidr_range         = "10.0.0.0/16"
    private_subnets    = ["10.0.1.0/24","10.0.3.0/24","10.0.5.0/24"]
    public_subnets     = ["10.0.2.0/24","10.0.4.0/24","10.0.6.0/24"]
    populate_all_zones = "true"
}

module "bastion" {
    source = "../../bastion"

    region                      = "${var.region}"
    project                     = "${var.project}"
    creator                     = "${var.creator}"
    environment                 = "${var.environment}"
    freetext                    = "Bastion boxes should be the only instances in the public subnets"
    instance_type               = "t2.nano"
    ssh_key_name                = "Bastion"
    min_size                    = "1"
    max_size                    = "2"
    cooldown                    = "60"
    health_check_grace_period   = "300"
    desired_capacity            = "1"
    scale_down_desired_capacity = "0"
    scale_down_min_size         = "0"
    scale_up_cron               = "${var.scale_up_cron}"
    scale_down_cron             = "${var.scale_down_cron}"
    public_ssh_key              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfYQ0mYkeux8yK8w/Wb3LnYDHVB9mwCaaN/UXnD/1gN4Ka7ArcMCHHzo4JUnHl6AM2vzZbbt+sgETZoYgpMGZIh+6wwnxOSdRen/b4aKer0ni8yW38r/DnhXa4FGBiwhgMBCs43e7TDnwSwJBUNpBbcD99XnYzvtsbOV0tHYUh11VoqAi4xqha3+L4G00tpQFk/WU+YZicrPjjMhtd14fnlmaMaxI3On5We3b/OXkSuqTnBjE074dmyORy0V6Lp6+814Cnme4OHR/15fRHp6JfZc1dGKgJdyM1csrxWzuJmPkdPnfwFIR+xbx6jIps/uojCV+ADe5TS+3OrJVIbtaB rkurr@jvmguy.com"
    bastion_ingress_cidr_blocks = ["50.235.141.198/32","98.216.147.13/32"]
    subnet_ids                  = "${module.vpc.public_subnet_ids}"
    vpc_id                      = "${module.vpc.vpc_id}"
}

module "ecs" {
    source = "../../ecs"

    region             = "${var.region}"
    name               = "Terraform"
    project            = "${var.project}"
    purpose            = "${var.purpose}"
    creator            = "${var.creator}"
    environment        = "${var.environment}"
    freetext           = "All instances are in the private subnet."
    internal           = "No"
    subnet_ids         = "${module.vpc.private_subnet_ids}"
    vpc_id             = "${module.vpc.vpc_id}"

    ami_regexp                       = "^amzn-ami-.*-amazon-ecs-optimized$"
    instance_type                    = "m4.large"
    ssh_key_name                     = "${module.bastion.ssh_key_name}"
    ebs_optimized                    = "false"
    spot_price                       = "0.1000"
    cluster_min_size                 = "1"
    cluster_desired_size             = "${length( module.vpc.private_subnet_ids )}"
    cluster_max_size                 = "${length( module.vpc.private_subnet_ids )}"
    cooldown                         = "90"
    health_check_grace_period        = "300"
    ecs_subnet_ids                   = "${module.vpc.private_subnet_ids}"
    scale_down_cron                  = "${var.scale_down_cron}"
    scale_up_cron                    = "${var.scale_up_cron}"
    cluster_scaled_down_min_size     = "0"
    cluster_scaled_down_desired_size = "0"
    cluster_scaled_down_max_size     = "0"
    bastion_security_group_id        = "${module.bastion.security_group_id}"
}

resource "aws_cloudwatch_log_group" "log_group" {
    name = "${var.log_group}"
    retention_in_days = 7
    tags {
        Name        = "Terraform"
        Project     = "${var.project}"
        Purpose     = "${var.purpose}"
        Creator     = "${var.creator}"
        Environment = "${var.environment}"
        Freetext    = "No notes."
    }
}

data "template_file" "task_definition" {
    template = "${file("${path.root}/../../ecs-service/debug/files/task-definition.json.template")}"
    vars {
        region = "${var.region}"
        log_group = "${var.log_group}"
    }
}

resource "aws_ecs_task_definition" "definition" {
    family                = "spring-cloud-echo"
    container_definitions = "${data.template_file.task_definition.rendered}"
    network_mode          = "bridge"
}

module "ecs_service" {

    source = "../../ecs-service"

    region                         = "${var.region}"
    name                           = "Terraform"
    project                        = "${var.project}"
    purpose                        = "${var.purpose}"
    creator                        = "${var.creator}"
    environment                    = "${var.environment}"
    freetext                       = "Using insecure communications"

    enable_stickiness              = "Yes"
    health_check_interval          = "15"
    health_check_path              = "/alpha/operations/health"
    health_check_timeout           = "5"
    health_check_healthy_threshold = "5"
    unhealthy_threshold            = "2"
    matcher                        = "200-299"

    path_pattern                   = "/alpha*"
    rule_priority                  = "1"
    vpc_id                         = "${module.vpc.vpc_id}"
    insecure_listener_arn          = "${module.ecs.insecure_listener_arn}"

    task_definition_arn                = "${aws_ecs_task_definition.definition.arn}"
    desired_count                      = "3"
    cluster_arn                        = "${module.ecs.cluster_arn}"
    deployment_maximum_percent         = "200"
    deployment_minimum_healthy_percent = "50"
    container_name                     = "spring-cloud-echo"
    container_port                     = "8080"
    container_protocol                 = "HTTP"
    iam_role                           = "${module.ecs.role_id}"

    placement_strategies = [
        {
            "type"  = "spread"
            "field" = "attribute:ecs.availability-zone"
        },
        {
            "type"  = "binpack"
            "field" = "memory"
        }
    ]
    placement_constraints    = [
        {
            "type" = "distinctInstance"
        },
        {
            "type"       = "memberOf"
            "expression" = "attribute:ecs.instance-type =~ m4.*"
        }
    ]

}
