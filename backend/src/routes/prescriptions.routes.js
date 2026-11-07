const express = require('express');
const multer = require('multer');
const crypto = require('crypto');
const path = require('path');
const nextcloud = require('../services/nextcloud.service');
const { getFirestore } = require('../services/firebase.service');

const router = express.Router();
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 15 * 1024 * 1024, files: 1 },
  fileFilter: (req, file, done) => {
    if (!['application/pdf', 'image/jpeg', 'image/png'].includes(file.mimetype)) {
      const error = new Error('Only PDF, JPEG and PNG prescriptions are accepted.');
      error.status = 415;
      return done(error);
    }
    done(null, true);
  },
});

function validId(value) {
  return typeof value === 'string' && /^[A-Za-z0-9_-]{1,150}$/.test(value);
}
function safeName(value) {
  return path.basename(String(value || 'prescription')).replace(/[^\x20-\x7E]|[\r\n"\\]/g, '_');
}
function detectMime(buffer) {
  if (buffer.length >= 5 && buffer.subarray(0, 5).toString('ascii') === '%PDF-') return 'application/pdf';
  if (buffer.length >= 3 && buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff) return 'image/jpeg';
  if (buffer.length >= 8 && buffer.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))) return 'image/png';
  return null;
}

router.post('/', upload.single('file'), async (req, res) => {
  try {
    const uid = String(req.user?.uid || '');
    if (!uid) return res.status(401).json({ success: false, message: 'Authentication required.' });
    if (!req.file) return res.status(400).json({ success: false, message: 'A prescription file is required.' });
    const productId = String(req.body.productId || '');
    const pharmacyId = String(req.body.pharmacyId || '');
    if (!validId(productId) || !validId(pharmacyId)) return res.status(400).json({ success: false, message: 'Invalid product or pharmacy ID.' });
    const mimeType = detectMime(req.file.buffer);
    if (!mimeType || mimeType !== req.file.mimetype) return res.status(415).json({ success: false, message: 'The file content does not match an accepted prescription format.' });

    const db = getFirestore();
    const [productSnap, pharmacySnap] = await Promise.all([
      db.collection('products').doc(productId).get(),
      db.collection('pharmacies').doc(pharmacyId).get(),
    ]);
    if (!productSnap.exists || !pharmacySnap.exists) return res.status(404).json({ success: false, message: 'Product or pharmacy not found.' });
    const product = productSnap.data() || {};
    const pharmacy = pharmacySnap.data() || {};
    if (String(product.pharmacyId || '') !== pharmacyId || product.requiresPrescription !== true && product.prescriptionRequired !== true) {
      return res.status(400).json({ success: false, message: 'This product is not linked to this pharmacy or does not require a prescription.' });
    }
    if (product.approvalStatus !== 'approved' || product.isPublished !== true || product.isActive !== true || pharmacy.status !== 'approved' || pharmacy.isActive === false) {
      return res.status(409).json({ success: false, message: 'The product or pharmacy is not currently available.' });
    }

    const prescriptionId = crypto.randomUUID().replace(/-/g, '');
    const fileName = safeName(req.file.originalname);
    const stored = await nextcloud.uploadBuffer({
      chatId: 'prescriptions_' + uid,
      messageId: prescriptionId,
      fileName,
      buffer: req.file.buffer,
      mimeType,
    });
    const now = new Date();
    await db.collection('prescriptions').doc(prescriptionId).create({
      userId: uid,
      patientId: uid,
      pharmacyId,
      productId,
      productName: String(product.name || ''),
      fileRemotePath: stored.remotePath,
      fileName,
      mimeType,
      fileSize: req.file.size,
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    });
    return res.status(201).json({ success: true, prescriptionId, status: 'pending', fileName, size: req.file.size });
  } catch (error) {
    console.error('Prescription upload failed:', error);
    const status = error.code === 'LIMIT_FILE_SIZE' ? 413 : (error.status || 500);
    return res.status(status).json({ success: false, message: status === 413 ? 'Prescription exceeds the 15 MB limit.' : status === 415 ? 'Only valid PDF, JPEG and PNG files are accepted.' : 'Could not securely upload the prescription.' });
  }
});

router.get('/:prescriptionId/download', async (req, res) => {
  try {
    const uid = String(req.user?.uid || '');
    const { prescriptionId } = req.params;
    if (!uid) return res.status(401).json({ success: false, message: 'Authentication required.' });
    if (!validId(prescriptionId)) return res.status(400).json({ success: false, message: 'Invalid prescription ID.' });
    const db = getFirestore();
    const snapshot = await db.collection('prescriptions').doc(prescriptionId).get();
    if (!snapshot.exists) return res.status(404).json({ success: false, message: 'Prescription not found.' });
    const record = snapshot.data() || {};
    let allowed = String(record.userId || record.patientId || '') === uid;
    if (!allowed && record.pharmacyId) {
      const pharmacySnap = await db.collection('pharmacies').doc(String(record.pharmacyId)).get();
      const pharmacy = pharmacySnap.data() || {};
      allowed = pharmacySnap.exists && [pharmacy.ownerId, pharmacy.userId, record.pharmacyId].some(value => String(value || '') === uid);
    }
    if (!allowed) return res.status(403).json({ success: false, message: 'You are not allowed to access this prescription.' });
    const remotePath = String(record.fileRemotePath || '');
    const expectedPrefix = String(nextcloud.rootPath || 'Sehatak') + '/prescriptions_' + String(record.userId || record.patientId || '') + '/' + prescriptionId + '/';
    if (!remotePath || !remotePath.startsWith(expectedPrefix) || remotePath.split('/').some(part => part === '.' || part === '..')) {
      return res.status(404).json({ success: false, message: 'No valid prescription file is attached.' });
    }
    const buffer = await nextcloud.downloadBuffer(remotePath);
    res.setHeader('Content-Type', 'application/octet-stream');
    res.setHeader('Content-Length', String(buffer.length));
    res.setHeader('Content-Disposition', 'attachment; filename="' + safeName(record.fileName) + '"');
    res.setHeader('Cache-Control', 'private, no-store, max-age=0');
    return res.status(200).send(buffer);
  } catch (error) {
    console.error('Prescription download failed:', error);
    return res.status(500).json({ success: false, message: 'Could not retrieve the prescription.' });
  }
});

module.exports = router;
