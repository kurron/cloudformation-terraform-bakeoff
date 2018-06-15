#!/bin/bash

# destroys a stack in AWS via CloudFromation

STACKNAME=${1:-ECS}

DESTROY="aws cloudformation delete-stack --stack-name $STACKNAME"
echo $DESTROY
$DESTROY
