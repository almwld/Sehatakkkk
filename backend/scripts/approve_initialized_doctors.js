/**
 * Approve the platform doctor accounts that were intentionally initialized
 * by the Sehatak doctor bootstrap process.
 *
 * Run from the backend directory with Firebase Admin credentials available
 * through the normal Admin SDK environment. No passwords are stored here.
 *
 *   node scripts/approve_initialized_doctors.js
 */

const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

const doctors = [
  {
    doctorId: 'doctor_1',
    uid: 'zV2MoRJQCDZKa1I25dw9oU01f5e2',
  },
  {
    doctorId: 'doctor_asmaa_alhindi',
    uid: 'ncwyV4bPD3M7LCQgejbtO98Kva43',
  },
  {
    doctorId: 'doctor_hamed_dhamran',
    uid: 'seDjgSFGzFMJWDYDLPLURk9Q5wg2',
  },
  {
    doctorId: 'doctor_khaled_alkahlani',
    uid: '8UDTqFdcBugyMOMx3gm85McLybC3',
  },
];

async function main() {
  const batch = db.batch();

  for (const doctor of doctors) {
    const doctorRef = db.collection('doctors').doc(doctor.doctorId);
    const userRef = db.collection('users').doc(doctor.uid);

    batch.set(
      doctorRef,
      {
        userId: doctor.uid,
        isVerified: true,
        verificationStatus: 'approved',
        isAvailable: true,
        isOnline: false,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );

    batch.set(
      userRef,
      {
        uid: doctor.uid,
        doctorId: doctor.doctorId,
        role: 'doctor',
        isVerified: true,
        verificationStatus: 'approved',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
  }

  await batch.commit();
  console.log(`Approved ${doctors.length} initialized Sehatak doctors.`);
}

main().catch((error) => {
  console.error('Doctor approval migration failed:', error);
  process.exitCode = 1;
});
