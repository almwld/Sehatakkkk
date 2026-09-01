// ============================================================
// 📱 شاشة المحادثات - النسخة النهائية
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/chat/create_group_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _totalUnread = 0;
  bool _isCreatingChats = false;
  bool _isLoading = true;

  final ChatService _chatService = ChatService();

  // ✅ تبويبات الدردشة
  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.chat_bubble_outline, 'label': 'المحادثات'},
    {'icon': Icons.call_outlined, 'label': 'المكالمات'},
    {'icon': Icons.circle_outlined, 'label': 'الحالات'},
  ];

  // ✅ قائمة الأطباء
  final List<Map<String, dynamic>> _doctors = [
    {'id': 'doc1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'image': '', 'isOnline': true},
    {'id': 'doc2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'image': '', 'isOnline': false},
    {'id': 'doc3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'image': '', 'isOnline': true},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _loadChats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadChats() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = false);
    });
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
      title: const Text('المحادثات'),
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: isDark ? Colors.white : Colors.black87),
              onPressed: () {
                Navigator.pushNamed(context, /notifications);
              },
            ),
            Positioned(
              right: 0,
              top: 0,
              child: _buildNotificationBadge(),
            ),
          ],
        ),
        
        IconButton(
          icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black87),
          onPressed: _loadChats,
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
              case 'create_all':
                _createChatsWithAllDoctors();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'create_all',
              child: Row(
                children: [
                  Icon(Icons.add_comment, color: Colors.green),
                  SizedBox(width: 8),
                  Text('إنشاء محادثات مع جميع الأطباء'),
                ],
              ),
            ),
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
    }
    return FloatingActionButton(
      onPressed: () => ToastService.showInfo('📞 جاري بدء المكالمة...'),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.call, color: Colors.white),
    );
  }

  // ============================================================
  // 📱 تبويب المحادثات
  // ============================================================

  Widget _buildChatsTab(bool isDark) {
    return Column(
      children: [
        _buildSearchBar(isDark),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildEmptyState(isDark),
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

  // ============================================================
  // 📞 تبويب المكالمات
  // ============================================================

  Widget _buildCallsTab(bool isDark) {
    final calls = [
      {'name': 'د. أحمد المؤيد', 'type': 'audio', 'status': 'answered', 'time': '10:30 ص', 'duration': '5:23'},
      {'name': 'د. خالد النخلاني', 'type': 'video', 'status': 'missed', 'time': 'أمس', 'duration': ''},
      {'name': 'د. أسماء الهندي', 'type': 'audio', 'status': 'incoming', 'time': 'منذ ساعة', 'duration': ''},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        final name = call['name'] as String? ?? 'مستخدم';
        final type = call['type'] as String? ?? 'audio';
        final status = call['status'] as String? ?? 'answered';
        final time = call['time'] as String? ?? '';
        final isMissed = status == 'missed';
        final isIncoming = status == 'incoming';
        final isVideo = type == 'video';

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
                  name.isNotEmpty ? name[0] : 'م',
                  style: const TextStyle(color: AppColors.primary),
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
                          time,
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
    final List<Map<String, dynamic>> stories = [
      {'name': 'د. أحمد المؤيد', 'time': 'منذ 5 دقائق', 'viewed': false},
      {'name': 'د. خالد النخلاني', 'time': 'منذ ساعة', 'viewed': true},
      {'name': 'د. أسماء الهندي', 'time': 'منذ 3 ساعات', 'viewed': false},
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
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              final name = story['name'] as String? ?? 'مستخدم';
              final time = story['time'] as String? ?? '';
              final viewed = story['viewed'] as bool? ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: viewed == false
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        name.isNotEmpty ? name[0] : 'م',
                        style: const TextStyle(color: AppColors.primary),
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
                              fontWeight: viewed == false ? FontWeight.bold : FontWeight.normal,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            time,
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
                        viewed == false ? Icons.circle : Icons.check_circle,
                        color: viewed == false ? AppColors.primary : Colors.grey,
                      ),
                      onPressed: () => ToastService.showSuccess('✅ تم مشاهدة الحالة'),
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

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================

  Future<void> _createChatsWithAllDoctors() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول');
      return;
    }

    setState(() => _isCreatingChats = true);
    ToastService.showInfo('⏳ جاري إنشاء المحادثات...');

    try {
      int count = 0;
      for (final doctor in _doctors) {
        try {
          final chatId = await _chatService.createChat(
            doctorId: doctor['id'] as String,
            doctorName: doctor['name'] as String,
            patientId: user.uid,
            patientName: user.displayName ?? 'مريض',
            doctorImage: doctor['image'] as String?,
          );
          count++;
        } catch (e) {
          print('❌ Error creating chat with ${doctor['name']}: $e');
        }
      }

      ToastService.showSuccess('✅ تم إنشاء $count محادثة');
    } catch (e) {
      ToastService.showError('❌ فشل إنشاء المحادثات: $e');
    }

    setState(() => _isCreatingChats = false);
    _loadChats();
  }

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
                'اختر طبيباً',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            ..._doctors.map((doctor) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(
                  (doctor['name'] as String).isNotEmpty ? (doctor['name'] as String)[0] : 'ط',
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
              title: Text(doctor['name'] as String? ?? 'طبيب'),
              subtitle: Text(doctor['specialty'] as String? ?? 'طبيب'),
              trailing: const Icon(Icons.chat, color: AppColors.primary),
              onTap: () {
                Navigator.pop(context);
                _startChatWithDoctor(doctor);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _startChatWithDoctor(Map<String, dynamic> doctor) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول');
      return;
    }

    try {
      _chatService.createChat(
        doctorId: doctor['id'] as String,
        doctorName: doctor['name'] as String,
        patientId: user.uid,
        patientName: user.displayName ?? 'مريض',
        doctorImage: doctor['image'] as String?,
      ).then((chatId) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: chatId,
              userId: user.uid,
              userName: doctor['name'] as String,
              isDoctor: true,
            ),
          ),
        );
      }).catchError((e) {
        ToastService.showError('❌ فشل بدء المحادثة: $e');
      });
    } catch (e) {
      ToastService.showError('❌ فشل بدء المحادثة: $e');
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
}

  // ✅ عرض عدد الإشعارات غير المقروءة في AppBar
  Widget _buildNotificationBadge() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '')
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final count = snapshot.data!.docs.length;
        if (count == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
