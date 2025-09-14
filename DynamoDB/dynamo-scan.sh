#!/usr/bin/env bash
set -euo pipefail
REGION="us-west-1"
TABLE="Employees"

aws dynamodb scan --region "$REGION" --table-name "$TABLE"
