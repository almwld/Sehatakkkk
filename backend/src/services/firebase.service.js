const {
  initializeApp,
  cert,
  getApps,
} = require('firebase-admin/app');

const {
  getFirestore: getAdminFirestore,
} = require('firebase-admin/firestore');

const {
  getAuth: getAdminAuth,
} = require('firebase-admin/auth');

const {
  getStorage: getAdminStorage,
} = require('firebase-admin/storage');

const {
  getMessaging: getAdminMessaging,
} = require('firebase-admin/messaging');

let initialized = false;

/*
|--------------------------------------------------------------------------
| Initialize Firebase Admin
|--------------------------------------------------------------------------
*/

function initializeFirebase() {
  if (initialized || getApps().length > 0) {
    initialized = true;
    return;
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId || !clientEmail || !privateKey) {
    throw new Error(
      'FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY are required'
    );
  }

  try {
    initializeApp({
      credential: cert({
        projectId,
        clientEmail,
        privateKey: privateKey.replace(/\\n/g, '\n'),
      }),
      projectId,
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET || undefined,
    });

    initialized = true;

    console.log('Firebase Admin SDK initialized successfully');
  } catch (error) {
    console.error('Firebase initialization error:', error);
    throw error;
  }
}

/*
|--------------------------------------------------------------------------
| Firestore
|--------------------------------------------------------------------------
*/

function getFirestore() {
  initializeFirebase();
  return getAdminFirestore();
}

/*
|--------------------------------------------------------------------------
| Firebase Auth
|--------------------------------------------------------------------------
*/

function getAuth() {
  initializeFirebase();
  return getAdminAuth();
}

/*
|--------------------------------------------------------------------------
| Firebase Storage
|--------------------------------------------------------------------------
*/

function getStorage() {
  initializeFirebase();
  return getAdminStorage();
}

/*
|--------------------------------------------------------------------------
| Export
|--------------------------------------------------------------------------
*/

module.exports = {
  initializeFirebase,
  getFirestore,
  getAuth,
  getStorage,
  getMessaging,
};
