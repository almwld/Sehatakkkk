// Firebase Functions entrypoint.
// Keep the existing payment/auth functions and register lab and chat functions together.
require('./index');
require('./lab_functions');
require('./chat_notifications');
