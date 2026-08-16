import 'package:sehatak/core/services/toast_service.dart';
import "package:sehatak/utils/image_utils.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
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
  final List<Map<String, dynamic>> _stories = [];

  // ✅ أيقونات الدردشة الجديدة
  final List<Map<String, dynamic>> _chatIcons = [
    {'icon': 'assets/images/chat/audio_record.png', 'label': 'تسجيل صوتي', 'color': Colors.red},
    {'icon': 'assets/images/chat/phone_call.png', 'label': 'مكالمة', 'color': Colors.green},
    {'icon': 'assets/images/chat/video_call.png', 'label': 'مكالمة فيديو', 'color': Colors.blue},
    {'icon': 'assets/images/chat/chat_bubble.png', 'label': 'دردشة', 'color': AppColors.primary},
    {'icon': 'assets/images/chat/calendar_booking.png', 'label': 'حجز موعد', 'color': Colors.orange},
    {'icon': 'assets/images/chat/microphone.png', 'label': 'ميكروفون', 'color': Colors.purple},
    {'icon': 'assets/images/chat/play_button.png', 'label': 'تشغيل', 'color': Colors.teal},
  ];

  // ✅ أطباء وهميون مع صور من ImageKit
  final List<Map<String, dynamic>> _doctors = [
    {'name': 'د. أحمد المولد', 'image': ImageKit.doctor1, 'id': 'doc1'},
    {'name': 'د. خالد النخلاني', 'image': ImageKit.doctor2, 'id': 'doc2'},
    {'name': 'د. أسماء الهندي', 'image': ImageKit.doctor3, 'id': 'doc3'},
    {'name': 'د. محمد العلاي', 'image': ImageKit.doctor4, 'id': 'doc4'},
    {'name': 'د. فاطمة صديقي', 'image': ImageKit.doctor5, 'id': 'doc5'},
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

  void _navigateToChat(String chatId, String userName, String userId, bool isDoctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatId: chatId,
          userName: userName,
          userId: userId,
          isDoctor: isDoctor,
        ),
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
            _buildDoctorList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          final doctor = _doctors[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Image.network(
                doctor['image'] as String,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey),
                ),
              ),
            ),
            title: Text(doctor['name'] as String),
            trailing: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0D5257)),
            onTap: () {
              Navigator.pop(context);
              _navigateToChat(
                'chat_${DateTime.now().millisecondsSinceEpoch}',
                doctor['name'] as String,
                doctor['id'] as String,
                true,
              );
            },
          );
        },
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

  // ✅ دالة عرض عنصر دردشة فردي مع أيقونات جديدة
  Widget _buildChatActionItem(Map<String, dynamic> item, bool isDark) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('📱 ${item['label']}'),
            backgroundColor: item['color'] as Color,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Image.asset(
                  item['icon'] as String,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.circle, color: item['color'] as Color, size: 32);
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
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
            icon: const Icon(Icons.search, color: Color(0xFF0D5257)),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatErrorState) {
            ToastService.showSuccess(context, "تمت العملية");
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
          final currentUser = FirebaseAuth.instance.currentUser;
          final isDoctor = chat['doctorId'] == currentUser?.uid;
          final otherName = isDoctor ? chat['patientName'] : chat['doctorName'];
          final otherId = isDoctor ? chat['patientId'] : chat['doctorId'];
          final lastMessage = chat['lastMessage'] ?? 'ابدأ المحادثة';
          final lastTime = _formatTime(chat['lastMessageTime']);
          final unreadCount = chat['unreadCount'] ?? 0;

          return GestureDetector(
            onTap: () => _navigateToChat(
              chat['id'],
              otherName ?? 'مستخدم',
              otherId ?? '',
              isDoctor,
            ),
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
                title: Text(
                  otherName ?? 'مستخدم',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.end,
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    lastMessage,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    isDoctor ? '' : ImageKit.doctor1,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      radius: 24,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Icon(
                        isDoctor ? Icons.person : Icons.local_hospital,
                        color: primaryColor,
                      ),
                    ),
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
}
