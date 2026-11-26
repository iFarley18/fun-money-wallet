'use strict';
// Local sandbox runner (no Firebase needed). Reads credentials from env only:
//   PLAID_CLIENT_ID, PLAID_SECRET (or PLAID_SANDBOX_SECRET), CREW_STASH_APP_KEY
//   PORT (default 8787), CREW_STASH_STORE (default ./.local-store.json)
const path = require('path');
const { createApp, makePlaidClient } = require('./src/app');
const { fileStore } = require('./src/stores');

const env = process.env.PLAID_ENV || 'sandbox';
if (env !== 'sandbox') { console.error('local-server is sandbox-only'); process.exit(1); }
const app = createApp({
  plaid: makePlaidClient({ clientId: process.env.PLAID_CLIENT_ID, secret: process.env.PLAID_SECRET || process.env.PLAID_SANDBOX_SECRET, env }),
  store: fileStore(process.env.CREW_STASH_STORE || path.join(__dirname, '.local-store.json')),
  appKey: process.env.CREW_STASH_APP_KEY,
  androidPackageName: process.env.PLAID_ANDROID_PACKAGE_NAME || undefined,
});
const port = Number(process.env.PORT || 8787);
app.listen(port, '0.0.0.0', () => console.log(`crew-sync local sandbox API on :${port}`));
