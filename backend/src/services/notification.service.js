const { getMessaging, getFirestore } = require('./firebase.service');

/**
 * إنشاء سجل إشعار داخل Firestore.
 *
 * مهم:
 * يتم إنشاء السجل بشكل مستقل عن FCM.
 * لذلك يبقى الإشعار ظاهرًا في مركز الإشعارات
 * حتى لو لم يكن لدى المستخدم FCM token صالح.
 */
async function createNotification({
  userId,
  type,
  title,
  body,
  chatId = '',
  callId = '',
  senderId = '',
  senderName = '',
}) {
  if (!userId) {
    return {
      success: false,
      skipped: true,
      reason: 'missing_user_id',
    };
  }

  const db = getFirestore();

  const notificationData = {
    userId: String(userId),
    type: String(type || 'general'),
    title: String(title || 'صحتك'),
    body: String(body || ''),
    chatId: chatId ? String(chatId) : '',
    callId: callId ? String(callId) : '',
    senderId: senderId ? String(senderId) : '',
    senderName: senderName ? String(senderName) : '',
    isRead: false,
    createdAt: new Date(),
  };

  try {
    const notificationRef = await db
      .collection('notifications')
      .add(notificationData);

    return {
      success: true,
      notificationId: notificationRef.id,
    };
  } catch (error) {
    console.error(
      'Firestore notification error:',
      error?.message || error,
    );

    return {
      success: false,
      skipped: false,
      reason: 'notification_create_failed',
    };
  }
}

/**
 * إرسال إشعار FCM إلى جهاز مستخدم واحد.
 *
 * token يتم قراءته من users/{userId}.fcmToken
 * ولا يتم الوثوق بأي token قادم من Flutter.
 */
async function sendToUser({
  userId,
  notification,
  data = {},
  android = {},
}) {
  if (!userId) {
    return {
      success: false,
      skipped: true,
      reason: 'missing_user_id',
    };
  }

  const db = getFirestore();

  const userSnapshot = await db
    .collection('users')
    .doc(String(userId))
    .get();

  if (!userSnapshot.exists) {
    return {
      success: false,
      skipped: true,
      reason: 'user_not_found',
    };
  }

  const userData = userSnapshot.data() || {};
  const token = userData.fcmToken;

  if (!token || typeof token !== 'string' || !token.trim()) {
    return {
      success: false,
      skipped: true,
      reason: 'fcm_token_missing',
    };
  }

  const message = {
    token: token.trim(),

    notification: {
      title: String(notification?.title || 'صحتك'),
      body: String(notification?.body || ''),
    },

    data: Object.fromEntries(
      Object.entries(data || {}).map(([key, value]) => [
        String(key),
        value == null ? '' : String(value),
      ]),
    ),

    android: {
      priority: 'high',

      notification: {
        channelId: android.channelId || 'sehatak_channel',
        sound: android.sound || 'notification',
      },
    },
  };

  try {
    const messageId = await getMessaging().send(message);

    return {
      success: true,
      messageId,
    };
  } catch (error) {
    console.error(
      'FCM send error:',
      error?.code || error?.message || error,
    );

    /*
     * إذا كان token غير صالح، نحذفه حتى لا نستمر
     * بإرسال إشعارات إلى جهاز لم يعد مسجلاً.
     */
    const invalidTokenCodes = new Set([
      'messaging/registration-token-not-registered',
      'messaging/invalid-registration-token',
    ]);

    if (invalidTokenCodes.has(error?.code)) {
      try {
        await db
          .collection('users')
          .doc(String(userId))
          .update({
            fcmToken: null,
            lastTokenUpdate: null,
          });
      } catch (cleanupError) {
        console.error(
          'Failed to remove invalid FCM token:',
          cleanupError?.message || cleanupError,
        );
      }
    }

    return {
      success: false,
      skipped: false,
      reason: error?.code || 'fcm_send_failed',
    };
  }
}

/**
 * إشعار رسالة جديدة.
 */
async function sendNewMessageNotification({
  receiverId,
  chatId,
  senderId,
  senderName,
  text,
  type = 'text',
}) {
  const preview =
    type === 'image'
      ? '📷 أرسل صورة'
      : type === 'audio'
        ? '🎤 أرسل رسالة صوتية'
        : type === 'file'
          ? '📎 أرسل ملفًا'
          : String(text || 'رسالة جديدة');

  const title = senderName || 'رسالة جديدة';

  /*
   * 1. حفظ الإشعار في Firestore.
   */
  const notificationResult = await createNotification({
    userId: receiverId,
    type: 'new_message',
    title,
    body: preview,
    chatId,
    senderId,
    senderName,
  });

  /*
   * 2. إرسال FCM بشكل مستقل.
   */
  const fcmResult = await sendToUser({
    userId: receiverId,

    notification: {
      title,
      body: preview,
    },

    data: {
      type: 'new_message',
      chatId,
      senderId,
      senderName: senderName || '',
    },

    android: {
      channelId: 'sehatak_channel',
      sound: 'notification',
    },
  });

  return {
    success: notificationResult.success || fcmResult.success,
    notification: notificationResult,
    fcm: fcmResult,
  };
}

/**
 * إشعار مكالمة واردة.
 */
async function sendIncomingCallNotification({
  receiverId,
  chatId,
  callId = '',
  callerId,
  callerName,
  isVideo = false,
}) {
  const title = isVideo
    ? '📹 مكالمة فيديو واردة'
    : '📞 مكالمة صوتية واردة';

  const body = `${callerName || 'مستخدم'} يتصل بك`;

  /*
   * 1. حفظ إشعار المكالمة في Firestore.
   */
  const notificationResult = await createNotification({
    userId: receiverId,
    type: 'incoming_call',
    title,
    body,
    chatId,
    callId,
    senderId: callerId,
    senderName: callerName,
  });

  /*
   * 2. إرسال FCM.
   */
  const fcmResult = await sendToUser({
    userId: receiverId,

    notification: {
      title,
      body,
    },

    data: {
      type: 'incoming_call',
      chatId,
      callId,
      callerId,
      callerName: callerName || '',
      isVideo: isVideo ? 'true' : 'false',
    },

    android: {
      channelId: 'call_channel',
      sound: 'call_ringtone',
    },
  });

  return {
    success: notificationResult.success || fcmResult.success,
    notification: notificationResult,
    fcm: fcmResult,
  };
}

module.exports = {
  createNotification,
  sendToUser,
  sendNewMessageNotification,
  sendIncomingCallNotification,
};
