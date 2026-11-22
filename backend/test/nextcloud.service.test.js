const test = require('node:test');
const assert = require('node:assert/strict');

process.env.NEXTCLOUD_URL = 'https://cloud.example.test';
process.env.NEXTCLOUD_USERNAME = 'sehatak-service';
process.env.NEXTCLOUD_PASSWORD = 'test-only-password';
process.env.NEXTCLOUD_ROOT_PATH = 'sehatak/Sehatak/archive';

const nextcloud = require('../src/services/nextcloud.service');

test('Nextcloud paths have one canonical Sehatak root and include authenticated uid', () => {
  assert.equal(
    nextcloud.buildPath('patient_123', 'chat_456', 'message_789'),
    'Sehatak/archive/users/patient_123/chats/chat_456/messages/message_789',
  );
});

test('Nextcloud paths isolate each uid and chat', () => {
  const first = nextcloud.buildPath('user-a', 'chat-1', 'message-1');
  const second = nextcloud.buildPath('user-b', 'chat-1', 'message-1');
  const third = nextcloud.buildPath('user-a', 'chat-2', 'message-1');

  assert.notEqual(first, second);
  assert.notEqual(first, third);
});

test('Nextcloud path builder rejects missing identity components', () => {
  assert.throws(() => nextcloud.buildPath('', 'chat-1', 'message-1'), /uid, chatId and messageId are required/);
  assert.throws(() => nextcloud.buildPath('user-1', '', 'message-1'), /uid, chatId and messageId are required/);
  assert.throws(() => nextcloud.buildPath('user-1', 'chat-1', ''), /uid, chatId and messageId are required/);
});
