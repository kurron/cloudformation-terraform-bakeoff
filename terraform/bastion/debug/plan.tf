terraform {
    required_version = ">= 0.10.6"
    backend "s3" {}
}

data "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "transparent-test-terraform-state"
        key    = "us-west-2/debug/networking/vpc/terraform.tfstate"
        region = "us-east-1"
    }
}

data "terraform_remote_state" "security-groups" {
    backend = "s3"
    config {
        bucket = "transparent-test-terraform-state"
        key    = "us-west-2/debug/networking/security-groups/terraform.tfstate"
        region = "us-east-1"
    }
}

module "bastion" {
    source = "../"

    region = "us-west-2"

    project     = "Debug"
    creator     = "kurron@jvmguy.com"
    environment = "development"
    freetext    = "No notes at this time."
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
    public_ssh_key              = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCv70t6ne08BNDf3aAQOdhe7h1NssBGPEucjKA/gL9vXpclGBqZnvOiQltKrOeOLzcbDJYDMYIJCwtoq7R/3RLOLDSi5OChhFtyjGULkIxa2dJgKXWPz04E1260CMqkKcgrQ1AaYA122zepakE7d+ysMoKSbQSVGaleZ6aFxe8DfKMzAFFra44tF5JUSMpuqwwI/bKEyehX/PDMNe/GWUTk+5c4XC6269NbaeWMivH2CiYPPBXblj6IT+QhBY5bTEFT57GmUff1sJOyhGN+9kMhlsSrXtp1A5wGiZ8nhoUduphzP3h0RNbRVA4mmI4jMnOF51uKbOvNk3Y79FSIS9Td Access to Bastion box"

    security_group_ids = ["${data.terraform_remote_state.security-groups.bastion_id}"]
    subnet_ids         = "${data.terraform_remote_state.vpc.public_subnet_ids}"
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
