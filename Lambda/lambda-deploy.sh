#!/usr/bin/env bash
set -euo pipefail

REGION="us-west-1"

zip -r employee_get.zip employee_get.py >/dev/null
zip -r employee_post.zip employee_post.py >/dev/null

aws lambda update-function-code \
  --function-name employee_get \
  --zip-file fileb://employee_get.zip \
  --region "$REGION"

aws lambda update-function-code \
  --function-name employee_post \
  --zip-file fileb://employee_post.zip \
  --region "$REGION"

echo "Deployed employee_get & employee_post."

