function stringOrEmpty(value, maxLength) {
  return typeof value === 'string' ? value.trim().slice(0, maxLength) : '';
}

function numberOrZero(value) {
  return typeof value === 'number' && Number.isFinite(value) ? value : 0;
}

// Deliberately excludes email, phone, vitals, medical history, tokens,
// notification state, moderation flags, and private messaging preferences.
function publicProfileFromUser(data, uid) {
  const role = stringOrEmpty(data.role, 40) || 'user';
  return {
    uid,
    name: stringOrEmpty(data.name || data.displayName, 100) || 'مستخدم',
    photoUrl: stringOrEmpty(data.photoUrl || data.avatar, 2048),
    bio: stringOrEmpty(data.bio, 500),
    role,
    specialty: stringOrEmpty(data.specialty, 120),
    hospital: stringOrEmpty(data.hospital, 160),
    location: stringOrEmpty(data.location || data.city, 160),
    rating: numberOrZero(data.rating),
    reviewsCount: Math.max(0, Math.trunc(numberOrZero(data.reviewsCount || data.reviewCount))),
    isDoctor: role === 'doctor' || data.isDoctor === true,
    isVerified: data.isVerified === true,
    // Minimal presence data for authenticated chat peers.
    isOnline: data.isOnline === true,
    lastSeen: data.lastSeen || null,
  };
}

module.exports = {publicProfileFromUser};
