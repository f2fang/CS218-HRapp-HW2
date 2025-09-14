#!/usr/bin/env bash
set -euo pipefail

REGION="${REGION:-us-west-1}"
TABLE_NAME="${TABLE_NAME:-Employees}"
ROLE_NAME="${ROLE_NAME:-hr-lambda-exec}"
POLICY_NAME="${POLICY_NAME:-hr-lambda-dynamodb-access}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/${ROLE_NAME}"
DDB_TABLE_ARN="arn:aws:dynamodb:${REGION}:${ACCOUNT_ID}:table/${TABLE_NAME}"
DDB_INDEX_ARN="${DDB_TABLE_ARN}/index/*"

TRUST_DOC='{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}'

echo "[1/4] Create role '${ROLE_NAME}' (if not exists)"
if ! aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  aws iam create-role --role-name "$ROLE_NAME"         --assume-role-policy-document "$TRUST_DOC" >/dev/null
  echo "  Created."
else
  echo "  Role exists."
fi

echo "[2/4] Attach CloudWatch Logs policy"
aws iam attach-role-policy       --role-name "$ROLE_NAME"       --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole >/dev/null || true

echo "[3/4] Put inline DynamoDB policy '${POLICY_NAME}' for table ${TABLE_NAME}"
POLICY_DOC_FILE="$(dirname "$0")/policy-inline.generated.json"
cat > "$POLICY_DOC_FILE" <<JSON
{{
  "Version": "2012-10-17",
  "Statement": [
    {{
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:Query"
      ],
      "Resource": [
        "${{DDB_TABLE_ARN}}",
        "${{DDB_INDEX_ARN}}"
      ]
    }}
  ]
}}
JSON

aws iam put-role-policy       --role-name "$ROLE_NAME"       --policy-name "$POLICY_NAME"       --policy-document file://"$POLICY_DOC_FILE"

echo "[4/4] Done."
echo "ROLE_ARN: ${ROLE_ARN}"
