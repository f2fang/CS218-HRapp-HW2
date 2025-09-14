# Lambda – functions and deployment

**Region:** us-west-1  
**Runtime:** Node.js 18.x  
**Env vars (both functions):**
- `TABLE_NAME` = `Employees`
- `CORS_ORIGIN` = `https://staging.d2zq2v1gu1gfsu.amplifyapp.com`

## Files
- `getEmployee.js` – Handler for **GET** `/hr/{id}?fields=name,salary,dateOfJoin` (returns only selected fields).
- `addEmployee.js` – Handler for **POST** `/hr` (body: `{id,name,salary,dateOfJoin}`).
- `lambda-deploy.sh` – Create or update both functions, set env vars.
- `create-role.sh` – (optional) Create an execution role with basic logs + DynamoDB access.
- `policy-inline.json` – Least-privilege sample policy (used by `create-role.sh`).

## Quick deploy
1) Create a role (or use your own and skip this step):
```bash
cd lambda
chmod +x create-role.sh lambda-deploy.sh
./create-role.sh            # prints the ROLE_ARN at the end
```
2) Edit `lambda-deploy.sh`, set `ROLE_ARN` to the printed value (or your existing role).  
3) Deploy / update:
```bash
./lambda-deploy.sh
```
4) In API Gateway, wire routes to functions:
   - `GET /hr/{id}`  → `hr-get-employee`
   - `POST /hr`        → `hr-add-employee`
   (Lambda proxy integration, with your existing Cognito authorizer on the methods.)

## Notes
- CORS headers are added by the function responses (success and errors) using `CORS_ORIGIN`.
- Authorization is enforced at **API Gateway** (Cognito authorizer). Lambda does not parse JWT.
- `aws-sdk` v2 is available in the Node.js 18 runtime; no extra dependencies required.
