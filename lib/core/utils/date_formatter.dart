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
  static String timeAgo(DateTime d) { final x=DateTime.now().difference(d); if(x.inMinutes<1)return 'الآن'; if(x.inHours<1)return 'منذ ${x.inMinutes} د'; if(x.inDays<1)return 'منذ ${x.inHours} س'; if(x.inDays<7)return 'منذ ${x.inDays} ي'; if(x.inDays<30)return 'منذ ${(x.inDays/7).floor()} أسبوع'; if(x.inDays<365)return 'منذ ${(x.inDays/30).floor()} شهر'; return 'منذ ${(x.inDays/365).floor()} سنة'; }
  static String timeAgoShort(DateTime d) { final x=DateTime.now().difference(d); if(x.inMinutes<1)return 'الآن'; if(x.inHours<1)return '${x.inMinutes}د'; if(x.inDays<1)return '${x.inHours}س'; if(x.inDays<7)return '${x.inDays}ي'; if(x.inDays<30)return '${(x.inDays/7).floor()}أ'; if(x.inDays<365)return '${(x.inDays/30).floor()}ش'; return '${(x.inDays/365).floor()}س'; }
  static String formatMessageTime(DateTime t) { final n=DateTime.now(); if(isSameDay(t,n))return formatTime(t); if(isSameDay(t,n.subtract(const Duration(days:1))))return 'أمس ${formatTime(t)}'; return formatDateShort(t); }
  static String formatMessageDate(DateTime t) { final n=DateTime.now(); if(isSameDay(t,n))return 'اليوم'; if(isSameDay(t,n.subtract(const Duration(days:1))))return 'أمس'; return formatDate(t); }
  static String formatDuration(Duration d) { final h=d.inHours,m=d.inMinutes%60,s=d.inSeconds%60; final mm=m.toString().padLeft(2,'0'),ss=s.toString().padLeft(2,'0'); return h>0?'$h:$mm:$ss':'$m:$ss'; }
  static String formatDurationLong(Duration d) { final h=d.inHours,m=d.inMinutes%60,s=d.inSeconds%60; if(h>0)return '$h ساعة و $m دقيقة'; if(m>0)return '$m دقيقة و $s ثانية'; return '$s ثانية'; }
  static String formatAppointmentDate(DateTime d)=>DateFormat('EEEE, dd MMMM yyyy','ar').format(d);
  static String formatAppointmentTime(DateTime d)=>DateFormat('hh:mm a').format(d);
  static String formatAppointment(DateTime d)=>'${formatAppointmentDate(d)} ${formatAppointmentTime(d)}';
  static bool isToday(DateTime d)=>isSameDay(d,DateTime.now());
  static bool isYesterday(DateTime d)=>isSameDay(d,DateTime.now().subtract(const Duration(days:1)));
  static bool isThisWeek(DateTime d)=>DateTime.now().difference(d).inDays<7;
  static bool isThisMonth(DateTime d){final n=DateTime.now();return d.month==n.month&&d.year==n.year;}
  static bool isSameDay(DateTime a,DateTime b)=>a.year==b.year&&a.month==b.month&&a.day==b.day;
  static DateTime startOfDay(DateTime d)=>DateTime(d.year,d.month,d.day);
  static DateTime endOfDay(DateTime d)=>DateTime(d.year,d.month,d.day,23,59,59);
  static DateTime startOfWeek(DateTime d)=>d.subtract(Duration(days:d.weekday-1));
  static DateTime endOfWeek(DateTime d)=>d.add(Duration(days:7-d.weekday));
  static DateTime startOfMonth(DateTime d)=>DateTime(d.year,d.month,1);
  static DateTime endOfMonth(DateTime d)=>DateTime(d.year,d.month+1,0);
}
