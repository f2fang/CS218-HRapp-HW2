# Cognito – Exported Config (for grading)

**Region:** us-west-1

This folder contains exported Cognito configuration so the instructor can verify settings (no secrets or passwords included).

## Files in `out/`
- `user-pool.json` – User Pool details
- `clients.json` – App Clients under this pool
- `app-client.json` – The app client used by this app (ID: 6ea5qbg5cf8lbr5cpp2javetp4)
- `domain.json` – Hosted UI domain status (hr-auth-14661.auth.us-west-1.amazoncognito.com)
- `resource-servers.json` – Resource servers (if any)
- `idps.json` – Identity providers (if any)
- `groups.json` – Groups (if any)

> The exported `out/*.json` files are already included—no script execution required to review.

## OAuth highlights (also visible in `app-client.json`)
- Flow: **Authorization Code + PKCE**
- Scopes: `openid email profile`
- Callback URLs: `https://staging.d2zq2v1gu1gfsu.amplifyapp.com/`
- Sign-out URLs: `https://staging.d2zq2v1gu1gfsu.amplifyapp.com/`
- No client secret (public client for browser app)

## (Optional) Re-export from AWS
If needed, re-generate the JSON files by running:
```bash
./cognito/export-config.sh

