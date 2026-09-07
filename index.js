// Railway/Nixpacks root entrypoint for Sehatak's standalone LiveKit token server.
// Railway starts `npm start` from the repository root; the actual server lives
// under livekit-token-server so the Flutter source tree remains unchanged.
require('./livekit-token-server/server.js');
