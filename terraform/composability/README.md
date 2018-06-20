# Overview
This Terraform module is an opinionated view on how to build a VPC.  It places
both a public and private subnet in all availability zones.  This is for both
fault tolerance as well as to draw on a larger market for Spot intances.

# Prerequisites
* [Terraform](https://terraform.io/) installed and working
* Development and testing was done on [Ubuntu Linux](http://www.ubuntu.com/)

# Building
Since this is just a collection of Terraform scripts, there is nothing to build.

# Installation
This module is not installed but, instead, is obtained by the project using
the module.  See [kurron/terraform-environments](https://github.com/kurron/terraform-environments)
for example usage.

# Tips and Tricks

## Debugging
The `debug` folder contains files that can be used to test out local changes
to the module.  Edit `backend.cfg` and `plan.tf` to your liking and
then run `debug/debug-module.sh` to test your changes.

## Subnet Ranges
The module automatically detects the number of availability zones in the region
and installs both public and a private subnet in each zone.  When specifying
`public_subnets` and `private_subnets` make sure to provide enough choices to
match the number of availability zones in the region.  If the list is short, Terraform
will attempt to reuse an entry in the list and the subnet construction will
fail. This behavior can be disabled by setting the `populate_all_zones` property
to `false`.  In this scenario, all provided subnets will be created, regardless
of the number of availability zones in the region.

## Private Subnets
If you do not want to create private subnets, set the `private_subnets` property
to an empty list.

# Troubleshooting

# License and Credits
This project is licensed under the [Apache License Version 2.0, January 2004](http://www.apache.org/licenses/).

# List of Changes
