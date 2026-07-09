import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_event.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_state.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ✅ بيانات القصص (Stories) العلوية
  final List<Map<String, dynamic>> _stories = [
    {'name': 'قصتي', 'isMe': true, 'color': Colors.grey},
    {'name': 'د. أحمد', 'isMe': false, 'color': Colors.teal},
    {'name': 'صيدلية الشفاء', 'isMe': false, 'color': Colors.amber},
    {'name': 'مستشفى الثورة', 'isMe': false, 'color': Colors.brown},
    {'name': 'مختبرات العولقي', 'isMe': false, 'color': Colors.blue},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
    
    // ✅ تحميل المحادثات من Firebase
    _loadChats();
  }

  void _loadChats() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final isDoctor = user.displayName?.contains('د.') ?? false;
    context.read<ChatBloc>().add(LoadChatList(
      userId: user.uid,
      role: isDoctor ? 'doctor' : 'patient',
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    context.read<ChatBloc>().add(const StopListening());
    super.dispose();
  }

  // ✅ نافذة خيارات النقاط الثلاث
  void _showMenuOptions(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(16, 80, 100, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      items: [
        _buildPopupMenuItem('قائمة بث جديدة', Icons.campaign_outlined),
        _buildPopupMenuItem('مجموعة جديدة', Icons.group_add_outlined),
        _buildPopupMenuItem('الرسائل المميزة', Icons.star_border_rounded),
        _buildPopupMenuItem('الإعدادات', Icons.settings_outlined),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(String title, IconData icon) {
    return PopupMenuItem(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(title, style: const TextStyle(fontFamily: 'NotoSansArabicUI', fontSize: 14)),
          const SizedBox(width: 12),
          Icon(icon, color: Colors.teal, size: 20),
        ],
      ),
    );
  }

  // ✅ شيت إنشاء محادثة جديدة
  void _showNewChatSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F9F9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text(
              'بدء محادثة جديدة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D5257)),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.teal),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'ابحث عن مستخدم...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSheetActionTile('إنشاء مجموعة جديدة', Icons.group_add, () {}),
            const SizedBox(height: 12),
            _buildSheetActionTile('قائمة بث جديدة', Icons.campaign, () {}),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetActionTile(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(width: 16),
            CircleAvatar(
              backgroundColor: const Color(0xFFE2F4F4),
              child: Icon(icon, color: const Color(0xFF0D5257)),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ التنقل إلى شاشة المحادثة
  void _navigateToChat(String chatId, String userName, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatId: chatId,
          userName: userName,
          userId: userId,
          isDoctor: false,
        ),
      ),
    );
  }

  // ✅ دوال مساعدة للأيقونات
  Color _getCategoryColor(String type) {
    switch (type) {
      case 'doctor': return Colors.teal;
      case 'bot': return Colors.blueGrey;
      case 'pharmacy': return Colors.amber.shade700;
      case 'group': return Colors.purple;
      case 'hospital': return Colors.red;
      case 'lab': return Colors.blue;
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type) {
      case 'doctor': return Icons.person;
      case 'bot': return Icons.smart_button_rounded;
      case 'pharmacy': return Icons.local_pharmacy;
      case 'group': return Icons.group;
      case 'hospital': return Icons.local_hospital;
      case 'lab': return Icons.science;
      default: return Icons.chat;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        if (date.day == now.day && date.month == now.month && date.year == now.year) {
          return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        } else if (date.day == now.day - 1) {
          return 'أمس';
        } else {
          return '${date.day}/${date.month}';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'المحادثات',
          style: TextStyle(color: Color(0xFF0D5257), fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0D5257)),
            onPressed: () => _showMenuOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF0D5257)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFF0D5257)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // ✅ القصص (Stories)
              _buildStoriesRow(isDark),
              
              // ✅ تبويبات
              TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'NotoSansArabicUI'),
                tabs: const [
                  Tab(text: 'الحالات'),
                  Tab(text: 'المكالمات'),
                  Tab(text: 'المحادثات'),
                ],
              ),
              
              // ✅ المحتوى حسب التبويب
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ✅ تبويب الحالات
                    _buildStatusTab(isDark),
                    
                    // ✅ تبويب المكالمات
                    _buildCallsTab(isDark),
                    
                    // ✅ تبويب المحادثات (مع Firebase)
                    _buildChatsTab(state, isDark, primaryColor),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatSheet,
        backgroundColor: primaryColor,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // ============================================================
  // 📸 القصص (Stories)
  // ============================================================
  Widget _buildStoriesRow(bool isDark) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: story['isMe'] ? Colors.grey.shade300 : const Color(0xFF0D5257),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: (story['color'] as Color).withOpacity(0.1),
                        child: Icon(
                          story['isMe'] ? Icons.add : Icons.person,
                          color: story['color'],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story['name'],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 📞 تبويب المكالمات
  // ============================================================
  Widget _buildCallsTab(bool isDark) {
    final calls = [
      {'name': 'د. أحمد المولد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'incoming': true},
      {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'incoming': false},
      {'name': 'مستشفى الثورة', 'type': 'audio', 'status': 'answered', 'time': 'منذ ساعة', 'duration': '2:45', 'incoming': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final isMissed = call['status'] == 'missed';
        final isVideo = call['type'] == 'video';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  isVideo ? Icons.videocam : Icons.phone,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call['name'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          isMissed ? Icons.phone_missed : Icons.phone_callback,
                          size: 14,
                          color: isMissed ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isMissed ? 'مكالمة فائتة' : (call['duration'] as String).isNotEmpty ? 'واردة' : 'تم الرد',
                          style: TextStyle(
                            color: isMissed ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          call['time'] as String,
                          style: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔵 تبويب الحالات
  // ============================================================
  Widget _buildStatusTab(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حالات',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 💬 تبويب المحادثات (مع Firebase)
  // ============================================================
  Widget _buildChatsTab(ChatState state, bool isDark, Color primaryColor) {
    // ✅ حالة التحميل
    if (state is ChatLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ حالة عرض المحادثات
    if (state is ChatListLoadedState) {
      final chats = state.chats;
      
      // ✅ إذا كانت القائمة فارغة
      if (chats.isEmpty) {
        return _buildEmptyState(isDark);
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: chats.length,
        itemBuilder: (context, index) {
          final chat = chats[index];
          final isDoctor = chat['doctorId'] == FirebaseAuth.instance.currentUser?.uid;
          final otherName = isDoctor ? chat['patientName'] : chat['doctorName'];
          final otherId = isDoctor ? chat['patientId'] : chat['doctorId'];
          final lastMessage = chat['lastMessage'] ?? 'ابدأ المحادثة';
          final lastTime = _formatTime(chat['lastMessageTime']);
          final chatType = isDoctor ? 'patient' : 'doctor';
          
          return GestureDetector(
            onTap: () => _navigateToChat(chat['id'], otherName ?? 'مستخدم', otherId ?? ''),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastTime,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (chat['unreadCount'] != null && chat['unreadCount'] > 0)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                            child: Text(
                              '${chat['unreadCount']}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ]
                    )
                  ],
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      otherName ?? 'مستخدم',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: CircleAvatar(
                  radius: 24,
                  backgroundColor: _getCategoryColor(chatType).withOpacity(0.1),
                  child: Icon(
                    _getCategoryIcon(chatType),
                    color: _getCategoryColor(chatType),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // ✅ حالة الخطأ
    if (state is ChatErrorState) {
      return _buildErrorState(state.message, isDark);
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // 🟡 حالة فارغة
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
            onPressed: _showNewChatSheet,
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('محادثة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
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
  // 🔴 حالة خطأ
  // ============================================================
  Widget _buildErrorState(String message, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadChats,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
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
}
