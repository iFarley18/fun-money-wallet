'use strict';
// Firebase Cloud Functions entry point (2nd gen). Requires the Blaze plan to deploy.
// Secrets live in Google Secret Manager:
//   firebase functions:secrets:set PLAID_CLIENT_ID
//   firebase functions:secrets:set PLAID_SECRET
//   firebase functions:secrets:set CREW_STASH_APP_KEY
const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret, defineString } = require('firebase-functions/params');
const admin = require('firebase-admin');
const { createApp, makePlaidClient } = require('./src/app');
const { firestoreStore } = require('./src/stores');

const PLAID_CLIENT_ID = defineSecret('PLAID_CLIENT_ID');
const PLAID_SECRET = defineSecret('PLAID_SECRET');
const CREW_STASH_APP_KEY = defineSecret('CREW_STASH_APP_KEY');
const PLAID_ENV = defineString('PLAID_ENV', { default: 'sandbox' });
const ANDROID_PACKAGE = defineString('PLAID_ANDROID_PACKAGE_NAME', { default: '' });

admin.initializeApp();
let app;

exports.crewSync = onRequest(
  { secrets: [PLAID_CLIENT_ID, PLAID_SECRET, CREW_STASH_APP_KEY], region: 'us-central1', maxInstances: 2 },
  (req, res) => {
    if (!app) {
      app = createApp({
        plaid: makePlaidClient({ clientId: PLAID_CLIENT_ID.value(), secret: PLAID_SECRET.value(), env: PLAID_ENV.value() }),
        store: firestoreStore(admin.firestore()),
        appKey: CREW_STASH_APP_KEY.value(),
        androidPackageName: ANDROID_PACKAGE.value() || undefined,
      });
    }
    return app(req, res);
  },
);
