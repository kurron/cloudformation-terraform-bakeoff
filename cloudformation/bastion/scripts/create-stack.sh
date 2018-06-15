#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-Bastion}
PROJECTNAME=${2:-BakeOff}
ENVIRONMENT=${3:-development}
CREATOR=${4:-CloudFormation}
CIDR=${5:-98.216.147.13/32}
VPC=${6:-vpc-7c194414}
SUBNETS=${7:-subnet-755d1e1d,subnet-7efd4504,subnet-3dd43771}
TEMPLATELOCATION=${8:-file://$(pwd)/bastion.yml}

VALIDATE="aws cloudformation validate-template --template-body $TEMPLATELOCATION"
echo $VALIDATE
$VALIDATE

CREATE="aws cloudformation create-stack --stack-name $STACKNAME \
                                        --disable-rollback \
                                        --template-body $TEMPLATELOCATION \
                                        --capabilities CAPABILITY_NAMED_IAM \
                                        --parameters ParameterKey=Project,ParameterValue=$PROJECTNAME \
                                                     ParameterKey=Environment,ParameterValue=$ENVIRONMENT \
                                                     ParameterKey=Creator,ParameterValue=$CREATOR \
                                                     ParameterKey=SshCidr,ParameterValue=$CIDR \
                                                     ParameterKey=VPC,ParameterValue=$VPC \
                                                     ParameterKey=PublicSubnets,ParameterValue=\"$SUBNETS\" \
                                        --tags Key=Project,Value=$PROJECTNAME \
                                               Key=Environment,Value=$ENVIRONMENT \
                                               Key=Creator,Value=$CREATOR"
echo $CREATE
$CREATE
