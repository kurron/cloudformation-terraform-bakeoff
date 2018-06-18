terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

provider "aws" {
    region     = "${var.region}"
}

data "terraform_remote_state" "ecs_cluster" {
    backend = "s3"
    config {
        bucket = "bake-off-terraform-state"
        key    = "us-east-2/debug/compute/ecs/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "bake-off-terraform-state"
        key    = "us-east-2/debug/networking/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

variable "region" {
    type = "string"
    default = "us-east-2"
}

variable "log_group" {
    type = "string"
    default = "bakeoff"
}

resource "aws_cloudwatch_log_group" "log_group" {
    name = "${var.log_group}"
    retention_in_days = 7
    tags {
        Name        = "Terraform"
        Project     = "Bake Off"
        Purpose     = "Terraform vs CloudFormation comparison"
        Creator     = "rkurr@jvmguy.com"
        Environment = "development"
        Freetext    = "No notes."
    }
}

data "template_file" "task_definition" {
    template = "${file("${path.module}/files/task-definition.json.template")}"
    vars {
        region = "${var.region}"
        log_group = "${var.log_group}"
    }
}

resource "aws_ecs_task_definition" "definition" {
    family                = "Nginx"
    container_definitions = "${data.template_file.task_definition.rendered}"
    network_mode          = "bridge"
}

module "ecs_service" {
    source = "../"

    region                         = "${var.region}"
    name                           = "Terraform"
    project                        = "Bake Off"
    purpose                        = "Terraform vs CloudFormation comparison"
    creator                        = "rkurr@jvmguy.com"
    environment                    = "development"
    freetext                       = "Using insecure communications"

    enable_stickiness              = "Yes"
    health_check_interval          = "15"
    health_check_path              = "/"
    health_check_timeout           = "5"
    health_check_healthy_threshold = "5"
    unhealthy_threshold            = "2"
    matcher                        = "200-299"

    path_pattern                   = "/alpha*"
    rule_priority                  = "1"
    vpc_id                         = "${data.terraform_remote_state.vpc.vpc_id}"
    insecure_listener_arn          = "${data.terraform_remote_state.ecs_cluster.insecure_listener_arn}"

    task_definition_arn                = "${aws_ecs_task_definition.definition.arn}"
    desired_count                      = "2"
    cluster_arn                        = "${data.terraform_remote_state.ecs_cluster.cluster_arn}"
    deployment_maximum_percent         = "200"
    deployment_minimum_healthy_percent = "50"
    container_name                     = "Nginx"
    container_port                     = "80"
    container_protocol                 = "HTTP"
    iam_role                           = "${data.terraform_remote_state.ecs_cluster.role_id}"

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
