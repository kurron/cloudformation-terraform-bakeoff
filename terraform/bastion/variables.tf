variable "region" {
    type = "string"
    description = "The AWS region to deploy into (e.g. us-east-1)"
}

variable "project" {
    type = "string"
    description = "Name of the project these resources are being created for"
}

variable "creator" {
    type = "string"
    description = "Person creating these resources"
}

variable "environment" {
    type = "string"
    description = "Context these resources will be used in, e.g. production"
}

variable "freetext" {
    type = "string"
    description = "Information that does not fit in the other tags"
}

variable "instance_type" {
    type = "string"
    description = "Instance type to make the Bastion host from"
}

variable "ssh_key_name" {
    type = "string"
    description = "Name of the SSH key pair to use when logging into the bastion host"
}

variable "max_size" {
    type = "string"
    description = "Maximum number of bastion instances that can be run simultaneously"
}

variable "min_size" {
    type = "string"
    description = "Minimum number of bastion instances that can be run simultaneously"
}

variable "cooldown" {
    type = "string"
    description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start."
}

variable "health_check_grace_period" {
    type = "string"
    description = "Time, in seconds, after instance comes into service before checking health."
}

variable "desired_capacity" {
    type = "string"
    description = "The number of bastion instances that should be running in the group."
}

variable "scale_down_desired_capacity" {
    type = "string"
    description = "The number of bastion instances that should be running when scaling down."
}

variable "scale_down_min_size" {
    type = "string"
    description = "Minimum number of bastion instances that can be running when scaling down"
}

variable "scale_up_cron" {
    type = "string"
    description = "In UTC, when to scale up the bastion servers"
}

variable "scale_down_cron" {
    type = "string"
    description = "In UTC, when to scale down the bastion servers"
}

variable "public_ssh_key" {
    type = "string"
    description = "Public half of the SSH key to import into AWS"
}

variable "security_group_ids" {
    type = "list"
    description = "List of security groups to apply to the instances"
}

variable "subnet_ids" {
    type = "list"
    description = "List of subnets to create the instances in"
}
