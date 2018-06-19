#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-ECS-Service}
PROJECTNAME=${2:-Bake-Off}
VPC=${3:-vpc-7fc69a17}
CLUSTER=${4:-ECS}
ELB=${5:-arn:aws:elasticloadbalancing:us-east-2:387188308760:listener/app/ECS-LoadBal-DH5R3V5J9J9W/202522ee252280e8/d6187cf1ae640bb5}
ENVIRONMENT=${6:-development}
CREATOR=${7:-CloudFormation}
LOG_GROUP=${8:-BakeOff}
TEMPLATELOCATION=${9:-file://$(pwd)/service.yml}

VALIDATE="aws cloudformation validate-template --template-body $TEMPLATELOCATION"
echo $VALIDATE
$VALIDATE

CREATE="aws cloudformation create-stack --stack-name $STACKNAME \
                                        --template-body $TEMPLATELOCATION \
                                        --capabilities CAPABILITY_NAMED_IAM \
                                        --parameters ParameterKey=Project,ParameterValue=$PROJECTNAME \
                                                     ParameterKey=Environment,ParameterValue=$ENVIRONMENT \
                                                     ParameterKey=Creator,ParameterValue=$CREATOR \
                                                     ParameterKey=VPC,ParameterValue=$VPC \
                                                     ParameterKey=Cluster,ParameterValue=$CLUSTER \
                                                     ParameterKey=Listener,ParameterValue=$ELB \
                                                     ParameterKey=LogGroup,ParameterValue=$LOG_GROUP \
                                        --tags Key=Project,Value=$PROJECTNAME \
                                               Key=Environment,Value=$ENVIRONMENT \
                                               Key=Creator,Value=$CREATOR"
echo $CREATE
$CREATE
