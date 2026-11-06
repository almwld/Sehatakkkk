const {
  initializeApp,
  cert,
  applicationDefault,
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

function initializeFirebase() {
  if (initialized || getApps().length > 0) {
    initialized = true;
    return;
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (!projectId) {
    throw new Error('FIREBASE_PROJECT_ID is required');
  }
  if (Boolean(clientEmail) !== Boolean(privateKey)) {
    throw new Error('FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY must be provided together');
  }

  // Support both explicit service-account fields and the documented
  // GOOGLE_APPLICATION_CREDENTIALS / platform ADC deployment flow.
  const credential = clientEmail && privateKey
    ? cert({
        projectId,
        clientEmail,
        privateKey: privateKey.replace(/\\n/g, '\n'),
      })
    : applicationDefault();

  try {
    initializeApp({
      credential,
      projectId,
      storageBucket:
          process.env.FIREBASE_STORAGE_BUCKET || undefined,
    });

    initialized = true;
    console.log('✅ Firebase Admin SDK initialized successfully');
  } catch (error) {
    console.error('❌ Firebase initialization error:', error);
    throw error;
  }
}

function getFirestore() {
  initializeFirebase();
  return getAdminFirestore();
}

function getAuth() {
  initializeFirebase();
  return getAdminAuth();
}

function getStorage() {
  initializeFirebase();
  return getAdminStorage();
}

function getMessaging() {
  initializeFirebase();
  return getAdminMessaging();
}

module.exports = {
  initializeFirebase,
  getFirestore,
  getAuth,
  getStorage,
  getMessaging,
};
