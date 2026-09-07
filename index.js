// Railway production entrypoint for Sehatak's standalone LiveKit token server.
// Some Railway services are configured with the default `node index.js` command.
// Keep this tiny shim at repository root so that command always reaches the
// actual token service under livekit-token-server/server.js.
require('./livekit-token-server/server.js');
