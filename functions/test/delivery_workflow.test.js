'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const { DELIVERY_TRANSITIONS, canDeliveryTransition, isDeliveryCompanyOwner } = require('../delivery_workflow');

test('delivery transitions are sequential and terminal after delivery', () => {
  assert.deepEqual(DELIVERY_TRANSITIONS.assigned, ['picked_up']);
  assert.deepEqual(DELIVERY_TRANSITIONS.picked_up, ['in_transit']);
  assert.deepEqual(DELIVERY_TRANSITIONS.in_transit, ['delivered']);
  assert.deepEqual(DELIVERY_TRANSITIONS.delivered, []);
  assert.equal(canDeliveryTransition('assigned', 'picked_up'), true);
  assert.equal(canDeliveryTransition('assigned', 'delivered'), false);
  assert.equal(canDeliveryTransition('delivered', 'in_transit'), false);
});

test('only the mapped delivery company owner may update a delivery', () => {
  assert.equal(isDeliveryCompanyOwner({ownerId:'courier-owner'}, 'courier-owner', 'company-1'), true);
  assert.equal(isDeliveryCompanyOwner({userId:'courier-user'}, 'courier-user', 'company-1'), true);
  assert.equal(isDeliveryCompanyOwner({}, 'company-1', 'company-1'), true);
  assert.equal(isDeliveryCompanyOwner({ownerId:'courier-owner'}, 'intruder', 'company-1'), false);
});
