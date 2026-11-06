const admin = require('firebase-admin');
const {publicProfileFromUser} = require('../public_profile_projection');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.GCLOUD_PROJECT || 'sehatak-platform',
  });
}

const db = admin.firestore();
const apply = process.argv.includes('--apply');
const pageSize = 400;

async function main() {
  if (!apply) {
    console.log('DRY RUN: no Firestore documents will be written. Pass --apply to execute.');
  }

  let cursor = null;
  let scanned = 0;
  let written = 0;

  while (true) {
    let query = db.collection('users')
      .orderBy(admin.firestore.FieldPath.documentId())
      .limit(pageSize);
    if (cursor) query = query.startAfter(cursor);

    const page = await query.get();
    if (page.empty) break;

    if (apply) {
      const batch = db.batch();
      for (const userDoc of page.docs) {
        const projection = publicProfileFromUser(userDoc.data() || {}, userDoc.id);
        batch.set(db.collection('public_profiles').doc(userDoc.id), {
          ...projection,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        }, {merge: false});
      }
      await batch.commit();
      written += page.size;
    }

    scanned += page.size;
    cursor = page.docs[page.docs.length - 1];
    console.log(`Scanned ${scanned} user records; ${apply ? written : 0} public profiles written.`);
    if (page.size < pageSize) break;
  }

  console.log(JSON.stringify({projectId: process.env.GCLOUD_PROJECT || 'sehatak-platform', scanned, written, dryRun: !apply}));
}

main().catch((error) => {
  console.error('Public profile migration failed:', error.message);
  process.exitCode = 1;
});
