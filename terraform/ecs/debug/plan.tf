terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

variable "region" {
    type = "string"
    default = "us-east-1"
}

provider "aws" {
    region = "${var.region}"
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "bake-off-terraform-state"
        key    = "us-east-2/debug/networking/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

module "alb" {
    source = "../"

    region             = "us-east-2"
    name               = "Terraform"
    project            = "Bake Off"
    purpose            = "Terraform vs CloudFormation comparison"
    creator            = "rkurr@jvmguy.com"
    environment        = "development"
    freetext           = "No notes."
    internal           = "No"
    subnet_ids         = "${data.terraform_remote_state.vpc.public_subnet_ids}"
    vpc_id             = "${data.terraform_remote_state.vpc.vpc_id}"
}

output "alb_id" {
    value = "${module.alb.alb_id}"
}

output "alb_arn" {
    value = "${module.alb.alb_arn}"
}

output "alb_arn_suffix" {
    value = "${module.alb.alb_arn_suffix}"
}

output "alb_dns_name" {
    value = "${module.alb.alb_dns_name}"
}

output "alb_zone_id" {
    value = "${module.alb.alb_zone_id}"
}

output "insecure_listener_arn" {
    value = "${module.alb.insecure_listener_arn}"
}

output "security_group_id" {
    value = "${module.alb.security_group_id}"
}

output "security_group_name" {
    value = "${module.alb.security_group_name}"
}
