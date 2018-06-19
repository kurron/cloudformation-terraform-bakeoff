#!/bin/bash

# Validates a CloudFromation stack

TEMPLATELOCATION=${1:-file://$(pwd)/service.yml}

VALIDATE="aws cloudformation validate-template --template-body $TEMPLATELOCATION"
echo $VALIDATE
$VALIDATE
