# Overview
TODO

## Assets Produced
1. TODO

## Tagging Strategy
The following tags are applied to assets that allow tagging:
* Project - useful for generating cost reports, defaults to `Weapon-X`
* Purpose - what role the asset plays in the VPC, eg `Bastion Server`
* Creator - the entity creating the assets, defaults to `CloudFormation`
* Environment - the context the assets are a part of, defaults to `development`
* Freetext - place holder for asset-specific notes, meant to be adjusted in the console if needed

# Prerequisites
* a working [AW CLI](https://aws.amazon.com/cli/)
* you have run `aws configure`, providing the required information

# Building
There is noting to build.

# Installation
There is nothing to install.

# Tips and Tricks

## Creating The Stack
There is a convenience Bash script that can be run to create a new VPC.  If
you just want to test things out run `scripts/create-stack.sh`.  In several
moments, your VPC should be created.  Check your AWS console for confirmation.

TODO:
If you want to specify certain aspects of the Bastion, try running something like this:
`scripts/create-stack.sh production-vpc Phoenix production you@somewhere.com`.
This form provides the following:
* stack name of `production-vpc`
* project name of `Phoenix`
* environment name of `production`
* creator of `you@somewhere.com`


## Destroying The Stack
There is a convenience script for destroying VPCs.  run
`scripts/destroy-stack.sh production-vpc` to destroy the VPC we created above.

## Creation Via The Console
TODO: need to talk about getting the `bastion.yml` file into S3 so that the console can see it

# Troubleshooting

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).
