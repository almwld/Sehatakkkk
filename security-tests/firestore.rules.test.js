import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import { collection, doc, getDoc, getDocs, setDoc, updateDoc, writeBatch } from 'firebase/firestore';

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
    await setDoc(doc(db, 'users/platform-super-admin'), {
      uid: 'platform-super-admin',
      role: 'superAdmin',
      name: 'Synthetic Super Admin',
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
    await setDoc(doc(db, 'users/patient-b/following/patient-c'), {
      userId: 'patient-c',
      createdAt: new Date(),
    });
  });
});

after(async () => {
  await env.cleanup();
});

test('hospital owners can toggle operating state but cannot change verification or publication fields', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/hospital-1'), { uid: 'hospital-1', role: 'hospital' });
    await setDoc(doc(db, 'hospitals/hospital-1'), { name: 'Synthetic Hospital', isOpen: true, status: 'approved', isPublished: true });
  });
  const owner = env.authenticatedContext('hospital-1').firestore();
  await assertSucceeds(updateDoc(doc(owner, 'hospitals/hospital-1'), { isOpen: false }));
  await assertFails(updateDoc(doc(owner, 'hospitals/hospital-1'), { status: 'pending_review', isPublished: false }));
});

test('hospital owners can manage only their own departments', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/hospital-1'), { uid: 'hospital-1', role: 'hospital' });
    await setDoc(doc(db, 'users/hospital-2'), { uid: 'hospital-2', role: 'hospital' });
  });
  const owner = env.authenticatedContext('hospital-1').firestore();
  const otherOwner = env.authenticatedContext('hospital-2').firestore();
  await assertSucceeds(setDoc(doc(owner, 'hospital_departments/department-1'), { hospitalId: 'hospital-1', name: 'Emergency', isActive: true }));
  await assertSucceeds(updateDoc(doc(owner, 'hospital_departments/department-1'), { isActive: false }));
  await assertFails(updateDoc(doc(otherOwner, 'hospital_departments/department-1'), { isActive: false }));
  await assertFails(setDoc(doc(owner, 'hospital_departments/forged-owner'), { hospitalId: 'hospital-2', name: 'Forged', isActive: true }));
});

test('hospital staff directory exposes only explicitly public staff profiles', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'hospital_staff/staff-public'), {
      hospitalId: 'hospital-1',
      displayName: 'Synthetic Public Clinician',
      jobTitle: 'Consultant',
      isPublic: true,
    });
    await setDoc(doc(db, 'hospital_staff/staff-private'), {
      hospitalId: 'hospital-1',
      displayName: 'Synthetic Private Employee',
      personalPhone: '+000000000',
      isPublic: false,
    });
  });
  const publicDb = env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(publicDb, 'hospital_staff/staff-public')));
  await assertFails(getDoc(doc(publicDb, 'hospital_staff/staff-private')));
  await assertFails(setDoc(doc(publicDb, 'hospital_staff/forged'), {
    hospitalId: 'hospital-1',
    displayName: 'Forged Profile',
    isPublic: true,
  }));
});

test('hospital owners can read and update only the status of their hospital bookings', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/hospital-1'), { uid: 'hospital-1', role: 'hospital' });
    await setDoc(doc(db, 'bookings/booking-1'), { userId: 'patient-b', providerId: 'hospital-1', type: 'hospital', status: 'pending' });
  });
  const owner = env.authenticatedContext('hospital-1').firestore();
  const outsider = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(getDoc(doc(owner, 'bookings/booking-1')));
  await assertSucceeds(updateDoc(doc(owner, 'bookings/booking-1'), { status: 'confirmed' }));
  await assertFails(updateDoc(doc(owner, 'bookings/booking-1'), { amount: 999999 }));
  await assertFails(getDoc(doc(outsider, 'bookings/booking-1')));
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

test('an admin cannot promote themselves to superAdmin', async () => {
  const db = env.authenticatedContext('platform-admin').firestore();
  await assertFails(updateDoc(doc(db, 'users/platform-admin'), {
    role: 'superAdmin',
  }));
});

test('an admin can update non-privileged user profile fields', async () => {
  const db = env.authenticatedContext('platform-admin').firestore();
  await assertSucceeds(updateDoc(doc(db, 'users/patient-b'), {
    name: 'Admin corrected display name',
  }));
});

test('a superAdmin can assign a privileged role', async () => {
  const db = env.authenticatedContext('platform-super-admin').firestore();
  await assertSucceeds(updateDoc(doc(db, 'users/patient-b'), {
    role: 'admin',
  }));
});

