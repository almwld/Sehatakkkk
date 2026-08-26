import 'package:sehatak/core/services/toast_service.dart';

class AdvancedNotificationService {
  static final AdvancedNotificationService _instance = AdvancedNotificationService._internal();
  factory AdvancedNotificationService() => _instance;
  AdvancedNotificationService._internal();

  int _unreadCount = 3;

  Future<void> initialize() async {
    print('✅ AdvancedNotificationService initialized');
  }

  Future<int> getUnreadCount() async {
    return _unreadCount;
  }

  Future<void> sendMentionNotification(String mentionedUser, String senderName) async {
    print('📩 Mention notification: $senderName mentioned $mentionedUser');
    ToastService.showSuccess('@$mentionedUser تم منشنك بواسطة $senderName');
  }

  Future<void> showNotification(String title, String body) async {
    ToastService.showSuccess('📩 $title: $body');
  }

  Future<void> markAsRead(String id) async {
    if (_unreadCount > 0) _unreadCount--;
    print('✅ Notification marked as read: $id');
  }

  Future<void> markAllAsRead() async {
    _unreadCount = 0;
    print('✅ All notifications marked as read');
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    return [
      {'id': '1', 'title': 'تذكير دواء', 'body': 'حان وقت تناول دوائك', 'time': 'منذ 5 دقائق', 'read': false},
      {'id': '2', 'title': 'موعد جديد', 'body': 'لديك موعد مع د. أحمد غداً', 'time': 'منذ ساعة', 'read': false},
      {'id': '3', 'title': 'تحديث صحي', 'body': 'تم تحديث بياناتك الصحية', 'time': 'منذ 3 ساعات', 'read': true},
    ];
  }
}
