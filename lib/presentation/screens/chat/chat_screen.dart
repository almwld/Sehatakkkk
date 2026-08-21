import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/chat/calls_screen.dart';
import 'package:sehatak/presentation/screens/chat/updates_screen.dart';
import 'package:sehatak/presentation/screens/chat/search_screen.dart';

class ChatScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ChatScreen({super.key, this.scrollController});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String _userName = 'مستخدم';

  // ✅ قائمة الدردشات (بيانات وهمية + Firebase)
  final List<Map<String, dynamic>> _mockChats = [
    {
      'id': '1',
      'name': 'د. أحمد المؤيد',
      'lastMessage': 'مرحباً، كيف يمكنني مساعدتك اليوم؟',
      'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
      'unreadCount': 2,
      'image': ImageKit.doctor1,
      'isOnline': true,
      'isDoctor': true,
      'specialty': 'باطنية',
    },
    {
      'id': '2',
      'name': 'د. خالد النخلاني',
      'lastMessage': 'سأتصل بك غداً صباحاً',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
      'unreadCount': 0,
      'image': ImageKit.doctor2,
      'isOnline': false,
      'isDoctor': true,
      'specialty': 'قلبية',
    },
    {
      'id': '3',
      'name': 'د. أسماء الهندي',
      'lastMessage': 'تم تأكيد موعدك يوم الأحد',
      'lastMessageTime': DateTime.now().subtract(const Duration(hours: 5)),
      'unreadCount': 1,
      'image': ImageKit.doctor3,
      'isOnline': true,
      'isDoctor': true,
      'specialty': 'أطفال',
    },
    {
      'id': '4',
      'name': 'د. محمد العلاي',
      'lastMessage': 'نحتاج إلى تحليل جديد',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 1)),
      'unreadCount': 0,
      'image': ImageKit.doctor4,
      'isOnline': false,
      'isDoctor': true,
      'specialty': 'أنف وأذن وحنجرة',
    },
    {
      'id': '5',
      'name': 'د. فاطمة صديقي',
      'lastMessage': 'كيف تشعر اليوم؟',
      'lastMessageTime': DateTime.now().subtract(const Duration(days: 2)),
      'unreadCount': 0,
      'image': ImageKit.doctor5,
      'isOnline': true,
      'isDoctor': true,
      'specialty': 'نساء وولادة',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _loadUserData();
    _loadChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        _isLoggedIn = user != null;
        if (user != null) {
          _userName = user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم';
        }
      });
    }
  }

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
                'name': data['doctorName'] ?? data['patientName'] ?? 'طبيب',
                'lastMessage': data['lastMessage'] ?? 'ابدأ المحادثة',
                'lastMessageTime': data['lastMessageTime'],
                'unreadCount': data['unreadCount'] ?? 0,
                'image': data['image'] ?? ImageKit.doctor1,
                'isOnline': data['isOnline'] ?? false,
                'isDoctor': data['isDoctor'] ?? true,
                'specialty': data['specialty'] ?? 'طبيب عام',
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

    // ✅ استخدام البيانات الوهمية
    setState(() {
      _chats.clear();
      _chats.addAll(_mockChats);
      _isLoading = false;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'م';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return name[0];
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
      Colors.brown,
      Colors.cyan,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

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

  void _navigateToChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          chatId: chat['id'] as String,
          userName: chat['name'] as String,
          userId: 'user_123',
          isDoctor: chat['isDoctor'] as bool? ?? false,
        ),
      ),
    );
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0b141a),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'بدء محادثة جديدة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildNewChatOption(
              icon: Icons.person_add,
              title: 'محادثة فردية',
              subtitle: 'ابدأ محادثة مع طبيب',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🔍 ابحث عن طبيب لبدء محادثة'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildNewChatOption(
              icon: Icons.group_add,
              title: 'مجموعة جديدة',
              subtitle: 'أنشئ مجموعة دردشة',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('👥 جاري إنشاء مجموعة...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildNewChatOption(
              icon: Icons.medical_services,
              title: 'استشارة طبية',
              subtitle: 'احصل على استشارة فورية',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🩺 جاري البحث عن طبيب متاح...'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF202c33),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0b141a) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ✅ شريط التبويبات
          Container(
            color: isDark ? const Color(0xFF0b141a) : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: isDark ? Colors.white : AppColors.primary,
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'المحادثات'),
                Tab(text: 'المكالمات'),
                Tab(text: 'الحالات'),
              ],
            ),
          ),
          // ✅ المحتوى
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(isDark),
                const CallsScreen(),
                const UpdatesScreen(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton(
              onPressed: _startNewChat,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            ),
    );
  }

  // ============================================================
  // 💬 تبويب المحادثات
  // ============================================================

  Widget _buildChatsTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chats.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return Column(
      children: [
        // ✅ شريط البحث
        Padding(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202c33) : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'ابحث عن محادثة...',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // ✅ قائمة المحادثات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _chats.length,
            itemBuilder: (context, index) {
              final chat = _chats[index];
              return _buildChatTile(chat, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, bool isDark) {
    final name = chat['name'] as String;
    final image = chat['image'] as String;
    final lastMessage = chat['lastMessage'] as String;
    final unreadCount = chat['unreadCount'] as int;
    final time = _formatTime(chat['lastMessageTime']);
    final isOnline = chat['isOnline'] as bool? ?? false;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _navigateToChat(chat);
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الضغط المطول على: $name'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // ✅ صورة المستخدم
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: _getAvatarColor(name),
                  backgroundImage: image.isNotEmpty && image.startsWith('http')
                      ? NetworkImage(image)
                      : null,
                  child: image.isEmpty || !image.startsWith('http')
                      ? Text(
                          _getInitials(name),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ معلومات المحادثة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: unreadCount > 0
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
}
