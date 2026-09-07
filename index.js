// Railway production entrypoint for Sehatak's standalone LiveKit token server.
// Railway may execute `node index.js` from the repository root.
// Keep this file at repository root so the service works even when Railway's
// Start Command is configured as `node index.js`.
console.log('Starting Sehatak LiveKit token server entrypoint');
require('./livekit-token-server/server.js');
