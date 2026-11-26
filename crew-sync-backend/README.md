# Crew Stash – Crew balance sync backend (read-only, Plaid)

Small HTTPS API the Crew Stash app calls. It holds the Plaid secret and each
linked login's `access_token` (server side only) and returns **only** account
name, mask and current/available balance. It cannot move money.

| Endpoint | Body | Returns |
|---|---|---|
| `POST /link-token` | `{kidId}` | `{link_token}` for Plaid Link (products `auth` → Balance included, US) |
| `POST /exchange` | `{kidId, public_token, institution_name?, account_id?}` | stores access token, maps kid → account; returns accounts |
| `POST /items` | `{}` | already-linked logins (so a 2nd kid can reuse one login) |
| `POST /assign` | `{kidId, item_id?, account_id}` | choose which account is that kid's |
| `POST /balance` | `{kidId}` | live `accounts/balance/get` for the kid's account |
| `POST /unlink` | `{kidId}` | unmaps kid; calls `item/remove` when no kid uses the login |

Every call (except `GET /health`) needs header `x-crew-stash-key: <CREW_STASH_APP_KEY>`.
Only deposit accounts are returned. Firestore collections `crewStashKids` and
`crewStashItems` are closed to all clients by `firestore.rules`.


## Firebase project

- Project ID: `crew-stash` (display name: crew-stash). Owned by bfarley.86@gmail.com.
- Android app: `com.ifarley.gemini_fun_money` (app ID `1:578415278803:android:30e8a28dab777e60beb226`).
- Firestore: native mode in `nam5` is configured in `firebase.json`, but the Cloud Firestore API is not enabled yet (blocked until it is turned on in this project).
- Do not add a billing account from this repo. After Brian upgrades the project to Blaze at
  https://console.firebase.google.com/project/crew-stash/usage/details
  and enables Firestore, functions can be deployed (not done yet).

## Local sandbox run (what was used for testing)

```bash
cd functions && npm ci
export PLAID_CLIENT_ID=... PLAID_SECRET=<sandbox secret> CREW_STASH_APP_KEY=<random>
npm start            # http://0.0.0.0:8787, data in .local-store.json (git-ignored)
npm test             # unit tests (fake Plaid)
node scripts/sandbox-e2e.js   # live Plaid sandbox round trip, First Platypus Bank
```
Android emulator reaches it at `http://10.0.2.2:8787` (local builds only; needs cleartext enabled in the local build).

## Deploy (needs Brian's OK)

1. A Firebase project on the **Blaze** plan (Cloud Functions 2nd gen + Secret Manager require it; this traffic fits in the free tier).
2. `firebase functions:secrets:set PLAID_CLIENT_ID`, `PLAID_SECRET`, `CREW_STASH_APP_KEY`
3. Set params `PLAID_ENV=production`, `PLAID_ANDROID_PACKAGE_NAME=com.ifarley.gemini_fun_money`
   (Crew is an OAuth bank, so the package name must also be added under
   Plaid Dashboard → Developers → API → Allowed Android package names).
4. `firebase deploy --only functions:crew-sync,firestore:rules --project <id>`
5. Build the app with `--dart-define=CREW_SYNC_URL=https://us-central1-<id>.cloudfunctions.net/crewSync --dart-define=CREW_SYNC_KEY=<key>`.

## Sandbox test notes (Nov 25, 2026)
- Backend: `npm test` (4/4) and `scripts/sandbox-e2e.js` pass against live Plaid sandbox.
- Plaid Link: completed with First Platypus Bank / `user_good` / `pass_good` via Plaid's web Link
  (the box's API-31 emulator ships WebView 91, too old for Plaid Link's UI, so the native
  Link sheet opens but stays blank there; real phones have a current WebView).
- App on emulator: "Link Crew account" → "Use my linked First Platypus Bank login" → pick
  "Plaid Saving ••1111" → total became $210.00 → vault shows 2×$100 + $10 bills.
