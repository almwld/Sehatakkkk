const express = require('express');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();

/*
|--------------------------------------------------------------------------
| Helpers
|--------------------------------------------------------------------------
*/

function getUserId(req) {
  return (
    req.user?.uid ||
    req.body?.userId ||
    req.query?.userId ||
    null
  );
}

function normalizeMessageData(data = {}) {
  return {
    ...data,

    // ضمان وجود حقول متوافقة مع MessageModel
    text: data.text ?? '',
    type: data.type ?? 'text',

    senderId: data.senderId ?? '',
    receiverId: data.receiverId ?? '',

    timestamp: data.timestamp ?? null,

    isRead: data.isRead ?? false,

    // حقول الملفات - ستُستخدم لاحقًا مع Nextcloud
    fileUrl: data.fileUrl ?? null,
    fileName: data.fileName ?? null,
    fileType: data.fileType ?? null,
    fileSize: data.fileSize ?? null,

    imageUrl: data.imageUrl ?? null,
    audioUrl: data.audioUrl ?? null,

    replyToMessageId: data.replyToMessageId ?? null,

    metadata: data.metadata ?? null,
  };
}

/*
|--------------------------------------------------------------------------
| POST /api/chats
| إنشاء محادثة جديدة أو إعادة المحادثة الموجودة
|--------------------------------------------------------------------------
*/

router.post('/', async (req, res) => {
  try {
    const db = getFirestore();

    const {
      doctorId,
      doctorName = '',
      doctorImage = '',
      patientId,
      patientName = '',
      patientImage = '',
      participants,
      isGroup = false,
      groupName = '',
      groupImage = '',
    } = req.body;

    const currentUserId = getUserId(req);

    const finalPatientId = patientId || currentUserId;

    if (!finalPatientId) {
      return res.status(400).json({
        success: false,
        message: 'patientId مطلوب',
      });
    }

    if (!doctorId && !isGroup) {
      return res.status(400).json({
        success: false,
        message: 'doctorId مطلوب',
      });
    }

    let finalParticipants = participants;

    if (!Array.isArray(finalParticipants) || finalParticipants.length === 0) {
      finalParticipants = isGroup
        ? [finalPatientId]
        : [finalPatientId, doctorId];
    }

    finalParticipants = [...new Set(
      finalParticipants.filter(Boolean).map(String)
    )];

    /*
     * البحث عن محادثة موجودة بين المشاركين.
     * لا نعتمد على ترتيب العناصر داخل array.
     */
    const chatsSnapshot = await db
      .collection('chats')
      .where('participants', 'array-contains', finalParticipants[0])
      .get();

    for (const doc of chatsSnapshot.docs) {
      const data = doc.data();

      const existingParticipants =
        Array.isArray(data.participants)
          ? data.participants.map(String)
          : [];

      const sameParticipants =
        existingParticipants.length === finalParticipants.length &&
        finalParticipants.every((id) =>
          existingParticipants.includes(id)
        );

      if (sameParticipants) {
        return res.json({
          success: true,
          created: false,
          chat: {
            id: doc.id,
            ...data,
          },
        });
      }
    }

    const now = new Date();

    const chatData = {
      doctorId: doctorId || '',
      doctorName,
      doctorImage,

      patientId: finalPatientId,
      patientName,
      patientImage,

      lastMessage: '',
      lastMessageTime: now,
      createdAt: now,
      updatedAt: now,

      participants: finalParticipants,

      unreadCount: 0,

      isOnline: false,
      lastSeen: null,

      isGroup,
      groupName,
      groupImage,

      isPinned: false,
      isMuted: false,
      mutedUntil: null,

      labels: [],

      isArchived: false,

      callHistory: [],
      lastCall: null,
    };

    const chatRef = await db.collection('chats').add(chatData);

    return res.status(201).json({
      success: true,
      created: true,
      chat: {
        id: chatRef.id,
        ...chatData,
      },
    });
  } catch (error) {
    console.error('Create chat error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل إنشاء المحادثة',
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/chats
| جلب محادثات المستخدم
|--------------------------------------------------------------------------
*/

router.get('/', async (req, res) => {
  try {
    const db = getFirestore();

    const userId = getUserId(req);

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'userId مطلوب',
      });
    }

    const snapshot = await db
      .collection('chats')
      .where('participants', 'array-contains', userId)
      .get();

    const chats = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    chats.sort((a, b) => {
      const aTime = a.updatedAt?.toMillis?.() || 0;
      const bTime = b.updatedAt?.toMillis?.() || 0;

      return bTime - aTime;
    });

    return res.json({
      success: true,
      chats,
      count: chats.length,
    });
  } catch (error) {
    console.error('Get chats error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل جلب المحادثات',
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/chats/:chatId
| جلب محادثة واحدة
|--------------------------------------------------------------------------
*/

router.get('/:chatId', async (req, res) => {
  try {
    const db = getFirestore();

    const { chatId } = req.params;

    const chatRef = db.collection('chats').doc(chatId);
    const snapshot = await chatRef.get();

    if (!snapshot.exists) {
      return res.status(404).json({
        success: false,
        message: 'المحادثة غير موجودة',
      });
    }

    return res.json({
      success: true,
      chat: {
        id: snapshot.id,
        ...snapshot.data(),
      },
    });
  } catch (error) {
    console.error('Get chat error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل جلب المحادثة',
    });
  }
});

/*
|--------------------------------------------------------------------------
| GET /api/chats/:chatId/messages
| جلب رسائل المحادثة
|--------------------------------------------------------------------------
*/

router.get('/:chatId/messages', async (req, res) => {
  try {
    const db = getFirestore();

    const { chatId } = req.params;

    const limitValue = Math.min(
      Math.max(parseInt(req.query.limit || '50', 10), 1),
      100
    );

    const messagesRef = db
      .collection('chats')
      .doc(chatId)
      .collection('messages');

    const snapshot = await messagesRef
      .orderBy('timestamp', 'asc')
      .limit(limitValue)
      .get();

    const messages = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...normalizeMessageData(doc.data()),
    }));

    return res.json({
      success: true,
      chatId,
      messages,
      count: messages.length,
    });
  } catch (error) {
    console.error('Get messages error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل جلب الرسائل',
    });
  }
});

