#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-ECS}
PROJECTNAME=${2:-Bake-Off}
VPC=${3:-vpc-456b352d}
PUBLIC_SUBNETS=${4:-subnet-aa064ac2,subnet-8b5be1f1,subnet-2941ac65}
PRIVATE_SUBNETS=${5:-subnet-9b0a46f3,subnet-e266dc98,subnet-bb40adf7}
VISIBILITY=${6:-internet-facing}
ENVIRONMENT=${7:-development}
CREATOR=${8:-CloudFormation}
BASTION_SECURITY_GROUP=${9:-sg-3776ea5d}
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
                                                     ParameterKey=ECSAMI,ParameterValue=ami-956e52f0 \
                                        --tags Key=Project,Value=$PROJECTNAME \
                                               Key=Environment,Value=$ENVIRONMENT \
                                               Key=Creator,Value=$CREATOR"
echo $CREATE
$CREATE
