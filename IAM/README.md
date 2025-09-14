# IAM – Lambda execution role (least privilege)

This package creates a minimal **Lambda execution role** that:
- Allows CloudWatch Logs (managed policy)
- Allows read/write to a single DynamoDB table: `Employees`
- Trusts `lambda.amazonaws.com`

**Defaults**
- Region: `us-west-1`
- Table: `Employees`
- Role name: `hr-lambda-exec`
- Inline policy name: `hr-lambda-dynamodb-access`

## Files
- `create-role.sh` – Create the role, attach logs policy, add inline DynamoDB policy.
- `get-role.sh` – Describe the role and its inline policy.
- `delete-role.sh` – Detach policies and delete the role.
- `README.md` – This guide.

## Quick start
```bash
cd iam
chmod +x *.sh

# Create role with defaults (Region us-west-1, Table Employees)
./create-role.sh

# Or override via env vars:
REGION=us-west-1 TABLE_NAME=Employees ROLE_NAME=hr-lambda-exec ./create-role.sh

# Inspect
./get-role.sh

# Cleanup (optional)
./delete-role.sh
```

## Use with your Lambda deploy script
After `./create-role.sh`, it prints the `ROLE_ARN`. Paste that ARN into your Lambda deploy (`lambda-deploy.sh`).
