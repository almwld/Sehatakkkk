import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/firestore_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_booking_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _isCreatingChat = false;

  late Map<String, dynamic> _doctor;

  int _selectedIndex = -1;

  final List<Map<String, dynamic>> _contactIcons = [
    {
      'icon': 'assets/images/chat/phone_call.png',
      'label': 'اتصال',
      'color': Colors.green,
      'action': 'call',
    },
    {
      'icon': 'assets/images/chat/video_call.png',
      'label': 'مكالمة فيديو',
      'color': Colors.blue,
      'action': 'video',
    },
    {
      'icon': 'assets/images/chat/chat_bubble.png',
      'label': 'مراسلة',
      'color': AppColors.primary,
      'action': 'chat',
    },
    {
      'icon': 'assets/images/chat/calendar_booking.png',
      'label': 'حجز موعد',
      'color': Colors.orange,
      'action': 'book',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  Future<void> _loadDoctorData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final data = await FirestoreService().getDoctor(widget.doctorId);

      if (!mounted) return;

      if (data == null) {
        ToastService.showError('لم يتم العثور على بيانات الطبيب');
        Navigator.pop(context);
        return;
      }

      final rawExperience = data['experience'];

      final normalizedDoctor = {
        ...data,
        'id': data['id']?.toString() ?? widget.doctorId,
        'name': data['name']?.toString() ?? 'طبيب',
        'specialty': data['specialty']?.toString() ?? 'طبيب عام',
        'experience': rawExperience?.toString() ?? 'غير محدد',
        'rating': data['rating'] ?? 0,
        'reviews': data['reviews'] ?? 0,
        'fee': data['fee'] ?? 0,
        'available': data['available'] ?? false,
        'online': data['online'] ?? false,
        'about': data['about']?.toString() ?? 'لا توجد نبذة متاحة',
        'hospital': data['hospital']?.toString() ?? 'غير محدد',
        'availability': data['availability'] is List
            ? List<dynamic>.from(data['availability'])
            : <dynamic>[],
        'image': data['photoUrl']?.toString() ??
            data['image']?.toString() ??
            '',
      };

      setState(() {
        _doctor = normalizedDoctor;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint('Load doctor error: $error');

      if (!mounted) return;

      setState(() => _isLoading = false);

      ToastService.showError(
        'تعذر تحميل بيانات الطبيب',
      );
    }
  }

  Future<void> _handleAction(int index) async {
    if (_isCreatingChat) return;

    setState(() => _selectedIndex = index);

    final action = _contactIcons[index]['action'] as String;

    switch (action) {
      case 'call':
        ToastService.showSuccess('📞 جاري الاتصال بالطبيب...');
        break;

      case 'video':
        ToastService.showSuccess('📹 جاري بدء مكالمة فيديو...');
        break;

      case 'chat':
        await _openDoctorChat();
        break;

      case 'book':
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorBookingScreen(
              doctorId: widget.doctorId,
            ),
          ),
        );
        break;
    }

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _selectedIndex = -1);
      }
    });
  }

  Future<void> _openDoctorChat() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ToastService.showError(
        'يرجى تسجيل الدخول أولاً لبدء المحادثة',
      );
      return;
    }

    if (_isCreatingChat) return;

    // لا يمكن بدء محادثة مع طبيب غير متاح.
    final isAvailable = _doctor['available'] == true;

    if (!isAvailable) {
      ToastService.showError(
        'الطبيب غير متاح للمحادثة حاليًا',
      );
      return;
    }

    final doctorId =
        _doctor['id']?.toString() ?? widget.doctorId;

    if (doctorId.trim().isEmpty) {
      ToastService.showError(
        'معرف الطبيب غير صالح',
      );
      return;
    }

    final doctorName =
        _doctor['name']?.toString() ?? 'الطبيب';

    final doctorImage =
        _doctor['image']?.toString() ?? '';

    final patientName =
        user.displayName?.trim().isNotEmpty == true
            ? user.displayName!.trim()
            : 'المريض';

    setState(() => _isCreatingChat = true);

    try {
      final chatService = ChatService();

      /*
       * patientId يتم تمريره للتوافق مع الواجهة الحالية
       * لكن ChatService والـ Backend يستخدمان Firebase UID
       * الحقيقي للمستخدم المسجل.
       */
      final chatId = await chatService.createChat(
        doctorId: doctorId,
        doctorName: doctorName,
        patientId: user.uid,
        patientName: patientName,
        doctorImage: doctorImage,
        patientImage: user.photoURL,
      );

      if (!mounted) return;

      if (chatId.trim().isEmpty) {
        throw Exception(
          'لم يتم الحصول على معرف المحادثة',
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: chatId,
            userId: doctorId,
            userName: doctorName,
            isDoctor: false,
          ),
        ),
      );
    } catch (error) {
      debugPrint(
        'Open doctor chat error: $error',
      );

      if (!mounted) return;

      ToastService.showError(
        'تعذر فتح المحادثة، حاول مرة أخرى',
      );
    } finally {
      if (mounted) {
        setState(
          () => _isCreatingChat = false,
        );
      }
    }
  }

  Widget _buildContactIcon(
    Map<String, dynamic> item,
    int index,
    bool isDark,
  ) {
    final isSelected = _selectedIndex == index;
    final color = item['color'] as Color;

    final isChatAction = item['action'] == 'chat';

    return GestureDetector(
      onTap: () => _handleAction(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: isSelected
            ? Matrix4.diagonal3Values(0.9, 0.9, 1.0)
            : Matrix4.identity(),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.3)
                    : color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(
                        color: color,
                        width: 2,
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: _isCreatingChat && isChatAction
                    ? SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      )
                    : Image.asset(
                        item['icon'] as String,
                        width: 40,
                        height: 40,
                        color: isSelected ? color : null,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return Icon(
                            Icons.circle,
                            color: color,
                            size: 40,
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? color
                    : (isDark
                        ? Colors.white70
                        : Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0B1121)
            : const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor:
            isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: _isFavorite
                  ? Colors.red
                  : (isDark
                      ? Colors.white
                      : Colors.black87),
            ),
            onPressed: () {
              setState(() => _isFavorite = !_isFavorite);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.share,
              color:
                  isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              ToastService.showSuccess('🔗 تم نسخ الرابط');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: AppImage(
                        imageUrl: _doctor['image'],
                        fit: BoxFit.cover,
                        errorWidget: const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration:
                          const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Column(
                children: [
                  Text(
                    _doctor['name'],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _doctor['specialty'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _doctor['rating'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color: isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_doctor['reviews']} تقييم)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _doctor['available']
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      _doctor['available']
                          ? 'متاح الآن'
                          : 'غير متاح',
                      style: TextStyle(
                        fontSize: 12,
                        color: _doctor['available']
                            ? Colors.green
                            : Colors.red,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2540)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _contactIcons.length,
                  (index) => _buildContactIcon(
                    _contactIcons[index],
                    index,
                    isDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2540)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'نبذة عن الطبيب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _doctor['about'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.work,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الخبرة: ${_doctor['experience']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'المستشفى: ${_doctor['hospital']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? Colors.grey[300]
                              : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'رسوم الكشف: ${_doctor['fee']} ر.ي',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A2540)
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'أوقات العمل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(_doctor['availability']
                          as List<dynamic>)
                      .map((time) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            color:
                                AppColors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              time as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey[300]
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