test('a trusted admin can read user documents for platform operations', async () => {
  const db = env.authenticatedContext('platform-admin').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/patient-b')));
});

test('an ordinary user cannot list the users collection', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertFails(getDocs(collection(db, 'users')));
});

test('an approved admin can list user documents', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'users/admin-list'), {
      uid: 'admin-list',
      role: 'admin',
    });
  });
  const db = env.authenticatedContext('admin-list').firestore();
  await assertSucceeds(getDocs(collection(db, 'users')));
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

test('authenticated users can read public social-graph edges', async () => {
  const db = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(getDoc(doc(db, 'users/patient-b/following/patient-c')));
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

test('delivery companies are publicly readable but only admins can manage them', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'delivery_companies/company-1'), {
      name: 'Synthetic delivery provider',
      isActive: true,
      coveredAreas: ['Sanaa'],
    });
  });
  const publicDb = env.unauthenticatedContext().firestore();
  const patientDb = env.authenticatedContext('patient-b').firestore();
  const adminDb = env.authenticatedContext('platform-admin').firestore();
  await assertSucceeds(getDoc(doc(publicDb, 'delivery_companies/company-1')));
  await assertFails(updateDoc(doc(patientDb, 'delivery_companies/company-1'), { isActive: false }));
  await assertSucceeds(updateDoc(doc(adminDb, 'delivery_companies/company-1'), { isActive: false }));
});

test('delivery tracking is readable only by the owner of its linked order', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'orders/order-1'), { userId: 'patient-b', total: 5000 });
    await setDoc(doc(db, 'delivery_companies/company-1'), { ownerId: 'delivery-owner', isActive: true });
    await setDoc(doc(db, 'deliveries/order-1'), { status: 'shipping', currentStep: 2, companyId: 'company-1' });
  });
  const owner = env.authenticatedContext('patient-b').firestore();
  const outsider = env.authenticatedContext('patient-a').firestore();
  const admin = env.authenticatedContext('platform-admin').firestore();
  const deliveryOwner = env.authenticatedContext('delivery-owner').firestore();
  const anonymous = env.unauthenticatedContext().firestore();
  await assertSucceeds(getDoc(doc(owner, 'deliveries/order-1')));
  await assertSucceeds(getDoc(doc(deliveryOwner, 'deliveries/order-1')));
  await assertFails(getDoc(doc(outsider, 'deliveries/order-1')));
  await assertFails(getDoc(doc(anonymous, 'deliveries/order-1')));
  await assertFails(updateDoc(doc(owner, 'deliveries/order-1'), { status: 'delivered' }));
  await assertSucceeds(updateDoc(doc(admin, 'deliveries/order-1'), { status: 'delivered' }));
});

test('pharmacy order reads are scoped to patient and assigned pharmacy owner; clients cannot fulfil orders', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'pharmacies/pharmacy-1'), { ownerId: 'pharmacy-owner', status: 'approved', isActive: true });
    await setDoc(doc(db, 'orders/order-1'), { userId: 'patient-b', pharmacyId: 'pharmacy-1', providerId: 'pharmacy-owner', type: 'pharmacy', status: 'pending', total: 500 });
    await setDoc(doc(db, 'orders/order-paid'), { userId: 'patient-b', pharmacyId: 'pharmacy-1', providerId: 'pharmacy-owner', type: 'pharmacy', status: 'pending', paymentStatus: 'paid', total: 500 });
  });
  const patient = env.authenticatedContext('patient-b').firestore();
  const owner = env.authenticatedContext('pharmacy-owner').firestore();
  const outsider = env.authenticatedContext('patient-a').firestore();
  const admin = env.authenticatedContext('platform-admin').firestore();
  await assertSucceeds(getDoc(doc(patient, 'orders/order-1')));
  await assertSucceeds(getDoc(doc(owner, 'orders/order-1')));
  await assertFails(getDoc(doc(outsider, 'orders/order-1')));
  await assertFails(updateDoc(doc(owner, 'orders/order-1'), { status: 'confirmed' }));
  await assertFails(updateDoc(doc(patient, 'orders/order-1'), { status: 'confirmed' }));
  await assertSucceeds(updateDoc(doc(patient, 'orders/order-1'), { status: 'cancelled' }));
  await assertFails(updateDoc(doc(patient, 'orders/order-paid'), { status: 'cancelled' }));
  await assertSucceeds(updateDoc(doc(admin, 'orders/order-1'), { status: 'confirmed' }));
});

