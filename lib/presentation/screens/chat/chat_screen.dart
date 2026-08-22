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
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // ✅ صور الأطباء من ImageKit
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

  Future<void> _addStory() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
      if (image == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ رفع الصورة إلى Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('stories/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(image.path));
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('stories').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'مستخدم',
        'image': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'isOnline': true,
        'viewers': [],
      });

      ToastService.showSuccess('✅ تم إضافة الحالة بنجاح');
      _loadStories();
    } catch (e) {
      ToastService.showError('❌ فشل إضافة الحالة: $e');
    }
  }

  void _shareStory(Map<String, dynamic> story) {
    ToastService.showSuccess('✅ تم مشاركة الحالة مع ${story['name']}');
    // TODO: تنفيذ المشاركة الفعلية
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
            Tab(text: 'المحادثات'),  // ✅ الترتيب الصحيح: المحادثات أولاً
            Tab(text: 'المكالمات'),
            Tab(text: 'الحالات'),
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
          _buildChatsTab(isDark),
          _buildCallsTab(isDark),
          _buildStoriesTab(isDark),
        ],
      ),
    );
  }

  // ============================================================
  // 💬 تبويب المحادثات (الأول)
  // ============================================================
  Widget _buildChatsTab(bool isDark) {
    return StreamBuilder<QuerySnapshot>(
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
          padding: const EdgeInsets.all(12),
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
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
    );
  }

  // ============================================================
  // 📞 تبويب المكالمات
  // ============================================================
  Widget _buildCallsTab(bool isDark) {
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

  // ============================================================
  // 📸 تبويب الحالات (مع إضافة حالة)
  // ============================================================
  Widget _buildStoriesTab(bool isDark) {
    return Column(
      children: [
        // ✅ إضافة حالة جديدة
        Container(
          padding: const EdgeInsets.all(12),
          child: GestureDetector(
            onTap: _addStory,
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
        // ✅ قائمة الحالات
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _stories.length,
            itemBuilder: (context, index) {
              final story = _stories[index];
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
                      onTap: () => _shareStory(story),
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
