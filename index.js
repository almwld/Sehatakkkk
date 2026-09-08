// Railway production entrypoint for Sehatak's standalone LiveKit token server.
// Railway starts this repository from its root; keep the actual server isolated
// under livekit-token-server/ while preserving the Flutter source tree.
require('./livekit-token-server/server.js');
