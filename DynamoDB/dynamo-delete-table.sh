#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
TABLE="Employees"

if ! aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" >/dev/null 2>&1; then
  echo "Table '$TABLE' does not exist in $REGION."; exit 0;
fi

read -p "Delete table '$TABLE' in $REGION? (y/N): " yn
if [[ "$yn" != "y" && "$yn" != "Y" ]]; then
  echo "Aborted."; exit 0;
fi

aws dynamodb delete-table --region "$REGION" --table-name "$TABLE"
echo "Waiting for deletion ..."
aws dynamodb wait table-not-exists --region "$REGION" --table-name "$TABLE"
echo "Deleted."
