# Lambda – functions and deployment (Python 3.13)

**Region:** us-west-1  
**Runtime:** Python 3.13  
**Env vars (both functions):**
- `TABLE_NAME` = `Employees`
- `CORS_ORIGIN` = `https://staging.d2zq2v1gu1gfsu.amplifyapp.com`

## Files
- `employee_get.py` – Handler for **GET** `/hr/{id}?fields=name|salary|dateOfJoin` (returns **only** the selected field).
- `employee_post.py` – Handler for **POST** `/hr` (body: `{ id, name, salary, dateOfJoin }`).
- `lambda-deploy.sh` – Zip & update both functions (code only).
- `create-role.sh` – (optional) Create two execution roles and attach least-privilege policies.
- `policy-get.json` – Inline policy for `employee_get` role (`dynamodb:GetItem` only).
- `policy-post.json` – Inline policy for `employee_post` role (`dynamodb:PutItem` only).

## Quick deploy
1) (Optional) Create roles (edit TABLE_ARN and ACCOUNT_ID):
```bash
cd lambda_pkg
chmod +x create-role.sh lambda-deploy.sh
./create-role.sh
```

2) Deploy/update Lambda code (set REGION if needed):
```bash
./lambda-deploy.sh
```

3) In API Gateway (REST), wire methods to Lambdas (Lambda **proxy** integration):
- `GET /hr/{id}`  → `employee_get`
- `POST /hr`      → `employee_post`

Keep your **Cognito User Pool Authorizer** on these methods (we use the **ID token** as `Authorization: Bearer <id_token>`).

## Notes
- **CORS**: Both handlers return the headers using `CORS_ORIGIN`.
- **Auth**: Authorization is enforced at **API Gateway** (Cognito authorizer). Lambda does not need to parse the JWT unless you want group checks.
- **Least privilege**: separate roles/policies for GET vs POST.