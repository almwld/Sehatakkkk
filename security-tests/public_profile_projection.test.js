import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const {publicProfileFromUser} = require('../functions/public_profile_projection.js');

test('public profile projection contains only approved display fields', () => {
  const projection = publicProfileFromUser({
    name: 'Test Patient',
    email: 'private@example.invalid',
    phone: '+000000000',
    role: 'doctor',
    specialty: 'Cardiology',
    isVerified: true,
    isOnline: true,
    vitals: {systolic: 180},
    medicalHistory: ['private diagnosis'],
    fcmToken: 'secret-token',
    messageSettings: {enabled: false},
    blockedPatientIds: ['patient-2'],
  }, 'doctor-1');

  assert.equal(projection.uid, 'doctor-1');
  assert.equal(projection.name, 'Test Patient');
  assert.equal(projection.role, 'doctor');
  assert.equal(projection.isVerified, true);
  for (const privateKey of [
    'email', 'phone', 'isOnline', 'vitals', 'medicalHistory',
    'fcmToken', 'messageSettings', 'blockedPatientIds',
  ]) {
    assert.equal(Object.hasOwn(projection, privateKey), false, `leaked ${privateKey}`);
  }
});

test('public profile projection sanitizes optional values', () => {
  const projection = publicProfileFromUser({
    name: 123,
    rating: '5',
    reviewsCount: -3,
  }, 'user-1');

  assert.equal(projection.name, 'مستخدم');
  assert.equal(projection.rating, 0);
  assert.equal(projection.reviewsCount, 0);
});
