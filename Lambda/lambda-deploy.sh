#!/usr/bin/env bash
set -euo pipefail

REGION="us-west-1"
ROLE_ARN="arn:aws:iam::<YOUR_ACCOUNT_ID>:role/<YourLambdaRole>"   # TODO: replace
TABLE_NAME="Employees"
CORS_ORIGIN="https://staging.d2zq2v1gu1gfsu.amplifyapp.com"

FUNC_GET="hr-get-employee"
FUNC_ADD="hr-add-employee"

zip -j ${FUNC_GET}.zip getEmployee.js
if aws lambda get-function --region "$REGION" --function-name "$FUNC_GET" >/dev/null 2>&1; then
  aws lambda update-function-code --region "$REGION" --function-name "$FUNC_GET" --zip-file fileb://${FUNC_GET}.zip >/dev/null
else
  aws lambda create-function     --region "$REGION"     --function-name "$FUNC_GET"     --runtime nodejs18.x     --role "$ROLE_ARN"     --handler getEmployee.handler     --zip-file fileb://${FUNC_GET}.zip     --timeout 10     --environment "Variables={TABLE_NAME=${TABLE_NAME},CORS_ORIGIN=${CORS_ORIGIN}}"
fi
aws lambda update-function-configuration   --region "$REGION" --function-name "$FUNC_GET"   --environment "Variables={TABLE_NAME=${TABLE_NAME},CORS_ORIGIN=${CORS_ORIGIN}}"

zip -j ${FUNC_ADD}.zip addEmployee.js
if aws lambda get-function --region "$REGION" --function-name "$FUNC_ADD" >/dev/null 2>&1; then
  aws lambda update-function-code --region "$REGION" --function-name "$FUNC_ADD" --zip-file fileb://${FUNC_ADD}.zip >/dev/null
else
  aws lambda create-function     --region "$REGION"     --function-name "$FUNC_ADD"     --runtime nodejs18.x     --role "$ROLE_ARN"     --handler addEmployee.handler     --zip-file fileb://${FUNC_ADD}.zip     --timeout 10     --environment "Variables={TABLE_NAME=${TABLE_NAME},CORS_ORIGIN=${CORS_ORIGIN}}"
fi
aws lambda update-function-configuration   --region "$REGION" --function-name "$FUNC_ADD"   --environment "Variables={TABLE_NAME=${TABLE_NAME},CORS_ORIGIN=${CORS_ORIGIN}}"

echo "Lambda functions deployed/updated."
