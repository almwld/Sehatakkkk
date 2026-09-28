# Sehatak FCM payload contracts

## Message notifications

**Producer:** Firebase Cloud Function `notifyNewChatMessage` on `chats/{chatId}/messages/{messageId}`.

**Transport:** data-only FCM.

Required data:
- `type=new_message`
- `chatId`
- `messageId`
- `senderId`
- `senderName`
- `recipientId`
- `messageType`
- `body`
- `title`

Optional media data:
- `senderPhotoUrl`
- `imageUrl`
- `videoUrl`
- `audioUrl`
- `fileUrl`
- `fileName`
- `fileMimeType`
- `fileSize`

The Flutter client writes chat messages directly to Firestore; therefore the Firestore trigger is the single FCM producer. The backend chat API no longer sends message FCM.

## Incoming-call notifications

**Producer:** Railway LiveKit token server `POST /call-notification`.

**Transport:** high-priority data-only FCM.

Required data:
- `type=incoming_call`
- `callId`
- `chatId`
- `callerId`
- `receiverId`
- `userId` (receiver UID)
- `callerName`
- `isVideo`
- `callType`

The Firebase Function `notifyIncomingCall` is intentionally disabled so a call document cannot create a second FCM notification.

## Canonical token storage

The canonical client/server token document is:

`users/{uid}/private/tokens`

Field:
- `tokens: string[]`

Legacy `users/{uid}.fcmToken` and `users/{uid}.fcmTokens` remain only during migration. New readers use the private document. The migration utility is `tools/migrate_fcm_tokens.js`.

## Background notification actions

Notification action handling is registered with `onDidReceiveBackgroundNotificationResponse`.

- Message replies are bound to a UID and queued locally when an authenticated session is not available.
- A queued reply is sent only when the current Firebase Auth UID exactly matches the queued UID.
- Call answer/reject actions verify the call document receiver UID before changing state.
- Background call actions update Firestore state directly and do not require a Flutter screen.
