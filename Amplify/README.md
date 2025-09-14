# Amplify (Frontend)

Static frontend for the HR app (Cognito login + call API Gateway).

**Live URL:** https://staging.d2zq2v1gu1gfsu.amplifyapp.com/  
**Auth flow:** Cognito Hosted UI — Authorization Code + PKCE  
**Token storage:** `sessionStorage` (clears when tab/browser closes)

## Files
- `index.html` – Landing page with **Login/Logout**. Shows **Get / Add** menu only after sign-in.
- `get.html` – Fetch employee by ID with selected fields.
- `add.html` – Create employee record.
- `auth-config.js` – Amplify Auth config + tiny `AuthKit` helper.
