import 'dart:async';
// ... باقي الكود

String _formatTime(Timestamp? timestamp) {
  if (timestamp == null) return '';
  final date = timestamp.toDate();
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
  if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
  return '${date.day}/${date.month}';
}
