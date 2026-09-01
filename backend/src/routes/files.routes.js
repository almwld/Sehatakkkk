const express = require('express');
const multer = require('multer');
const crypto = require('crypto');
const nextcloud = require('../services/nextcloud.service');

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 100 * 1024 * 1024,
  },
});

router.post(
  '/upload',
  upload.single('file'),
  async (req, res) => {
    try {
      if (!req.file) {
        return res.status(400).json({
          success: false,
          message: 'لم يتم إرسال ملف',
        });
      }

      const { chatId } = req.body;

      if (!chatId) {
        return res.status(400).json({
          success: false,
          message: 'chatId مطلوب',
        });
      }

      const messageId = crypto.randomUUID();

      console.log('========== NEXTCLOUD UPLOAD ==========');
      console.log('chatId:', chatId);
      console.log('messageId:', messageId);
      console.log('fileName:', req.file.originalname);
      console.log('mimeType:', req.file.mimetype);
      console.log('size:', req.file.size);

      const result = await nextcloud.uploadBuffer({
        chatId,
        messageId,
        fileName: req.file.originalname,
        buffer: req.file.buffer,
        mimeType: req.file.mimetype,
      });

      console.log('Nextcloud upload SUCCESS');
      console.log('remotePath:', result.remotePath);
      console.log('======================================');

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

      console.error('');
      console.error('========== NEXTCLOUD UPLOAD ERROR ==========');
      console.error('message:', error.message);
      console.error('status:', error.response?.status);
      console.error('statusText:', error.response?.statusText);
      console.error('data:', error.response?.data);
      console.error('url:', error.config?.url);
      console.error('method:', error.config?.method);
      console.error('============================================');
      console.error('');

      return res.status(500).json({
        success: false,
        message: 'فشل رفع الملف',
        error: process.env.NODE_ENV === 'development'
          ? error.message
          : undefined,
      });
    }
  }
);

module.exports = router;
