const test = require('node:test');
const assert = require('node:assert/strict');
const {appointmentInstantFromDateMarker} = require('./appointment-date');

test('uses the selected clinic date and timezone, not the noon marker as appointment time', () => {
  const marker = new Date('2026-11-07T09:00:00.000Z'); // 12:00 in Asia/Aden
  const appointment = appointmentInstantFromDateMarker(marker, '18:30', 'Asia/Aden');
  assert.equal(appointment.toISOString(), '2026-11-07T15:30:00.000Z');
});

test('rejects malformed time values', () => {
  const marker = new Date('2026-11-07T09:00:00.000Z');
  assert.throws(() => appointmentInstantFromDateMarker(marker, '24:00', 'Asia/Aden'), /Invalid appointment time/);
});

test('handles early clinic hours without changing the stored clinic date marker', () => {
  const marker = new Date('2026-11-07T09:00:00.000Z');
  const appointment = appointmentInstantFromDateMarker(marker, '01:15', 'Asia/Aden');
  assert.equal(appointment.toISOString(), '2026-11-06T22:15:00.000Z');
  assert.equal(marker.getUTCDay(), 6);
});
