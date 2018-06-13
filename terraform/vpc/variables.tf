variable "region" {
    type = "string"
    description = "The AWS region to deploy into, e.g. us-east-1"
}

variable "name" {
    type = "string"
    description = "Name of the VPC"
}

variable "project" {
    type = "string"
    description = "Name of the project these resources are being created for, e.g. violet-sloth"
}

variable "purpose" {
    type = "string"
    description = "Role or reason for the existence of these resources, e.g. network for performance testing"
}

variable "creator" {
    type = "string"
    description = "Person creating these resources, e.g. operations@example.com"
}

variable "environment" {
    type = "string"
    description = "Context these resources will be used in, e.g. production"
}

variable "freetext" {
    type = "string"
    description = "Information that does not fit in the other tags, e.g. request in for more EIPs"
}

variable "cidr_range" {
    type = "string"
    description = "IP range of the network to create, e.g. 10.0.0.0/16"
}

variable "public_subnets" {
    description = "List of IP ranges for the public subnets, e.g. [10.0.2.0/24, 10.0.4.0/24]"
    type        = "list"
}

variable "private_subnets" {
    description = "List of IP ranges for the private subnets, e.g. [10.0.1.0/24, 10.0.3.0/24]"
    type        = "list"
}

variable "populate_all_zones" {
    description = "If true, all availability zones will be assigned a public and private subnet, otherwise limit creation to the subnet lists"
    type        = "string"
}
