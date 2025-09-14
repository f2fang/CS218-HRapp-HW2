#!/bin/bash
set -e

# ===== Configuration =====
REGION="us-west-1"
STACK="hr-spa-client-stack"
USER_POOL_ID="us-west-1_gPOIMCEDP"
TEMPLATE="hr-spa-client-code.yaml"

# ===== Write CloudFormation template (Authorization Code + PKCE) =====
cat > $TEMPLATE <<'YAML'
AWSTemplateFormatVersion: '2010-09-09'
Parameters:
  UserPoolId: { Type: String }

Resources:
  HRSPAClient:
    Type: AWS::Cognito::UserPoolClient
    Properties:
      ClientName: HR-SPA-Client
      UserPoolId: !Ref UserPoolId
      GenerateSecret: false
      AllowedOAuthFlowsUserPoolClient: true
      AllowedOAuthFlows: [ code ]
      AllowedOAuthScopes: [ openid, email, profile ]
      SupportedIdentityProviders: [ COGNITO ]
      CallbackURLs: [ "https://oauth.pstmn.io/v1/callback" ]
      LogoutURLs:   [ "https://oauth.pstmn.io/v1/callback" ]
      EnableTokenRevocation: true
      PreventUserExistenceErrors: ENABLED

Outputs:
  AppClientId:
    Value: !Ref HRSPAClient
YAML

# ===== Deploy stack =====
echo "Deploying CloudFormation stack: $STACK ..."
aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$STACK" \
  --template-file "$TEMPLATE" \
  --parameter-overrides UserPoolId="$USER_POOL_ID"

# ===== Get App Client ID =====
APP_CLIENT_ID=$(aws cloudformation describe-stacks \
  --region "$REGION" --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='AppClientId'].OutputValue" \
  --output text)

echo "✅ Deployment finished."
echo "Your App Client ID is: $APP_CLIENT_ID"

