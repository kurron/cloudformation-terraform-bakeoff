# Overview
See the master README for details.

# Tips and Tricks

## Creating The Stack
Edit `scripts/create-stack.sh` as necessary, pasting in any values from previous modules that may be required.  Run `scripts/create-stack.sh` and watch progress in the CloudFormation console.

*WARNING:* you must create an SSH key pair in the console named `BakeOff`.  Terraform lets you create a key on the fly but AWS does not.

## Validating The Stack
Run `scripts/validate-stack.sh` to validate any changes to the stack file you may have made.

## Destroying The Stack
Run `scripts/destroy-stack.sh` to destroy any created resources.
