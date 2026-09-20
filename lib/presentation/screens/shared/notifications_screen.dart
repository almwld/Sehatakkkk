import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/verification/verification_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> _watchNotifications(String uid) {
    // Do not require a composite index: filter by user only and sort the
    // small notification feed locally.
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .limit(200)
        .snapshots();
  }

  Future<void> _markRead(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Mark notification read failed: $e');
    }
  }

  Future<void> _markAllRead(String uid, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final unread = docs.where((doc) => doc.data()['isRead'] != true).toList();
    if (unread.isEmpty) return;
    try {
      final batch = _firestore.batch();
      for (final doc in unread) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('❌ Mark all notifications read failed: $e');
    }
  }

  DateTime? _timestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  String _formatTime(dynamic value) {
    final date = _timestamp(value);
    if (date == null) return 'الآن';
    final difference = DateTime.now().difference(date);
    if (difference.inSeconds < 60) return 'الآن';
    if (difference.inMinutes < 60) return 'منذ ${difference.inMinutes} دقيقة';
    if (difference.inHours < 24) return 'منذ ${difference.inHours} ساعة';
    if (difference.inDays < 7) return 'منذ ${difference.inDays} يوم';
    return DateFormat('yyyy/MM/dd - HH:mm', 'ar').format(date);
  }

  IconData _iconFor(String type) {
    if (type == 'new_message' || type == 'chat_message' || type == 'message') return Icons.chat_bubble_outline;
    if (type.startsWith('appointment')) return Icons.calendar_today_outlined;
    if (type.startsWith('medication')) return Icons.medication_outlined;
    if (type.startsWith('lab_')) return Icons.science_outlined;
    if (type.startsWith('payment') || type == 'balance_added') return Icons.account_balance_wallet_outlined;
    if (type.startsWith('order')) return Icons.local_pharmacy_outlined;
    if (type.startsWith('health')) return Icons.favorite_outline;
    if (type.startsWith('social')) return Icons.people_outline;
    if (type == 'promotional') return Icons.local_offer_outlined;
    if (type == 'incoming_call') return Icons.call_outlined;
    return Icons.notifications_none_outlined;
  }

  Color _colorFor(String type) {
    if (type == 'new_message' || type == 'chat_message' || type == 'message') return AppColors.primary;
    if (type.startsWith('appointment')) return Colors.blue;
    if (type.startsWith('medication')) return Colors.orange;
    if (type.startsWith('lab_')) return Colors.green;
    if (type.startsWith('payment')) return Colors.teal;
    if (type.startsWith('order')) return Colors.indigo;
    if (type.startsWith('health')) return Colors.red;
    if (type.startsWith('social')) return Colors.purple;
    if (type == 'promotional') return Colors.deepPurple;
    return AppColors.primary;
  }

  Future<void> _openNotification(Map<String, dynamic> data) async {
    final type = data['type']?.toString() ?? '';
    final payload = data['data'];
    final nested = payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{};
    final chatId = (data['chatId'] ?? nested['chatId'])?.toString();
    if (type == 'verification_required' || type == 'verification_result') { if (mounted) { Navigator.of(context).push(MaterialPageRoute(builder: (_) => const VerificationScreen())); } return; }
    if ((type == 'new_message' || type == 'chat_message' || type == 'message') && chatId != null && chatId.isNotEmpty && mounted) { Navigator.of(context).pop(chatId); }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text('سجّل الدخول لعرض الإشعارات')));
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الإشعارات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _watchNotifications(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('تعذر تحميل الإشعارات: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = [...(snapshot.data?.docs ?? const <QueryDocumentSnapshot<Map<String, dynamic>>>[])];
          docs.sort((a, b) {
            final aDate = _timestamp(a.data()['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = _timestamp(b.data()['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });
          final unreadCount = docs.where((doc) => doc.data()['isRead'] != true).length;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('لا توجد إشعارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('ستظهر الإشعارات هنا عند استلامها'),
                ],
              ),
            );
          }

          return Column(
            children: [
              if (unreadCount > 0)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () => _markAllRead(uid, docs),
                    icon: const Icon(Icons.done_all),
                    label: Text('تحديد الكل كمقروء ($unreadCount)'),
                  ),
                ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data();
                    final isRead = data['isRead'] == true;
                    final type = data['type']?.toString() ?? 'system';
                    final color = _colorFor(type);
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        if (!isRead) await _markRead(doc.id);
                        await _openNotification(data);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2540) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isRead ? (isDark ? Colors.grey[800]! : Colors.grey[200]!) : color.withOpacity(0.35), width: isRead ? 1 : 2),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                              child: Icon(_iconFor(type), color: color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(data['title']?.toString() ?? 'صحتك', style: TextStyle(fontWeight: isRead ? FontWeight.w500 : FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                  const SizedBox(height: 3),
                                  Text(data['body']?.toString() ?? '', maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                                  const SizedBox(height: 4),
                                  Text(_formatTime(data['createdAt']), style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[500] : Colors.grey[500])),
                                ],
                              ),
                            ),
                            if (!isRead)
                              Container(width: 9, height: 9, decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
