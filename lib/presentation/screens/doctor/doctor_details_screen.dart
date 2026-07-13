import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/utils/icon_helper.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_booking_screen.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String? doctorId;
  const DoctorDetailsScreen({super.key, this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> with SingleTickerProviderStateMixin {
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
          'about': 'استشاري باطنية وأطفال مع خبرة واسعة في تشخيص وعلاج الأمراض الباطنية وأطفال. حاصل على شهادة البورد العربي في الباطنية والأطفال.',
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
          'about': 'أخصائي أمراض القلب والقسطرة. خبرة واسعة في علاج حالات القلب المعقدة والقسطرة التداخلية.',
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
          'about': 'أخصائية أطفال وحديثي الولادة. خبرة في رعاية الأطفال المبتسرين وحديثي الولادة.',
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
          'about': 'أخصائي أنف وأذن وحنجرة. خبرة في جراحات الأنف والأذن والحنجرة لدى الأطفال والبالغين.',
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
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
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
                  child: CachedNetworkImage(
                    imageUrl: doc['image'],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.white24,
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.white24,
                      child: const Icon(Icons.person, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['name'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(doc['specialty'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(' ${doc['rating']} (${doc['reviews']} تقييم)', style: const TextStyle(color: Colors.white70)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: doc['available'] ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(doc['available'] ? 'متاح' : 'غير متاح', style: const TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ✅ أزرار الإجراءات - باستخدام IconHelper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _actionBtn('assets/icons/core/text_chat.svg', 'محادثة', AppColors.info, () => ChatNavigation.openChat(context, doctorName: doc['name'], doctorId: widget.doctorId ?? '1')),
                _actionBtn('assets/icons/core/video_call.svg', 'اتصال', AppColors.success, () => ChatNavigation.openCall(
                  context,
                  chatId: 'call_${widget.doctorId ?? "1"}_${DateTime.now().millisecondsSinceEpoch}',
                  doctorName: doc['name'],
                  doctorId: widget.doctorId ?? '1',
                  isVideo: false,
                )),
                _actionBtn('assets/icons/core/video_call.svg', 'فيديو', AppColors.primary, () => ChatNavigation.openCall(
                  context,
                  chatId: 'call_${widget.doctorId ?? "1"}_${DateTime.now().millisecondsSinceEpoch}',
                  doctorName: doc['name'],
                  doctorId: widget.doctorId ?? '1',
                  isVideo: true,
                )),
                _actionBtn('assets/icons/core/appointments.svg', 'حجز', AppColors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorBookingScreen(doctorId: widget.doctorId ?? '1')))),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tab,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey,
                  tabs: const [
                    Tab(text: 'نبذة'),
                    Tab(text: 'مواعيد'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tab,
                    children: [
                      _aboutTab(doc),
                      _appointmentsTab(doc),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String iconPath, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.chat, size: 22, color: Colors.white), size: 22, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _aboutTab(Map<String, dynamic> doc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نبذة عن الطبيب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(doc['about'], style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 16),
          _infoRow('المستشفى', doc['hospital'], isDark),
          _infoRow('الخبرة', doc['experience'], isDark),
          _infoRow('رسوم الكشف', '${doc['fee']} ريال', isDark),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يمكنك التواصل مع الطبيب عبر المحادثة أو المكالمة',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13, color: isDark ? Colors.white : Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _appointmentsTab(Map<String, dynamic> doc) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الأوقات المتاحة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...(doc['availability'] as List).map((a) => Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.grey[800]! : AppColors.primary.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.primary, size: 18),
                const SizedBox(width: 10),
                Text(a, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorBookingScreen(doctorId: widget.doctorId ?? '1'))),
              icon: const Icon(Icons.calendar_month),
              label: const Text('حجز موعد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
