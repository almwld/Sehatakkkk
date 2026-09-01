const admin = require('firebase-admin');

let initialized = false;

function initializeFirebase() {
  if (initialized) return;

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error(
      'FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY are required'
    );
  }

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId,
      clientEmail,
      privateKey: privateKey.replace(/\\n/g, '\n'),
    }),
  });

  initialized = true;
}

function getFirestore() {
  initializeFirebase();
  return admin.firestore();
}

function getAuth() {
  initializeFirebase();
  return admin.auth();
}

module.exports = {
  admin,
  initializeFirebase,
  getFirestore,
  getAuth,
};
