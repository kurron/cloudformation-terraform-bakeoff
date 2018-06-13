#!/bin/bash

rm -rf .terraform

INIT="terraform init -backend=true \
                     -backend-config=debug/backend.cfg \
                     -get=true \
                     -get-plugins=true \
                     -input=true \
                     -lock=true \
                     -upgrade=true \
                     -verify-plugins=true \
                     debug"
echo ${INIT}
${INIT}

export TF_LOG=DEBUG
export TF_LOG_PATH=debug/terraform-log.txt
rm -f debug/terraform-log.txt

PLAN="terraform plan -refresh=true \
                     -input=false \
                     -lock=true \
                     -out=debug/proposed-changes.plan \
                     -refresh=true \
                     debug"
echo ${PLAN}
${PLAN}

SHOW="terraform show debug/proposed-changes.plan"
echo ${SHOW}
${SHOW}

APPLY="terraform apply -refresh=true \
                       -lock=true \
                       -auto-approve=true \
                       -input=false \
                       debug/proposed-changes.plan"
echo ${APPLY}
${APPLY}

DESTROY="terraform destroy -refresh=true \
                           -input=false \
                           debug"
echo ${DESTROY}
${DESTROY}
