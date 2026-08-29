// ============================================================
// 📅 تنسيق التواريخ والأوقات
// ============================================================

import 'package:intl/intl.dart';

class DateFormatter {
  // ============================================================
  // 🕐 تنسيق الوقت
  // ============================================================

  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  static String formatTime24(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // ============================================================
  // 📅 تنسيق التاريخ
  // ============================================================

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'ar').format(date);
  }

  static String formatDateShort(DateTime date) {
    return DateFormat('dd MMM', 'ar').format(date);
  }

  // ============================================================
  // ⏱️ الوقت المنقضي
  // ============================================================

  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).floor()} أسبوع';
    if (diff.inDays < 365) return 'منذ ${(diff.inDays / 30).floor()} شهر';
    return 'منذ ${(diff.inDays / 365).floor()} سنة';
  }

  static String timeAgoShort(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes}د';
    if (diff.inDays < 1) return '${diff.inHours}س';
    if (diff.inDays < 7) return '${diff.inDays}ي';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}أ';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}ش';
    return '${(diff.inDays / 365).floor()}س';
  }

  // ============================================================
  // 📅 تنسيق الرسائل
  // ============================================================

  static String formatMessageTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return formatTime(time);
    }
    if (time.day == now.day - 1 && time.month == now.month && time.year == now.year) {
      return 'أمس ${formatTime(time)}';
    }
    return formatDateShort(time);
  }

  static String formatMessageDate(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return 'اليوم';
    }
    if (time.day == now.day - 1 && time.month == now.month && time.year == now.year) {
      return 'أمس';
    }
    return formatDate(time);
  }

  // ============================================================
  // 📊 تنسيق المدة
  // ============================================================

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:$minutes.toString().padLeft(2, '0')';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  static String formatDurationLong(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    }
    if (minutes > 0) {
      return '$minutes دقيقة و $seconds ثانية';
    }
    return '$seconds ثانية';
  }

  // ============================================================
  // 📅 تنسيق المواعيد
  // ============================================================

  static String formatAppointmentDate(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy', 'ar').format(date);
  }

  static String formatAppointmentTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  static String formatAppointment(DateTime date) {
    return '${formatAppointmentDate(date)} ${formatAppointmentTime(date)}';
  }

  // ============================================================
  // 🎯 دوال مساعدة
  // ============================================================

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day && date.month == now.month && date.year == now.year;
  }

  static bool isYesterday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day - 1 && date.month == now.month && date.year == now.year;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    return diff.inDays < 7;
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.month == now.month && date.year == now.year;
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.day == date2.day && date1.month == date2.month && date1.year == date2.year;
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static DateTime startOfWeek(DateTime date) {
    final diff = (date.weekday - 1) % 7;
    return date.subtract(Duration(days: diff));
  }

  static DateTime endOfWeek(DateTime date) {
    final diff = (7 - date.weekday) % 7;
    return date.add(Duration(days: diff));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
}
