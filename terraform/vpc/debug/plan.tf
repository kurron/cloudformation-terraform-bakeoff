terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

module "vpc" {
    source = "../"

    region             = "us-east-2"
    name               = "Terraform"
    project            = "Bake Off"
    purpose            = "Terraform vs CloudFormation comparison"
    creator            = "rkurr@jvmguy.com"
    environment        = "development"
    freetext           = "One public and private subnet in each AZ."
    cidr_range         = "10.0.0.0/16"
    private_subnets    = ["10.0.1.0/24","10.0.3.0/24","10.0.5.0/24"]
    public_subnets     = ["10.0.2.0/24","10.0.4.0/24","10.0.6.0/24"]
    populate_all_zones = "false"
}

output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "cidr" {
    value = "${module.vpc.cidr}"
}

output "main_route_table_id" {
    value = "${module.vpc.main_route_table_id}"
}

output "default_network_acl_id" {
    value = "${module.vpc.default_network_acl_id}"
}

output "default_security_group_id" {
    value = "${module.vpc.default_security_group_id}"
}

output "default_route_table_id" {
    value = "${module.vpc.default_route_table_id}"
}

output "public_subnet_ids" {
    value = "${module.vpc.public_subnet_ids}"
}

output "private_subnet_ids" {
    value = "${module.vpc.private_subnet_ids}"
}

output "availability_zones" {
    value = "${module.vpc.availability_zones}"
}
