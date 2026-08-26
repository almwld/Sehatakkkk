import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({super.key});

  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': '1',
      'name': 'د. أحمد المولد',
      'specialty': 'باطنية',
      'rating': 4.9,
      'reviews': 328,
      'price': '150',
      'available': true,
      'online': true,
      'image': 'https://ik.imagekit.io/fqcynk86c/images/doctors/doctor_1.png',
      'nextAvailable': 'الآن',
    },
    {
      'id': '2',
      'name': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'rating': 4.8,
      'reviews': 256,
      'price': '200',
      'available': true,
      'online': true,
      'image': 'https://ik.imagekit.io/fqcynk86c/images/doctors/doctor_2.png',
      'nextAvailable': 'الآن',
    },
    {
      'id': '3',
      'name': 'د. أسماء الهندي',
      'specialty': 'أطفال',
      'rating': 4.7,
      'reviews': 189,
      'price': '120',
      'available': true,
      'online': false,
      'image': 'https://ik.imagekit.io/fqcynk86c/images/doctors/doctor_3.png',
      'nextAvailable': 'بعد 15 دقيقة',
    },
    {
      'id': '4',
      'name': 'د. محمد العلاي',
      'specialty': 'أنف وأذن وحنجرة',
      'rating': 4.6,
      'reviews': 89,
      'price': '180',
      'available': false,
      'online': false,
      'image': 'https://ik.imagekit.io/fqcynk86c/images/doctors/doctor_4.png',
      'nextAvailable': 'بعد ساعة',
    },
    {
      'id': '5',
      'name': 'د. فاطمة صديقي',
      'specialty': 'نساء وولادة',
      'rating': 4.8,
      'reviews': 210,
      'price': '160',
      'available': true,
      'online': true,
      'image': 'https://ik.imagekit.io/fqcynk86c/images/doctors/doctor_5.png',
      'nextAvailable': 'الآن',
    },
    {
      'id': '6',
      'name': 'د. سليمان الحكيم',
      'specialty': 'جلدية',
      'rating': 4.5,
      'reviews': 145,
      'price': '130',
      'available': true,
      'online': true,
      'image': 'https://ik.imagekit.io/fqcynk86c/images/doctors/doctor_6.png',
      'nextAvailable': 'الآن',
    },
  ];

  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'متاح الآن', 'الأعلى تقييماً', 'الأقل سعراً'];

  List<Map<String, dynamic>> get _filteredDoctors {
    var list = List<Map<String, dynamic>>.from(_doctors);
    
    switch (_selectedFilter) {
      case 'متاح الآن':
        list = list.where((d) => d['online'] == true).toList();
        break;
      case 'الأعلى تقييماً':
        list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'الأقل سعراً':
        list.sort((a, b) => (int.parse(a['price'])).compareTo(int.parse(b['price'])));
        break;
      default:
        break;
    }
    return list;
  }

  void _startConsultation(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('استشارة مع ${doctor['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🩺 التخصص: ${doctor['specialty']}'),
            const SizedBox(height: 8),
            Text('⭐ التقييم: ${doctor['rating']} (${doctor['reviews']} تقييم)'),
            const SizedBox(height: 8),
            Text('💰 السعر: ${doctor['price']} ر.ي'),
            const SizedBox(height: 8),
            if (doctor['online'] == true)
              const Text('🟢 متاح الآن', style: TextStyle(color: Colors.green))
            else
              Text('🟡 متاح ${doctor['nextAvailable']}', style: TextStyle(color: Colors.orange)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showCallingDialog(doctor);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('بدء الاستشارة'),
          ),
        ],
      ),
    );
  }

  void _showCallingDialog(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('جاري الاتصال...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(doctor['image']),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(height: 12),
            Text(doctor['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(doctor['specialty'], style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('جاري الاتصال بالطبيب...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );

    // محاكاة الاتصال
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        _showCallConnectedDialog(doctor);
      }
    });
  }

  void _showCallConnectedDialog(Map<String, dynamic> doctor) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('📹 جاهز للاستشارة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(doctor['image']),
              onBackgroundImageError: (_, __) {},
            ),
            const SizedBox(height: 12),
            Text(doctor['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(doctor['specialty'], style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('تم الاتصال بنجاح', style: TextStyle(color: Colors.green)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ToastService.showSuccess('✅ بدء الاستشارة مع ${doctor['name']}');
                  },
                  icon: const Icon(Icons.videocam),
                  label: const Text('بدء الفيديو'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ToastService.showSuccess('📞 بدء المكالمة الصوتية مع ${doctor['name']}');
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('صوت فقط'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('استشارة فيديو'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              ToastService.showSuccess('📋 عرض سجل الاستشارات');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ الفلاتر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : [],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          // ✅ قائمة الأطباء
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _filteredDoctors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 60, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('لا يوجد أطباء متاحون حالياً', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredDoctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _filteredDoctors[index];
                        return _buildDoctorCard(doctor, isDark);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // ✅ صورة الطبيب
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: doctor['online'] == true ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.network(
                doctor['image'],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Text(doctor['name'][0], style: TextStyle(fontSize: 24, color: AppColors.primary)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ✅ معلومات الطبيب
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        doctor['name'],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: doctor['online'] == true ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doctor['online'] == true ? '🟢 متاح' : '⏳ ${doctor['nextAvailable']}',
                        style: TextStyle(
                          fontSize: 9,
                          color: doctor['online'] == true ? Colors.green : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  doctor['specialty'],
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${doctor['rating']} (${doctor['reviews']})',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.payments, size: 14, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      '${doctor['price']} ر.ي',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ زر البدء
          ElevatedButton(
            onPressed: doctor['available'] == true ? () => _startConsultation(doctor) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              minimumSize: const Size(60, 32),
            ),
            child: const Text(
              'ابدأ',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
