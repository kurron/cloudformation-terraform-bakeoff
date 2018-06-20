# Overview
This project is a [CloudFormation](https://aws.amazon.com/cloudformation/) template
that creates a new [ECS](https://aws.amazon.com/ecs/) cluster into an existing
VPC.  Four EC2 instances are added to the cluster.  Two instances in each availability
zone.

## Assets Produced
1. ECS Cluster
1. EC2 instance in the public subnet 10.0.10.0/24
1. EC2 instance in the private subnet 10.0.20.0/24
1. EC2 instance in the public subnet 10.0.30.0/24
1. EC2 instance in the private subnet 10.0.40.0/24

## Tagging Strategy
The following tags are applied to assets that allow tagging:
* Project - useful for generating cost reports, defaults to `Weapon-X`
* Purpose - what role the asset plays in the VPC, eg `ECS Agent`
* Creator - the entity creating the assets, defaults to `CloudFormation`
* Environment - the context the assets are a part of, defaults to `development`
* Freetext - place holder for asset-specific notes, meant to be adjusted in the console if needed

# Prerequisites
* a working [AW CLI](https://aws.amazon.com/cli/)
* you have run `aws configure`, providing the required information
* a working VPC [based on this template]https://github.com/kurron/cloud-formation-vpc)

# Building
There is noting to build.

# Installation
There is nothing to install.

# Tips and Tricks

## Creating an ECS Cluster
There is a convenience Bash script that can be run to create a new cluster.  If
you just want to test things out run `scripts/create-stack.sh`.  In several
moments, your cluster should be created.  Check your AWS console for confirmation.

If you want to specify certain aspects of the VPC, try running something like this:
`scripts/create-stack.sh production-cluster Phoenix production you@somewhere.com`.
This form provides the following:
* stack name of `production-cluster`
* project name of `Phoenix`
* environment name of `production`
* creator of `you@somewhere.com`


## Destroying an ECS Cluster
There is a convenience script for destroying clusters.  Run
`scripts/destroy-stack.sh production-cluster` to destroy the cluster we created above.

## Creation Via The Console
TODO: need to talk about getting the `ecs.yml` file into S3 so that the console can see it

# Troubleshooting
TODO

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).
