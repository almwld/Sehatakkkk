// Firebase Functions entrypoint.
// Keep all trusted backend functions registered from one production entrypoint.
require('./index');
require('./lab_functions');
require('./chat_notifications');
require('./livekit_functions');
