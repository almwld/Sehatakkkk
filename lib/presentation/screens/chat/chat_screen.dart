import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/utils/icon_helper.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_event.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_state.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _stories = [
    {'name': 'قصتي', 'isMe': true, 'color': Colors.grey, 'image': null, 'hasStory': false},
    {'name': 'د. أحمد المولد', 'isMe': false, 'color': Colors.teal, 'image': 'assets/images/doctors/doctor_1.png', 'hasStory': true},
    {'name': 'د. خالد النخلاني', 'isMe': false, 'color': Colors.teal, 'image': 'assets/images/doctors/doctor_2.png', 'hasStory': true},
    {'name': 'د. أسماء الهندي', 'isMe': false, 'color': Colors.teal, 'image': 'assets/images/doctors/doctor_3.png', 'hasStory': true},
    {'name': 'صيدلية الشفاء', 'isMe': false, 'color': Colors.amber, 'image': 'assets/images/pharmacies/pharmacy_1.png', 'hasStory': false},
    {'name': 'مستشفى الثورة', 'isMe': false, 'color': Colors.brown, 'image': 'assets/images/hospitals/hospital_1.png', 'hasStory': false},
    {'name': 'مختبرات العولقي', 'isMe': false, 'color': Colors.blue, 'image': 'assets/images/labs/lab_1.png', 'hasStory': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 2);
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

  void _showMenuOptions(BuildContext context) {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(16, 80, 100, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      items: [
        _buildPopupMenuItem('قائمة بث جديدة', Icons.campaign_outlined, () {
          Navigator.pop(context);
          _showNewBroadcastSheet();
        }),
        _buildPopupMenuItem('مجموعة جديدة', Icons.group_add_outlined, () {
          Navigator.pop(context);
          _showNewGroupSheet();
        }),
        _buildPopupMenuItem('الرسائل المميزة', Icons.star_border_rounded, () {
          Navigator.pop(context);
          _showStarredMessages();
        }),
        _buildPopupMenuItem('الإعدادات', Icons.settings_outlined, () {
          Navigator.pop(context);
          _showChatSettings();
        }),
      ],
    );
  }

  PopupMenuItem _buildPopupMenuItem(String title, IconData icon, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
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

  void _showNewBroadcastSheet() {
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
              'قائمة بث جديدة',
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
                        hintText: 'ابحث عن جهات اتصال...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSheetActionTile('إنشاء قائمة بث جديدة', Icons.campaign, () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء قائمة بث جديدة'), backgroundColor: Colors.green),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNewGroupSheet() {
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
              'مجموعة جديدة',
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
                        hintText: 'ابحث عن جهات اتصال...',
                        hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSheetActionTile('إنشاء مجموعة جديدة', Icons.group_add, () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء مجموعة جديدة'), backgroundColor: Colors.green),
              );
            }),
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

  void _showStarredMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الرسائل المميزة'), backgroundColor: Colors.amber),
    );
  }

  void _showChatSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('إعدادات المحادثات'), backgroundColor: Colors.teal),
    );
  }

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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('بحث في المحادثات'), backgroundColor: Colors.teal),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera_outlined, color: Color(0xFF0D5257)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فتح الكاميرا'), backgroundColor: Colors.teal),
              );
            },
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
              _buildStoriesRow(isDark),
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
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatusTab(isDark),
                    _buildCallsTab(isDark),
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
  // 📸 القصص (Stories) - مع أيقونات حقيقية
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
          final hasStory = story['hasStory'] ?? false;
          final imagePath = story['image'] as String?;

          return GestureDetector(
            onTap: () {
              if (story['isMe'] == true) {
                // ✅ إضافة قصة جديدة
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('إضافة قصة جديدة'), backgroundColor: Colors.teal),
                );
              } else if (hasStory) {
                // ✅ عرض القصة
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('عرض قصة ${story['name']}'), backgroundColor: Colors.teal),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('لا توجد قصص لـ ${story['name']}'), backgroundColor: Colors.grey),
                );
              }
            },
            child: Padding(
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
                            color: story['isMe'] ? Colors.grey.shade300 : (hasStory ? const Color(0xFF0D5257) : Colors.grey.shade300),
                            width: hasStory ? 2.5 : 1.5,
                          ),
                        ),
                        child: imagePath != null
                            ? CircleAvatar(
                                radius: 26,
                                backgroundImage: AssetImage(imagePath),
                                onBackgroundImageError: (_, __) {},
                              )
                            : CircleAvatar(
                                radius: 26,
                                backgroundColor: (story['color'] as Color).withOpacity(0.1),
                                child: Icon(
                                  story['isMe'] ? Icons.add : Icons.person,
                                  color: story['color'],
                                ),
                              ),
                      ),
                      if (story['isMe'] == true)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D5257),
                              shape: BoxShape.circle,
                              border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story['name'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 📞 تبويب المكالمات - مع أيقونات حقيقية
  // ============================================================
  Widget _buildCallsTab(bool isDark) {
    final calls = [
      {'name': 'د. أحمد المولد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'incoming': true, 'image': 'assets/images/doctors/doctor_1.png'},
      {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'incoming': false, 'image': 'assets/images/doctors/doctor_2.png'},
      {'name': 'د. أسماء الهندي', 'type': 'audio', 'status': 'answered', 'time': 'منذ ساعة', 'duration': '2:45', 'incoming': true, 'image': 'assets/images/doctors/doctor_3.png'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final isMissed = call['status'] == 'missed';
        final isVideo = call['type'] == 'video';
        final imagePath = call['image'] as String?;

        return GestureDetector(
          onTap: () {
            // ✅ بدء مكالمة
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CallScreen(
                  chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                  doctorName: call['name'] as String,
                  doctorId: 'doctor_123',
                  isVideo: isVideo,
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
            ),
            child: Row(
              children: [
                // ✅ صورة الملف الشخصي
                imagePath != null
                    ? CircleAvatar(
                        radius: 22,
                        backgroundImage: AssetImage(imagePath),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Icon(
                          isVideo ? Icons.videocam : Icons.phone,
                          color: AppColors.primary,
                          size: 20,
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
                          // ✅ زر إعادة الاتصال
                          if (isMissed)
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.green, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('جاري الاتصال بـ ${call['name']}...'), backgroundColor: Colors.green),
                                );
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
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
          const SizedBox(height: 8),
          Text(
            'شارك حالتك مع الآخرين',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('إضافة حالة جديدة'), backgroundColor: Colors.teal),
              );
            },
            icon: const Icon(Icons.add_photo_alternate_rounded),
            label: const Text('إضافة حالة'),
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
  // 💬 تبويب المحادثات (مع Firebase)
  // ============================================================
  Widget _buildChatsTab(ChatState state, bool isDark, Color primaryColor) {
    if (state is ChatLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ChatListLoadedState) {
      final chats = state.chats;
      
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
          final unreadCount = chat['unreadCount'] ?? 0;
          final chatImage = chat['doctorImage'] ?? chat['patientImage'] ?? '';
          
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
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ]
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
                trailing: chatImage.isNotEmpty
                    ? CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(chatImage),
                        onBackgroundImageError: (_, __) {},
                      )
                    : CircleAvatar(
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
            _buildSheetActionTile('محادثة فردية جديدة', Icons.person_add, () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen()));
            }),
            const SizedBox(height: 12),
            _buildSheetActionTile('إنشاء مجموعة جديدة', Icons.group_add, () {
              Navigator.pop(context);
              _showNewGroupSheet();
            }),
            const SizedBox(height: 12),
            _buildSheetActionTile('قائمة بث جديدة', Icons.campaign, () {
              Navigator.pop(context);
              _showNewBroadcastSheet();
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
