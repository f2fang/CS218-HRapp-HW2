#!/bin/bash
set -euo pipefail

REGION="us-west-1"
POOL_NAME="HR-UserPool"
CLIENT_NAME="HR-SPA-Client"
CALLBACK_URL="http://localhost:3000/callback"
LOGOUT_URL="http://localhost:3000/"
DOMAIN_PREFIX="hr-auth-$RANDOM"   # must be globally unique

echo "[1] Create User Pool..."
USER_POOL_ID=$(aws cognito-idp create-user-pool \
  --region $REGION \
  --pool-name "$POOL_NAME" \
  --auto-verified-attributes email \
  --query 'UserPool.Id' --output text)
echo "USER_POOL_ID=$USER_POOL_ID"

echo "[2] Create App Client via CloudFormation..."
cat > hr-spa-client.yaml <<'YAML'
AWSTemplateFormatVersion: '2010-09-09'
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
      CallbackURLs: [ !Ref CallbackUrl ]
      LogoutURLs:   [ !Ref LogoutUrl ]
      EnableTokenRevocation: true
      PreventUserExistenceErrors: ENABLED
Parameters:
  UserPoolId:
    Type: String
  CallbackUrl:
    Type: String
  LogoutUrl:
    Type: String
Outputs:
  AppClientId:
    Value: !Ref HRSPAClient
YAML

aws cloudformation deploy \
  --region $REGION \
  --stack-name hr-spa-client-stack \
  --template-file hr-spa-client.yaml \
  --parameter-overrides \
      UserPoolId=$USER_POOL_ID \
      CallbackUrl=$CALLBACK_URL \
      LogoutUrl=$LOGOUT_URL

APP_CLIENT_ID=$(aws cloudformation describe-stacks \
  --region $REGION \
  --stack-name hr-spa-client-stack \
  --query "Stacks[0].Outputs[?OutputKey=='AppClientId'].OutputValue" \
  --output text)
echo "APP_CLIENT_ID=$APP_CLIENT_ID"

echo "[3] Create Hosted UI domain..."
aws cognito-idp create-user-pool-domain \
  --region $REGION \
  --user-pool-id $USER_POOL_ID \
  --domain $DOMAIN_PREFIX

DOMAIN_URL="https://${DOMAIN_PREFIX}.auth.${REGION}.amazoncognito.com"
echo "DOMAIN_URL=$DOMAIN_URL"

echo "DONE ✅"
echo "Pool: $USER_POOL_ID"
echo "Client: $APP_CLIENT_ID"
echo "Hosted UI: $DOMAIN_URL"


#Change call back to jwt.io
REGION="us-west-1"
USER_POOL_ID="us-west-1_gPOIMCEDP"
STACK="hr-spa-client-stack"

# call back to jwt.io
cat > hr-spa-client-implicit.yaml <<'YAML'
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
      # active implicit
      AllowedOAuthFlows: [ implicit ]
      AllowedOAuthScopes: [ openid, email, profile ]
      SupportedIdentityProviders: [ COGNITO ]
      # call back to jwt.io 
      CallbackURLs: [ "https://jwt.io" ]
      LogoutURLs:   [ "https://jwt.io" ]
      EnableTokenRevocation: true
      PreventUserExistenceErrors: ENABLED
Outputs:
  AppClientId:
    Value: !Ref HRSPAClient
YAML

aws cloudformation deploy \
  --region "$REGION" \
  --stack-name "$STACK" \
  --template-file hr-spa-client-implicit.yaml \
  --parameter-overrides UserPoolId="$USER_POOL_ID"

APP_CLIENT_ID=$(aws cloudformation describe-stacks \
  --region "$REGION" --stack-name "$STACK" \
  --query "Stacks[0].Outputs[?OutputKey=='AppClientId'].OutputValue" --output text)
echo "APP_CLIENT_ID=$APP_CLIENT_ID"

 
#Create User
REGION="us-west-1"
POOL_ID="us-west-1_gPOIMCEDP"

# 1) Create user “fftest”
aws cognito-idp admin-create-user \
  --region "$REGION" \
  --user-pool-id "$POOL_ID" \
  --username "fftest" \
  --user-attributes Name=email,Value=fftest@example.com Name=email_verified,Value=true \
  --message-action SUPPRESS

# 2) Set password “FFtest123!”
aws cognito-idp admin-set-user-password \
  --region us-west-1 \
  --user-pool-id us-west-1_gPOIMCEDP \
  --username fftest \
  --password FFtest123! \
  --permanent