test('prescription review is private to patient and linked pharmacy and cannot be forged by patient', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'pharmacies/pharmacy-1'), { ownerId: 'pharmacy-owner', status: 'approved', isActive: true });
    await setDoc(doc(db, 'prescriptions/prescription-1'), { userId: 'patient-b', patientId: 'patient-b', pharmacyId: 'pharmacy-1', status: 'pending', fileRemotePath: 'Sehatak/prescriptions_patient-b/prescription-1/file.pdf' });
  });
  const patient = env.authenticatedContext('patient-b').firestore();
  const owner = env.authenticatedContext('pharmacy-owner').firestore();
  const outsider = env.authenticatedContext('patient-a').firestore();
  await assertSucceeds(getDoc(doc(patient, 'prescriptions/prescription-1')));
  await assertSucceeds(getDoc(doc(owner, 'prescriptions/prescription-1')));
  await assertFails(getDoc(doc(outsider, 'prescriptions/prescription-1')));
  await assertFails(updateDoc(doc(owner, 'prescriptions/prescription-1'), { status: 'approved' }));
  await assertFails(setDoc(doc(patient, 'prescriptions/forged-approved'), { userId: 'patient-b', patientId: 'patient-b', pharmacyId: 'pharmacy-1', status: 'approved' }));
  await assertSucceeds(setDoc(doc(patient, 'prescriptions/prescription-2'), { userId: 'patient-b', patientId: 'patient-b', pharmacyId: 'pharmacy-1', status: 'pending' }));
});

test('blood donor registration is tied to the signed-in account', async () => {
  const owner = env.authenticatedContext('patient-b').firestore();
  const other = env.authenticatedContext('patient-a').firestore();
  const anonymous = env.unauthenticatedContext().firestore();
  await assertFails(setDoc(doc(anonymous, 'blood_donors/anonymous'), { name: 'Donor', phone: '000', age: 25, bloodType: 'O+', city: 'Sanaa' }));
  await assertFails(setDoc(doc(owner, 'blood_donors/missing-owner'), { name: 'Donor', phone: '000', age: 25, bloodType: 'O+', city: 'Sanaa' }));
  await assertSucceeds(setDoc(doc(owner, 'blood_donors/owned'), { userId: 'patient-b', name: 'Donor', phone: '000', age: 25, bloodType: 'O+', city: 'Sanaa' }));
  await assertFails(updateDoc(doc(other, 'blood_donors/owned'), { phone: '111' }));
  await assertSucceeds(getDoc(doc(other, 'blood_donors/owned')));
});

test('community publishing is restricted to verified doctors', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, 'users/doctor-1'), { uid: 'doctor-1', role: 'doctor', isVerified: true });
    await setDoc(doc(db, 'users/patient-b'), { uid: 'patient-b', role: 'patient', isVerified: false });
  });
  const doctor = env.authenticatedContext('doctor-1').firestore();
  const patient = env.authenticatedContext('patient-b').firestore();
  await assertSucceeds(setDoc(doc(doctor, 'community_posts/doctor-post'), { userId: 'doctor-1', title: 'Health note', content: 'Educational content', isPublished: true, likes: 0, comments: 0, shares: 0 }));
  await assertFails(setDoc(doc(patient, 'community_posts/patient-post'), { userId: 'patient-b', title: 'Post', content: 'Not authorized', isPublished: true }));
});

test('community likes require an atomic owned liked-post edge and counters only increment by one', async () => {
  await env.withSecurityRulesDisabled(async (context) => {
    await setDoc(doc(context.firestore(), 'community_posts/post-1'), { userId: 'doctor-1', title: 'Post', likes: 0, comments: 0, shares: 0 });
  });
  const patient = env.authenticatedContext('patient-b').firestore();
  const other = env.authenticatedContext('patient-a').firestore();
  const postRef = doc(patient, 'community_posts/post-1');
  const likeRef = doc(patient, 'users/patient-b/liked_posts/post-1');
  await assertFails(updateDoc(postRef, { likes: 1 }));
  const likeBatch = writeBatch(patient);
  likeBatch.set(likeRef, { postId: 'post-1' });
  likeBatch.update(postRef, { likes: 1 });
  await assertSucceeds(likeBatch.commit());
  const unlikeBatch = writeBatch(patient);
  unlikeBatch.delete(likeRef);
  unlikeBatch.update(postRef, { likes: 0 });
  await assertSucceeds(unlikeBatch.commit());
  await assertFails(updateDoc(doc(other, 'community_posts/post-1'), { shares: 50 }));
  await assertSucceeds(updateDoc(doc(other, 'community_posts/post-1'), { shares: 1 }));
  await assertSucceeds(updateDoc(doc(other, 'community_posts/post-1'), { comments: 1 }));
});
