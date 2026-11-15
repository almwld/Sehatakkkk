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

function normalizedRole(role) {
  return String(role || '').trim().toLowerCase().replace(/[\s-]+/g, '_');
}

function isAdminRole(role) {
  return ['admin', 'superadmin', 'super_admin'].includes(normalizedRole(role));
}

function isSuperAdminRole(role) {
  return ['superadmin', 'super_admin'].includes(normalizedRole(role));
}

function isPharmacyRole(role) {
  return ['pharmacy', 'pharmacist', 'pharmacyowner', 'pharmacy_owner'].includes(normalizedRole(role));
}
function isPharmacyOwner(pharmacy, uid, pharmacyId) {
  if (!pharmacy || !uid) return false;
  return [pharmacy.ownerId, pharmacy.userId, pharmacyId].some(value => String(value || '') === String(uid));
}

module.exports = { PHARMACY_ORDER_TRANSITIONS, canTransition, isPharmacyOwner, isPharmacyRole, isAdminRole, isSuperAdminRole };
