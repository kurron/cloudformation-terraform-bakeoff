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
