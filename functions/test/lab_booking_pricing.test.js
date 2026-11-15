const test = require('node:test');
const assert = require('node:assert/strict');
const { resolveLabBookingPricing } = require('../lab_booking_pricing');

const lab = {
  tests: [
    { id: 'cbc', name: 'CBC', price: 1500 },
    { id: 'glucose', name: 'Glucose', price: 700.25 },
  ],
};

test('lab payment pricing is calculated from the trusted lab catalog, not client totals', () => {
  const result = resolveLabBookingPricing(lab, {
    testIds: ['cbc', 'glucose'],
    totalPrice: 1,
    total: 0.01,
    tests: [{ id: 'cbc', name: 'Forged', price: 0.01 }],
  });
  assert.equal(result.total, 2200.25);
  assert.deepEqual(result.tests, [
    { id: 'cbc', name: 'CBC', price: 1500 },
    { id: 'glucose', name: 'Glucose', price: 700.25 },
  ]);
});

test('lab pricing derives test IDs from legacy booking item objects', () => {
  const result = resolveLabBookingPricing(lab, {
    tests: [{ id: 'cbc', price: 1 }, { id: 'glucose', price: 1 }],
  });
  assert.equal(result.total, 2200.25);
});

test('lab pricing rejects unknown or missing test IDs', () => {
  assert.throws(() => resolveLabBookingPricing(lab, { testIds: ['unknown'] }));
  assert.throws(() => resolveLabBookingPricing(lab, { totalPrice: 1 }));
});

test('lab pricing rejects invalid trusted catalog prices', () => {
  assert.throws(() => resolveLabBookingPricing({ tests: [{ id: 'bad', price: 'NaN' }] }, {
    testIds: ['bad'],
  }));
});
