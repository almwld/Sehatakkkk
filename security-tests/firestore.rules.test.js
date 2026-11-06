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
    await setDoc(doc(db, 'users/patient-b/medications/rx-1'), {
      name: 'Synthetic medication',
      dose: '1 tablet',
    });
    await setDoc(doc(db, 'public_profiles/patient-b'), {
      uid: 'patient-b',
      name: 'Synthetic Patient B',
      photoUrl: '',
      bio: 'Public test profile',
      role: 'user',
      isVerified: false,
    });
    await setDoc(doc(db, 'users/platform-admin'), {
      uid: 'platform-admin',
      role: 'admin',
      name: 'Synthetic Admin',
    });
    await setDoc(doc(db, 'shared_records/share-1'), {
      recordId: 'record-1',
      sharedBy: 'patient-a',
      sharedWith: 'patient-b',
      status: 'pending',
    });
    await setDoc(doc(db, 'chats/chat-1'), {
      participants: ['patient-a', 'patient-b'],
    });
    await setDoc(doc(db, 'chats/chat-1/presence/patient-b'), {
      isOnline: true,
      lastSeen: new Date(),
      updatedAt: new Date(),
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

test('an unrelated signed-in user cannot read another private user document', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertFails(getDoc(doc(db, 'users/patient-b')));
});

test('a trusted admin can read user documents for platform operations', async () => {
  const db = env.authenticatedContext('platform-admin').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/patient-b')));
});

test('an unauthenticated user cannot read a private user document', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'users/patient-b')));
});

test('public profile projection is readable to authenticated users', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(getDoc(doc(db, 'public_profiles/patient-b')));
});

test('public profile projection is not exposed to unauthenticated clients', async () => {
  const db = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(db, 'public_profiles/patient-b')));
});

test('clients cannot write public profile projections', async () => {
  const db = env.authenticatedContext('patient-b').firestore();
  await assertFails(updateDoc(doc(db, 'public_profiles/patient-b'), {
    name: 'Forged public name',
  }));
});

test('only participants can read a shared-record request', async () => {
  const sender = env.authenticatedContext('patient-a').firestore();
  const recipient = env.authenticatedContext('patient-b').firestore();
  const outsider = env.authenticatedContext('patient-c').firestore();
  await assertSucceeds(getDoc(doc(sender, 'shared_records/share-1')));
  await assertSucceeds(getDoc(doc(recipient, 'shared_records/share-1')));
  await assertFails(getDoc(doc(outsider, 'shared_records/share-1')));
});

test('clients cannot create shared-record requests directly', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertFails(setDoc(doc(db, 'shared_records/share-2'), {
    recordId: 'record-2',
    sharedBy: 'patient-a',
    sharedWith: 'patient-b',
    status: 'pending',
  }));
});

test('chat participants can read scoped presence but outsiders cannot', async () => {
  const participant = env.authenticatedContext('patient-a').firestore();
  const outsider = env.authenticatedContext('patient-c').firestore();
  await assertSucceeds(getDoc(doc(participant, 'chats/chat-1/presence/patient-b')));
  await assertFails(getDoc(doc(outsider, 'chats/chat-1/presence/patient-b')));
});

test('a chat participant can write only their own presence document', async () => {
  const owner = env.authenticatedContext('patient-b').firestore();
  const peer = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(setDoc(doc(owner, 'chats/chat-1/presence/patient-b'), {
    isOnline: false,
    updatedAt: new Date(),
  }));
  await assertFails(setDoc(doc(peer, 'chats/chat-1/presence/patient-b'), {
    isOnline: false,
    updatedAt: new Date(),
  }));
});

test('an unrelated signed-in user cannot read another private user document', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertFails(getDoc(doc(db, 'users/patient-b')));
});

test('an approved admin can read user documents for administration', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/admin-1'), {
      uid: 'admin-1',
      role: 'admin',
    });
  });
  const db = env.authenticatedContext('admin-1').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/patient-b')));
});

test('private medication subcollections are owner-only', async () => {
  const owner = env.authenticatedContext('patient-b').firestore();
  const outsider = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(getDoc(doc(owner, 'users/patient-b/medications/rx-1')));
  await assertFails(getDoc(doc(outsider, 'users/patient-b/medications/rx-1')));
});
