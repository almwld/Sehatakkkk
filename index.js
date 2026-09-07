// Railway production entrypoint for Sehatak's standalone LiveKit token server.
// This intentionally lives at the repository root because Railway may invoke
// `node index.js` when a service has a custom start command configured.
console.log('[Sehatak] booting LiveKit token server from repository root');
require('./livekit-token-server/server.js');
