// ============================================================
// 📱 شاشة المحادثات الرئيسية - مع المساعد الذكي
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/bloc/chat/chat_bloc.dart';
import 'package:sehatak/bloc/chat/chat_event.dart';
import 'package:sehatak/bloc/chat/chat_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/chat/create_group_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _totalUnread = 0;

  // ✅ تبويبات الدردشة
  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.chat_bubble_outline, 'label': 'المحادثات'},
    {'icon': Icons.call_outlined, 'label': 'المكالمات'},
    {'icon': Icons.circle_outlined, 'label': 'الحالات'},
  ];

  // ✅ قائمة الأطباء + المساعد الذكي
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 'ai_assistant',
      'name': 'المساعد الذكي',
      'specialty': 'شات بوت',
      'image': 'assets/images/services/ai_assistant.png',
      'isOnline': true,
      'isAi': true,  // ✅ علامة للتعرف على المساعد الذكي
    },
    {'id': 'doc1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'image': '', 'isOnline': true, 'isAi': false},
    {'id': 'doc2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'image': '', 'isOnline': false, 'isAi': false},
    {'id': 'doc3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'image': '', 'isOnline': true, 'isAi': false},
    {'id': 'doc4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'image': '', 'isOnline': false, 'isAi': false},
    {'id': 'doc5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'image': '', 'isOnline': true, 'isAi': false},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    WidgetsBinding.instance.addObserver(this);
    context.read<ChatBloc>().add(LoadChatsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      context.read<ChatBloc>().add(RefreshChatsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          _buildTabBar(isDark),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(isDark),
                _buildCallsTab(isDark),
                _buildStoriesTab(isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // ============================================================
  // 🏗️ واجهة التبويبات
  // ============================================================

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      title: Row(
        children: [
          const Text('المحادثات', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          if (_totalUnread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$_totalUnread',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => context.read<ChatBloc>().add(RefreshChatsEvent()),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
          onSelected: (value) {
            switch (value) {
              case 'groups':
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                );
                break;
              case 'settings':
                Navigator.pushNamed(context, '/chat_settings');
                break;
              case 'archive':
                ToastService.showInfo('📦 جاري عرض المحادثات المؤرشفة...');
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'groups',
              child: Row(
                children: [
                  Icon(Icons.group_add, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('إنشاء مجموعة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('إعدادات الدردشة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'archive',
              child: Row(
                children: [
                  Icon(Icons.archive, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('المحادثات المؤرشفة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      color: isDark ? AppColors.darkBackground : Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        tabs: _tabs.map((tab) {
          return Tab(
            icon: Icon(tab['icon'] as IconData),
            text: tab['label'] as String,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    if (_tabController.index == 0) {
      return FloatingActionButton(
        onPressed: _showDoctorList,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      );
    } else if (_tabController.index == 1) {
      return FloatingActionButton(
        onPressed: () => ToastService.showInfo('📞 جاري بدء المكالمة...'),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.call, color: Colors.white),
      );
    } else {
      return FloatingActionButton(
        onPressed: _addStory,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_photo_alternate, color: Colors.white),
      );
    }
  }

  // ============================================================
  // 📱 تبويب المحادثات
  // ============================================================

  Widget _buildChatsTab(bool isDark) {
    return Column(
      children: [
        _buildSearchBar(isDark),
        Expanded(
          child: BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              if (state is ChatLoadingState || state is ChatRefreshingState) {
                return ChatShimmer(isDark: isDark);
              }

              if (state is ChatErrorState) {
                return _buildErrorState(isDark, state.message);
              }

              if (state is ChatsLoadedState) {
                _totalUnread = state.unreadCount;
                final chats = _filterChats(state.chats);
                if (chats.isEmpty) {
                  return _buildEmptyState(isDark);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ChatBloc>().add(RefreshChatsEvent());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      final chat = chats[index];
                      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      return _buildChatTile(chat, userId, isDark);
                    },
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن محادثة...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat, String userId, bool isDark) {
    final name = chat.getOtherParticipantName(userId);
    final image = chat.getOtherParticipantImage(userId);
    final unread = chat.getUnreadCount(userId);
    final isOnline = chat.isOnline;

    return GestureDetector(
      onTap: () {
        context.read<ChatBloc>().add(MarkAsReadEvent(chatId: chat.id));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chat.id,
              userId: userId,
              userName: name,
              userImage: image,
              isDoctor: false,
            ),
          ),
        );
      },
      onLongPress: () => _showChatOptions(chat, isDark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  radius: 26,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                  child: image.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0] : 'م',
                          style: TextStyle(
                            color: AppColors.primary,
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
                        color: AppColors.online,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
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
                          chat.isGroup ? chat.groupName ?? 'مجموعة' : name,
                          style: TextStyle(
                            fontWeight: unread > 0 ? FontWeight.bold : FontWeight.w600,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(chat.lastMessageTime),
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
                          chat.lastMessage,
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
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📞 تبويب المكالمات
  // ============================================================

  Widget _buildCallsTab(bool isDark) {
    final calls = [
      {'name': 'د. أحمد المؤيد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'image': ''},
      {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'image': ''},
      {'name': 'د. أسماء الهندي', 'type': 'audio', 'status': 'incoming', 'time': 'منذ ساعة', 'duration': '', 'image': ''},
      {'name': 'د. محمد العلاي', 'type': 'video', 'status': 'answered', 'time': '2:15 م', 'duration': '12:45', 'image': ''},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final isMissed = call['status'] == 'missed';
        final isIncoming = call['status'] == 'incoming';
        final isVideo = call['type'] == 'video';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isIncoming ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  call['name'][0],
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Row(
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
                          call['time'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isIncoming)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.green),
                      onPressed: () => ToastService.showSuccess('✅ تم قبول المكالمة'),
                    ),
                    IconButton(
                      icon: const Icon(Icons.call_end, color: Colors.red),
                      onPressed: () => ToastService.showError('❌ تم رفض المكالمة'),
                    ),
                  ],
                )
              else
                IconButton(
                  icon: Icon(
                    isVideo ? Icons.videocam : Icons.call,
                    color: AppColors.primary,
                  ),
                  onPressed: () => ToastService.showInfo('📞 جاري الاتصال...'),
                ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 📸 تبويب الحالات
  // ============================================================

  Widget _buildStoriesTab(bool isDark) {
    final stories = [
      {'name': 'د. أحمد المؤيد', 'image': '', 'time': 'منذ 5 دقائق', 'viewed': false},
      {'name': 'د. خالد النخلاني', 'image': '', 'time': 'منذ ساعة', 'viewed': true},
      {'name': 'د. أسماء الهندي', 'image': '', 'time': 'منذ 3 ساعات', 'viewed': false},
      {'name': 'د. محمد العلاي', 'image': '', 'time': 'منذ 5 ساعات', 'viewed': true},
    ];

    return Column(
      children: [
        _buildAddStoryCard(isDark),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return _buildStoryItem(story, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddStoryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: GestureDetector(
        onTap: _addStory,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.add, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أضف حالة جديدة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'شارك لحظة مع أطبائك',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryItem(Map<String, dynamic> story, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: story['viewed'] == false
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              story['name'][0],
              style: const TextStyle(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story['name'],
                  style: TextStyle(
                    fontWeight: story['viewed'] == false ? FontWeight.bold : FontWeight.normal,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  story['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              story['viewed'] == false ? Icons.circle : Icons.check_circle,
              color: story['viewed'] == false ? AppColors.primary : Colors.grey,
            ),
            onPressed: () => ToastService.showSuccess('✅ تم مشاهدة الحالة'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================

  List<ChatModel> _filterChats(List<ChatModel> chats) {
    if (_searchQuery.isEmpty) return chats;
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return chats.where((chat) {
      final name = chat.getOtherParticipantName(userId);
      return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             chat.lastMessage.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showChatOptions(ChatModel chat, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin, color: AppColors.primary),
              title: const Text('تثبيت المحادثة'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(PinChatEvent(chatId: chat.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_off, color: AppColors.primary),
              title: const Text('كتم الإشعارات'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(MuteChatEvent(chatId: chat.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: AppColors.primary),
              title: const Text('أرشفة المحادثة'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatBloc>().add(ArchiveChatEvent(chatId: chat.id));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف المحادثة', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteChatConfirmation(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteChatConfirmation(ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من حذف المحادثة مع ${chat.getOtherParticipantName(FirebaseAuth.instance.currentUser?.uid ?? '')}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ChatBloc>().add(DeleteChatEvent(chatId: chat.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ✅ عرض قائمة الأطباء + المساعد الذكي
  void _showDoctorList() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'اختر طبيباً أو المساعد الذكي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ..._doctors.map((doctor) => ListTile(
              leading: Stack(
                children: [
                  // ✅ أيقونة المساعد الذكي أو صورة الطبيب
                  if (doctor['isAi'] == true)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Colors.purple.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology_alt,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    )
                  else
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        doctor['name'][0],
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                  if (doctor['isOnline'] as bool)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: AppColors.online,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                        ),
                      ),
                    ),
                ],
              ),
              title: Row(
                children: [
                  Text(doctor['name']),
                  if (doctor['isAi'] == true) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              subtitle: Text(doctor['specialty']),
              trailing: Icon(
                doctor['isAi'] == true ? Icons.psychology_alt : Icons.chat,
                color: AppColors.primary,
              ),
              onTap: () {
                Navigator.pop(context);
                
                // ✅ إذا كان المساعد الذكي → فتح AiChatbotScreen
                if (doctor['isAi'] == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AiChatbotScreen(),
                    ),
                  );
                } else {
                  // ✅ إذا كان طبيب → فتح محادثة
                  _startChatWithDoctor(doctor);
                }
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _startChatWithDoctor(Map<String, dynamic> doctor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول');
      return;
    }

    try {
      final chatId = await context.read<ChatBloc>().createChat(
        doctorId: doctor['id'],
        doctorName: doctor['name'],
        patientId: user.uid,
        patientName: user.displayName ?? 'مريض',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: chatId,
            userId: user.uid,
            userName: doctor['name'],
            userImage: doctor['image'],
            isDoctor: true,
          ),
        ),
      );
    } catch (e) {
      ToastService.showError('❌ فشل إنشاء المحادثة: $e');
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('بحث متقدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'ابحث عن محادثة...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('بحث'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addStory() {
    ToastService.showInfo('📸 جاري فتح الكاميرا...');
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showDoctorList,
            icon: const Icon(Icons.search),
            label: const Text('البحث عن طبيب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ChatBloc>().add(RefreshChatsEvent()),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ إنشاء محادثة تجريبية
  Future<void> _createTestChat() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يجب تسجيل الدخول');
        return;
      }

      final chatId = await context.read<ChatBloc>().createChat(
        doctorId: 'test_doctor',
        doctorName: 'د. أحمد (تجريبي)',
        patientId: user.uid,
        patientName: user.displayName ?? 'مريض',
      );

      ToastService.showSuccess('✅ تم إنشاء محادثة تجريبية');
      context.read<ChatBloc>().add(RefreshChatsEvent());
    } catch (e) {
      ToastService.showError('❌ فشل إنشاء المحادثة: $e');
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    if (diff.inDays < 30) return 'منذ ${diff.inDays} ي';
    return '${time.day}/${time.month}/${time.year}';
  }
}
