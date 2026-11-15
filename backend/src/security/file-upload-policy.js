const path = require('path');

const MAX_CHAT_FILE_BYTES = 100 * 1024 * 1024;

const MIME_BY_EXTENSION = Object.freeze({
  jpg: 'image/jpeg',
  jpeg: 'image/jpeg',
  png: 'image/png',
  gif: 'image/gif',
  webp: 'image/webp',
  mp4: 'video/mp4',
  mov: 'video/quicktime',
  avi: 'video/x-msvideo',
  mkv: 'video/x-matroska',
  mp3: 'audio/mpeg',
  wav: 'audio/wav',
  m4a: 'audio/mp4',
  pdf: 'application/pdf',
  doc: 'application/msword',
  docx: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  xls: 'application/vnd.ms-excel',
  xlsx: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  ppt: 'application/vnd.ms-powerpoint',
  pptx: 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  txt: 'text/plain',
  zip: 'application/zip',
  rar: 'application/x-rar-compressed',
  '7z': 'application/x-7z-compressed',
});

function isAllowedChatFile({ mimeType, originalName }) {
  if (typeof mimeType !== 'string' || typeof originalName !== 'string') return false;
  const extension = path.extname(originalName).slice(1).toLowerCase();
  return Boolean(extension && MIME_BY_EXTENSION[extension] === mimeType.toLowerCase());
}

module.exports = { MAX_CHAT_FILE_BYTES, MIME_BY_EXTENSION, isAllowedChatFile };
