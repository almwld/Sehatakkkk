const test = require('node:test');
const assert = require('node:assert/strict');
const { MAX_CHAT_FILE_BYTES, isAllowedChatFile } = require('../src/security/file-upload-policy');

test('chat upload policy caps payloads at 100 MiB', () => {
  assert.equal(MAX_CHAT_FILE_BYTES, 100 * 1024 * 1024);
});

test('chat upload policy accepts supported file extensions with matching MIME types', () => {
  assert.equal(isAllowedChatFile({ originalName: 'report.pdf', mimeType: 'application/pdf' }), true);
  assert.equal(isAllowedChatFile({ originalName: 'voice.m4a', mimeType: 'audio/mp4' }), true);
  assert.equal(isAllowedChatFile({ originalName: 'clip.mp4', mimeType: 'video/mp4' }), true);
  assert.equal(isAllowedChatFile({ originalName: 'notes.txt', mimeType: 'text/plain' }), true);
});

test('chat upload policy rejects MIME spoofing, unknown extensions and generic binary uploads', () => {
  assert.equal(isAllowedChatFile({ originalName: 'report.pdf', mimeType: 'image/jpeg' }), false);
  assert.equal(isAllowedChatFile({ originalName: 'payload.exe', mimeType: 'application/octet-stream' }), false);
  assert.equal(isAllowedChatFile({ originalName: 'no-extension', mimeType: 'application/pdf' }), false);
  assert.equal(isAllowedChatFile({ originalName: 'image.png', mimeType: 'application/octet-stream' }), false);
});
