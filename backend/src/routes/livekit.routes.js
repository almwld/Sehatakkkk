const express = require('express');
const { AccessToken } = require('livekit-server-sdk');
const { requireAuth } = require('../middleware/auth.middleware');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();

/**
 * POST /api/livekit/token
 *
 * إنشاء LiveKit token للمستخدم الموثق فقط.
 *
 * قواعد الأمان:
 * 1. Firebase ID Token مطلوب.
 * 2. participantIdentity يؤخذ من req.user.uid فقط.
 * 3. roomName يجب أن يكون Chat ID موجوداً في Firestore.
 * 4. المستخدم يجب أن يكون أحد participants في المحادثة.
 */
router.post('/token', requireAuth, async (req, res) => {
  try {
    const { roomName, participantName } = req.body;

    const currentUserId = String(req.user.uid || '');

    if (!currentUserId) {
      return res.status(401).json({
        success: false,
        message: 'المصادقة مطلوبة',
      });
    }

    if (
      typeof roomName !== 'string' ||
      roomName.trim().length === 0 ||
      roomName.trim().length > 200
    ) {
      return res.status(400).json({
        success: false,
        message: 'roomName غير صالح',
      });
    }

    const safeRoomName = roomName.trim();

    if (
      !process.env.LIVEKIT_API_KEY ||
      !process.env.LIVEKIT_API_SECRET ||
      !process.env.LIVEKIT_URL
    ) {
      return res.status(500).json({
        success: false,
        message: 'إعدادات LiveKit غير مكتملة',
      });
    }

    /**
     * التحقق من أن roomName هو Chat ID حقيقي
     * وأن المستخدم مشارك في المحادثة.
     */
    const db = getFirestore();

    const chatSnapshot = await db
      .collection('chats')
      .doc(safeRoomName)
      .get();

    if (!chatSnapshot.exists) {
      return res.status(404).json({
        success: false,
        message: 'المحادثة المرتبطة بالمكالمة غير موجودة',
      });
    }

    const chatData = chatSnapshot.data() || {};

    const participants = Array.isArray(chatData.participants)
      ? chatData.participants.map(String)
      : [];

    if (!participants.includes(currentUserId)) {
      return res.status(403).json({
        success: false,
        message: 'ليس لديك صلاحية الانضمام إلى هذه المكالمة',
      });
    }

    /**
     * الهوية الحقيقية دائماً من Firebase.
     * لا نستخدم participantIdentity من body.
     */
    const participantIdentity = currentUserId;

    const safeParticipantName =
      typeof participantName === 'string' &&
      participantName.trim().length > 0
        ? participantName.trim().slice(0, 100)
        : String(req.user.name || currentUserId);

    const token = new AccessToken(
      process.env.LIVEKIT_API_KEY,
      process.env.LIVEKIT_API_SECRET,
      {
        identity: participantIdentity,
        name: safeParticipantName,
        ttl: '1h',
      },
    );

    token.addGrant({
      roomJoin: true,
      room: safeRoomName,
      canPublish: true,
      canSubscribe: true,
      canPublishData: true,
    });

    const accessToken = await token.toJwt();

    return res.json({
      success: true,
      data: {
        token: accessToken,
        url: process.env.LIVEKIT_URL,
        roomName: safeRoomName,
        participantIdentity,
        participantName: safeParticipantName,
      },
    });
  } catch (error) {
    console.error('========== LIVEKIT TOKEN ERROR ==========');
    console.error(error);
    console.error('==========================================');

    return res.status(500).json({
      success: false,
      message: 'فشل إنشاء توكن LiveKit',
    });
  }
});

/**
 * GET /api/livekit/health
 *
 * فحص عام بدون كشف الأسرار.
 */
router.get('/health', (req, res) => {
  res.json({
    success: true,
    livekit: Boolean(process.env.LIVEKIT_URL),
    credentials: Boolean(
      process.env.LIVEKIT_API_KEY &&
      process.env.LIVEKIT_API_SECRET
    ),
    url: process.env.LIVEKIT_URL || null,
  });
});

module.exports = router;
