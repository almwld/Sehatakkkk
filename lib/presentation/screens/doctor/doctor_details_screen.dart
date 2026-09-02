import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_booking_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isCreatingChat = false;
  Map<String, dynamic>? _doctor;
  int _selectedIndex = -1;
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();

  final List<Map<String, dynamic>> _contactIcons = [
    {'icon': Icons.phone, 'label': 'اتصال', 'color': Colors.green, 'action': 'call'},
    {'icon': Icons.videocam, 'label': 'فيديو', 'color': Colors.blue, 'action': 'video'},
    {'icon': Icons.chat_bubble_outline, 'label': 'مراسلة', 'color': AppColors.primary, 'action': 'chat'},
    {'icon': Icons.calendar_today, 'label': 'حجز', 'color': Colors.orange, 'action': 'book'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _doctor = {
            'id': doc.id,
            'name': data['name'] ?? 'طبيب',
            'specialty': data['specialty'] ?? 'طبيب عام',
            'experience': data['experience']?.toString() ?? 'غير محدد',
            'rating': data['rating']?.toDouble() ?? 0.0,
            'reviews': data['reviews'] ?? 0,
            'fee': data['consultationFee']?.toDouble() ?? data['fee'] ?? 0,
            'available': data['isAvailable'] ?? data['available'] ?? true,
            'image': data['image'] ?? data['photoUrl'] ?? ImageKit.doctor1,
            'hospital': data['clinicAddress'] ?? data['hospital'] ?? 'مستشفى',
            'online': data['isOnline'] ?? data['online'] ?? false,
            'about': data['about'] ?? data['bio'] ?? 'لا توجد نبذة',
            'availability': data['workingHours'] ?? data['availability'] ?? 'غير محدد',
          };
          _isLoading = false;
        });
      } else {
        ToastService.showError('❌ الطبيب غير موجود');
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Error loading doctor: $e');
      setState(() => _isLoading = false);
      ToastService.showError('❌ فشل في جلب بيانات الطبيب');
    }
  }

  // ✅ 1. مراسلة → ChatDetailScreen
  Future<void> _openChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول أولاً');
      return;
    }
    if (_doctor == null || _isCreatingChat) return;

    setState(() => _isCreatingChat = true);
    try {
      // ✅ إنشاء محادثة جديدة
      final chatId = await _chatService.createChat(
        doctorId: _doctor!['id'],
        doctorName: _doctor!['name'],
        patientName: user.displayName ?? 'مريض',
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: chatId,
            userId: _doctor!['id'],
            userName: _doctor!['name'],
            isDoctor: true,
          ),
        ),
      );
    } catch (e) {
      ToastService.showError('❌ فشل إنشاء المحادثة: $e');
    } finally {
      if (mounted) setState(() => _isCreatingChat = false);
    }
  }

  // ✅ 2. اتصال → CallScreen (صوتي)
  Future<void> _makeCall() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول أولاً');
      return;
    }
    if (_doctor == null) return;

    try {
      final chatId = await _chatService.createChat(
        doctorId: _doctor!['id'],
        doctorName: _doctor!['name'],
        patientName: user.displayName ?? 'مريض',
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: _doctor!['name'],
            doctorId: _doctor!['id'],
            isVideo: false,
          ),
        ),
      );
    } catch (e) {
      ToastService.showError('❌ فشل بدء المكالمة: $e');
    }
  }

  // ✅ 3. فيديو → CallScreen (فيديو)
  Future<void> _makeVideoCall() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('❌ يجب تسجيل الدخول أولاً');
      return;
    }
    if (_doctor == null) return;

    try {
      final chatId = await _chatService.createChat(
        doctorId: _doctor!['id'],
        doctorName: _doctor!['name'],
        patientName: user.displayName ?? 'مريض',
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: _doctor!['name'],
            doctorId: _doctor!['id'],
            isVideo: true,
          ),
        ),
      );
    } catch (e) {
      ToastService.showError('❌ فشل بدء مكالمة الفيديو: $e');
    }
  }

  // ✅ 4. حجز → DoctorBookingScreen
  void _bookAppointment() {
    if (_doctor == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorBookingScreen(doctorId: _doctor!['id']),
      ),
    );
  }

  void _handleAction(int index) {
    if (_isCreatingChat) return;
    setState(() => _selectedIndex = index);
    final action = _contactIcons[index]['action'] as String;
    switch (action) {
      case 'call': _makeCall(); break;
      case 'video': _makeVideoCall(); break;
      case 'chat': _openChat(); break;
      case 'book': _bookAppointment(); break;
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _selectedIndex = -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading || _doctor == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black87)),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => ToastService.showInfo('🔗 تم نسخ الرابط'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  // ✅ صورة الطبيب - استخدام CachedNetworkImage
                  ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: CachedNetworkImage(
                      imageUrl: _doctor!['image'] ?? ImageKit.doctor1,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 120,
                        color: Colors.grey[300],
                        child: Text(
                          _doctor!['name'][0],
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_doctor!['name'] ?? 'طبيب', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_doctor!['specialty'] ?? 'طبيب عام', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text((_doctor!['rating'] ?? 0).toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 4),
                      Text('(${_doctor!['reviews'] ?? 0} تقييم)', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ✅ أزرار التفاعل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _contactIcons.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = _selectedIndex == index;
                      final color = item['color'] as Color;
                      return GestureDetector(
                        onTap: () => _handleAction(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withOpacity(0.3) : color.withOpacity(0.16),
                            borderRadius: BorderRadius.circular(18),
                            border: isSelected ? Border.all(color: color, width: 2) : null,
                          ),
                          child: Column(
                            children: [
                              Icon(item['icon'] as IconData, color: color, size: 24),
                              const SizedBox(height: 4),
                              Text(item['label'], style: TextStyle(fontSize: 10, color: isDark ? Colors.white70 : Colors.black87)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            const Text('نبذة عن الطبيب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_doctor!['about'] ?? 'لا توجد معلومات', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.6)),
            const SizedBox(height: 16),
            _buildInfoRow('🏥 المستشفى', _doctor!['hospital'] ?? 'غير محدد', isDark),
            _buildInfoRow('💰 سعر الكشف', '${(_doctor!['fee'] ?? 0).toStringAsFixed(0)} ر.س', isDark),
            _buildInfoRow('📋 الحالة', (_doctor!['available'] ?? false) ? 'متاح' : 'غير متاح', isDark),
            _buildInfoRow('🎓 الخبرة', _doctor!['experience'] ?? 'غير محدد', isDark),
            _buildInfoRow('🕐 أوقات العمل', _doctor!['availability'] ?? 'غير محدد', isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600]))),
          Expanded(child: Text(value, style: TextStyle(color: isDark ? Colors.white : Colors.black87))),
        ],
      ),
    );
  }
}
