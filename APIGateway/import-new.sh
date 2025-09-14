#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
STAGE_NAME="ff_test"

if [[ ! -f apigw/apigw-oas30.json ]]; then
  echo "ERROR: apigw/apigw-oas30.json not found. Place your OpenAPI here."; exit 1;
fi

API_ID=$(aws apigateway import-rest-api       --region "${REGION}"       --body 'fileb://apigw/apigw-oas30.json'       --query id --output text)

echo "Created API: ${API_ID}"

aws apigateway create-deployment       --region "${REGION}"       --rest-api-id "${API_ID}"       --stage-name "${STAGE_NAME}"

echo "Deployed to stage: ${STAGE_NAME}"
