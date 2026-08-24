import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/core/constants/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  
  final List<Map<String, dynamic>> _filters = [
    {'label': 'الكل', 'icon': null},
    {'label': 'غير مقروءة', 'icon': null},
    {'label': 'المفضلة', 'icon': null},
    {'label': 'المجموعات', 'icon': null},
    {'label': 'عميل جديد', 'icon': Icons.circle, 'iconColor': Colors.blue},
  ];
  int _selectedFilterIndex = 0;

  bool _isLoading = true;
  bool _isOffline = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
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

  Widget _buildFilterChips(bool isDark) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilterIndex == index;
          
          return GestureDetector(
            onTap: () => setState(() => _selectedFilterIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter['icon'] != null) ...[
                    Icon(
                      filter['icon'],
                      color: filter['iconColor'] ?? Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter['label'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.only(top: 12),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        _buildFilterChips(isDark),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('chats')
                .where('participants', arrayContains: FirebaseAuth.instance.currentUser?.uid ?? '')
                .orderBy('lastMessageTime', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'حدث خطأ في تحميل المحادثات',
                        style: TextStyles.headline6.copyWith(color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'يرجى المحاولة مرة أخرى',
                        style: TextStyles.body2.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadChats,
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

              final chats = snapshot.data?.docs ?? [];

              if (chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد محادثات',
                        style: TextStyles.headline6.copyWith(color: isDark ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ابدأ محادثة جديدة مع طبيبك',
                        style: TextStyles.body2.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final data = chats[index].data() as Map<String, dynamic>;
                  final docId = chats[index].id;
                  final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                  final name = data['doctorName'] ?? data['patientName'] ?? 'طبيب';
                  final lastMessage = data['lastMessage'] ?? 'ابدأ المحادثة';
                  final unread = (data['unreadCount'] as Map?)?[userId] ?? 0;
                  final isOnline = data['isOnline'] ?? false;
                  final image = data['image'] ?? ImageKit.doctor1;
                  final time = data['lastMessageTime'] as Timestamp?;
                  final dateTime = time?.toDate() ?? DateTime.now();

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(
                            chatId: docId,
                            userName: name,
                            userId: userId,
                            isDoctor: false,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A2540) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          _buildDoctorAvatar(image, size: 48, isOnline: isOnline, name: name),
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
                                        style: TextStyles.subtitle1.copyWith(color: isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                    Text(
                                      _formatTime(dateTime),
                                      style: TextStyles.body4.copyWith(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMessage,
                                        style: TextStyles.body2.copyWith(
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallsTab(bool isDark) {
    final calls = [
      {'name': 'د. أحمد المؤيد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23', 'image': ImageKit.doctor1, 'doctorId': 'doc1'},
      {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': '', 'image': ImageKit.doctor2, 'doctorId': 'doc2'},
      {'name': 'د. أسماء الهندي', 'type': 'audio', 'status': 'incoming', 'time': 'منذ ساعة', 'duration': '', 'image': ImageKit.doctor3, 'doctorId': 'doc3'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            border: isIncoming ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: Row(
            children: [
              _buildDoctorAvatar(call['image'] as String, size: 50, name: call['name'] as String),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(call['name'] as String, style: TextStyles.subtitle1),
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
                          style: TextStyles.body3.copyWith(
                            color: isMissed ? Colors.red : isIncoming ? AppColors.primary : Colors.green,
                          ),
                        ),
                        const Spacer(),
                        Text(call['time'] as String, style: TextStyles.body4.copyWith(color: isDark ? Colors.grey[500] : Colors.grey[400])),
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
                          ToastService.showSuccess('✅ تم قبول المكالمة');
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
                        onPressed: () => ToastService.showError('❌ تم رفض المكالمة'),
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

  Widget _buildStoriesTab(bool isDark) {
    final stories = [
      {'name': 'د. أحمد المؤيد', 'image': ImageKit.doctor1, 'isOnline': true, 'time': 'منذ 5 دقائق'},
      {'name': 'د. خالد النخلاني', 'image': ImageKit.doctor2, 'isOnline': false, 'time': 'منذ ساعة'},
      {'name': 'د. أسماء الهندي', 'image': ImageKit.doctor3, 'isOnline': true, 'time': 'منذ 3 ساعات'},
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: () => ToastService.showInfo('📸 جاري فتح الكاميرا...'),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                          style: TextStyles.subtitle1.copyWith(color: isDark ? Colors.white : Colors.black87),
                        ),
                        Text(
                          'شارك لحظة مع أطبائك',
                          style: TextStyles.body3.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                    _buildDoctorAvatar(
                      story['image'] as String,
                      size: 40,
                      isOnline: story['isOnline'] as bool,
                      name: story['name'] as String,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story['name'] as String,
                            style: TextStyles.subtitle1.copyWith(color: isDark ? Colors.white : Colors.black87),
                          ),
                          Text(
                            story['time'] as String,
                            style: TextStyles.body3.copyWith(color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                            Icon(Icons.share, size: 14, color: AppColors.primary),
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
}
