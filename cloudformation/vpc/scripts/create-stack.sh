#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-BakeOff}
NAME=${2:-CloudFormation}
PROJECTNAME=${3:-BakeOff}
NETWORK=${4:-10.0.0.0}
ENVIRONMENT=${5:-development}
CREATOR=${6:-rkurr@jvmguy.com}
TEMPLATELOCATION=${7:-file://$(pwd)/vpc.yml}

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
                                                     ParameterKey=Network,ParameterValue=$NETWORK \
                                                     ParameterKey=Name,ParameterValue=$NAME \
                                        --tags Key=Project,Value=$PROJECTNAME \
                                               Key=Environment,Value=$ENVIRONMENT \
                                               Key=Creator,Value=$CREATOR"
echo $CREATE
$CREATE
