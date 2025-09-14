#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
TABLE="Employees"

if aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" >/dev/null 2>&1; then
  echo "Table '$TABLE' already exists in $REGION. Skipping create."
  exit 0
fi

echo "Creating table '$TABLE' in $REGION ..."
aws dynamodb create-table       --region "$REGION"       --table-name "$TABLE"       --attribute-definitions AttributeName=id,AttributeType=S       --key-schema AttributeName=id,KeyType=HASH       --billing-mode PAY_PER_REQUEST

echo "Waiting for table to be ACTIVE ..."
aws dynamodb wait table-exists --region "$REGION" --table-name "$TABLE"
echo "Done."
