// ============================================================
// 📁 lib/presentation/screens/doctor/doctor_details_screen.dart
// 👨‍⚕️ شاشة تفاصيل الطبيب
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/booking/booking_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  DoctorModel? _doctor;
  bool _isLoading = true;
  bool _isFavorite = false;
  int _selectedTab = 0;

  final List<String> _tabs = ['المعلومات', 'المواعيد', 'التقييمات'];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _checkFavorite();
  }

  Future<void> _loadDoctorData() async {
    try {
      final doc = await _firestore.collection('doctors').doc(widget.doctorId).get();
      if (doc.exists) {
        setState(() {
          _doctor = DoctorModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ToastService.showError('❌ الطبيب غير موجود');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ToastService.showError('❌ فشل تحميل البيانات: $e');
    }
  }

  Future<void> _checkFavorite() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.doctorId)
          .get();
      setState(() {
        _isFavorite = doc.exists;
      });
    } catch (e) {
      // ignore
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.doctorId);

      if (_isFavorite) {
        await ref.delete();
        setState(() => _isFavorite = false);
        ToastService.showInfo('❌ تم إزالة الطبيب من المفضلة');
      } else {
        await ref.set({
          'doctorId': widget.doctorId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        setState(() => _isFavorite = true);
        ToastService.showSuccess('✅ تم إضافة الطبيب إلى المفضلة');
      }
    } catch (e) {
      ToastService.showError('❌ فشل تحديث المفضلة: $e');
    }
  }

  // ✅ دردشة مع الطبيب
  Future<void> _startChat() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      if (_doctor == null) return;

      final chatId = await _chatService.createChat(
        doctorId: _doctor!.id,
        doctorName: _doctor!.name,
        patientName: user.displayName ?? 'مريض',
      );

      if (chatId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatId: chatId,
              otherUserId: _doctor!.id,
              otherUserName: _doctor!.name,
              isGroup: false,
            ),
          ),
        );
      }
    } catch (e) {
      ToastService.showError('❌ فشل بدء المحادثة: $e');
    }
  }

  // ✅ مكالمة مع الطبيب
  void _startCall(bool isVideo) {
    if (_doctor == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: _doctor!.name,
          doctorId: _doctor!.id,
          isVideo: isVideo,
        ),
      ),
    );
  }

  // ✅ حجز موعد مع الطبيب
  void _bookAppointment() {
    if (_doctor == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(doctorId: _doctor!.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
          elevation: 0,
          foregroundColor: isDark ? Colors.white : Colors.black87,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
          elevation: 0,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          title: const Text('غير موجود'),
        ),
        body: const Center(child: Text('الطبيب غير موجود')),
      );
    }

    final doctor = _doctor!;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: const Text('تفاصيل الطبيب'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black87),
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => ToastService.showInfo('📤 مشاركة الطبيب'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ رأس الطبيب
            _buildDoctorHeader(doctor, isDark),
            const SizedBox(height: 16),

            // ✅ أزرار الإجراءات السريعة
            _buildActionButtons(isDark),
            const SizedBox(height: 16),

            // ✅ التبويبات
            _buildTabs(isDark),
            const SizedBox(height: 12),

            // ✅ محتوى التبويبات
            _buildTabContent(isDark),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🧩 رأس الطبيب
  // ============================================================
  Widget _buildDoctorHeader(DoctorModel doctor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
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
          // ✅ صورة الطبيب
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: doctor.isAvailable ? Colors.green : Colors.grey,
                width: 3,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: AppImage(
                imageUrl: doctor.photoUrl ?? ImageKit.doctor1,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // ✅ المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${doctor.rating ?? 0}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${doctor.reviewsCount ?? 0})',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: doctor.isAvailable ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doctor.isAvailable ? 'متاح' : 'غير متاح',
                        style: TextStyle(
                          fontSize: 9,
                          color: doctor.isAvailable ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (doctor.isOnline)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'متصل',
                              style: TextStyle(
                                fontSize: 9,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.payments, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.consultationFee ?? 0} ر.ي',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.work_outline, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.experienceYears ?? 0} سنة خبرة',
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
        ],
      ),
    );
  }

  // ============================================================
  // 🔘 أزرار الإجراءات السريعة
  // ============================================================
  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.chat,
            label: 'دردشة',
            color: AppColors.primary,
            isDark: isDark,
            onTap: _startChat,
          ),
          _buildActionButton(
            icon: Icons.phone,
            label: 'اتصال',
            color: Colors.green,
            isDark: isDark,
            onTap: () => _startCall(false),
          ),
          _buildActionButton(
            icon: Icons.videocam,
            label: 'فيديو',
            color: Colors.blue,
            isDark: isDark,
            onTap: () => _startCall(true),
          ),
          _buildActionButton(
            icon: Icons.calendar_today,
            label: 'حجز',
            color: Colors.orange,
            isDark: isDark,
            onTap: _bookAppointment,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📑 التبويبات
  // ============================================================
  Widget _buildTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ============================================================
  // 📄 محتوى التبويبات
  // ============================================================
  Widget _buildTabContent(bool isDark) {
    switch (_selectedTab) {
      case 0:
        return _buildInfoTab(isDark);
      case 1:
        return _buildAppointmentsTab(isDark);
      case 2:
        return _buildReviewsTab(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // ℹ️ تبويب المعلومات
  // ============================================================
  Widget _buildInfoTab(bool isDark) {
    final doctor = _doctor!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (doctor.about != null && doctor.about!.isNotEmpty) ...[
            const Text('السيرة الذاتية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(doctor.about!, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.5)),
            const SizedBox(height: 16),
          ],
          const Text('المعلومات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildInfoRow(icon: Icons.medical_services, label: 'التخصص', value: doctor.specialty, isDark: isDark),
          _buildInfoRow(icon: Icons.work_outline, label: 'سنوات الخبرة', value: '${doctor.experienceYears ?? 0} سنة', isDark: isDark),
          _buildInfoRow(icon: Icons.payments, label: 'رسوم الكشف', value: '${doctor.consultationFee ?? 0} ر.ي', isDark: isDark),
          if (doctor.clinicAddress != null) ...[
            _buildInfoRow(icon: Icons.location_on, label: 'العنوان', value: doctor.clinicAddress!, isDark: isDark),
          ],
          if (doctor.hospital != null) ...[
            _buildInfoRow(icon: Icons.local_hospital, label: 'المستشفى', value: doctor.hospital!, isDark: isDark),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📅 تبويب المواعيد
  // ============================================================
  Widget _buildAppointmentsTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ✅ زر حجز موعد
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _bookAppointment,
              icon: const Icon(Icons.calendar_today),
              label: const Text('حجز موعد جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ✅ قائمة المواعيد القادمة
          const Text(
            'المواعيد القادمة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // TODO: جلب المواعيد من Firestore
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text('لا توجد مواعيد قادمة'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ⭐ تبويب التقييمات
  // ============================================================
  Widget _buildReviewsTab(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_doctor!.rating ?? 0}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                      const Text(
                        'من 5',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تقييم عام ممتاز',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_doctor!.reviewsCount ?? 0} تقييم',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (index) {
                          final filled = index < (_doctor!.rating ?? 0).round();
                          return Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'آخر التقييمات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // TODO: جلب التقييمات من Firestore
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text('لا توجد تقييمات'),
            ),
          ),
        ],
      ),
    );
  }
}
