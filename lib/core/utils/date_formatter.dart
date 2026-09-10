// ============================================================
// 📅 تنسيق التواريخ والأوقات
// ============================================================

import 'package:intl/intl.dart';

class DateFormatter {
  static String formatTime(DateTime time) => DateFormat('hh:mm a').format(time);
  static String formatTime24(DateTime time) => DateFormat('HH:mm').format(time);
  static String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
  static String formatDateLong(DateTime date) => DateFormat('EEEE, dd MMMM yyyy', 'ar').format(date);
  static String formatDateShort(DateTime date) => DateFormat('dd MMM', 'ar').format(date);

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  static String timeAgoShort(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes}د';
    if (diff.inDays < 1) return '${diff.inHours}س';
    if (diff.inDays < 7) return '${diff.inDays}ي';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}أ';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}ش';
    return '${(diff.inDays / 365).floor()}س';
  }

  static String formatMessageTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) return formatTime(time);
    if (time.day == now.day - 1 && time.month == now.month && time.year == now.year) return 'أمس ${formatTime(time)}';
    return formatDateShort(time);
  }

  static String formatMessageDate(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) return 'اليوم';
    if (time.day == now.day - 1 && time.month == now.month && time.year == now.year) return 'أمس';
    return formatDate(time);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final secondsText = seconds.toString().padLeft(2, '0');
    final minutesText = minutes.toString().padLeft(2, '0');
    if (hours > 0) return '$hours:$minutesText:$secondsText';
    return '$minutes:$secondsText';
  }

  static String formatDurationLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    if (hours > 0) return '$hours ساعة و $minutes دقيقة';
    if (minutes > 0) return '$minutes دقيقة و $seconds ثانية';
    return '$seconds ثانية';
  }

  static String formatAppointmentDate(DateTime date) => DateFormat('EEEE, dd MMMM yyyy', 'ar').format(date);
  static String formatAppointmentTime(DateTime date) => DateFormat('hh:mm a').format(date);
  static String formatAppointment(DateTime date) => '${formatAppointmentDate(date)} ${formatAppointmentTime(date)}';
  static bool isToday(DateTime date) => DateUtils.dateOnly(date) == DateUtils.dateOnly(DateTime.now());
  static bool isYesterday(DateTime date) => DateUtils.dateOnly(date) == DateUtils.dateOnly(DateTime.now().subtract(const Duration(days: 1)));
  static bool isThisWeek(DateTime date) => DateTime.now().difference(date).inDays < 7;
  static bool isThisMonth(DateTime date) { final now = DateTime.now(); return date.month == now.month && date.year == now.year; }
  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  static DateTime startOfDay(DateTime date) => DateTime(date.year, date.month, date.day);
  static DateTime endOfDay(DateTime date) => DateTime(date.year, date.month, date.day, 23, 59, 59);
  static DateTime startOfWeek(DateTime date) => date.subtract(Duration(days: date.weekday - 1));
  static DateTime endOfWeek(DateTime date) => date.add(Duration(days: 7 - date.weekday));
  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month, 1);
  static DateTime endOfMonth(DateTime date) => DateTime(date.year, date.month + 1, 0);
}
