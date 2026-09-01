const express = require('express');
const multer = require('multer');
const crypto = require('crypto');

const nextcloud = require('../services/nextcloud.service');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 100 * 1024 * 1024,
  },
});

router.post('/upload', upload.single('file'), async (req, res) => {
  try {
    const currentUserId = String(req.user?.uid || '');

    if (!currentUserId) {
      return res.status(401).json({
        success: false,
        message: 'المصادقة مطلوبة',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'لم يتم إرسال ملف',
      });
    }

    const { chatId } = req.body;

    if (
      typeof chatId !== 'string' ||
      chatId.trim().length === 0
    ) {
      return res.status(400).json({
        success: false,
        message: 'chatId مطلوب',
      });
    }

    const safeChatId = chatId.trim();

    /**
     * التأكد أن المستخدم مشارك في المحادثة.
     */
    const db = getFirestore();

    const chatSnapshot = await db
      .collection('chats')
      .doc(safeChatId)
      .get();

    if (!chatSnapshot.exists) {
      return res.status(404).json({
        success: false,
        message: 'المحادثة غير موجودة',
      });
    }

    const chatData = chatSnapshot.data() || {};

    const participants = Array.isArray(chatData.participants)
      ? chatData.participants.map(String)
      : [];

    if (!participants.includes(currentUserId)) {
      return res.status(403).json({
        success: false,
        message: 'ليس لديك صلاحية رفع ملفات إلى هذه المحادثة',
      });
    }

    const messageId = crypto.randomUUID();

    const result = await nextcloud.uploadBuffer({
      chatId: safeChatId,
      messageId,
      fileName: req.file.originalname,
      buffer: req.file.buffer,
      mimeType: req.file.mimetype,
    });

    return res.status(201).json({
      success: true,
      file: {
        messageId,
        provider: result.provider,
        remotePath: result.remotePath,
        fileName: result.fileName,
        mimeType: result.mimeType,
        size: req.file.size,
      },
    });
  } catch (error) {
    console.error('Nextcloud upload error:', error);

    return res.status(500).json({
      success: false,
      message: 'فشل رفع الملف',
    });
  }
});

module.exports = router;
