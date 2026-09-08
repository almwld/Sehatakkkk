# Sehatak Chat V2

## Target
Upgrade the existing health-chat UX without replacing its Firebase/MessagesBloc/Nextcloud/LiveKit integrations.

## Required behavior
- Empty composer: local microphone asset.
- Non-empty composer: animated transition to local send asset.
- Clearing text reverses the animation.
- Long press on empty microphone starts recording; release sends; cancel action deletes recording.
- Local chat assets are used for composer/attachment actions.
- Media remains first-class timeline messages, not just text placeholders.
- Existing verified-doctor chat flow and health-specific actions remain intact.
- Text sending continues through ReliableMessageService.
- Media writes use an atomic Firestore batch for message + chat metadata.

## Media types
text, image, video, audio, file, location, call, system.

## Important integration rule
Do not replace ChatRoomScreen or MessagesBloc with a demo screen. The UI must remain attached to the production Firebase conversation stream.

## Current implementation note
`chat_input_bar_v2.dart` contains the new composer behavior and local-asset references. It is intentionally separate until the call/media integrations are validated and then should replace the old composer atomically.
