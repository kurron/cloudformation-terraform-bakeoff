output "ami_id" {
    value = "${data.aws_ami.amazon_linux_ami.id}"
    description = "ID of the selected AMI"
}

output "launch_configuration_id" {
    value = "${aws_launch_configuration.bastion.id}"
    description = "ID of the Bastion's launch configuration"
}

output "launch_configuration_name" {
    value = "${aws_launch_configuration.bastion.name}"
    description = "Name of the Bastion's launch configuration"
}

output "auto_scaling_group_id" {
    value = "${aws_autoscaling_group.bastion.id}"
    description = "ID of the Bastion's auto scaling group"
}

output "auto_scaling_group_name" {
    value = "${aws_autoscaling_group.bastion.name}"
    description = "Name of the Bastion's auto scaling group"
}

output "ssh_key_name" {
    value = "${aws_key_pair.bastion.key_name}"
    description = "Name of the Bastion's SSH key"
}

output "security_group_id" {
    value = "${aws_security_group.bastion_access.id}"
    description = "ID of the security group controlling network access to the Bastion instances."
}
