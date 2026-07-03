import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatModel {
  final String id;
  final String name;
  final String? avatar;
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;
  final bool isMuted;
  final bool isVerified;
  final String? typingStatus;
  final IconData? icon;
  final Color? color;

  ChatModel({
    required this.id,
    required this.name,
    this.avatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isVerified = false,
    this.typingStatus,
    this.icon,
    this.color,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  final List<ChatModel> _chats = [
    ChatModel(
      id: '1',
      name: 'د. أحمد المولد',
      lastMessage: '🎤 رسالة صوتية',
      lastMessageTime: '10:30 ص',
      unreadCount: 2,
      isOnline: true,
      isPinned: true,
      isVerified: true,
      color: AppColors.primary,
      icon: Icons.person,
      typingStatus: 'يكتب...',
    ),
    ChatModel(
      id: '2',
      name: 'د. خالد النخلاني',
      lastMessage: 'شكراً على الاستشارة 👍',
      lastMessageTime: 'أمس',
      unreadCount: 0,
      isOnline: false,
      isPinned: false,
      color: Colors.blue,
      icon: Icons.person,
    ),
    ChatModel(
      id: '3',
      name: 'صيدلية الشفاء',
      lastMessage: '📢 عرض خاص: خصم 30% على الأدوية',
      lastMessageTime: 'أمس',
      unreadCount: 0,
      isOnline: true,
      isPinned: false,
      isVerified: true,
      color: const Color(0xFFF0B90B),
      icon: Icons.local_pharmacy,
    ),
    ChatModel(
      id: '4',
      name: 'مجموعة الأطباء',
      lastMessage: 'د. علي: تم تحديث المواعيد',
      lastMessageTime: 'الثلاثاء',
      unreadCount: 8,
      isOnline: false,
      isPinned: false,
      color: Colors.purple,
      icon: Icons.group,
    ),
    ChatModel(
      id: '5',
      name: 'المساعد الصحي',
      lastMessage: 'كيف يمكنني مساعدتك اليوم؟',
      lastMessageTime: 'الآن',
      unreadCount: 0,
      isOnline: true,
      isPinned: true,
      isVerified: true,
      color: AppColors.primary,
      icon: Icons.smart_toy,
    ),
    ChatModel(
      id: '6',
      name: 'مستشفى الثورة',
      lastMessage: 'تم تأكيد حجزك ✅',
      lastMessageTime: 'منذ ساعة',
      unreadCount: 1,
      isOnline: true,
      isPinned: false,
      isVerified: true,
      color: const Color(0xFF795548),
      icon: Icons.local_hospital,
    ),
    ChatModel(
      id: '7',
      name: 'مختبرات الوطنية',
      lastMessage: '📸 نتيجة التحليل',
      lastMessageTime: 'منذ 3 ساعات',
      unreadCount: 0,
      isOnline: false,
      isPinned: false,
      color: const Color(0xFF00BCD4),
      icon: Icons.science,
    ),
    ChatModel(
      id: '8',
      name: 'خدمات التوصيل',
      lastMessage: 'سيتم توصيل الطلب اليوم 🚚',
      lastMessageTime: 'منذ يوم',
      unreadCount: 0,
      isOnline: true,
      isPinned: false,
      color: Colors.green,
      icon: Icons.delivery_dining,
    ),
  ];

  List<ChatModel> get _filteredChats {
    var chats = _chats;
    if (_searchQuery.isNotEmpty) {
      chats = chats.where((c) => c.name.contains(_searchQuery) || c.lastMessage.contains(_searchQuery)).toList();
    }
    chats.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });
    return chats;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    final bgColor = isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC);
    final cardColor = isDark ? const Color(0xFF1A2540) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _isSearching ? _buildSearchAppBar(isDark) : _buildMainAppBar(isDark),
      body: Column(
        children: [
          // ✅ قصص (Stories)
          _buildStoriesRow(isDark),
          // ✅ تبويبات
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'المحادثات'),
                Tab(text: 'المكالمات'),
                Tab(text: 'الحالات'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ✅ قائمة المحادثات
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatsList(isDark, cardColor),
                _buildCallsList(isDark, cardColor),
                _buildStatusList(isDark, cardColor),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatOptions(isDark),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  // ============================================================
  // 📱 AppBar
  // ============================================================
  PreferredSizeWidget _buildMainAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      elevation: 0,
      title: const Text(
        'المحادثات',
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.search, color: AppColors.primary),
          onPressed: () => setState(() => _isSearching = true),
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert, color: AppColors.primary),
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'broadcast',
              child: Text('قائمة بث جديدة'),
            ),
            const PopupMenuItem(
              value: 'group',
              child: Text('مجموعة جديدة'),
            ),
            const PopupMenuItem(
              value: 'starred',
              child: Text('الرسائل المميزة'),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Text('الإعدادات'),
            ),
          ],
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      elevation: 0,
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'بحث...',
          hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
          border: InputBorder.none,
        ),
        onChanged: (v) => setState(() => _searchQuery = v),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  // 📸 قصص (Stories)
  // ============================================================
  Widget _buildStoriesRow(bool isDark) {
    final stories = [
      {'name': 'قصتي', 'isMe': true, 'color': AppColors.primary},
      {'name': 'د. أحمد', 'isMe': false, 'color': AppColors.primary, 'unseen': true},
      {'name': 'صيدلية الشفاء', 'isMe': false, 'color': const Color(0xFFF0B90B), 'unseen': true},
      {'name': 'مستشفى الثورة', 'isMe': false, 'color': const Color(0xFF795548)},
      {'name': 'مختبرات الوطنية', 'isMe': false, 'color': const Color(0xFF00BCD4), 'unseen': true},
      {'name': 'د. خالد', 'isMe': false, 'color': Colors.blue},
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: stories.length,
        itemBuilder: (_, i) {
          final s = stories[i];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: s['unseen'] == true
                              ? LinearGradient(
                                  colors: [s['color'] as Color, (s['color'] as Color).withOpacity(0.7)],
                                )
                              : null,
                          border: s['unseen'] != true
                              ? Border.all(color: isDark ? const Color(0xFF1A2540) : Colors.grey[300]!, width: 2)
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                            ),
                            child: s['isMe'] == true
                                ? const Center(
                                    child: Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 30,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.person,
                                      color: s['color'] as Color,
                                      size: 30,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s['name'] as String,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 💬 قائمة المحادثات
  // ============================================================
  Widget _buildChatsList(bool isDark, Color cardColor) {
    if (_filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: isDark ? Colors.grey[600] : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد محادثات',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredChats.length,
      itemBuilder: (_, i) => _buildChatCard(_filteredChats[i], isDark, cardColor),
    );
  }

  Widget _buildChatCard(ChatModel chat, bool isDark, Color cardColor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chat.id,
              userName: chat.name,
              userId: chat.id,
              isDoctor: false,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: chat.unreadCount > 0
              ? (isDark ? const Color(0xFF1A2A44) : AppColors.primary.withOpacity(0.05))
              : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: chat.unreadCount > 0
                ? AppColors.primary.withOpacity(0.2)
                : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // ✅ الصورة
            Stack(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (chat.color ?? AppColors.primary).withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      chat.icon ?? Icons.person,
                      color: chat.color ?? AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
                if (chat.isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF0B1121) : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ المحتوى
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          chat.name,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.w500,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.verified, color: AppColors.primary, size: 16),
                      ],
                      const Spacer(),
                      Text(
                        chat.lastMessageTime,
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat.isMuted) ...[
                        Icon(Icons.volume_off, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 14),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat.typingStatus ?? chat.lastMessage,
                          style: TextStyle(
                            color: chat.unreadCount > 0
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontSize: 13,
                            fontStyle: chat.typingStatus != null ? FontStyle.italic : FontStyle.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (chat.isPinned)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.push_pin, color: AppColors.primary, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📞 قائمة المكالمات
  // ============================================================
  Widget _buildCallsList(bool isDark, Color cardColor) {
    final calls = [
      {'name': 'د. أحمد المولد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'incoming': true},
      {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'incoming': false},
      {'name': 'مستشفى الثورة', 'type': 'audio', 'status': 'answered', 'time': 'منذ ساعة', 'duration': '2:45', 'incoming': true},
      {'name': 'صيدلية الشفاء', 'type': 'video', 'status': 'rejected', 'time': 'منذ يوم', 'duration': '', 'incoming': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: calls.length,
      itemBuilder: (_, i) {
        final call = calls[i];
        final isMissed = call['status'] == 'missed';
        final isVideo = call['type'] == 'video';
        final isIncoming = call['incoming'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
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
                          isMissed
                              ? 'مكالمة فائتة'
                              : (call['duration'] as String).isNotEmpty
                                  ? (isIncoming ? 'واردة' : 'صادرة')
                                  : 'تم الرد',
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
              IconButton(
                icon: Icon(
                  isVideo ? Icons.videocam : Icons.phone,
                  color: AppColors.primary,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CallScreen(
                        chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                        doctorName: call['name'] as String,
                        doctorId: 'doctor_1',
                        isVideo: isVideo,
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 📸 الحالات (Status)
  // ============================================================
  Widget _buildStatusList(bool isDark, Color cardColor) {
    final statuses = [
      {'name': 'د. أحمد المولد', 'time': 'منذ 30 دقيقة', 'unseen': true, 'color': AppColors.primary},
      {'name': 'صيدلية الشفاء', 'time': 'منذ ساعة', 'unseen': true, 'color': const Color(0xFFF0B90B)},
      {'name': 'مستشفى الثورة', 'time': 'منذ 3 ساعات', 'unseen': false, 'color': const Color(0xFF795548)},
      {'name': 'مختبرات الوطنية', 'time': 'منذ 5 ساعات', 'unseen': false, 'color': const Color(0xFF00BCD4)},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: statuses.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: AppColors.primary, size: 30),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حالتي',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'اضغط لإضافة حالة',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        final s = statuses[i - 1];
        return Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: s['unseen'] == true
                      ? LinearGradient(
                          colors: [s['color'] as Color, (s['color'] as Color).withOpacity(0.7)],
                        )
                      : null,
                  border: s['unseen'] != true
                      ? Border.all(color: isDark ? const Color(0xFF1A2540) : Colors.grey[300]!, width: 2)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: s['color'] as Color,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s['name'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      s['time'] as String,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
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
  // ➕ بدء محادثة جديدة
  // ============================================================
  void _showNewChatOptions(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'بدء محادثة جديدة',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              autofocus: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'ابحث عن مستخدم...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.group_add, color: Colors.green),
              ),
              title: const Text(
                'إنشاء مجموعة جديدة',
                style: TextStyle(color: AppColors.primary),
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign, color: Colors.blue),
              ),
              title: const Text(
                'قائمة بث جديدة',
                style: TextStyle(color: AppColors.primary),
              ),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
