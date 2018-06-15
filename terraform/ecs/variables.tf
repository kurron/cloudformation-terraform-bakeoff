variable "region" {
    type = "string"
    description = "The AWS region to deploy into (e.g. us-east-1)"
}

variable "name" {
    type = "string"
    description = "What to name the resources being created"
}

variable "project" {
    type = "string"
    description = "Name of the project these resources are being created for"
}

variable "purpose" {
    type = "string"
    description = "The role the resources will play"
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

variable "internal" {
    type = "string"
    description = "If set to Yes, the load balancer can only be seen from inside the VPC, otherwise it is publicly available."
}

variable "subnet_ids" {
    type = "list"
    description = "List of subnet IDs the balancer can access"
}

variable "vpc_id" {
    type = "string"
    description = "The identifier of the VPC in which to create the target group."
}

variable "instance_type" {
    type = "string"
    description = "They instance type to build the instances from"
}

variable "ssh_key_name" {
    type = "string"
    description = "Name of the SSH key to install onto the instances"
}

variable "ebs_optimized" {
    type = "string"
    description = "Boolean indicating if the instance should enable EBS optimization or not"
}

variable "spot_price" {
    type = "string"
    description = "How much, per hour, you are willing to pay for the instances, e.g. 0.015"
}

variable "cluster_min_size" {
    type = "string"
    description = "Minimum number of instances to maintain in the cluster, e.g. 2"
}

variable "cluster_max_size" {
    type = "string"
    description = "Maximum number of instances to maintain in the cluster, e.g. 8"
}

variable "cluster_desired_size" {
    type = "string"
    description = "Desired number of instances to maintain in the cluster, e.g. 4"
}

variable "cooldown" {
    type = "string"
    description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start, e.g. 30"
}

variable "health_check_grace_period" {
    type = "string"
    description = "Time (in seconds) after instance comes into service before checking health, e.g. 300"
}

variable "ecs_subnet_ids" {
    type = "list"
    description = "List of subnets to create the instances in, e.g. [subnet-4a33b402,subnet-ac5f72f7]"
}

variable "scale_up_cron" {
    type = "string"
    description = "Cron expression detailing when to increase cluster capacity, e.g. 0 7 * * MON-FRI"
}

variable "scale_down_cron" {
    type = "string"
    description = "Cron expression detailing when to decrease cluster capacity, e.g. 0 0 * * SUN-SAT"
}

variable "cluster_scaled_down_desired_size" {
    type = "string"
    description = "Minimum number of instances to maintain in the cluster when scaled down, e.g. 2"
}

variable "cluster_scaled_down_min_size" {
    type = "string"
    description = "Desired number of instances to maintain in the cluster when scaled down, e.g. 4"
}

variable "cluster_scaled_down_max_size" {
    type = "string"
    description = "Maximum number of instances to maintain in the cluster when scaled down, e.g. 8"
}

variable "ami_regexp" {
    type = "string"
    description = "Regular expression to use when looking up an AMI in the specified region"
}

variable "bastion_security_group_id" {
    type = "string"
    description = "ID of the Bastion security group"
}
