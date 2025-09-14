#!/usr/bin/env bash
set -euo pipefail

# ==== Required values (replace with your own) ====
REGION="us-west-1"
USER_POOL_ID="us-west-1_gPOIMCEDP"
APP_CLIENT_ID="6ea5qbg5cf8lbr5cpp2javetp4"   # your User Pool App Client ID
CALLBACK_URLS=("https://staging.d2zq2v1gu1gfsu.amplifyapp.com/")  # can include multiple
LOGOUT_URLS=("https://staging.d2zq2v1gu1gfsu.amplifyapp.com/")    # can include multiple

# OAuth scopes you want to allow
SCOPES=("openid" "email" "profile")

# ==== helper to convert Bash arrays into JSON arrays ====
json_array() {
  local arr=("$@")
  local json="["
  local first=1
  for v in "${arr[@]}"; do
    if [[ $first -eq 1 ]]; then first=0; else json+=", "; fi
    json+="\"$v\""
  done
  json+="]"
  echo "$json"
}
CALLBACKS_JSON=$(json_array "${CALLBACK_URLS[@]}")
LOGOUTS_JSON=$(json_array "${LOGOUT_URLS[@]}")
SCOPES_JSON=$(json_array "${SCOPES[@]}")

echo "==> Updating Cognito User Pool Client to Authorization Code + PKCE..."
aws cognito-idp update-user-pool-client \
  --region "$REGION" \
  --user-pool-id "$USER_POOL_ID" \
  --client-id "$APP_CLIENT_ID" \
  --supported-identity-providers '["COGNITO"]' \
  --allowed-o-auth-flows-user-pool-client \
  --allowed-o-auth-flows '["code"]' \
  --allowed-o-auth-scopes "$SCOPES_JSON" \
  --callback-urls "$CALLBACKS_JSON" \
  --logout-urls "$LOGOUTS_JSON" \
  >/dev/null

echo "==> Done. Current client settings:"
aws cognito-idp describe-user-pool-client \
  --region "$REGION" \
  --user-pool-id "$USER_POOL_ID" \
  --client-id "$APP_CLIENT_ID" \
  --query 'UserPoolClient.{ClientId:ClientId,CallbackURLs:CallbackURLs,LogoutURLs:LogoutURLs,AllowedOAuthFlows:AllowedOAuthFlows,AllowedOAuthScopes:AllowedOAuthScopes,SupportedIdentityProviders:SupportedIdentityProviders}' \
  --output table

