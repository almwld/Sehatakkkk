import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
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
  late Map<String, dynamic> _doctor;
  int _selectedIndex = -1;

  // ✅ الأيقونات الأربعة المحلية من مجلد chat (مكبرة بنسبة 10%)
  final List<Map<String, dynamic>> _contactIcons = [
    {
      'icon': 'assets/images/chat/phone_call.png',
      'label': 'اتصال',
      'color': Colors.green,
      'action': 'call',
      'screen': null,
    },
    {
      'icon': 'assets/images/chat/video_call.png',
      'label': 'مكالمة فيديو',
      'color': Colors.blue,
      'action': 'video',
      'screen': null,
    },
    {
      'icon': 'assets/images/chat/chat_bubble.png',
      'label': 'رسالة',
      'color': AppColors.primary,
      'action': 'chat',
      'screen': const ChatScreen(),
    },
    {
      'icon': 'assets/images/chat/calendar_booking.png',
      'label': 'حجز موعد',
      'color': Colors.orange,
      'action': 'book',
      'screen': DoctorBookingScreen(doctorId: '1'),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctorData();
  }

  void _loadDoctorData() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _doctor = _getDoctorData(widget.doctorId);
        _isLoading = false;
      });
    });
  }

  Map<String, dynamic> _getDoctorData(String doctorId) {
    switch (doctorId) {
      case '1':
        return {
          'name': 'د. أحمد المولد',
          'specialty': 'استشاري باطنية وأطفال',
          'experience': '20+ سنة',
          'rating': 4.9,
          'reviews': 328,
          'fee': '500',
          'available': true,
          'about': 'استشاري باطنية وأطفال مع خبرة واسعة في تشخيص وعلاج الأمراض المزمنة والحادة.',
          'hospital': 'مستشفى الثورة العام',
          'availability': ['السبت - الأربعاء: 9 ص - 5 م'],
          'image': ImageKit.doctor1,
        };
      case '2':
        return {
          'name': 'د. خالد النخلاني',
          'specialty': 'قلبية',
          'experience': '12 سنة',
          'rating': 4.8,
          'reviews': 256,
          'fee': '450',
          'available': true,
          'about': 'أخصائي قلوب ذو خبرة عالية في تشخيص وعلاج أمراض القلب والشرايين.',
          'hospital': 'مستشفى الكويت',
          'availability': ['الأحد - الخميس: 10 ص - 4 م'],
          'image': ImageKit.doctor2,
        };
      case '3':
        return {
          'name': 'د. أسماء الهندي',
          'specialty': 'أطفال',
          'experience': '9 سنوات',
          'rating': 4.7,
          'reviews': 189,
          'fee': '420',
          'available': true,
          'about': 'أخصائية أطفال متابعة التطور الصحي للأطفال من الولادة حتى المراهقة.',
          'hospital': 'مستشفى السبعين',
          'availability': ['السبت - الأربعاء: 8 ص - 2 م'],
          'image': ImageKit.doctor3,
        };
      case '4':
        return {
          'name': 'د. محمد العلاي',
          'specialty': 'أنف وأذن وحنجرة',
          'experience': '8 سنوات',
          'rating': 4.6,
          'reviews': 89,
          'fee': '400',
          'available': true,
          'about': 'أخصائي أنف وأذن وحنجرة مع خبرة في جراحات الأنف والأذن.',
          'hospital': 'مستشفى الأنف والأذن',
          'availability': ['الأحد - الخميس: 9 ص - 3 م'],
          'image': ImageKit.doctor4,
        };
      case '5':
        return {
          'name': 'د. فاطمة صديقي',
          'specialty': 'نساء وولادة',
          'experience': '10 سنوات',
          'rating': 4.8,
          'reviews': 210,
          'fee': '480',
          'available': true,
          'about': 'طبيبة نساء وولادة مختصة بالحالات الروتينية والمعقدة ورعاية الحمل.',
          'hospital': 'المستشفى الجمهوري',
          'availability': ['الإثنين - الجمعة: 9 ص - 1 م'],
          'image': ImageKit.doctor5,
        };
      default:
        return {
          'name': 'د. غير معروف',
          'specialty': 'عام',
          'experience': 'غير متوفر',
          'rating': 0.0,
          'reviews': 0,
          'fee': '0',
          'available': false,
          'about': 'معلومات الطبيب غير متوفرة',
          'hospital': '',
          'availability': [],
          'image': ImageKit.doctor1,
        };
    }
  }

  void _handleAction(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final action = _contactIcons[index]['action'] as String;
    final screen = _contactIcons[index]['screen'] as Widget?;

    switch (action) {
      case 'call':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📞 جاري الاتصال بالطبيب...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'video':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📹 جاري بدء مكالمة فيديو...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case 'chat':
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
        break;
      case 'book':
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        }
        break;
    }

    // إعادة تعيين التحديد بعد 300ms
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _selectedIndex = -1;
        });
      }
    });
  }

  Widget _buildContactIcon(Map<String, dynamic> item, int index, bool isDark) {
    final isSelected = _selectedIndex == index;
    final color = item['color'] as Color;

    return GestureDetector(
      onTap: () => _handleAction(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: isSelected
            ? Matrix4.identity()..scale = const Offset(0.9, 0.9)
            : Matrix4.identity(),
        child: Column(
          children: [
            Container(
              width: 80, // ✅ زيادة الحجم من 72 إلى 80 (زيادة 10%)
              height: 80, // ✅ زيادة الحجم من 72 إلى 80 (زيادة 10%)
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withOpacity(0.3)
                    : color.withOpacity(0.16),
                borderRadius: BorderRadius.circular(18),
                border: isSelected
                    ? Border.all(color: color, width: 2)
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
                child: Image.asset(
                  item['icon'] as String,
                  width: 40, // ✅ زيادة من 36 إلى 40 (زيادة 10%)
                  height: 40, // ✅ زيادة من 36 إلى 40 (زيادة 10%)
                  color: isSelected ? color : null,
                  errorBuilder: (context, error, stackTrace) {
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
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white70 : Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
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
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black87),
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🔗 تم نسخ الرابط'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة الطبيب
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: ClipOval(
                      child: AppImage(
                        imageUrl: _doctor['image'],
                        fit: BoxFit.cover,
                        errorWidget: const Icon(Icons.person, size: 60, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 16),
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
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _doctor['specialty'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _doctor['rating'].toString(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${_doctor['reviews']} تقييم)',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _doctor['available'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _doctor['available'] ? 'متاح الآن' : 'غير متاح',
                      style: TextStyle(
                        fontSize: 12,
                        color: _doctor['available'] ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ الأيقونات الأربعة المحلية (مكبرة بنسبة 10%)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  _contactIcons.length,
                  (index) => _buildContactIcon(_contactIcons[index], index, isDark),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // معلومات الطبيب
            Container(
              padding: const EdgeInsets.all(16),
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
                    _doctor['about'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.work, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'الخبرة: ${_doctor['experience']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.local_hospital, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'المستشفى: ${_doctor['hospital']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_money, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'رسوم الكشف: ${_doctor['fee']} ر.ي',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // أوقات العمل
            Container(
              padding: const EdgeInsets.all(16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أوقات العمل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(_doctor['availability'] as List<dynamic>).map((time) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              time as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
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
