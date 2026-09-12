const admin = require('firebase-admin');

function getCredential() {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    return admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON));
  }
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    return admin.credential.applicationDefault();
  }
  throw new Error('Set FIREBASE_SERVICE_ACCOUNT_JSON or GOOGLE_APPLICATION_CREDENTIALS');
}

function getAdmin() {
  if (!admin.apps.length) admin.initializeApp({ credential: getCredential() });
  return admin;
}

function db() { return getAdmin().firestore(); }
function auth() { return getAdmin().auth(); }
function messaging() { return getAdmin().messaging(); }

async function createTempUser(prefix = 'node-test') {
  const user = await auth().createUser({
    email: `${prefix}-${Date.now()}-${Math.random().toString(36).slice(2,8)}@sehatak-test.invalid`,
    password: `NodeTest-${Date.now()}-Aa1!`,
    displayName: prefix,
  });
  return user;
}

async function deleteUser(uid) {
  try { await auth().deleteUser(uid); } catch (e) { if (e.code !== 'auth/user-not-found') throw e; }
}

async function getIdTokenForUser(uid) {
  const apiKey = process.env.FIREBASE_WEB_API_KEY;
  if (!apiKey) throw new Error('Set FIREBASE_WEB_API_KEY to exchange a custom token for a Firebase ID token');
  const customToken = await auth().createCustomToken(uid);
  const response = await fetch(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithCustomToken?key=${encodeURIComponent(apiKey)}`, {
    method: 'POST', headers: {'content-type':'application/json'}, body: JSON.stringify({token: customToken, returnSecureToken: true}),
  });
  const json = await response.json();
  if (!response.ok) throw new Error(`Identity Toolkit failed: ${json.error?.message || response.status}`);
  return json.idToken;
}

async function findRealFcmToken(uid) {
  const snap = await db().collection('users').doc(uid).get();
  const token = snap.data()?.fcmToken;
  return typeof token === 'string' && token.trim() ? token.trim() : null;
}

module.exports = { admin: getAdmin, db, auth, messaging, createTempUser, deleteUser, getIdTokenForUser, findRealFcmToken };
