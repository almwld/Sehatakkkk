import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _chats = [];
  final List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;

  // ============================================================
  // ✅ قائمة المكالمات
  // ============================================================
  final List<Map<String, dynamic>> _calls = [
    {
      'name': 'د. أحمد المولد',
      'type': 'audio',
      'status': 'answered',
      'time': '10:30 ص',
      'duration': '5:23',
      'image': ImageKit.doctor1,
      'doctorId': 'doc1',
      'date': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'name': 'د. خالد النخلاني',
      'type': 'video',
      'status': 'missed',
      'time': 'أمس',
      'duration': '',
      'image': ImageKit.doctor2,
      'doctorId': 'doc2',
      'date': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'name': 'د. أسماء الهندي',
      'type': 'audio',
      'status': 'incoming',
      'time': 'منذ ساعة',
      'duration': '',
      'image': ImageKit.doctor3,
      'doctorId': 'doc3',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'name': 'د. محمد العلاي',
      'type': 'video',
      'status': 'answered',
      'time': 'منذ 3 ساعات',
      'duration': '12:30',
      'image': ImageKit.doctor4,
      'doctorId': 'doc4',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'name': 'د. فاطمة صديقي',
      'type': 'audio',
      'status': 'missed',
      'time': 'منذ 5 ساعات',
      'duration': '',
      'image': ImageKit.doctor5,
      'doctorId': 'doc5',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'name': 'د. سارة العمري',
      'type': 'video',
      'status': 'incoming',
      'time': 'الآن',
      'duration': '',
      'image': ImageKit.doctor6,
      'doctorId': 'doc6',
      'date': DateTime.now(),
    },
  ];

  // ============================================================
  // ✅ دوال المكالمات
  // ============================================================

  void _acceptCall(Map<String, dynamic> call) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم قبول المكالمة'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: call['name'] as String,
          doctorId: call['doctorId'] as String,
          isVideo: call['type'] == 'video',
        ),
      ),
    );
  }

  void _rejectCall(Map<String, dynamic> call) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('❌ تم رفض المكالمة'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _startCall(Map<String, dynamic> call, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: call['name'] as String,
          doctorId: call['doctorId'] as String,
          isVideo: isVideo,
        ),
      ),
    );
  }

  // ============================================================
  // ✅ تحميل المحادثات
  // ============================================================

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _loadChats();
    _loadStories();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .get();

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
          };
        }).toList());
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // بيانات وهمية للاختبار
      setState(() {
        _chats.addAll([
          {
            'id': '1',
            'doctorName': 'د. أحمد المؤيد',
            'lastMessage': 'مرحباً، كيف يمكنني مساعدتك؟',
            'lastMessageTime': DateTime.now().subtract(const Duration(minutes: 5)),
            'unreadCount': 2,
            'image': ImageKit.doctor1,
          },
          {
            'id': '2',
            'doctorName': 'د. خالد النخلاني',
            'lastMessage': 'سأتصل بك غداً',
            'lastMessageTime': DateTime.now().subtract(const Duration(hours: 2)),
            'unreadCount': 0,
            'image': ImageKit.doctor2,
          },
          {
            'id': '3',
            'doctorName': 'د. أسماء الهندي',
            'lastMessage': 'تم تأكيد موعدك',
            'lastMessageTime': DateTime.now().subtract(const Duration(hours: 5)),
            'unreadCount': 1,
            'image': ImageKit.doctor3,
          },
        ]);
      });
    }
  }

  Future<void> _loadStories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      setState(() {
        _stories.clear();
        _stories.addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'userId': data['userId'] ?? '',
            'userName': data['userName'] ?? 'مستخدم',
            'userImage': data['userImage'] ?? '',
            'image': data['image'] ?? '',
            'text': data['text'] ?? '',
            'timestamp': data['timestamp'],
            'viewers': data['viewers'] ?? [],
          };
        }).toList());
      });
    } catch (e) {
      // بيانات وهمية
      setState(() {
        _stories.addAll([
          {'name': 'د. أحمد', 'image': ImageKit.doctor1, 'isOnline': true},
          {'name': 'د. خالد', 'image': ImageKit.doctor2, 'isOnline': false},
          {'name': 'د. أسماء', 'image': ImageKit.doctor3, 'isOnline': true},
          {'name': 'د. محمد', 'image': ImageKit.doctor4, 'isOnline': false},
        ]);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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

  // ============================================================
  // 🎨 بناء الواجهة الرئيسية
  // ============================================================

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
            onPressed: _showSearch,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'حالات'),
            Tab(text: 'المكالمات'),
            Tab(text: 'المحادثات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoriesTab(isDark),
          _buildCallsTab(isDark), // ✅ تبويب المكالمات الجديد
          _buildChatsTab(isDark),
        ],
      ),
    );
  }

  // ============================================================
  // 📸 تبويب الحالات
  // ============================================================

  Widget _buildStoriesTab(bool isDark) {
    return Column(
      children: [
        // ✅ عرض دائري للحالات
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: _stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAddStoryButton(isDark);
              }
              final story = _stories[index - 1];
              return _buildStoryCircle(story, isDark);
            },
          ),
        ),
        // ✅ قائمة الحالات
        Expanded(
          child: _stories.isEmpty
              ? _buildEmptyStories(isDark)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    return _buildStoryListItem(story, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddStoryButton(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Icon(Icons.add, color: AppColors.primary, size: 30),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'قصتي',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCircle(Map<String, dynamic> story, bool isDark) {
    final isOnline = story['isOnline'] as bool? ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isOnline ? AppColors.primary : Colors.grey[400]!,
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.network(
                    story['image'] ?? ImageKit.doctor1,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                      child: Icon(Icons.person, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            story['name'] ?? 'مستخدم',
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStoryListItem(Map<String, dynamic> story, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              story['image'] ?? ImageKit.doctor1,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 40,
                height: 40,
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[200],
                child: Icon(Icons.person, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story['name'] ?? 'مستخدم',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  story['text'] ?? 'قصة جديدة',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTime(story['timestamp'] as DateTime?),
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStories(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle_outlined,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حالات',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف حالة جديدة',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📞 تبويب المكالمات (NEW!)
  // ============================================================

  Widget _buildCallsTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _calls.length,
      itemBuilder: (context, index) {
        final call = _calls[index];
        final isMissed = call['status'] == 'missed';
        final isIncoming = call['status'] == 'incoming';
        final isVideo = call['type'] == 'video';
        final isAnswered = call['status'] == 'answered';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
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
            border: isIncoming
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              // ✅ صورة الطبيب
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      call['image'] as String,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 50,
                        height: 50,
                        color: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          isVideo ? Icons.videocam : Icons.phone,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // ✅ علامة مكالمة واردة
                  if (isIncoming)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.call_received,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  // ✅ علامة مكالمة فائتة
                  if (isMissed)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.phone_missed,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // ✅ معلومات المكالمة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      call['name'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.end,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        // ✅ حالة المكالمة
                        Icon(
                          isMissed
                              ? Icons.phone_missed
                              : isAnswered
                                  ? Icons.phone_callback
                                  : isIncoming
                                      ? Icons.call_received
                                      : Icons.phone,
                          size: 14,
                          color: isMissed
                              ? Colors.red
                              : isAnswered
                                  ? Colors.green
                                  : isIncoming
                                      ? AppColors.primary
                                      : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMissed
                              ? 'مكالمة فائتة'
                              : isAnswered
                                  ? (call['duration'] as String).isNotEmpty
                                      ? 'واردة'
                                      : 'تم الرد'
                                  : isIncoming
                                      ? 'مكالمة واردة...'
                                      : 'مكالمة',
                          style: TextStyle(
                            color: isMissed
                                ? Colors.red
                                : isAnswered
                                    ? (isDark ? Colors.grey[400] : Colors.grey[600])
                                    : isIncoming
                                        ? AppColors.primary
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        // ✅ الوقت
                        Text(
                          call['time'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    // ✅ مدة المكالمة
                    if (isAnswered && (call['duration'] as String).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Icon(
                              Icons.timer,
                              size: 12,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              call['duration'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // ✅ أزرار الإجراء
              if (isIncoming)
                // ✅ مكالمة واردة - أزرار قبول ورفض
                Column(
                  children: [
                    // ✅ زر قبول
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.call, color: Colors.white, size: 18),
                        onPressed: () => _acceptCall(call),
                        padding: EdgeInsets.zero,
                        splashRadius: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // ✅ زر رفض
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.white, size: 18),
                        onPressed: () => _rejectCall(call),
                        padding: EdgeInsets.zero,
                        splashRadius: 18,
                      ),
                    ),
                  ],
                )
              else
                // ✅ مكالمة عادية - زر اتصال
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      isVideo ? Icons.videocam : Icons.phone,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    onPressed: () => _startCall(call, isVideo),
                    padding: EdgeInsets.zero,
                    splashRadius: 20,
                  ),
                ),
            ],
          ),
        );
      },
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

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        final isDoctor = chat.containsKey('doctorName');
        final name = isDoctor ? chat['doctorName'] : chat['patientName'];
        final image = chat['image'] ?? ImageKit.doctor1;
        final lastMessage = chat['lastMessage'] ?? 'ابدأ المحادثة';
        final unreadCount = chat['unreadCount'] ?? 0;
        final time = chat['lastMessageTime'] != null
            ? _formatTime(chat['lastMessageTime'] as DateTime)
            : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
      },
    );
  }

  // ============================================================
  // 📭 حالة فارغة
  // ============================================================

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
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔍 ابحث عن طبيب لبدء محادثة'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('محادثة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔍 البحث
  // ============================================================

  void _showSearch() {
    showSearch(
      context: context,
      delegate: _ChatSearchDelegate(_chats),
    );
  }

  // ============================================================
  // 🛠️ مساعدات
  // ============================================================

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${time.day}/${time.month}';
  }
}

// ============================================================
// 🔍 Delegate للبحث
// ============================================================

class _ChatSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> chats;

  _ChatSearchDelegate(this.chats);

  @override
  String get searchFieldLabel => 'ابحث عن محادثة...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildResults();
  }

  Widget _buildResults() {
    final results = chats.where((chat) {
      final name = chat['doctorName'] as String? ?? chat['patientName'] as String? ?? '';
      final message = chat['lastMessage'] as String? ?? '';
      return name.toLowerCase().contains(query.toLowerCase()) ||
          message.toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('لا توجد نتائج لـ "$query"'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        final name = chat['doctorName'] as String? ?? chat['patientName'] as String? ?? 'مستخدم';
        final message = chat['lastMessage'] as String? ?? 'ابدأ المحادثة';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0] : 'م',
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          title: Text(name),
          subtitle: Text(message),
          onTap: () {
            close(context, null);
            // فتح المحادثة
          },
        );
      },
    );
  }
}
