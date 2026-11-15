'use strict';

const PHARMACY_ORDER_TRANSITIONS = Object.freeze({
  pending: Object.freeze(['confirmed', 'cancelled']),
  confirmed: Object.freeze(['preparing', 'cancelled']),
  preparing: Object.freeze(['ready']),
  ready: Object.freeze(['delivering']),
  delivering: Object.freeze(['delivered']),
  delivered: Object.freeze([]),
  cancelled: Object.freeze([]),
});

function canTransition(current, next) {
  return (PHARMACY_ORDER_TRANSITIONS[String(current || '')] || []).includes(String(next || ''));
}

function isAdminRole(role) {
  return ['admin', 'superadmin'].includes(String(role || '').trim().toLowerCase());
}

function isPharmacyRole(role) {
  return ['pharmacy', 'pharmacist', 'pharmacyowner', 'pharmacy_owner'].includes(String(role || '').trim().toLowerCase());
}

function isPharmacyOwner(pharmacy, uid, pharmacyId) {
  if (!pharmacy || !uid) return false;
  return [pharmacy.ownerId, pharmacy.userId, pharmacyId].some(value => String(value || '') === String(uid));
}

module.exports = { PHARMACY_ORDER_TRANSITIONS, canTransition, isPharmacyOwner, isPharmacyRole, isAdminRole };
