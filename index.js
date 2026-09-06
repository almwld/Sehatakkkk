// Railway/Nixpacks root entrypoint for the standalone LiveKit token server.
// The Flutter application remains the main repository project; this entrypoint
// exists so a Railway service rooted at the repository can start correctly.
// Railway runs `npm start`, which resolves to this file from the root package.json.
require('./livekit-token-server/server.js');
