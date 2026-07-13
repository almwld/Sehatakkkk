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

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _stories = [
    {
      'name': 'قصتي',
      'isMe': true,
      'color': Colors.grey,
      'image': null,
      'hasStory': false
    },
    {
      'name': 'د. أحمد المولد',
      'isMe': false,
      'color': Colors.teal,
      'image': 'assets/images/doctors/doctor_1.png',
      'hasStory': true
    },
    {
      'name': 'د. خالد النخلاني',
      'isMe': false,
      'color': Colors.teal,
      'image': 'assets/images/doctors/doctor_2.png',
      'hasStory': true
    },
    {
      'name': 'د. أسماء الهندي',
      'isMe': false,
      'color': Colors.teal,
      'image': 'assets/images/doctors/doctor_3.png',
      'hasStory': true
    },
    {
      'name': 'صيدلية الشفاء',
      'isMe': false,
      'color': Colors.amber,
      'image': 'assets/images/pharmacies/pharmacy_1.png',
      'hasStory': false
    },
    {
      'name': 'مستشفى الثورة',
      'isMe': false,
      'color': Colors.brown,
      'image': 'assets/images/hospitals/hospital_1.png',
      'hasStory': false
    },
    {
      'name': 'مختبرات العولقي',
      'isMe': false,
      'color': Colors.blue,
      'image': 'assets/images/labs/lab_1.png',
      'hasStory': false
    },
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
    _messageController.dispose();
    context.read<ChatBloc>().add(const StopListening());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'الدردشة',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            onPressed: _showStatusPicker,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showMenuOptions(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'المكالمات'),
            Tab(text: 'الحالة'),
            Tab(text: 'الدردشات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCallsTab(isDark),
          _buildStatusTab(isDark),
          _buildChatsTab(isDark),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewChatSheet();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }

  // ✅ تبويب المكالمات
  Widget _buildCallsTab(bool isDark) {
    final calls = [
      {
        'name': 'د. أحمد المولد',
        'time': 'اليوم 10:30 ص',
        'type': 'incoming',
        'isVideo': false,
        'image': 'assets/images/doctors/doctor_1.png',
      },
      {
        'name': 'د. أسماء الهندي',
        'time': 'أمس 4:15 م',
        'type': 'missed',
        'isVideo': true,
        'image': 'assets/images/doctors/doctor_3.png',
      },
    ];

    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(call['image'] as String),
            onBackgroundImageError: (_, __) {},
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text(
            call['name'] as String,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          subtitle: Row(
            children: [
              Icon(
                call['type'] == 'incoming'
                    ? Icons.call_received
                    : Icons.call_missed,
                size: 16,
                color: call['type'] == 'missed' ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 4),
              Text(
                call['time'] as String,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              call['isVideo'] == true ? Icons.videocam : Icons.call,
              color: AppColors.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    receiverName: call['name'] as String,
                    receiverImage: call['image'] as String,
                    isVideo: call['isVideo'] as bool,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ تبويب الحالة مع خيار رفع حالة جديد
  Widget _buildStatusTab(bool isDark) {
    return Column(
      children: [
        // ✅ زر رفع حالة جديدة
        ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          title: Text(
            'حالتي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            'اضغط لإضافة حالة جديدة',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          onTap: _showStatusPicker,
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
              if (story['isMe'] == true) return const SizedBox.shrink();
              return ListTile(
                leading: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: story['hasStory'] == true
                        ? Border.all(color: Colors.green, width: 3)
                        : null,
                  ),
                  child: CircleAvatar(
                    backgroundImage: story['image'] != null
                        ? AssetImage(story['image'] as String)
                        : null,
                    onBackgroundImageError: (_, __) {},
                    backgroundColor: story['color'] as Color,
                    child: story['image'] == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
                title: Text(
                  story['name'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'منذ ${index + 1} ساعة',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                onTap: () {
                  _viewStatus(story);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showStatusPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'إضافة حالة جديدة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.teal),
                title: const Text('التقاط صورة'),
                onTap: () {
                  Navigator.pop(context);
                  _showStatusPreview('camera');
                },
              ),
              ListTile(
                leading: const Icon(Icons.image, color: Colors.teal),
                title: const Text('اختيار من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  _showStatusPreview('gallery');
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.teal),
                title: const Text('حالة نصية'),
                onTap: () {
                  Navigator.pop(context);
                  _showTextStatusDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTextStatusDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حالة نصية'),
        content: TextField(
          controller: controller,
          maxLength: 200,
          textAlign: TextAlign.right,
          decoration: const InputDecoration(
            hintText: 'اكتب حالتك هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم نشر حالتك'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('نشر'),
          ),
        ],
      ),
    );
  }

  void _showStatusPreview(String source) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              source == 'camera' ? Icons.camera_alt : Icons.image,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              source == 'camera'
                  ? 'سيتم فتح الكاميرا...'
                  : 'سيتم فتح المعرض...',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم نشر حالتك'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('نشر'),
          ),
        ],
      ),
    );
  }

  void _viewStatus(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              color: (story['color'] as Color).withOpacity(0.8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (story['image'] != null)
                    Image.asset(
                      story['image'] as String,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    story['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ تبويب الدردشات مع إصلاح اختفاء الرسائل
  Widget _buildChatsTab(bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoadingState) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ChatListLoadedState) {
          final chats = state.chats;
          if (chats.isEmpty) {
            return _buildEmptyChats(isDark);
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatTile(chat, isDark);
            },
          );
        }

        if (state is ChatErrorState) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // ✅ عرض محادثات افتراضية إذا لم تكن هناك بيانات
        return _buildDefaultChats(isDark);
      },
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, bool isDark) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: chat['image'] != null
            ? AssetImage(chat['image'] as String)
            : null,
        onBackgroundImageError: (_, __) {},
        backgroundColor: AppColors.primary,
        child: chat['image'] == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        chat['name'] ?? 'مستخدم',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        chat['lastMessage'] ?? 'لا توجد رسائل',
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            chat['time'] ?? '',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          if (chat['unreadCount'] != null && chat['unreadCount'] > 0)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${chat['unreadCount']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chat['id'] ?? 'default',
              receiverName: chat['name'] ?? 'مستخدم',
              receiverImage: chat['image'],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDefaultChats(bool isDark) {
    final defaultChats = [
      {
        'id': '1',
        'name': 'د. أحمد المولد',
        'lastMessage': 'شكراً لك، سأراجع التحاليل وأتواصل معك',
        'time': '10:30 ص',
        'unreadCount': 2,
        'image': 'assets/images/doctors/doctor_1.png',
      },
      {
        'id': '2',
        'name': 'صيدلية الشفاء',
        'lastMessage': 'تم تأكيد طلبك، سيتم التوصيل خلال ساعة',
        'time': 'أمس',
        'unreadCount': 0,
        'image': 'assets/images/pharmacies/pharmacy_1.png',
      },
      {
        'id': '3',
        'name': 'مختبرات العولقي',
        'lastMessage': 'نتائج تحاليلك جاهزة للاستلام',
        'time': 'أمس',
        'unreadCount': 1,
        'image': 'assets/images/labs/lab_1.png',
      },
    ];

    return ListView.builder(
      itemCount: defaultChats.length,
      itemBuilder: (context, index) {
        return _buildChatTile(defaultChats[index], isDark);
      },
    );
  }

  Widget _buildEmptyChats(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: isDark ? Colors.grey[700] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد محادثات',
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showNewChatSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'محادثة جديدة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text(
                  'د. أحمد المولد',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'استشاري باطنية وأطفال',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatDetailScreen(
                        chatId: 'doc_1',
                        receiverName: 'د. أحمد المولد',
                        receiverImage: 'assets/images/doctors/doctor_1.png',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.local_pharmacy, color: Colors.white),
                ),
                title: Text(
                  'صيدلية الشفاء',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'صيدلية 24 ساعة',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatDetailScreen(
                        chatId: 'pharmacy_1',
                        receiverName: 'صيدلية الشفاء',
                        receiverImage: 'assets/images/pharmacies/pharmacy_1.png',
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
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

  PopupMenuItem _buildPopupMenuItem(
      String title, IconData icon, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'NotoSansArabicUI',
              fontSize: 14,
            ),
          ),
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
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'قائمة بث جديدة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5257),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 20),
            _buildSheetActionTile('إنشاء قائمة بث جديدة', Icons.campaign, () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء قائمة البث')),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showNewGroupSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'مجموعة جديدة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSheetActionTile('إنشاء مجموعة', Icons.group_add, () {
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }

  void _showStarredMessages() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('الرسائل المميزة')),
          body: const Center(child: Text('لا توجد رسائل مميزة')),
        ),
      ),
    );
  }

  void _showChatSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('إعدادات الدردشة')),
          body: ListView(
            children: const [
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('إشعارات الدردشة'),
              ),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('الخصوصية'),
              ),
              ListTile(
                leading: Icon(Icons.backup),
                title: Text('نسخ احتياطي'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSheetActionTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: onTap,
    );
  }
}
