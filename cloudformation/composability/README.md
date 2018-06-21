# Overview
See the master README for details.

# Tips and Tricks

IMPORTANT: before you can create the stack, you need to edit and run `../copy-files-to-s3.sh` otherwise there won't be any files for the master stack to run.  You also need to edit `full-stack.yml` so that the URLs resolve to the bucket defined in `../copy-files-to-s3.sh`.

## Creating The Stack
Edit `scripts/create-stack.sh` as necessary, pasting in any values from previous modules that may be required.  Run `scripts/create-stack.sh` and watch progress in the CloudFormation console.

## Validating The Stack
Run `scripts/validate-stack.sh` to validate any changes to the stack file you may have made.

## Destroying The Stack
Run `scripts/destroy-stack.sh` to destroy any created resources.
