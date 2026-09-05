import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/core/constants/imagekit.dart';

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
  final ChatService _chatService = ChatService();
  DoctorModel? _doctor;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isBookmarked = false;
  String? _selectedDate;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
    _checkFavorite();
  }

  Future<void> _loadDoctorData() async {
    setState(() => _isLoading = true);
    try {
      final state = context.read<DoctorBloc>().state;
      if (state is DoctorLoaded) {
        _doctor = state.doctors.firstWhere(
          (d) => d.id == widget.doctorId,
          orElse: () => throw Exception('الطبيب غير موجود'),
        );
      } else {
        // ✅ جلب مباشر من Firestore إذا لم يكن في الـ BLoC
        final doc = await FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .get();
        
        if (doc.exists) {
          _doctor = DoctorModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ToastService.showError('❌ فشل تحميل بيانات الطبيب');
    }
  }

  Future<void> _checkFavorite() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final favorites = List<String>.from(doc.data() as Map<String, dynamic>?['favoriteDoctors'] ?? []);
      setState(() => _isFavorite = favorites.contains(widget.doctorId));
    } catch (e) {
      print('⚠️ Error checking favorite: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();
      final favorites = List<String>.from(doc.data() as Map<String, dynamic>?['favoriteDoctors'] ?? []);

      if (_isFavorite) {
        await userRef.update({
          'favoriteDoctors': FieldValue.arrayRemove([widget.doctorId]),
        });
      } else {
        await userRef.update({
          'favoriteDoctors': FieldValue.arrayUnion([widget.doctorId]),
        });
      }

      setState(() => _isFavorite = !_isFavorite);
      ToastService.showSuccess(
        _isFavorite ? '✅ تمت الإضافة إلى المفضلة' : '❌ تمت الإزالة من المفضلة',
      );
    } catch (e) {
      ToastService.showError('❌ فشل تحديث المفضلة');
    }
  }

  // ✅ بدء محادثة مع الطبيب
  Future<void> _startChat() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      if (_doctor == null) {
        ToastService.showError('❌ لم يتم تحميل بيانات الطبيب');
        return;
      }

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

  // ✅ بدء مكالمة مع الطبيب
  void _startCall(bool isVideo) {
    if (_doctor == null) {
      ToastService.showError('❌ لم يتم تحميل بيانات الطبيب');
      return;
    }

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

  // ✅ حجز موعد
  Future<void> _bookAppointment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      if (_selectedDate == null || _selectedTime == null) {
        ToastService.showError('❌ يرجى تحديد تاريخ ووقت الحجز');
        return;
      }

      await FirebaseFirestore.instance.collection('appointments').add({
        'doctorId': widget.doctorId,
        'doctorName': _doctor?.name ?? '',
        'patientId': user.uid,
        'patientName': user.displayName ?? 'مريض',
        'date': _selectedDate,
        'time': _selectedTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      ToastService.showSuccess('✅ تم حجز الموعد بنجاح!');
      Navigator.pop(context);
    } catch (e) {
      ToastService.showError('❌ فشل حجز الموعد: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (_doctor == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'لم يتم العثور على الطبيب',
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('رجوع'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => ToastService.showSuccess('📤 تم المشاركة'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بطاقة الطبيب
            _buildDoctorCard(isDark),
            const SizedBox(height: 16),
            
            // ✅ أزرار الإجراءات السريعة
            _buildActionButtons(isDark),
            const SizedBox(height: 16),
            
            // ✅ معلومات الطبيب
            _buildInfoSection(isDark),
            const SizedBox(height: 16),
            
            // ✅ حجز موعد
            _buildBookingSection(isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🃏 بطاقة الطبيب
  // ============================================================
  Widget _buildDoctorCard(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          // ✅ صورة الطبيب
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: _doctor!.photoUrl != null
                    ? NetworkImage(_doctor!.photoUrl!)
                    : null,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: _doctor!.photoUrl == null
                    ? Text(
                        _doctor!.name.isNotEmpty ? _doctor!.name[0] : 'ط',
                        style: TextStyle(
                          fontSize: 40,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              if (_doctor!.isOnline)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ✅ الاسم
          Text(
            _doctor!.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          
          // ✅ التخصص
          Text(
            _doctor!.specialty,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          
          // ✅ التقييم
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${_doctor!.rating ?? 0}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${_doctor!.reviewsCount ?? 0} تقييم)',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _doctor!.isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _doctor!.isAvailable ? 'متاح' : 'غير متاح',
                  style: TextStyle(
                    fontSize: 10,
                    color: _doctor!.isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // ✅ الخبرة والسعر
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work_history, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${_doctor!.experienceYears ?? 0} سنة خبرة',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.payments, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${_doctor!.consultationFee ?? 0} ر.ي',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (_doctor!.hospital != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _doctor!.hospital!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // 🎯 أزرار الإجراءات السريعة
  // ============================================================
  Widget _buildActionButtons(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.chat,
            label: 'دردشة',
            color: AppColors.primary,
            onTap: _startChat,
          ),
          _buildActionButton(
            icon: Icons.phone,
            label: 'اتصال',
            color: Colors.green,
            onTap: () => _startCall(false),
          ),
          _buildActionButton(
            icon: Icons.videocam,
            label: 'فيديو',
            color: Colors.blue,
            onTap: () => _startCall(true),
          ),
          _buildActionButton(
            icon: Icons.calendar_today,
            label: 'حجز',
            color: Colors.orange,
            onTap: () => _bookAppointment(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ℹ️ معلومات الطبيب
  // ============================================================
  Widget _buildInfoSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نبذة عن الطبيب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _doctor!.about ?? 'لا توجد معلومات إضافية',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          if (_doctor!.education != null && _doctor!.education!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'المؤهلات العلمية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ..._doctor!.education!.map((edu) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.school, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        edu['degree'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // 📅 حجز موعد
  // ============================================================
  Widget _buildBookingSection(bool isDark) {
    final dates = List.generate(7, (index) {
      final date = DateTime.now().add(Duration(days: index));
      return {
        'day': ['أحد', 'إثن', 'ثلاث', 'أربع', 'خميس', 'جمعة', 'سبت'][date.weekday % 7],
        'date': date.day,
        'month': ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'][date.month - 1],
        'full': date,
      };
    });

    final times = [
      '09:00 ص',
      '09:30 ص',
      '10:00 ص',
      '10:30 ص',
      '11:00 ص',
      '11:30 ص',
      '12:00 م',
      '12:30 م',
      '01:00 م',
      '01:30 م',
      '02:00 م',
      '02:30 م',
      '03:00 م',
      '03:30 م',
      '04:00 م',
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حجز موعد',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // ✅ اختيار التاريخ
          Text(
            'اختر التاريخ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              itemBuilder: (context, index) {
                final date = dates[index];
                final isSelected = _selectedDate == date['full'].toString();
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date['full'].toString();
                    });
                  },
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? const Color(0xFF0B1121) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date['day'],
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                          ),
                        ),
                        Text(
                          '${date['date']}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                        Text(
                          date['month'],
                          style: TextStyle(
                            fontSize: 8,
                            color: isSelected
                                ? Colors.white70
                                : (isDark ? Colors.grey.shade500 : Colors.grey.shade500),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          
          // ✅ اختيار الوقت
          Text(
            'اختر الوقت',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: times.map((time) {
              final isSelected = _selectedTime == time;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = time),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? const Color(0xFF0B1121) : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          
          // ✅ زر حجز الموعد
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'تأكيد الحجز',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
