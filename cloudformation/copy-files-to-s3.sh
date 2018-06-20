#!/usr/bin/env bash

BUCKET_NAME=${1:-com-jvmguy-cloudformation-templates}
REGION=${2:-us-east-2}

CREATE="aws s3 mb s3://${BUCKET_NAME} --region ${REGION}"
echo ${CREATE}
${CREATE}

COPY="aws s3 sync . s3://${BUCKET_NAME} --content-type application/yml --acl private --storage-class ONEZONE_IA"
echo ${COPY}
${COPY}
