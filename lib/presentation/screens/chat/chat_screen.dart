import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // ✅ دالة تحميل المحادثات
  Future<void> _loadChats() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: user.uid)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _chats.clear();
            _chats.addAll(snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'participants': data['participants'] ?? [],
                'lastMessage': data['lastMessage'] ?? 'ابدأ المحادثة',
                'lastMessageTime': data['lastMessageTime'],
                'unreadCount': data['unreadCount'] ?? 0,
                'doctorName': data['doctorName'] ?? 'طبيب',
                'patientName': data['patientName'] ?? 'مريض',
                'image': data['image'] ?? ImageKit.doctor1,
              };
            }).toList());
            _isLoading = false;
          });
          return;
        }
      } catch (e) {
        print('❌ Error loading chats: $e');
      }
    }

    // ✅ بيانات وهمية
    setState(() {
      _chats.clear();
      _chats.addAll([
        {
          'id': '1',
          'doctorName': 'د. أحمد المؤيد',
          'lastMessage': 'مرحباً، كيف يمكنني مساعدتك اليوم؟',
          'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
          'unreadCount': 2,
          'image': ImageKit.doctor1,
        },
        {
          'id': '2',
          'doctorName': 'د. خالد النخلاني',
          'lastMessage': 'سأتصل بك غداً صباحاً',
          'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
          'unreadCount': 0,
          'image': ImageKit.doctor2,
        },
        {
          'id': '3',
          'doctorName': 'د. أسماء الهندي',
          'lastMessage': 'تم تأكيد موعدك يوم الأحد',
          'lastMessageTime': DateTime.now().subtract(const Duration(hours: 5)),
          'unreadCount': 1,
          'image': ImageKit.doctor3,
        },
        {
          'id': '4',
          'doctorName': 'د. محمد العلاي',
          'lastMessage': 'نحتاج إلى تحليل جديد',
          'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
          'unreadCount': 0,
          'image': ImageKit.doctor4,
        },
        {
          'id': '5',
          'doctorName': 'د. فاطمة صديقي',
          'lastMessage': 'كيف تشعر اليوم؟',
          'lastMessageTime': DateTime.now().subtract(const Duration(days: 2)),
          'unreadCount': 0,
          'image': ImageKit.doctor5,
        },
      ]);
      _isLoading = false;
    });
  }

  // ✅ دالة تنسيق الوقت
  String _formatTime(dynamic time) {
    if (time == null) return '';

    DateTime dateTime;
    if (time is Timestamp) {
      dateTime = time.toDate();
    } else if (time is DateTime) {
      dateTime = time;
    } else {
      return '';
    }

    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${dateTime.day}/${dateTime.month}';
  }

  // ✅ دالة الانتقال للدردشة
  void _navigateToChat(String chatId, String userName, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chatId,
          userName: userName,
          userId: 'user_123',
          isDoctor: false,
        ),
      ),
    );
  }

  // ✅ دالة بدء محادثة جديدة
  void _startNewChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔍 ابحث عن طبيب لبدء محادثة جديدة'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ✅ دالة بناء عنصر المحادثة
  Widget _buildChatItem(Map<String, dynamic> chat, bool isDark) {
    final isDoctor = chat.containsKey('doctorName');
    final name = isDoctor ? chat['doctorName'] : chat['patientName'];
    final image = chat['image'] ?? ImageKit.doctor1;
    final lastMessage = chat['lastMessage'] ?? 'ابدأ المحادثة';
    final unreadCount = chat['unreadCount'] ?? 0;
    final time = _formatTime(chat['lastMessageTime']);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                image,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          name ?? 'مستخدم',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ),
        onTap: () => _navigateToChat(
          chat['id'] as String,
          name ?? 'مستخدم',
          image,
        ),
      ),
    );
  }

  // ✅ دالة عرض حالة فارغة
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد محادثات',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('محادثة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔍 ابحث عن محادثة...'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? _buildEmptyState(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _chats.length,
                  itemBuilder: (context, index) {
                    final chat = _chats[index];
                    return _buildChatItem(chat, isDark);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }
}
