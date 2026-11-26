'use strict';
// Live Plaid SANDBOX check of the real API surface (no app): creates a sandbox
// public_token for First Platypus Bank (ins_109508, user_good), then runs
// exchange -> balance -> assign against a local server. Prints no secrets.
const os = require('os'); const path = require('path'); const fs = require('fs');
const { createApp, makePlaidClient } = require('../src/app');
const { fileStore } = require('../src/stores');
(async () => {
  const plaid = makePlaidClient({ clientId: process.env.PLAID_CLIENT_ID, secret: process.env.PLAID_SECRET || process.env.PLAID_SANDBOX_SECRET, env: 'sandbox' });
  const storePath = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'cs-e2e-')), 's.json');
  const app = createApp({ plaid, store: fileStore(storePath), appKey: 'e2e' });
  const server = app.listen(0);
  const base = `http://127.0.0.1:${server.address().port}`;
  const call = async (p, body) => (await fetch(base + p, { method: 'POST', headers: { 'content-type': 'application/json', 'x-crew-stash-key': 'e2e' }, body: JSON.stringify(body) })).json();
  try {
    const lt = await call('/link-token', { kidId: 'kid_everest' });
    console.log('link-token:', lt.link_token ? 'ok' : lt);
    const pt = await plaid.sandboxPublicTokenCreate({ institution_id: 'ins_109508', initial_products: ['auth'] });
    const ex = await call('/exchange', { kidId: 'kid_everest', public_token: pt.data.public_token, institution_name: 'First Platypus Bank' });
    console.log('exchange accounts:', ex.accounts.map((a) => `${a.name} ****${a.mask} current=${a.current} available=${a.available}`));
    console.log('access token in response?', JSON.stringify(ex).includes('access-'));
    const sav = ex.accounts.find((a) => a.subtype === 'savings');
    const as = await call('/assign', { kidId: 'kid_everest', account_id: sav.account_id });
    const bal = await call('/balance', { kidId: 'kid_everest' });
    console.log('balance selected:', bal.selected.name, bal.selected.current, 'matches assign:', as.selected_account_id === bal.selected.account_id);
    const un = await call('/unlink', { kidId: 'kid_everest' });
    console.log('unlink:', un);
  } finally { server.close(); }
})().catch((e) => { console.error('FAILED', e.response?.data?.error_code || e.message); process.exit(1); });
