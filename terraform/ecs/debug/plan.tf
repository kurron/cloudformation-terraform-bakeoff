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

data "terraform_remote_state" "bastion" {
    backend = "s3"
    config {
        bucket = "bake-off-terraform-state"
        key    = "us-west-2/debug/compute/bastion/terraform.tfstate"
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

    ami_regexp                       = "^amzn-ami-.*-amazon-ecs-optimized$"
    instance_type                    = "m4.large"
    ssh_key_name                     = "${data.terraform_remote_state.bastion.ssh_key_name}"
    ebs_optimized                    = "false"
    spot_price                       = "0.1000"
    cluster_min_size                 = "1"
    cluster_desired_size             = "${length( data.terraform_remote_state.vpc.private_subnet_ids )}"
    cluster_max_size                 = "${length( data.terraform_remote_state.vpc.private_subnet_ids )}"
    cooldown                         = "90"
    health_check_grace_period        = "300"
    ecs_subnet_ids                   = "${data.terraform_remote_state.vpc.private_subnet_ids}"
    scale_down_cron                  = "0 0 * * SUN-SAT"
    scale_up_cron                    = "0 7 * * MON-FRI"
    cluster_scaled_down_min_size     = "0"
    cluster_scaled_down_desired_size = "0"
    cluster_scaled_down_max_size     = "0"
    bastion_security_group_id        = "${data.terraform_remote_state.bastion.security_group_id}"
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
