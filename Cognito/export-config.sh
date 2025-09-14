#!/usr/bin/env bash
set -euo pipefail

REGION="us-west-1"
USER_POOL_ID="us-west-1_gPOIMCEDP"
APP_CLIENT_ID="6ea5qbg5cf8lbr5cpp2javetp4"
DOMAIN="hr-auth-14661.auth.us-west-1.amazoncognito.com"

OUT_DIR="cognito/out"
mkdir -p "$OUT_DIR"

echo "[1/7] describe-user-pool"
aws cognito-idp describe-user-pool       --region "$REGION"       --user-pool-id "$USER_POOL_ID"       > "$OUT_DIR/user-pool.json"

echo "[2/7] list-user-pool-clients"
aws cognito-idp list-user-pool-clients       --region "$REGION"       --user-pool-id "$USER_POOL_ID"       --max-results 60       > "$OUT_DIR/clients.json"

echo "[3/7] describe-user-pool-client"
aws cognito-idp describe-user-pool-client       --region "$REGION"       --user-pool-id "$USER_POOL_ID"       --client-id "$APP_CLIENT_ID"       > "$OUT_DIR/app-client.json"

# [4/7] list-resource-servers (max 50)
aws cognito-idp list-resource-servers \
  --region "$REGION" \
  --user-pool-id "$USER_POOL_ID" \
  --max-results 50 \
  > "$OUT_DIR/resource-servers.json"

# [5/7] list-identity-providers (safe to use 50)
aws cognito-idp list-identity-providers \
  --region "$REGION" \
  --user-pool-id "$USER_POOL_ID" \
  --max-results 50 \
  > "$OUT_DIR/idps.json"

# [6/7] list-groups (param name is --limit; use 50)
aws cognito-idp list-groups \
  --region "$REGION" \
  --user-pool-id "$USER_POOL_ID" \
  --limit 50 \
  > "$OUT_DIR/groups.json"


echo "Done. See files in $OUT_DIR"
