// Railway/Nixpacks root entrypoint for Sehatak's standalone LiveKit token server.
// Railway deployments may default to `node index.js`; keep this entrypoint at
// the repository root and delegate to the isolated token-server implementation.
require('./livekit-token-server/server.js');
