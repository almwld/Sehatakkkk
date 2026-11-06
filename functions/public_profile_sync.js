const {onDocumentWritten} = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

function stringOrEmpty(value, maxLength) {
  return typeof value === 'string' ? value.trim().slice(0, maxLength) : '';
}

function numberOrZero(value) {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

function publicProfileFromUser(data, uid) {
  const role = stringOrEmpty(data.role, 40) || 'user';
  return {
    uid,
    name: stringOrEmpty(data.name || data.displayName, 100) || 'مستخدم',
    photoUrl: stringOrEmpty(data.photoUrl || data.avatar, 2048),
    bio: stringOrEmpty(data.bio, 500),
    role,
    specialty: stringOrEmpty(data.specialty, 120),
    hospital: stringOrEmpty(data.hospital, 160),
    location: stringOrEmpty(data.location || data.city, 160),
    rating: numberOrZero(data.rating),
    reviewsCount: Math.max(0, Math.trunc(numberOrZero(data.reviewsCount || data.reviewCount))),
    isDoctor: role === 'doctor' || data.isDoctor === true,
    // A profile may show verification only when the trusted verification flow set it.
    isVerified: data.isVerified === true,
    updatedAt: FieldValue.serverTimestamp(),
  };
}

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
