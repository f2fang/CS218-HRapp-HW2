#!/usr/bin/env bash
set -euo pipefail
export AWS_PAGER=""

REGION="us-west-1"
REST_API_ID="r7subbj2n5"                  # REST API id
STAGE_NAME="ff_test"
USER_POOL_ID="us-west-1_gPOIMCEDP"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
USER_POOL_ARN="arn:aws:cognito-idp:${REGION}:${ACCOUNT_ID}:userpool/${USER_POOL_ID}"

echo "Create (or reuse) Cognito authorizer"
AUTH_NAME="cognito-rest-$(date +%s)"
AUTH_ID=$(aws apigateway create-authorizer \
  --region "$REGION" \
  --rest-api-id "$REST_API_ID" \
  --name "$AUTH_NAME" \
  --type COGNITO_USER_POOLS \
  --provider-arns "$USER_POOL_ARN" \
  --identity-source "method.request.header.Authorization" \
  --query 'id' --output text)

echo "Find resource IDs for /hr and /hr/{id}"
aws apigateway get-resources --region "$REGION" --rest-api-id "$REST_API_ID" --output table

HR_RES_ID=$(aws apigateway get-resources --region "$REGION" --rest-api-id "$REST_API_ID" \
  --query "items[?path==\`/hr\`].id | [0]" --output text)
HR_ID_RES_ID=$(aws apigateway get-resources --region "$REGION" --rest-api-id "$REST_API_ID" \
  --query "items[?path==\`/hr/{id}\`].id | [0]" --output text)

echo "Update methods to use Cognito authorizer"
aws apigateway update-method \
  --region "$REGION" --rest-api-id "$REST_API_ID" \
  --resource-id "$HR_RES_ID" --http-method POST \
  --patch-operations op=replace,path=/authorizationType,value=COGNITO_USER_POOLS op=replace,path=/authorizerId,value="$AUTH_ID"

aws apigateway update-method \
  --region "$REGION" --rest-api-id "$REST_API_ID" \
  --resource-id "$HR_ID_RES_ID" --http-method GET \
  --patch-operations op=replace,path=/authorizationType,value=COGNITO_USER_POOLS op=replace,path=/authorizerId,value="$AUTH_ID"

echo "Deploy to stage ${STAGE_NAME}"
aws apigateway create-deployment --region "$REGION" --rest-api-id "$REST_API_ID" --stage-name "$STAGE_NAME" >/dev/null

echo "Done. Base: https://${REST_API_ID}.execute-api.${REGION}.amazonaws.com/${STAGE_NAME}"

