function stringOrEmpty(value, maxLength) {
  return typeof value === 'string' ? value.trim().slice(0, maxLength) : '';
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
    location: stringOrEmpty(data.publicLocation || data.city, 80),
    isDoctor: role === 'doctor',
    isVerified: data.isVerified === true,
  };
}

module.exports = {publicProfileFromUser};
