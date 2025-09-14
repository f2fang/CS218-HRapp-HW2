#!/usr/bin/env bash
set -euo pipefail

ROLE_NAME="${ROLE_NAME:-hr-lambda-exec}"
POLICY_NAME="${POLICY_NAME:-hr-lambda-dynamodb-access}"

echo "[1/3] Delete inline policy (if exists)"
aws iam delete-role-policy --role-name "$ROLE_NAME" --policy-name "$POLICY_NAME" >/dev/null 2>&1 || true

echo "[2/3] Detach CloudWatch Logs policy"
aws iam detach-role-policy --role-name "$ROLE_NAME" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole >/dev/null 2>&1 || true

echo "[3/3] Delete role"
aws iam delete-role --role-name "$ROLE_NAME" >/dev/null 2>&1 || true

echo "Done."
