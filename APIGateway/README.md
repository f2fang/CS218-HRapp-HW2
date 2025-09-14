# API Gateway (REST) – OpenAPI export

Region: us-west-1  
Stage: ff_test

## Files
- `apigw-oas30.json` – OpenAPI 3.0 with `x-amazon-apigateway-*` extensions.
- `cors-headers.json` – Common CORS headers for Gateway Responses.
- `export.sh` – Export current API definition (oas30 with apigateway extensions).
- `import-new.sh` – Import as a NEW API and deploy to stage.
- `overwrite-existing.sh` – Overwrite an EXISTING API and deploy.

## Import (NEW API)
```bash
./apigw/import-new.sh
```

## Overwrite existing API
```bash
# Edit REST_API_ID inside the script first, then run:
./apigw/overwrite-existing.sh
```

## Notes
- Authorizer expects Cognito User Pool ARN:
  `arn:aws:cognito-idp:us-west-1:<ACCOUNT_ID>:userpool/us-west-1_gPOIMCEDP`
- OpenAPI export does **not** include account-level **Gateway Responses** (e.g. DEFAULT_4XX, UNAUTHORIZED).
  Apply CORS headers for those error responses using:
```bash
# DEFAULT_4XX
aws apigateway put-gateway-response       --region us-west-1       --rest-api-id r7subbj2n5       --response-type DEFAULT_4XX       --status-code 400       --response-parameters file://apigw/cors-headers.json

# UNAUTHORIZED
aws apigateway put-gateway-response       --region us-west-1       --rest-api-id r7subbj2n5       --response-type UNAUTHORIZED       --status-code 401       --response-parameters file://apigw/cors-headers.json
```

### Validate
- Open `apigw-oas30.json` in https://editor.swagger.io to confirm it parses.
- Search for `x-amazon-apigateway-integration` and `x-amazon-apigateway-authorizer`.
