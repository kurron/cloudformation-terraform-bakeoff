#!/bin/bash

# creates a stack in AWS via CloudFromation

STACKNAME=${1:-Bake-Off}
PROJECTNAME=${2:-Bake-Off}
ENVIRONMENT=${3:-development}
CREATOR=${4:-CloudFormation}
TEMPLATELOCATION=${9:-file://$(pwd)/full-stack.yml}

VALIDATE="aws cloudformation validate-template --template-body $TEMPLATELOCATION"
echo $VALIDATE
$VALIDATE

CREATE="aws cloudformation create-stack --stack-name $STACKNAME \
                                        --disable-rollback \
                                        --template-body $TEMPLATELOCATION \
                                        --capabilities CAPABILITY_NAMED_IAM"
echo $CREATE
$CREATE
