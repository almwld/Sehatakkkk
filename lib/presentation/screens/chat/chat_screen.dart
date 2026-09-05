import 'package:shimmer/shimmer.dart';
import 'package:sehatak/presentation/screens/exercise/exercise_plan_screen.dart';
import 'package:sehatak/presentation/screens/health_tips/health_tips_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/symptom_checker/symptom_checker_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
// ============================================================
// 📁 lib/presentation/screens/chat/chat_screen.dart
// 💬 شاشة الدردشة - الإصدار المتكامل مع الأصول المحلية
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/bloc/chat/chat_bloc.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/core/services/toast_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

  // ✅ قائمة الأطباء الافتراضية (للمحادثات السريعة)
  final List<Map<String, dynamic>> _defaultDoctors = [
    {
      'id': 'd1',
      'name': 'د. أحمد المولد',
      'specialty': 'باطنية',
      'image': ImageKit.doctor1,
      'isOnline': true,
      'unread': 3,
    },
    {
      'id': 'd2',
      'name': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'image': ImageKit.doctor2,
      'isOnline': true,
      'unread': 0,
    },
    {
      'id': 'd3',
      'name': 'د. أسماء الهندي',
      'specialty': 'أطفال',
      'image': ImageKit.doctor3,
      'isOnline': false,
      'unread': 1,
    },
    {
      'id': 'd4',
      'name': 'د. محمد العلاي',
      'specialty': 'أنف وأذن وحنجرة',
      'image': ImageKit.doctor4,
      'isOnline': true,
      'unread': 0,
    },
    {
      'id': 'd5',
      'name': 'د. فاطمة صديقي',
      'specialty': 'نساء وولادة',
      'image': ImageKit.doctor5,
      'isOnline': false,
      'unread': 2,
    },
  ];

  // ✅ قائمة المكالمات التجريبية
  final List<CallModel> _sampleCalls = [
    CallModel(
      id: 'call1',
      chatId: 'chat1',
      callerId: 'user1',
      callerName: 'د. أحمد',
      receiverId: 'user2',
      receiverName: 'مستخدم',
      callType: CallType.audio,
      status: CallStatus.missed,
      durationSeconds: 0,
      isAnswered: false,
    ),
    CallModel(
      id: 'call2',
      chatId: 'chat2',
      callerId: 'user2',
      callerName: 'د. خالد',
      receiverId: 'user1',
      receiverName: 'مستخدم',
      callType: CallType.video,
      status: CallStatus.ended,
      durationSeconds: 45,
      isAnswered: true,
    ),
    CallModel(
      id: 'call3',
      chatId: 'chat3',
      callerId: 'user1',
      callerName: 'د. سارة',
      receiverId: 'user2',
      receiverName: 'مستخدم',
      callType: CallType.audio,
      status: CallStatus.connected,
      durationSeconds: 120,
      isAnswered: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ChatBloc>().add(LoadChats());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildTabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatList(isDark),      // التبويب 1: المحادثات
                _buildCallsList(isDark),     // التبويب 2: المكالمات
                _buildAIAssistant(isDark),   // التبويب 3: المساعد الذكي
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(isDark),
    );
  }

  // ============================================================
  // 📱 AppBar
  // ============================================================
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              FirebaseAuth.instance.currentUser?.displayName?[0]?.toUpperCase() ?? 'م',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المحادثات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                'مرحباً بك في صحتك',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/images/icons/search/Search_button.png',
            width: 24,
            height: 24,
            color: isDark ? Colors.white : Colors.black87,
            errorBuilder: (_, __, ___) => Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => setState(() => _isSearching = !_isSearching),
        ),
        IconButton(
          icon: Image.asset(
            'assets/images/icons/top_bar/notifications.png',
            width: 24,
            height: 24,
            color: isDark ? Colors.white : Colors.black87,
            errorBuilder: (_, __, ___) => Icon(
              Icons.notifications_outlined,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
        ),
      ],
    );
  }

  // ============================================================
  // 🔍 Search Bar
  // ============================================================
  Widget _buildSearchBar(bool isDark) {
    if (!_isSearching) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? const Color(0xFF1A2540) : Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'بحث عن محادثة...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF2D3A54) : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                context.read<ChatBloc>().add(SearchChatsEvent(query: value));
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchController.clear();
                _searchQuery = '';
              });
              context.read<ChatBloc>().add(LoadChats());
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 Tab Bar
  // ============================================================
  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        tabs: const [
          Tab(text: '📨 المحادثات'),
          Tab(text: '📞 المكالمات'),
          Tab(text: '🤖 المساعد'),
        ],
      ),
    );
  }

  // ============================================================
  // 💬 قائمة المحادثات
  // ============================================================
  Widget _buildChatList(bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const ChatShimmer();
        }
        if (state is ChatError) {
          return _buildErrorState(isDark);
        }

        // ✅ العنصر الأول: المساعد الذكي
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            // 🤖 المساعد الذكي - أول عنصر في القائمة
            _buildAIAssistantCard(isDark),
            const SizedBox(height: 8),
            
            // 👨‍⚕️ الأطباء الافتراضيون
            ..._defaultDoctors.map((doctor) => _buildDoctorChatCard(doctor, isDark)),
            
            // 💬 المحادثات الفعلية
            if (state is ChatLoaded) ...[
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              ...state.chats.where((c) => !c.isArchived).map((chat) {
                return _buildChatCard(chat, isDark);
              }),
            ],
            
            // ✅ إذا كانت القائمة فارغة
            if (state is ChatLoaded && state.chats.where((c) => !c.isArchived).isEmpty)
              _buildEmptyState(
                isDark,
                'لا توجد محادثات',
                'ابدأ محادثة جديدة مع طبيبك',
                'assets/images/ui/chat_bubble.png',
              ),
          ],
        );
      },
    );
  }

  // ============================================================
  // 🤖 بطاقة المساعد الذكي (أول عنصر)
  // ============================================================
  Widget _buildAIAssistantCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AiChatbotScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF4DB6AC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/images/services/ai_assistant.png',
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        '🤖 المساعد الذكي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'اسأل عن الأعراض، الأدوية، النصائح الصحية',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 👨‍⚕️ بطاقة الطبيب (للمحادثات السريعة)
  // ============================================================
  Widget _buildDoctorChatCard(Map<String, dynamic> doctor, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatId: 'doctor_${doctor['id']}',
              otherUserId: doctor['id'],
              otherUserName: doctor['name'],
              isGroup: false,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: doctor['image'] != null
                      ? NetworkImage(doctor['image'])
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: doctor['image'] == null
                      ? Text(
                          doctor['name'][0].toUpperCase(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (doctor['isOnline'] == true)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
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
                          doctor['name'],
                          style: TextStyle(
                            fontWeight: (doctor['unread'] as int) > 0 ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'الآن',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor['specialty'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if ((doctor['unread'] as int) > 0)
              Container(
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${doctor['unread']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primary,
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                      chatId: 'doctor_${doctor['id']}',
                      otherUserId: doctor['id'],
                      otherUserName: doctor['name'],
                      isGroup: false,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🃏 بطاقة المحادثة
  // ============================================================
  Widget _buildChatCard(ChatModel chat, bool isDark) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = chat.getDisplayName(userId);
    final photo = chat.getDisplayPhoto(userId);
    final unread = chat.getTotalUnreadCount();
    final lastMessage = chat.lastMessage ?? 'ابدأ المحادثة';
    final time = chat.lastMessageTime?.toDate();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatId: chat.id,
              otherUserId: chat.getOtherParticipant(userId),
              otherUserName: name,
              isGroup: chat.isGroup,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: photo.isNotEmpty
                      ? CachedNetworkImageProvider(photo)
                      : null,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: photo.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'م',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2),
                        ),
                      ),
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
                          name,
                          style: TextStyle(
                            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (time != null)
                        Text(
                          _formatTime(time),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.isGroup ? '👥 $lastMessage' : lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: unread > 0
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unread',
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
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 18,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'archive':
                    context.read<ChatBloc>().add(ArchiveChatEvent(chatId: chat.id));
                    ToastService.showInfo('📦 تم أرشفة المحادثة');
                    break;
                  case 'pin':
                    context.read<ChatBloc>().add(PinChatEvent(chatId: chat.id));
                    ToastService.showInfo('📌 تم تثبيت المحادثة');
                    break;
                  case 'mute':
                    context.read<ChatBloc>().add(MuteChatEvent(chatId: chat.id));
                    ToastService.showInfo('🔇 تم كتم الإشعارات');
                    break;
                  case 'delete':
                    _deleteChat(chat.id);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, size: 18),
                      SizedBox(width: 8),
                      Text('أرشفة'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(Icons.push_pin, size: 18),
                      SizedBox(width: 8),
                      Text('تثبيت'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'mute',
                  child: Row(
                    children: [
                      Icon(Icons.volume_off, size: 18),
                      SizedBox(width: 8),
                      Text('كتم الإشعارات'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('حذف', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📞 قائمة المكالمات
  // ============================================================
  // ============================================================
  // 📞 قائمة المكالمات
  // ============================================================
  Widget _buildCallsList(bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const ChatShimmer();
        }
        if (state is ChatError) {
          return _buildErrorState(isDark);
        }

        final calls = _sampleCalls;
        
        if (calls.isEmpty) {
          return _buildEmptyState(
            isDark,
            لا
        if (state is ChatError) {
          return _buildErrorState(isDark);
        }

        final calls = _sampleCalls;
        
        if (calls.isEmpty) {
          return _buildEmptyState(
            isDark,
            'لا توجد مكالمات',
            'سجل المكالمات فارغ',
            'assets/images/ui/phone_call.png',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _buildCallCard(chat, isDark);
          },
        );
      },
    );
  }

  // ============================================================
  // 🃏 بطاقة المكالمة
  // ============================================================
  Widget _buildCallCard(CallModel call, bool isDark) {
    final isMe = call.callerId == FirebaseAuth.instance.currentUser?.uid;
    final name = isMe ? call.receiverName : call.callerName;
    final isMissed = call.status == CallStatus.missed;
    final isRejected = call.status == CallStatus.rejected;
    final isEnded = call.status == CallStatus.ended;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'م',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      isMissed ? Icons.call_missed : Icons.call,
                      size: 14,
                      color: isMissed ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isMissed ? 'فائتة' :
                      isRejected ? 'مرفوضة' :
                      isEnded ? 'منتهية' : 'واردة',
                      style: TextStyle(
                        fontSize: 12,
                        color: isMissed ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (call.durationSeconds != null && call.durationSeconds! > 0)
                      Text(
                        _formatDuration(call.durationSeconds!),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isMissed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'فائتة',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: Image.asset(
              call.callType == CallType.video
                  ? 'assets/images/chat/video_call.png'
                  : 'assets/images/chat/phone_call.png',
              width: 24,
              height: 24,
              color: AppColors.primary,
              errorBuilder: (_, __, ___) => Icon(
                call.callType == CallType.video ? Icons.videocam : Icons.phone,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              ToastService.showInfo('📞 جاري الاتصال...');
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🤖 شاشة المساعد الذكي (التبويب الثالث)
  // ============================================================
  Widget _buildAIAssistant(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ بطاقة المساعد
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF4DB6AC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Image.asset(
                  'assets/images/services/ai_assistant.png',
                  width: 80,
                  height: 80,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'المساعد الذكي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اسألني عن أي استشارة طبية',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiChatbotScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'بدء المحادثة',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ ميزات المساعد
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildAIFeature(
                  icon: Icons.healing,
                  label: 'تحليل الأعراض',
                  color: Colors.blue,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SymptomCheckerScreen())),
                ),
                _buildAIFeature(
                  icon: Icons.medication,
                  label: 'معلومات الأدوية',
                  color: Colors.green,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicinesScreen())),
                ),
                _buildAIFeature(
                  icon: Icons.food_bank,
                  label: 'نصائح غذائية',
                  color: Colors.orange,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HealthTipsScreen())),
                ),
                _buildAIFeature(
                  icon: Icons.fitness_center,
                  label: 'خطط رياضية',
                  color: Colors.purple,
                  isDark: isDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExercisePlanScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 ميزات المساعد
  // ============================================================
  Widget _buildAIFeature({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🧩 ويدجتات مساعدة
  // ============================================================
  Widget _buildEmptyState(bool isDark, String title, String subtitle, String imagePath) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            width: 80,
            height: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
            errorBuilder: (_, __, ___) => Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل المحادثات',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ChatBloc>().add(RefreshChats()),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(bool isDark) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorsListScreen()));
      },
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.chat_bubble_outline),
    );
  }

  // ============================================================
  // 🧮 دوال مساعدة
  // ============================================================
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inDays > 7) {
      return '${time.day}/${time.month}';
    } else if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _deleteChat(String chatId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل أنت متأكد من حذف هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(DeleteChat(chatId: chatId));
              ToastService.showInfo('🗑️ تم حذف المحادثة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
