'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { PHARMACY_ORDER_TRANSITIONS, canTransition, isPharmacyOwner } = require('../pharmacy_order_workflow');

test('pharmacy workflow permits only the expected forward transitions', () => {
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.pending, ['confirmed', 'cancelled']);
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.confirmed, ['preparing', 'cancelled']);
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.preparing, ['ready']);
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.ready, ['delivering']);
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.delivering, ['delivered']);
});

test('transition validator rejects skipped, reversed and unknown states', () => {
  assert.equal(canTransition('pending', 'confirmed'), true);
  assert.equal(canTransition('pending', 'ready'), false);
  assert.equal(canTransition('ready', 'preparing'), false);
  assert.equal(canTransition('delivered', 'cancelled'), false);
  assert.equal(canTransition('unknown', 'confirmed'), false);
});

test('terminal order states cannot transition again', () => {
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.delivered, []);
  assert.deepEqual(PHARMACY_ORDER_TRANSITIONS.cancelled, []);
});

test('pharmacy ownership accepts only the pharmacy owner, user or exact pharmacy UID', () => {
  assert.equal(isPharmacyOwner({ ownerId: 'owner-1' }, 'owner-1', 'pharmacy-1'), true);
  assert.equal(isPharmacyOwner({ userId: 'owner-2' }, 'owner-2', 'pharmacy-1'), true);
  assert.equal(isPharmacyOwner({}, 'pharmacy-1', 'pharmacy-1'), true);
  assert.equal(isPharmacyOwner({ ownerId: 'owner-1' }, 'intruder', 'pharmacy-1'), false);
  assert.equal(isPharmacyOwner(null, 'owner-1', 'pharmacy-1'), false);
});
