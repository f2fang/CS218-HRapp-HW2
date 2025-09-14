#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
TABLE="Employees"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_FILE="${SCRIPT_DIR}/seed.json"

if ! aws dynamodb describe-table --region "$REGION" --table-name "$TABLE" >/dev/null 2>&1; then
  echo "Table '$TABLE' does not exist. Run ./dynamo-create.sh first."; exit 1;
fi

echo "Seeding data into $TABLE ..."
# Use jq if available; otherwise fallback to two hardcoded items
if command -v jq >/dev/null 2>&1; then
  COUNT=$(jq '.items | length' "$SEED_FILE")
  for ((i=0; i<COUNT; i++)); do
    id=$(jq -r ".items[$i].id" "$SEED_FILE")
    name=$(jq -r ".items[$i].name" "$SEED_FILE")
    salary=$(jq -r ".items[$i].salary" "$SEED_FILE")
    doj=$(jq -r ".items[$i].dateOfJoin" "$SEED_FILE")

    aws dynamodb put-item --region "$REGION" --table-name "$TABLE" --item "{
      \"id\": {\"S\": \"$id\"},
      \"name\": {\"S\": \"$name\"},
      \"salary\": {\"N\": \"$salary\"},
      \"dateOfJoin\": {\"S\": \"$doj\"}
    }" >/dev/null
    echo "  Put $id"
  done
else
  echo "jq not found; seeding two default items ..."
  aws dynamodb put-item --region "$REGION" --table-name "$TABLE" --item '{
    "id": {"S":"E1001"},
    "name": {"S":"Ada Lovelace"},
    "salary": {"N":"185000"},
    "dateOfJoin": {"S":"2020-01-15"}
  }' >/dev/null
  aws dynamodb put-item --region "$REGION" --table-name "$TABLE" --item '{
    "id": {"S":"E1002"},
    "name": {"S":"Grace Hopper"},
    "salary": {"N":"195000"},
    "dateOfJoin": {"S":"2021-07-01"}
  }' >/dev/null
fi

echo "Seed complete."
