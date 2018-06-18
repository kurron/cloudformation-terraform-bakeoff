variable "region" {
    type = "string"
    description = "The AWS region to deploy into (e.g. us-east-1)"
}

variable "name" {
    type = "string"
    description = "What to name the service being created, e.g. MongoDB"
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

variable "task_definition_arn" {
    type = "string"
    description = "Full ARN of the task definition that you want to run in your service"
}

variable "desired_count" {
    type = "string"
    description = "The number of instances of the task definition to place and keep running, e.g. 2"
}

variable "cluster_arn" {
    type = "string"
    description = "ARN of an ECS cluster to deploy to."
}

variable "iam_role" {
    type = "string"
    description = "The ARN of IAM role that allows your Amazon ECS container agent to make calls to your load balancer on your behalf."
}

variable "deployment_maximum_percent" {
    type = "string"
    description = "The upper limit (as a percentage of the service's desired_count) of the number of running tasks that can be running in a service during a deployment, e.g. 200"
}

variable "deployment_minimum_healthy_percent" {
    type = "string"
    description = " The lower limit (as a percentage of the service's desired_count) of the number of running tasks that must remain running and healthy in a service during a deployment, e.g. 50"
}

variable "container_name" {
    type = "string"
    description = "The name of the container to associate with the load balancer (as it appears in a container definition)."
}

variable "container_port" {
    type = "string"
    description = "The port on the container to associate with the load balancer, e.g. 80"
}

variable "container_protocol" {
    type = "string"
    description = " The protocol to use for routing traffic to the container, e.g. HTTP"
}

variable "vpc_id" {
    type = "string"
    description = " The identifier of the VPC in which to create the target group."
}

variable "enable_stickiness" {
    type = "string"
    description = "If set to Yes, the balancer will attempt to route clients to a consistent back end."
}

variable "health_check_interval" {
    type = "string"
    description = "The approximate amount of time, in seconds, between health checks of an individual target."
}

variable "health_check_path" {
    type = "string"
    description = "The destination for the health check request."
}

variable "health_check_timeout" {
    type = "string"
    description = "The amount of time, in seconds, during which no response means a failed health check."
}

variable "health_check_healthy_threshold" {
    type = "string"
    description = "The number of consecutive health checks successes required before considering an unhealthy target healthy."
}

variable "unhealthy_threshold" {
    type = "string"
    description = "The number of consecutive health check failures required before considering the target unhealthy."
}

variable "matcher" {
    type = "string"
    description = "The HTTP codes to use when checking for a successful response from a target."
}

variable "insecure_listener_arn" {
    type = "string"
    description = "The ARN of the insecure HTTP listener to which to attach the rule."
}

variable "rule_priority" {
    type = "string"
    description = "The priority for the rule. A listener can't have multiple rules with the same priority, e.g. 99"
}

variable "path_pattern" {
    type = "string"
    description = "The path patterns to match, e.g. /my-service*"
}

variable "placement_strategies" {
    type = "list"
    description = "Service level strategy rules that are taken into consideration during task placement."
}

variable "placement_constraints" {
    type = "list"
    description = "Instance level rules that are taken into consideration during task placement."
}
