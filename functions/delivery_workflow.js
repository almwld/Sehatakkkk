'use strict';

const DELIVERY_TRANSITIONS = Object.freeze({
  assigned: Object.freeze(['picked_up']),
  picked_up: Object.freeze(['in_transit']),
  in_transit: Object.freeze(['delivered']),
  delivered: Object.freeze([]),
});

function canDeliveryTransition(current, next) {
  return (DELIVERY_TRANSITIONS[String(current || '')] || []).includes(String(next || ''));
}

function isDeliveryCompanyOwner(company, uid, companyId) {
  if (!company || !uid) return false;
  return [company.ownerId, company.userId].some(value => String(value || '') === String(uid))
    || String(companyId || '') === String(uid);
}

module.exports = { DELIVERY_TRANSITIONS, canDeliveryTransition, isDeliveryCompanyOwner };
