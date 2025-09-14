#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
REST_API_ID="r7subbj2n5"    # <- change if different
STAGE_NAME="ff_test"

if [[ ! -f apigw/apigw-oas30.json ]]; then
  echo "ERROR: apigw/apigw-oas30.json not found. Place your OpenAPI here."; exit 1;
fi

aws apigateway put-rest-api       --region "${REGION}"       --rest-api-id "${REST_API_ID}"       --mode overwrite       --body 'fileb://apigw/apigw-oas30.json'

aws apigateway create-deployment       --region "${REGION}"       --rest-api-id "${REST_API_ID}"       --stage-name "${STAGE_NAME}"

echo "Overwritten API ${REST_API_ID} and deployed to ${STAGE_NAME}"
