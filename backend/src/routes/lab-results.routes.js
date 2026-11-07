const express = require('express');
const multer = require('multer');
const crypto = require('crypto');
const path = require('path');
const nextcloud = require('../services/nextcloud.service');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 20 * 1024 * 1024, files: 1 },
  fileFilter: (req, file, done) => {
    const allowed = new Set(['application/pdf', 'image/jpeg', 'image/png']);
    if (!allowed.has(file.mimetype)) { const error = new Error('Only PDF, JPEG and PNG lab reports are accepted.'); error.status = 415; return done(error); }
    done(null, true);
  },
});

function validBookingId(value) {
  return typeof value === 'string' && /^[A-Za-z0-9_-]{1,150}$/.test(value);
}

function safeDownloadName(value) {
  return path.basename(String(value || 'lab-result.pdf')).replace(/[^\\x20-\\x7E]|[\r\n"\\\\]/g, '_');
}

function detectMime(buffer) {
  if (buffer.length >= 5 && buffer.subarray(0, 5).toString('ascii') === '%PDF-') return 'application/pdf';
  if (buffer.length >= 3 && buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) return 'image/jpeg';
  if (buffer.length >= 8 && buffer.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) return 'image/png';
  return null;
}

// A laboratory may upload a result only to a booking assigned to its own UID.
router.post('/:bookingId', upload.single('file'), async (req, res) => {
  try {
    const uid = String(req.user?.uid || '');
    const { bookingId } = req.params;
    if (!uid) return res.status(401).json({ success: false, message: 'Authentication required.' });
    if (!validBookingId(bookingId)) return res.status(400).json({ success: false, message: 'Invalid booking ID.' });
    if (!req.file) return res.status(400).json({ success: false, message: 'A PDF, JPEG or PNG file is required.' });
    const detectedMime = detectMime(req.file.buffer);
    if (!detectedMime || detectedMime !== req.file.mimetype) return res.status(415).json({ success: false, message: 'The uploaded file content does not match an accepted report format.' });


    const db = getFirestore();
    const bookingRef = db.collection('lab_bookings').doc(bookingId);
    const bookingSnapshot = await bookingRef.get();
    if (!bookingSnapshot.exists) return res.status(404).json({ success: false, message: 'Booking not found.' });

    const booking = bookingSnapshot.data() || {};
    if (String(booking.labId || '') !== uid) return res.status(403).json({ success: false, message: 'This booking is not assigned to your laboratory.' });
    if (String(booking.status || '') !== 'confirmed') return res.status(409).json({ success: false, message: 'Only confirmed bookings can receive a result.' });

    const fileName = safeDownloadName(req.file.originalname);
    const uploadId = crypto.randomUUID();
    const stored = await nextcloud.uploadBuffer({
      chatId: 'lab_results_' + uid,
      messageId: bookingId + '_' + uploadId,
      fileName,
      buffer: req.file.buffer,
      mimeType: detectedMime,
    });

    const resultUrl = '/api/lab-results/' + encodeURIComponent(bookingId) + '/download';
    await bookingRef.update({
      resultUrl,
      resultRemotePath: stored.remotePath,
      resultFileName: fileName,
      resultMimeType: detectedMime,
      resultSize: req.file.size,
      status: 'completed',
      completedAt: new Date(),
      updatedAt: new Date(),
    });

    return res.status(201).json({
      success: true,
      bookingId,
      resultUrl,
      fileName,
      mimeType: detectedMime,
      size: req.file.size,
      status: 'completed',
    });
  } catch (error) {
    console.error('Lab result upload error:', error);
    const status = error.code === 'LIMIT_FILE_SIZE' ? 413 : (error.status || 500);
    return res.status(status).json({ success: false, message: status === 413 ? 'File exceeds the 20 MB limit.' : status === 415 ? 'Only valid PDF, JPEG and PNG files are accepted.' : 'Could not securely upload the laboratory result.' });
  }
});

// Only the patient who owns the booking or the assigned laboratory can download its result.
router.get('/:bookingId/download', async (req, res) => {
  try {
    const uid = String(req.user?.uid || '');
    const { bookingId } = req.params;
    if (!uid) return res.status(401).json({ success: false, message: 'Authentication required.' });
    if (!validBookingId(bookingId)) return res.status(400).json({ success: false, message: 'Invalid booking ID.' });

    const snapshot = await getFirestore().collection('lab_bookings').doc(bookingId).get();
    if (!snapshot.exists) return res.status(404).json({ success: false, message: 'Booking not found.' });
    const booking = snapshot.data() || {};
    if (String(booking.patientId || '') !== uid && String(booking.labId || '') !== uid) {
      return res.status(403).json({ success: false, message: 'You are not allowed to access this result.' });
    }
    const remotePath = String(booking.resultRemotePath || '');
    const expectedPrefix = String(nextcloud.rootPath || 'Sehatak') + '/lab_results_' + String(booking.labId || '') + '/' + bookingId + '_';
    if (!remotePath || !remotePath.startsWith(expectedPrefix) || remotePath.split('/').some((part) => part === '.' || part === '..')) return res.status(404).json({ success: false, message: 'No valid result is attached to this booking.' });

    const buffer = await nextcloud.downloadBuffer(remotePath);
    res.setHeader('Content-Type', 'application/octet-stream');
    res.setHeader('Content-Length', String(buffer.length));
    res.setHeader('Content-Disposition', 'attachment; filename="' + safeDownloadName(booking.resultFileName) + '"');
    res.setHeader('Cache-Control', 'private, no-store, max-age=0');
    return res.status(200).send(buffer);
  } catch (error) {
    console.error('Lab result download error:', error);
    return res.status(500).json({ success: false, message: 'Could not retrieve the laboratory result.' });
  }
});

module.exports = router;
