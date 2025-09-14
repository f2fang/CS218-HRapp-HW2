#!/usr/bin/env bash
set -euo pipefail
ROLE_NAME="${ROLE_NAME:-hr-lambda-exec}"
POLICY_NAME="${POLICY_NAME:-hr-lambda-dynamodb-access}"

echo "Role:"
aws iam get-role --role-name "$ROLE_NAME"

echo
echo "Inline policy (${POLICY_NAME}):"
aws iam get-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME"
