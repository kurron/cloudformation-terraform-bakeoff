#!/bin/bash

# destroys a stack in AWS via CloudFromation

STACKNAME=${1:-Bake-Off}

DESTROY="aws cloudformation delete-stack --stack-name $STACKNAME"
echo $DESTROY
$DESTROY
