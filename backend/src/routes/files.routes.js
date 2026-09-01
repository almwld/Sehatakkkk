const express = require('express');
const multer = require('multer');
const crypto = require('crypto');

const nextcloud = require('../services/nextcloud.service');

const router = express.Router();

const upload = multer({
  storage: multer.memoryStorage(),

  limits: {
    fileSize: 100 * 1024 * 1024, // 100 MB
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

      const result = await nextcloud.uploadBuffer({
        chatId,
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
  }
);

module.exports = router;
