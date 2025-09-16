# CS218 – HW2 – HR App (Amplify + API Gateway + Cognito + Lambda + DynamoDB)

**Author:** Fang Fang  
**Live URL:** https://staging.d2zq2v1gu1gfsu.amplifyapp.com/  
**Region:** us-west-1

## How to grade (happy path)
1) Open the Live URL → click **Login** (Cognito Hosted UI, Authorization Code + PKCE).  
2) Back on **index**, the menu appears: **Get Employee** / **Add Employee**.  
3) **Get**: go to `get.html`, enter `E1001`, select 1–3 fields → **Get** (table shows selected fields).  
4) **Add**: go to `add.html`, fill `id/name/salary/dateOfJoin` → **Add** (echo row).  
5) **Logout** (bottom of the page).

## Repo layout
- **Amplify/** – Frontend: `index.html`, `get.html`, `add.html`, `auth-config.js`  
- **APIGateway/** – `apigw-oas30.json` + README (export/import)  
- **Cognito/** – `out/*.json` (exported config) + `export-config.sh`  
- **Lambda/** – `employee_get.py`, `employee_post.py`, deploy scripts  
- **DynamoDB/** – table create/seed scripts (`Employees`)  
- **IAM/** – Lambda execution role scripts
- **Doc/** – Documentation & optional screenshots (see below)

## Doc
- `docs/README.md` – short instructions, resource IDs, and grading path recap.  
- `docs/screenshots/` – optional screenshots to assist grading:
  - `00-IndexNotSignedinPage.png` (Hosted UI)  
  - `01-Login Page.png` (Hosted UI)  
  - `02-SignedinIndexPage.png` (Get/Add menu visible)  
  - `03-GetEnployeePage.png` (successful GET)
  - `04-PostEnployeePage.png` (Sucessful Add) 


## AWS resources (for verification)
- **Amplify Hosting**: staging.d2zq2v1gu1gfsu.amplifyapp.com  
- **API Gateway (REST)**: API Id `r7subbj2n5`, Stage `ff_test`  
- **Cognito**: User Pool `us-west-1_gPOIMCEDP`, App Client `6ea5qbg5cf8lbr5cpp2javetp4`, Domain `hr-auth-14661.auth.us-west-1.amazoncognito.com`  
- **DynamoDB**: Table `Employees` (PK: `id`)  
- **Lambda**: `employee_get` (GET), `employee_post` (POST)

## Auth & CORS (summary)
- Frontend includes `Authorization: Bearer <Access_TOKEN>` from Amplify session (`sessionStorage`).  
- CORS origin allowed: `https://staging.d2zq2v1gu1gfsu.amplifyapp.com` (success + error paths).

