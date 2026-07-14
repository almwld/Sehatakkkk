import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final List<Map<String, dynamic>> hospitals = [
    {
      'name': 'مستشفى الثورة العام',
      'location': 'صنعاء',
      'specialty': 'عام',
      'rating': 4.8,
      'image': ImageService.hospital1,
      'phone': '01-234567',
    },
    {
      'name': 'المستشفى الجمهوري',
      'location': 'صنعاء',
      'specialty': 'عام',
      'rating': 4.7,
      'image': ImageService.hospital2,
      'phone': '01-234568',
    },
    {
      'name': 'مستشفى الكويت الجامعي',
      'location': 'صنعاء',
      'specialty': 'تعليمي',
      'rating': 4.9,
      'image': ImageService.hospital3,
      'phone': '01-234569',
    },
    {
      'name': 'مستشفى السبعين للأمومة والطفولة',
      'location': 'صنعاء',
      'specialty': 'أطفال وولادة',
      'rating': 4.6,
      'image': ImageService.hospital4,
      'phone': '01-234570',
    },
    {
      'name': 'المستشفى العسكري',
      'location': 'صنعاء',
      'specialty': 'عام',
      'rating': 4.5,
      'image': ImageService.hospital5,
      'phone': '01-234571',
    },
    {
      'name': 'مستشفى آزال',
      'location': 'صنعاء',
      'specialty': 'عام',
      'rating': 4.4,
      'image': ImageService.hospital6,
      'phone': '01-234572',
    },
    {
      'name': 'مستشفى اليمن الألماني',
      'location': 'صنعاء',
      'specialty': 'متخصص',
      'rating': 4.8,
      'image': ImageService.hospital7,
      'phone': '01-234573',
    },
    {
      'name': 'مستشفى النقيب',
      'location': 'صنعاء',
      'specialty': 'عام',
      'rating': 4.3,
      'image': ImageService.hospital8,
      'phone': '01-234574',
    },
    {
      'name': 'مستشفى العلوم والتكنولوجيا',
      'location': 'صنعاء',
      'specialty': 'تعليمي',
      'rating': 4.6,
      'image': ImageService.hospital9,
      'phone': '01-234575',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المستشفيات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              // TODO: فتح شاشة البحث
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hospitals.length,
        itemBuilder: (context, index) {
          final hospital = hospitals[index];
          return _buildHospitalCard(hospital, isDark);
        },
      ),
    );
  }

  Widget _buildHospitalCard(Map<String, dynamic> hospital, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ✅ صورة المستشفى
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: Image.asset(
              hospital['image'] as String,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.local_hospital,
                    color: Colors.grey,
                    size: 40,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // ✅ معلومات المستشفى
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital['name'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hospital['location'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          hospital['specialty'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${hospital['rating']}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hospital['phone'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'جاري حجز موعد في ${hospital['name']}',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'حجز',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
