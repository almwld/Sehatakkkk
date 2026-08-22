import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final List<Map<String, dynamic>> _chats = [];
  final List<Map<String, dynamic>> _mockChats = [
    {'id': '1', 'name': 'د. أحمد المؤيد', 'lastMessage': 'مرحباً، كيف يمكنني مساعدتك؟', 'time': DateTime.now().subtract(const Duration(minutes: 5)), 'unread': 2, 'image': ImageKit.doctor1, 'isOnline': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'lastMessage': 'سأتصل بك غداً', 'time': DateTime.now().subtract(const Duration(hours: 2)), 'unread': 0, 'image': ImageKit.doctor2, 'isOnline': false},
    {'id': '3', 'name': 'د. أسماء الهندي', 'lastMessage': 'تم تأكيد موعدك', 'time': DateTime.now().subtract(const Duration(hours: 5)), 'unread': 1, 'image': ImageKit.doctor3, 'isOnline': true},
  ];

  final List<Map<String, dynamic>> _calls = [
    {'name': 'د. أحمد المؤيد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'image': ImageKit.doctor1, 'doctorId': 'doc1'},
    {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'image': ImageKit.doctor2, 'doctorId': 'doc2'},
    {'name': 'د. أسماء الهندي', 'type': 'audio', 'status': 'incoming', 'time': 'منذ ساعة', 'duration': '', 'image': ImageKit.doctor3, 'doctorId': 'doc3'},
    {'name': 'د. محمد العلاي', 'type': 'video', 'status': 'answered', 'time': 'منذ 3 ساعات', 'duration': '12:30', 'image': ImageKit.doctor4, 'doctorId': 'doc4'},
    {'name': 'د. فاطمة صديقي', 'type': 'audio', 'status': 'missed', 'time': 'منذ 5 ساعات', 'duration': '', 'image': ImageKit.doctor5, 'doctorId': 'doc5'},
  ];

  bool _isLoading = true;
  bool _isOffline = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    _loadChats();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadChats();
    }
  }

  void _loadChats() {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _chats.clear();
        _chats.addAll(_mockChats);
        _isLoading = false;
        _isOffline = true;
      });
      return;
    }

    FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .get()
        .then((snapshot) {
          if (snapshot.docs.isEmpty) {
            setState(() {
              _chats.clear();
              _chats.addAll(_mockChats);
              _isLoading = false;
              _isOffline = true;
            });
            return;
          }
          setState(() {
            _chats.clear();
            _chats.addAll(snapshot.docs.map((doc) {
              final data = doc.data();
              return {
                'id': doc.id,
                'name': data['doctorName'] ?? data['patientName'] ?? 'طبيب',
                'lastMessage': data['lastMessage'] ?? 'ابدأ المحادثة',
                'time': data['lastMessageTime']?.toDate() ?? DateTime.now(),
                'unread': data['unreadCount']?[user.uid] ?? 0,
                'image': data['image'] ?? ImageKit.doctor1,
                'isOnline': data['isOnline'] ?? false,
              };
            }).toList());
            _isLoading = false;
            _isOffline = false;
          });
        })
        .catchError((e) {
          setState(() {
            _chats.clear();
            _chats.addAll(_mockChats);
            _isLoading = false;
            _isOffline = true;
            _errorMessage = 'حدث خطأ في تحميل المحادثات';
          });
        });
  }

  void _showToast(String message, {bool isError = false}) {
    if (isError) {
      ToastService.showError(message);
    } else {
      ToastService.showSuccess(message);
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${time.day}/${time.month}';
  }

  Widget _buildCallsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _calls.length,
      itemBuilder: (context, index) {
        final call = _calls[index];
        final isMissed = call['status'] == 'missed';
        final isIncoming = call['status'] == 'incoming';
        final isVideo = call['type'] == 'video';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
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
                        child: Icon(isVideo ? Icons.videocam : Icons.phone, color: AppColors.primary),
                      ),
                    ),
                  ),
                  if (isIncoming)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        child: const Icon(Icons.call_received, color: Colors.white, size: 12),
                      ),
                    ),
                  if (isMissed)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.phone_missed, color: Colors.white, size: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      call['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      textAlign: TextAlign.end,
                    ),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Icon(
                          isMissed ? Icons.phone_missed : isIncoming ? Icons.call_received : Icons.phone_callback,
                          size: 14,
                          color: isMissed ? Colors.red : isIncoming ? AppColors.primary : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMissed ? 'مكالمة فائتة' : isIncoming ? 'مكالمة واردة...' : 'واردة',
                          style: TextStyle(
                            color: isMissed ? Colors.red : isIncoming ? AppColors.primary : Colors.green,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          call['time'] as String,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isIncoming)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.green,
                      child: IconButton(
                        icon: const Icon(Icons.call, color: Colors.white, size: 18),
                        onPressed: () {
                          _showToast('✅ تم قبول المكالمة');
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
                        },
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.white, size: 18),
                        onPressed: () => _showToast('❌ تم رفض المكالمة', isError: true),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(isVideo ? Icons.videocam : Icons.phone, color: AppColors.primary, size: 20),
                    onPressed: () {
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
                    },
                    padding: EdgeInsets.zero,
                  ),
                ),
            ],
          ),
        );
      },
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'الحالات'),
            Tab(text: 'المكالمات'),
            Tab(text: 'المحادثات'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStoriesTab(isDark),
          _buildCallsTab(),
          _buildChatsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildStoriesTab(bool isDark) {
    final stories = [
      {'name': 'د. أحمد', 'image': ImageKit.doctor1, 'isOnline': true},
      {'name': 'د. خالد', 'image': ImageKit.doctor2, 'isOnline': false},
      {'name': 'د. أسماء', 'image': ImageKit.doctor3, 'isOnline': true},
    ];

    return Column(
      children: [
        Container(
          height: 100,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: stories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
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
                      Text('قصتي', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                    ],
                  ),
                );
              }
              final story = stories[index - 1];
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
                              color: story['isOnline'] as bool ? AppColors.primary : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              story['image'] as String,
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
                        if (story['isOnline'] as bool)
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
                    Text(story['name'] as String, style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ],
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        story['image'] as String,
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
                            story['name'] as String,
                            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                          ),
                          Text(
                            'قصة جديدة',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ToastService.showSuccess('✅ تم مشاركة الحالة'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.share, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text('مشاركة', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChatsTab(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[300]),
            const SizedBox(height: 16),
            Text('لا توجد محادثات', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18)),
            const SizedBox(height: 8),
            Text('ابدأ محادثة جديدة مع طبيبك', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        final time = _formatTime(chat['time'] as DateTime);
        final unread = chat['unread'] as int;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  chatId: chat['id'] as String,
                  userName: chat['name'] as String,
                  userId: 'user_123',
                  isDoctor: false,
                ),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(chat['image'] as String),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    if (chat['isOnline'] as bool)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          Text(time, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[500] : Colors.grey[400])),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat['lastMessage'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: unread > 0 ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unread > 0)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                              child: Text(
                                '$unread',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
      },
    );
  }
}
