#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-us-west-1}"
ACCOUNT_ID="${ACCOUNT_ID:-000000000000}"
TABLE_ARN="${TABLE_ARN:-arn:aws:dynamodb:us-west-1:$ACCOUNT_ID:table/Employees}"

TRUST_POLICY='{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "lambda.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}'

# Create roles
aws iam create-role --role-name lambda-employee-get-role --assume-role-policy-document "$TRUST_POLICY" >/dev/null
aws iam create-role --role-name lambda-employee-post-role --assume-role-policy-document "$TRUST_POLICY" >/dev/null

# Attach basic logs
aws iam attach-role-policy --role-name lambda-employee-get-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name lambda-employee-post-role --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

# Inline least-privilege policies
GET_POLICY=$(jq -c --arg TABLE_ARN "$TABLE_ARN" '.Statement[0].Resource=$TABLE_ARN' policy-get.json)
POST_POLICY=$(jq -c --arg TABLE_ARN "$TABLE_ARN" '.Statement[0].Resource=$TABLE_ARN' policy-post.json)

aws iam put-role-policy --role-name lambda-employee-get-role --policy-name LambdaEmployeeGetPolicy --policy-document "$GET_POLICY"
aws iam put-role-policy --role-name lambda-employee-post-role --policy-name LambdaEmployeePostPolicy --policy-document "$POST_POLICY"

echo "Roles created. Assign in Lambda console:"
echo " - employee_get  -> lambda-employee-get-role"
echo " - employee_post -> lambda-employee-post-role"