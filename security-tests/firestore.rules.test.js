import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc } from 'firebase/firestore';

const projectId = 'demo-sehatak-firestore-security';
const rules = readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8');
let env;

before(async () => {
  env = await initializeTestEnvironment({
    projectId,
    firestore: { rules },
  });
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/patient-b'), {
      uid: 'patient-b',
      role: 'user',
      name: 'Synthetic Patient B',
      email: 'patient-b@example.invalid',
      phone: '+000000000',
      vitals: { systolic: 120 },
    });
  });
});

after(async () => {
  await env.cleanup();
});

test('a user can create a basic self-owned account', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/patient-a'), {
    uid: 'patient-a',
    role: 'user',
    name: 'Synthetic Patient A',
  }));
});

test('a user cannot self-create an admin account', async () => {
  const db = env.authenticatedContext('attacker-admin').firestore();
  await assertFails(setDoc(doc(db, 'users/attacker-admin'), {
    uid: 'attacker-admin',
    role: 'admin',
  }));
});

test('a user cannot self-create a superAdmin account', async () => {
  const db = env.authenticatedContext('attacker-super').firestore();
  await assertFails(setDoc(doc(db, 'users/attacker-super'), {
    uid: 'attacker-super',
    role: 'superAdmin',
  }));
});

test('a user can register with an explicitly unverified status', async () => {
  const db = env.authenticatedContext('doctor-pending').firestore();
  await assertSucceeds(setDoc(doc(db, 'users/doctor-pending'), {
    uid: 'doctor-pending',
    role: 'doctor',
    doctorId: 'doctor-pending',
    isVerified: false,
    verificationStatus: 'notSubmitted',
  }));
});

test('a user cannot self-assign verification or admin permission fields', async () => {
  const db = env.authenticatedContext('attacker-verified').firestore();
  await assertFails(setDoc(doc(db, 'users/attacker-verified'), {
    uid: 'attacker-verified',
    role: 'doctor',
    doctorId: 'attacker-verified',
    isVerified: true,
    adminPermissions: ['users.write'],
  }));
});

test('a user cannot promote their own existing account', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/patient-a'), {
      uid: 'patient-a',
      role: 'user',
    });
  });
  const db = env.authenticatedContext('patient-a').firestore();
  await assertFails(updateDoc(doc(db, 'users/patient-a'), { role: 'admin' }));
});

test('a user can read their own user document', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/patient-a'), {
      uid: 'patient-a',
      role: 'user',
    });
  });
  const db = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/patient-a')));
});

test('an unauthenticated user cannot read a private user document', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/patient-b')));
});
