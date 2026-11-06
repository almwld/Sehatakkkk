const test = require('node:test');
const assert = require('node:assert/strict');
const {publicProfileFromUser} = require('./public_profile_projection');

test('public profile contains only the approved allowlist', () => {
  const profile = publicProfileFromUser({
    uid: 'ignored-uid',
    name: 'Synthetic User',
    displayName: 'Ignored Display Name',
    email: 'private@example.invalid',
    phone: '+000000000',
    bloodType: 'O+',
    vitals: {systolic: 180},
    medicalHistory: ['private condition'],
    fcmToken: 'secret-token',
    messageSettings: {enabled: false},
    blockedPatientIds: ['patient-x'],
    role: 'doctor',
    specialty: 'Cardiology',
    hospital: 'Synthetic Hospital',
    location: 'Sanaa',
    rating: 4.5,
    reviewsCount: 12,
    isVerified: true,
  }, 'user-123');

  assert.deepEqual(Object.keys(profile).sort(), [
    'bio', 'hospital', 'isDoctor', 'isVerified', 'location', 'name',
    'photoUrl', 'role', 'specialty', 'uid',
  ].sort());
  assert.equal(profile.uid, 'user-123');
  assert.equal(profile.name, 'Synthetic User');
  assert.equal(profile.isDoctor, true);
  assert.equal(profile.isVerified, true);
  for (const privateField of [
    'email', 'phone', 'bloodType', 'vitals', 'medicalHistory',
    'fcmToken', 'messageSettings', 'blockedPatientIds',
  ]) {
    assert.equal(Object.hasOwn(profile, privateField), false, privateField);
  }
});

test('public profile sanitizes types and limits text fields', () => {
  const profile = publicProfileFromUser({
    name: 'x'.repeat(150),
    bio: 'y'.repeat(700),
    rating: '5',
    reviewsCount: -4,
  }, 'user-456');

  assert.equal(profile.name.length, 100);
  assert.equal(profile.bio.length, 500);
  assert.equal(Object.hasOwn(profile, 'rating'), false);
  assert.equal(Object.hasOwn(profile, 'reviewsCount'), false);
  assert.equal(profile.role, 'user');
});
