import 'package:sehatak/core/services/sound_manager.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'غير مقروءة', 'مجموعات'];

  // ✅ أفضل 10 أطباء في صنعاء
  final List<Map<String, dynamic>> _topDoctors = [
    {'id': 'doctor_1', 'name': 'د. عبدالله الأصبحي', 'specialty': 'عظام', 'hospital': 'مستشفى الثورة', 'online': true},
    {'id': 'doctor_2', 'name': 'د. حامد ذمران', 'specialty': 'أعصاب', 'hospital': 'مستشفى المتحدون', 'online': false},
    {'id': 'doctor_3', 'name': 'د. روضة المنصوب', 'specialty': 'نسائية', 'hospital': 'مركز زاد الطبي', 'online': true},
    {'id': 'doctor_4', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'hospital': 'مستشفى المتحدون', 'online': true},
    {'id': 'doctor_5', 'name': 'د. عدنان البعداني', 'specialty': 'مسالك بولية', 'hospital': 'مستشفى المتحدون', 'online': false},
    {'id': 'doctor_6', 'name': 'د. خالد النخلاني', 'specialty': 'قلب', 'hospital': 'مركز قلب العاصمة', 'online': false},
    {'id': 'doctor_7', 'name': 'د. علي البراشي', 'specialty': 'جلدية', 'hospital': 'مركز البراشي', 'online': true},
    {'id': 'doctor_8', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن', 'hospital': 'مستشفى الأنف والأذن', 'online': false},
    {'id': 'doctor_9', 'name': 'د. لبيب الاغبري', 'specialty': 'جراحة عامة', 'hospital': 'مستشفى الاغبري', 'online': false},
    {'id': 'doctor_10', 'name': 'د. نديم البكير', 'specialty': 'قلب', 'hospital': 'مركز قلب العاصمة', 'online': false},
  ];

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
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isDoctor = FirebaseAuth.instance.currentUser?.displayName?.contains('د.') ?? false;
    final role = isDoctor ? 'doctor' : 'patient';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'الدردشة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // ✅ زر المكالمة الصوتية
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
            ),
            onPressed: () {
              if (_topDoctors.isNotEmpty) {
                final doctor = _topDoctors[0];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                      doctorName: doctor['name'],
                      doctorId: doctor['id'],
                      isVideo: false,
                    ),
                  ),
                );
              }
            },
            tooltip: 'مكالمة صوتية',
          ),
          // ✅ زر مكالمة الفيديو
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.videocam_rounded, color: AppColors.info, size: 20),
            ),
            onPressed: () {
              if (_topDoctors.isNotEmpty) {
                final doctor = _topDoctors[0];
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                      doctorName: doctor['name'],
                      doctorId: doctor['id'],
                      isVideo: true,
                    ),
                  ),
                );
              }
            },
            tooltip: 'مكالمة فيديو',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ..._filters.map((filter) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedFilter == filter
                            ? AppColors.primary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _selectedFilter == filter
                              ? AppColors.primary
                              : AppColors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedFilter == filter
                              ? Colors.white
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                )),
                const Spacer(),
                Text(
                  '${_topDoctors.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: userId == null
          ? _buildNotLoggedIn()
          : Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _topDoctors.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const Text(
                                'أفضل الأطباء',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const DoctorsListScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'عرض الكل',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      final doctor = _topDoctors[index - 1];
                      return _buildChatItem(
                        context,
                        doctorId: doctor['id'],
                        name: doctor['name'],
                        specialty: doctor['specialty'],
                        hospital: doctor['hospital'],
                        online: doctor['online'],
                        isDoctor: true,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'ابحث عن محادثة...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'يجب تسجيل الدخول',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'قم بتسجيل الدخول لعرض محادثاتك',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/login'),
            icon: const Icon(Icons.login_rounded),
            label: const Text('تسجيل الدخول'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context, {
    required String doctorId,
    required String name,
    required String specialty,
    required String hospital,
    required bool online,
    required bool isDoctor,
  }) {
    final lastMessage = _getLastMessage(name);
    final time = _getLastTime(name);
    final unread = _getUnreadCount(name);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(
              chatId: 'chat_${name.replaceAll(' ', '_')}',
              userName: name,
              userId: doctorId,
              isDoctor: isDoctor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ صورة المستخدم مع حالة الاتصال
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0] : 'ط',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (online)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ معلومات المحادثة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          style: TextStyle(
                            fontSize: 12,
                            color: unread > 0 ? AppColors.darkGrey : AppColors.grey,
                            fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  // ✅ التخصص والمستشفى
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          specialty,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hospital,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ أزرار الاتصال السريع
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ زر المكالمة الصوتية
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                          doctorName: name,
                          doctorId: doctorId,
                          isVideo: false,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.call_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // ✅ زر مكالمة الفيديو
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                          doctorName: name,
                          doctorId: doctorId,
                          isVideo: true,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: AppColors.info,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ بيانات وهمية للمحادثات
  String _getLastMessage(String name) {
    final messages = {
      'د. عبدالله الأصبحي': 'تم تأكيد الموعد غداً',
      'د. حامد ذمران': 'سأكون متاحاً في العاشرة',
      'د. روضة المنصوب': 'متابعة الحمل تسير بشكل جيد',
      'د. أسماء الهندي': 'تم إعطاء التطعيمات',
      'د. عدنان البعداني': 'نتائج التحاليل جيدة',
      'د. خالد النخلاني': 'يجب متابعة الضغط',
      'د. علي البراشي': 'العلاج يعمل بشكل جيد',
      'د. محمد العلاي': 'موعد الجراحة يوم الأحد',
      'د. لبيب الاغبري': 'الجراحة تمت بنجاح',
      'د. نديم البكير': 'تخطيط القلب طبيعي',
    };
    return messages[name] ?? 'ابدأ المحادثة';
  }

  String _getLastTime(String name) {
    final times = {
      'د. عبدالله الأصبحي': '10:30',
      'د. حامد ذمران': '09:15',
      'د. روضة المنصوب': '08:00',
      'د. أسماء الهندي': 'أمس',
      'د. عدنان البعداني': 'أمس',
      'د. خالد النخلاني': 'أمس',
      'د. علي البراشي': '10:00',
      'د. محمد العلاي': '09:30',
      'د. لبيب الاغبري': 'أمس',
      'د. نديم البكير': 'أمس',
    };
    return times[name] ?? '10:00';
  }

  int _getUnreadCount(String name) {
    final counts = {
      'د. عبدالله الأصبحي': 2,
      'د. حامد ذمران': 0,
      'د. روضة المنصوب': 1,
      'د. أسماء الهندي': 0,
      'د. عدنان البعداني': 3,
      'د. خالد النخلاني': 0,
      'د. علي البراشي': 0,
      'د. محمد العلاي': 1,
      'د. لبيب الاغبري': 0,
      'د. نديم البكير': 0,
    };
    return counts[name] ?? 0;
  }
}
