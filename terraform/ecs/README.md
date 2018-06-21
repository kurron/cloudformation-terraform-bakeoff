# Overview
See the master README for details.

# Tips and Tricks

## Creating The Stack
Edit `debug/backend.cfg` to point to an S3 bucket you have previously created to hold Terraform's state.  Run `debug/debug-module.sh` to execute the necessary Terraform commands to import modules and create resources.  If this module's resources are needed in a subsequent module, answer `NO` to the deletion question.

## Destroying The Stack
Run `debug/debug-module.sh` a second time and answer `YES` to the deletion question.
