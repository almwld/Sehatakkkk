const {onDocumentWritten} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

const {publicProfileFromUser} = require('./public_profile_projection');

exports.syncPublicProfile = onDocumentWritten(
  {document: 'users/{userId}', region: 'us-central1'},
  async (event) => {
    const uid = event.params.userId;
    const after = event.data && event.data.after;
    const profileRef = db.collection('public_profiles').doc(uid);

    if (!after || !after.exists) {
      await profileRef.delete().catch((error) => {
        if (error.code !== 5) throw error;
      });
      return;
    }

    const source = after.data() || {};
    await profileRef.set(publicProfileFromUser(source, uid), {merge: false});
  },
);
