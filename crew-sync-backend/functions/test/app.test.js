'use strict';
const test = require('node:test');
const assert = require('node:assert');
const os = require('os');
const path = require('path');
const fs = require('fs');
const { createApp } = require('../src/app');
const { fileStore } = require('../src/stores');

const ACCOUNTS = [
  { account_id: 'acc1', name: 'Plaid Checking', mask: '0000', type: 'depository', subtype: 'checking', balances: { current: 110, available: 100, iso_currency_code: 'USD' } },
  { account_id: 'acc2', name: 'Plaid Saving', mask: '1111', type: 'depository', subtype: 'savings', balances: { current: 210, available: 200, iso_currency_code: 'USD' } },
];
const fakePlaid = {
  removed: [],
  async linkTokenCreate(r) { this.lastLink = r; return { data: { link_token: 'link-sandbox-x', expiration: 'later' } }; },
  async itemPublicTokenExchange() { return { data: { access_token: 'access-sandbox-SECRET', item_id: 'item1' } }; },
  async accountsBalanceGet({ access_token }) { assert.strictEqual(access_token, 'access-sandbox-SECRET'); return { data: { accounts: ACCOUNTS } }; },
  async itemRemove({ access_token }) { this.removed.push(access_token); return { data: {} }; },
};

async function withServer(fn) {
  const storePath = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'cs-')), 's.json');
  const app = createApp({ plaid: fakePlaid, store: fileStore(storePath), appKey: 'k', logger: { warn() {}, error() {} } });
  const server = app.listen(0);
  const base = `http://127.0.0.1:${server.address().port}`;
  const call = async (p, body, key = 'k') => {
    const r = await fetch(base + p, { method: 'POST', headers: { 'content-type': 'application/json', 'x-crew-stash-key': key }, body: JSON.stringify(body) });
    const text = await r.text();
    return { status: r.status, text, json: JSON.parse(text) };
  };
  try { await fn(call, storePath); } finally { server.close(); }
}

test('rejects missing/wrong app key', () => withServer(async (call) => {
  assert.strictEqual((await call('/link-token', { kidId: 'kid_everest' }, 'nope')).status, 401);
}));

test('link token uses auth product + US, no balance product', () => withServer(async (call) => {
  const r = await call('/link-token', { kidId: 'kid_everest' });
  assert.strictEqual(r.status, 200);
  assert.strictEqual(r.json.link_token, 'link-sandbox-x');
  assert.deepStrictEqual(fakePlaid.lastLink.products, ['auth']);
  assert.deepStrictEqual(fakePlaid.lastLink.country_codes, ['US']);
}));

test('exchange never returns access token; balance + assign + reuse + unlink', () => withServer(async (call, storePath) => {
  const ex = await call('/exchange', { kidId: 'kid_everest', public_token: 'public-sandbox-1', institution_name: 'First Platypus Bank' });
  assert.strictEqual(ex.status, 200);
  assert.ok(!ex.text.includes('access-sandbox'), 'access token leaked');
  assert.strictEqual(ex.json.selected_account_id, 'acc1');
  assert.deepStrictEqual(Object.keys(ex.json.accounts[0]).sort(), ['account_id', 'available', 'currency', 'current', 'mask', 'name', 'official_name', 'subtype', 'type'].sort());
  assert.ok(fs.readFileSync(storePath, 'utf8').includes('access-sandbox-SECRET'), 'token stored server side');

  const asg = await call('/assign', { kidId: 'kid_everest', account_id: 'acc2' });
  assert.strictEqual(asg.json.selected_account_id, 'acc2');
  const bal = await call('/balance', { kidId: 'kid_everest' });
  assert.strictEqual(bal.json.selected.current, 210);
  assert.ok(!bal.text.includes('access-sandbox'));

  // Brighton reuses the same login, picks the checking account.
  const items = await call('/items', {});
  assert.deepStrictEqual(items.json.items, [{ item_id: 'item1', institution: 'First Platypus Bank' }]);
  const b = await call('/assign', { kidId: 'kid_brighton', item_id: 'item1', account_id: 'acc1' });
  assert.strictEqual(b.json.selected_account_id, 'acc1');

  assert.strictEqual((await call('/unlink', { kidId: 'kid_everest' })).json.item_removed, false);
  assert.strictEqual((await call('/unlink', { kidId: 'kid_brighton' })).json.item_removed, true);
  assert.deepStrictEqual(fakePlaid.removed, ['access-sandbox-SECRET']);
  assert.strictEqual((await call('/balance', { kidId: 'kid_brighton' })).status, 404);
}));

test('validates input', () => withServer(async (call) => {
  assert.strictEqual((await call('/balance', { kidId: '../x' })).status, 400);
  assert.strictEqual((await call('/exchange', { kidId: 'kid_a', public_token: 'access-x' })).status, 400);
}));
