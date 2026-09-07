// Railway production entrypoint for Sehatak's standalone LiveKit token server.
// Railway may execute `node index.js` from the repository root.
console.log('Starting Sehatak LiveKit token server entrypoint');
require('./livekit-token-server/server.js');
