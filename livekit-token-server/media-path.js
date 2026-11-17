function isSafeOwnedNextcloudPath(remotePath, uid) {
  const normalized = String(remotePath || '').replace(/^\/+/, '');
  const segments = normalized.split('/');
  if (!normalized || segments.length < 5 || segments.length > 24) return false;
  if (segments.some((part) =>
    !part || part === '.' || part === '..' ||
    part.includes('\\') || /[\x00-\x1f]/.test(part)
  )) return false;

  const ownerPrefix = 'Sehatak/users/' + String(uid || '') + '/';
  return Boolean(uid) && normalized.startsWith(ownerPrefix);
}

module.exports = { isSafeOwnedNextcloudPath };
