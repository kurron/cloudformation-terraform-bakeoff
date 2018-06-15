terraform {
    required_version = ">= 0.11.7"
    backend "s3" {}
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "bake-off-terraform-state"
        region = "us-east-1"
        key    = "us-east-2/debug/networking/vpc/terraform.tfstate"
    }
}

module "bastion" {
    source = "../"

    region                      = "us-east-2"
    project                     = "Bake Off"
    creator                     = "rkurr@jvmguy.com"
    environment                 = "development"
    freetext                    = "No notes at this time."
    instance_type               = "t2.nano"
    ssh_key_name                = "Bastion"
    min_size                    = "1"
    max_size                    = "2"
    cooldown                    = "60"
    health_check_grace_period   = "300"
    desired_capacity            = "1"
    scale_down_desired_capacity = "0"
    scale_down_min_size         = "0"
    scale_up_cron               = "0 7 * * MON-FRI"
    scale_down_cron             = "0 0 * * SUN-SAT"
    public_ssh_key              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDfYQ0mYkeux8yK8w/Wb3LnYDHVB9mwCaaN/UXnD/1gN4Ka7ArcMCHHzo4JUnHl6AM2vzZbbt+sgETZoYgpMGZIh+6wwnxOSdRen/b4aKer0ni8yW38r/DnhXa4FGBiwhgMBCs43e7TDnwSwJBUNpBbcD99XnYzvtsbOV0tHYUh11VoqAi4xqha3+L4G00tpQFk/WU+YZicrPjjMhtd14fnlmaMaxI3On5We3b/OXkSuqTnBjE074dmyORy0V6Lp6+814Cnme4OHR/15fRHp6JfZc1dGKgJdyM1csrxWzuJmPkdPnfwFIR+xbx6jIps/uojCV+ADe5TS+3OrJVIbtaB rkurr@jvmguy.com"
    bastion_ingress_cidr_blocks = ["50.235.141.198/32","98.216.147.13/32"]
    subnet_ids                  = "${data.terraform_remote_state.vpc.public_subnet_ids}"
    vpc_id                      = "${data.terraform_remote_state.vpc.vpc_id}"
}

output "ami_id" {
    value = "${module.bastion.ami_id}"
}

output "launch_configuration_id" {
    value = "${module.bastion.launch_configuration_id}"
}

output "launch_configuration_name" {
    value = "${module.bastion.launch_configuration_name}"
}

output "auto_scaling_group_id" {
    value = "${module.bastion.auto_scaling_group_id}"
}

output "auto_scaling_group_name" {
    value = "${module.bastion.auto_scaling_group_name}"
}

output "ssh_key_name" {
    value = "${module.bastion.ssh_key_name}"
}

output "security_group_id" {
    value = "${module.bastion.security_group_id}"
}
