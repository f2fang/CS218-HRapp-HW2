#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
REST_API_ID="r7subbj2n5"
STAGE_NAME="ff_test"

aws apigateway get-export       --region "${REGION}"       --rest-api-id "${REST_API_ID}"       --stage-name "${STAGE_NAME}"       --export-type oas30       --parameters extensions=apigateway       apigw/apigw-oas30.json

echo "Exported to apigw/apigw-oas30.json"
