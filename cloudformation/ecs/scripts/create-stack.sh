#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-ECS}
PROJECTNAME=${2:-Bake-Off}
VPC=${3:-vpc-7fc69a17}
PUBLIC_SUBNETS=${4:-subnet-28b9fb40,subnet-70a3180a,subnet-d716f49b}
PRIVATE_SUBNETS=${5:-subnet-65b4f60d,subnet-73a31809,subnet-ea13f1a6}
VISIBILITY=${6:-internet-facing}
ENVIRONMENT=${7:-development}
CREATOR=${8:-CloudFormation}
BASTION_SECURITY_GROUP=${9:-sg-df67f1b5}
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