/*
|--------------------------------------------------------------------------
| POST /api/chats/:chatId/messages
| إرسال رسالة
|--------------------------------------------------------------------------
*/

router.post('/:chatId/messages', async (req, res) => {
  try {
    const db = getFirestore();

    const { chatId } = req.params;

    const {
      senderId,
      receiverId,
      text = '',
      type = 'text',

      fileUrl = null,
      fileName = null,
      fileType = null,
      fileSize = null,

      imageUrl = null,
      audioUrl = null,

      replyToMessageId = null,
      metadata = null,
    } = req.body;

    const currentUserId = getUserId(req);
    const finalSenderId = senderId || currentUserId;

    if (!finalSenderId) {
      return res.status(400).json({
        success: false,
        message: 'senderId مطلوب',
      });
    }

    /*
     * التأكد من وجود المحادثة
     */
    const chatRef = db.collection('chats').doc(chatId);
    const chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      return res.status(404).json({
        success: false,
        message: 'المحادثة غير موجودة',
      });
    }

    const chatData = chatSnapshot.data();

    /*
     * إذا لم يرسل العميل receiverId،
     * نحاول استخراجه من participants.
     */
    let finalReceiverId = receiverId || '';

    if (!finalReceiverId && Array.isArray(chatData.participants)) {
      finalReceiverId =
        chatData.participants.find(
          (id) => String(id) !== String(finalSenderId)
        ) || '';
    }

    const now = new Date();

    const messageData = normalizeMessageData({
      senderId: finalSenderId,
      receiverId: finalReceiverId,

      text,
      type,

      timestamp: now,

      isRead: false,

      fileUrl,
      fileName,
      fileType,
      fileSize,

      imageUrl,
      audioUrl,

      replyToMessageId,

      metadata,
    });

    /*
     * إنشاء الرسالة داخل:
     *
     * chats/{chatId}/messages/{messageId}
     */
    const messageRef = await chatRef
      .collection('messages')
      .add(messageData);

    /*
     * تحديث آخر رسالة في المحادثة
     */
    const currentUnreadCount =
      typeof chatData.unreadCount === 'number'
        ? chatData.unreadCount
        : 0;

    await chatRef.update({
      lastMessage: text || `[${type}]`,
      lastMessageTime: now,
      updatedAt: now,
      unreadCount: currentUnreadCount + 1,
    });

    return res.status(201).json({
      success: true,
      message: {
        id: messageRef.id,
        ...messageData,
      },
    });
  } catch (error) {
    console.error('Send message error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل إرسال الرسالة',
    });
  }
});

/*
|--------------------------------------------------------------------------
| PATCH /api/chats/:chatId/read
| تحديد الرسائل كمقروءة
|--------------------------------------------------------------------------
*/


router.delete('/:chatId', async (req, res) => {
  try {
    const { chatId } = req.params;

    if (!chatId) {
      return res.status(400).json({
        success: false,
        message: 'chatId مطلوب',
      });
    }

    const db = getFirestore();
    const chatRef = db.collection('chats').doc(chatId);

    const chatSnapshot = await chatRef.get();

    if (!chatSnapshot.exists) {
      return res.status(404).json({
        success: false,
        message: 'المحادثة غير موجودة',
      });
    }

    const messagesSnapshot = await chatRef
      .collection('messages')
      .get();

    const batch = db.batch();

    messagesSnapshot.docs.forEach((doc) => {
      batch.delete(doc.ref);
    });

    batch.delete(chatRef);

    await batch.commit();

    return res.json({
      success: true,
      chatId,
      deletedMessages: messagesSnapshot.size,
    });
  } catch (error) {
    console.error('Delete chat error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل حذف المحادثة',
    });
  }
});

router.patch('/:chatId/read', async (req, res) => {
  try {
    const db = getFirestore();

    const { chatId } = req.params;

    const userId = getUserId(req);

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'userId مطلوب',
      });
    }

    const messagesRef = db
      .collection('chats')
      .doc(chatId)
      .collection('messages');

    const snapshot = await messagesRef
      .where('receiverId', '==', userId)
      .where('isRead', '==', false)
      .get();

    if (!snapshot.empty) {
      const batch = db.batch();

      snapshot.docs.forEach((doc) => {
        batch.update(doc.ref, {
          isRead: true,
          readAt: new Date(),
        });
      });

      await batch.commit();
    }

    /*
     * ChatModel الحالي يستخدم unreadCount كرقم.
     */
    await db.collection('chats').doc(chatId).update({
      unreadCount: 0,
      updatedAt: new Date(),
    });

    return res.json({
      success: true,
      markedAsRead: snapshot.size,
    });
  } catch (error) {
    console.error('Mark messages read error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل تحديد الرسائل كمقروءة',
    });
  }
});

module.exports = router;
