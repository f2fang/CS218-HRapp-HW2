#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-us-west-1}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_NAME="hr-lambda-exec"
POLICY_NAME="hr-lambda-dynamodb-access"

TRUST_DOC='{
  "Version": "2012-10-17",
  "Statement": [
    { "Effect": "Allow", "Principal": { "Service": "lambda.amazonaws.com" }, "Action": "sts:AssumeRole" }
  ]
}'

echo "Creating role ${ROLE_NAME} (if not exists)..."
if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-role --role-name "$ROLE_NAME" --assume-role-policy-document "$TRUST_DOC" >/dev/null
  echo "Role created."
else
  echo "Role already exists."
fi

echo "Attaching AWSLambdaBasicExecutionRole managed policy..."
aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole >/dev/null || true

echo "Creating/Updating inline DynamoDB policy ${POLICY_NAME} ..."
POLICY_DOC_FILE="policy-inline.json"
aws iam put-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" --policy-document file://$POLICY_DOC_FILE

ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
echo "Done. Use this ROLE_ARN in lambda-deploy.sh:"
echo "$ROLE_ARN"
