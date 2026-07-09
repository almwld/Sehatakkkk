import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class DoctorsListScreen extends StatelessWidget {
  const DoctorsListScreen({super.key});

  final List<Map<String, dynamic>> _doctors = const [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'experience': '20+ سنة', 'rating': 4.9, 'reviews': 328, 'price': 500, 'available': true, 'image': ImageService.doctor1, 'hospital': 'مستشفى الثورة العام', 'online': true},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'experience': '15 سنة', 'rating': 4.8, 'reviews': 256, 'price': 600, 'available': true, 'image': ImageService.doctor2, 'hospital': 'مركز قلب العاصمة', 'online': false},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'experience': '12 سنة', 'rating': 4.9, 'reviews': 189, 'price': 450, 'available': true, 'image': ImageService.doctor3, 'hospital': 'مستشفى السبعين', 'online': true},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'experience': '8 سنوات', 'rating': 4.7, 'reviews': 89, 'price': 400, 'available': false, 'image': ImageService.doctor4, 'hospital': 'مستشفى الأنف والأذن', 'online': false},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'experience': '18 سنة', 'rating': 4.8, 'reviews': 210, 'price': 550, 'available': true, 'image': ImageService.doctor5, 'hospital': 'مستشفى الولادة', 'online': true},
    {'id': '6', 'name': 'د. عمر الجابري', 'specialty': 'عظام', 'experience': '10 سنوات', 'rating': 4.6, 'reviews': 145, 'price': 520, 'available': true, 'image': ImageService.doctor6, 'hospital': 'مركز العظام', 'online': false},
    {'id': '7', 'name': 'د. ليلى الكبسي', 'specialty': 'جلدية', 'experience': '14 سنة', 'rating': 4.7, 'reviews': 178, 'price': 480, 'available': true, 'image': ImageService.doctor7, 'hospital': 'مركز الجلدية', 'online': true},
    {'id': '8', 'name': 'د. ناصر الحمزي', 'specialty': 'عيون', 'experience': '22 سنة', 'rating': 4.9, 'reviews': 312, 'price': 580, 'available': true, 'image': ImageService.doctor8, 'hospital': 'مركز العيون', 'online': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأطباء'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _doctors.length,
        itemBuilder: (context, index) {
          final doctor = _doctors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: ImageService.imageWithShimmer(
                doctor['image'],
                width: 50,
                height: 50,
                borderRadius: 12,
              ),
              title: Text(doctor['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['specialty']),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${doctor['rating']} (${doctor['reviews']})'),
                    ],
                  ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${doctor['price']} ر.ي',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: doctor['available'] ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doctor['available'] ? 'متاح' : 'غير متاح',
                      style: TextStyle(
                        color: doctor['available'] ? AppColors.success : AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailsScreen(doctorId: doctor['id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
