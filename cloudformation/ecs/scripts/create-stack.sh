#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-ECS}
PROJECTNAME=${2:-Bake-Off}
VPC=${3:-vpc-7c194414}
PUBLIC_SUBNETS=${4:-subnet-755d1e1d,subnet-7efd4504,subnet-3dd43771}
PRIVATE_SUBNETS=${5:-subnet-765d1e1e,subnet-28f94152,subnet-e5d536a9}
VISIBILITY=${6:-internet-facing}
ENVIRONMENT=${7:-development}
CREATOR=${8:-CloudFormation}
BASTION_SECURITY_GROUP=${9:-sg-ef7df285}
TEMPLATELOCATION=${10:-file://$(pwd)/ecs.yml}

VALIDATE="aws cloudformation validate-template --template-body $TEMPLATELOCATION"
echo $VALIDATE
$VALIDATE

CREATE="aws cloudformation create-stack --stack-name $STACKNAME \
                                        --template-body $TEMPLATELOCATION \
                                        --capabilities CAPABILITY_NAMED_IAM \
                                        --parameters ParameterKey=Project,ParameterValue=$PROJECTNAME \
                                                     ParameterKey=Environment,ParameterValue=$ENVIRONMENT \
                                                     ParameterKey=Creator,ParameterValue=$CREATOR \
                                                     ParameterKey=AlbSubnets,ParameterValue=\"$PUBLIC_SUBNETS\" \
                                                     ParameterKey=Ec2Subnets,ParameterValue=\"$PRIVATE_SUBNETS\" \
                                                     ParameterKey=LoadBalancerType,ParameterValue=$VISIBILITY \
                                                     ParameterKey=VPC,ParameterValue=$VPC \
                                                     ParameterKey=BastionSecurityGroup,ParameterValue=$BASTION_SECURITY_GROUP \
                                        --tags Key=Project,Value=$PROJECTNAME \
                                               Key=Environment,Value=$ENVIRONMENT \
                                               Key=Creator,Value=$CREATOR"
echo $CREATE
$CREATE
