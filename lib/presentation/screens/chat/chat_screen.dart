import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/core/constants/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ChatScreen({super.key, this.scrollController});
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  final List<Map<String, dynamic>> _mockChats = [
    {'id': '1', 'name': 'د. أحمد المؤيد', 'lastMessage': 'مرحباً، كيف يمكنني مساعدتك؟', 'time': DateTime.now().subtract(const Duration(minutes: 5)), 'unread': 2, 'image': ImageKit.doctor1, 'isOnline': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'lastMessage': 'سأتصل بك غداً', 'time': DateTime.now().subtract(const Duration(hours: 2)), 'unread': 0, 'image': ImageKit.doctor2, 'isOnline': false},
    {'id': '3', 'name': 'د. أسماء الهندي', 'lastMessage': 'تم تأكيد موعدك', 'time': DateTime.now().subtract(const Duration(hours: 5)), 'unread': 1, 'image': ImageKit.doctor3, 'isOnline': true},
  ];

  final List<Map<String, dynamic>> _calls = [
    {'name': 'د. أحمد المؤيد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'image': ImageKit.doctor1, 'doctorId': 'doc1'},
    {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'image': ImageKit.doctor2, 'doctorId': 'doc2'},
    {'name': 'د. أسماء الهندي', 'type': 'audio', 'status': 'incoming', 'time': 'منذ ساعة', 'duration': '', 'image': ImageKit.doctor3, 'doctorId': 'doc3'},
  ];

  List<Map<String, dynamic>> _stories = [
    {'name': 'د. أحمد المؤيد', 'image': ImageKit.doctor1, 'isOnline': true, 'time': 'منذ 5 دقائق', 'isMine': false},
    {'name': 'د. خالد النخلاني', 'image': ImageKit.doctor2, 'isOnline': false, 'time': 'منذ ساعة', 'isMine': false},
    {'name': 'د. أسماء الهندي', 'image': ImageKit.doctor3, 'isOnline': true, 'time': 'منذ 3 ساعات', 'isMine': false},
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
    _loadStories();
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

  Future<void> _loadStories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          _stories = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'name': data['userName'] ?? 'مستخدم',
              'image': data['image'] ?? ImageKit.doctor1,
              'isOnline': data['isOnline'] ?? false,
              'time': _formatTime((data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now()),
              'isMine': data['userId'] == user.uid,
            };
          }).toList();
        });
      }
    } catch (e) {
      print('❌ Error loading stories: $e');
    }
  }

  void _loadChats() {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        _isLoading = false;
        _isOffline = true;
        _errorMessage = 'يرجى تسجيل الدخول';
      });
      return;
    }

    FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.docs.isEmpty) {
              setState(() {
                _isLoading = false;
                _isOffline = true;
                _errorMessage = 'لا توجد محادثات';
              });
              return;
            }
            setState(() {
              _isLoading = false;
              _isOffline = false;
              _errorMessage = '';
            });
          },
          onError: (e) {
            setState(() {
              _isLoading = false;
              _isOffline = true;
              _errorMessage = 'حدث خطأ في تحميل المحادثات';
            });
            ToastService.showError('❌ ${_errorMessage}');
          },
        );
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

  Widget _buildDoctorAvatar(String imageUrl, {double size = 48, bool isOnline = false, String? name}) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name?.isNotEmpty == true ? name!.substring(0, 1) : 'ط',
                  style: TextStyle(color: AppColors.primary, fontSize: size * 0.4, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  name?.isNotEmpty == true ? name!.substring(0, 1) : 'ط',
                  style: TextStyle(color: AppColors.primary, fontSize: size * 0.4, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
              ),
            ),
          ),
      ],
    );
  }

  void _openAiChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AiChatbotScreen(),
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'المحادثات'),
            Tab(text: 'المكالمات'),
            Tab(text: 'الحالات'),
          ],
        ),
        actions: [
          // ✅ زر المساعد الذكي (AI Assistant) - بدون IconButton
          GestureDetector(
            onTap: _openAiChatbot,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/services/ai_assistant.png',
                width: 26,
                height: 26,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.auto_awesome, color: AppColors.primary, size: 26);
                },
              ),
            ),
          ),
          // ✅ زر البحث - بدون IconButton
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87, size: 26),
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(isDark),
          _buildCallsTab(isDark),
          _buildStoriesTab(isDark),
        ],
      ),
    );
  }

  Widget _buildChatsTab(bool isDark) {
    // ... باقي الكود
    return Container();
  }

  Widget _buildCallsTab(bool isDark) {
    // ... باقي الكود
    return Container();
  }

  Widget _buildStoriesTab(bool isDark) {
    // ... باقي الكود
    return Container();
  }
}
