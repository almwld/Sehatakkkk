// Firebase Functions production entrypoint.
// Re-export every function module so Firebase deploys all callables/triggers.
const indexFunctions = require('./index');
const labFunctions = require('./lab_functions');
const commerceFunctions = require('./commerce_functions');
const pharmacyFunctions = require('./pharmacy_marketplace_functions');
const catalogFunctions = require('./catalog_import_v2');
const chatFunctions = require('./chat_notifications');
const livekitFunctions = require('./livekit_functions');

Object.assign(
  exports,
  indexFunctions,
  labFunctions,
  commerceFunctions,
  pharmacyFunctions,
  catalogFunctions,
  chatFunctions,
  livekitFunctions,
);
