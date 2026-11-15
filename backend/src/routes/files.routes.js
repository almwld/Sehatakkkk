const express = require('express');
const multer = require('multer');
const crypto = require('crypto');

const nextcloud = require('../services/nextcloud.service');
const { getFirestore } = require('../services/firebase.service');
const { MAX_CHAT_FILE_BYTES, isAllowedChatFile } = require('../security/file-upload-policy');

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: MAX_CHAT_FILE_BYTES,
    files: 1,
    fields: 10,
    parts: 12,
    fieldSize: 10 * 1024,
  },
  fileFilter: (_req, file, done) => {
    if (!isAllowedChatFile(file)) {
      const error = new Error('Unsupported attachment type or file extension.');
      error.status = 415;
      return done(error);
    }
    return done(null, true);
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
      !/^[A-Za-z0-9_-]{1,150}$/.test(chatId.trim())
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
