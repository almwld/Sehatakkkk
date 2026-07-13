import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/utils/icon_helper.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_booking_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String? doctorId;
  const DoctorDetailsScreen({super.key, this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _isFavorite = false;

  Map<String, dynamic> get _doctor {
    switch (widget.doctorId) {
      case '1':
        return {
          'name': 'د. أحمد المولد',
          'specialty': 'استشاري باطنية وأطفال',
          'experience': '20+ سنة',
          'rating': 4.9,
          'reviews': 328,
          'fee': '500',
          'available': true,
          'about':
              'استشاري باطنية وأطفال مع خبرة واسعة في تشخيص وعلاج الأمراض الباطنية وأطفال. حاصل على شهادة البورد العربي في الباطنية والأطفال.',
          'hospital': 'مستشفى الثورة العام',
          'availability': ['السبت - الأربعاء: 9 ص - 5 م', 'الخميس: 9 ص - 2 م'],
          'image': "assets/images/doctors/doctor_1.png",
        };
      case '2':
        return {
          'name': 'د. خالد النخلاني',
          'specialty': 'أمراض قلبية',
          'experience': '15 سنة',
          'rating': 4.8,
          'reviews': 256,
          'fee': '600',
          'available': true,
          'about':
              'أخصائي أمراض القلب والقسطرة. خبرة واسعة في علاج حالات القلب المعقدة والقسطرة التداخلية.',
          'hospital': 'مركز قلب العاصمة',
          'availability': ['الأحد - الخميس: 10 ص - 6 م', 'السبت: 10 ص - 2 م'],
          'image': "assets/images/doctors/doctor_2.png",
        };
      case '3':
        return {
          'name': 'د. أسماء الهندي',
          'specialty': 'أطفال وحديثي الولادة',
          'experience': '12 سنة',
          'rating': 4.9,
          'reviews': 189,
          'fee': '450',
          'available': true,
          'about':
              'أخصائية أطفال وحديثي الولادة. خبرة في رعاية الأطفال المبتسرين وحديثي الولادة.',
          'hospital': 'مستشفى السبعين',
          'availability': ['السبت - الخميس: 8 ص - 2 م'],
          'image': "assets/images/doctors/doctor_3.png",
        };
      default:
        return {
          'name': 'د. محمد العلاي',
          'specialty': 'أنف وأذن وحنجرة',
          'experience': '8 سنوات',
          'rating': 4.7,
          'reviews': 89,
          'fee': '400',
          'available': true,
          'about':
              'أخصائي أنف وأذن وحنجرة. خبرة في جراحات الأنف والأذن والحنجرة لدى الأطفال والبالغين.',
          'hospital': 'مستشفى الأنف والأذن',
          'availability': ['الأحد - الخميس: 9 ص - 3 م'],
          'image': "assets/images/doctors/doctor_4.png",
        };
    }
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doctor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(doc['name']),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Header
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    doc['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: Colors.white24,
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 40),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        doc['specialty'],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${doc['rating']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${doc['reviews']} تقييم)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ✅ أزرار الإجراءات - محادثة / اتصال / فيديو
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'محادثة',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatNavigationScreen(
                          receiverId: widget.doctorId ?? '1',
                          receiverName: doc['name'],
                          receiverImage: doc['image'],
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.phone_outlined,
                  label: 'اتصال',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          receiverName: doc['name'],
                          receiverImage: doc['image'],
                          isVideo: false,
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.videocam_outlined,
                  label: 'فيديو',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          receiverName: doc['name'],
                          receiverImage: doc['image'],
                          isVideo: true,
                        ),
                      ),
                    );
                  },
                ),
                _buildActionButton(
                  icon: Icons.calendar_month_outlined,
                  label: 'حجز',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorBookingScreen(
                          doctorName: doc['name'],
                          doctorSpecialty: doc['specialty'],
                          doctorImage: doc['image'],
                          fee: doc['fee'],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // ✅ Tabs
          Container(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            child: TabBar(
              controller: _tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'نبذة'),
                Tab(text: 'المواعيد'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _buildAboutTab(doc, isDark),
                _buildScheduleTab(doc, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(Map<String, dynamic> doc, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard('نبذة', doc['about'], isDark),
          const SizedBox(height: 16),
          _buildInfoCard('المستشفى', doc['hospital'], isDark),
          const SizedBox(height: 16),
          _buildInfoCard('الخبرة', '${doc['experience']} من الخبرة', isDark),
          const SizedBox(height: 16),
          _buildInfoCard('رسوم الكشف', '${doc['fee']} ر.ي', isDark),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(Map<String, dynamic> doc, bool isDark) {
    final availability = doc['availability'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availability.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
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
              const Icon(Icons.access_time, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  availability[index],
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String content, bool isDark) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
