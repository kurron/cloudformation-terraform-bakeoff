#!/bin/bash

# destroys a stack in AWS via CloudFromation

STACKNAME=${1:-Bastion}

DESTROY="aws cloudformation delete-stack --stack-name $STACKNAME"
echo $DESTROY
$DESTROY
