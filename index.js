// Railway production entrypoint for Sehatak's standalone LiveKit token server.
// Railway may start Node services from the repository root with `node index.js`.
// This shim intentionally delegates to the real service implementation.
require('./livekit-token-server/server.js');
