import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
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
          'name': 'د. علي المولد',
          'specialty': 'استشاري باطنية وأطفال',
          'experience': '20+ سنة',
          'rating': 4.9,
          'reviews': 328,
          'fee': '500',
          'available': true,
          'about': 'استشاري باطنية وأطفال مع خبرة واسعة',
          'hospital': 'مستشفى الثورة العام',
          'availability': ['السبت - الأربعاء: 9 ص - 5 م']
        };
      default:
        return {
          'name': 'د. أحمد محمد',
          'specialty': 'طبيب عام',
          'experience': '5+ سنة',
          'rating': 4.5,
          'reviews': 89,
          'fee': '200',
          'available': true,
          'about': 'طبيب عام مهتم بصحة المجتمع',
          'hospital': 'مستشفى عام',
          'availability': ['الأحد - الخميس: 8 ص - 2 م']
        };
    }
  }

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doctor;

    return Scaffold(
      appBar: AppBar(
        title: Text(doc['name']),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.primary,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white24,
                  child: Text(
                    doc['name'][0],
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(doc['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(doc['specialty'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(' ${doc['rating']} (${doc['reviews']} تقييم)', style: const TextStyle(color: Colors.white70)),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: doc['available'] ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(doc['available'] ? 'متاح' : 'غير متاح', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _actionBtn(Icons.chat, 'محادثة', AppColors.info, () => ChatNavigation.openChat(context, doctorName: doc['name'], doctorId: widget.doctorId ?? '1')),
                    _actionBtn(Icons.call, 'اتصال', AppColors.success, () => ChatNavigation.openChat(context, doctorName: doc['name'], doctorId: widget.doctorId ?? '1')),
                    _actionBtn(Icons.calendar_today, 'حجز', AppColors.teal, () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorBookingScreen(doctorId: widget.doctorId ?? '1')))),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
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
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, VoidCallback onTap) {
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
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _aboutTab(Map<String, dynamic> doc) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('نبذة عن الطبيب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(doc['about'], style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text('المستشفى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(doc['hospital'], style: const TextStyle(fontSize: 14, color: AppColors.grey)),
          const SizedBox(height: 16),
          const Text('الخبرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(doc['experience'], style: const TextStyle(fontSize: 14, color: AppColors.grey)),
        ],
      ),
    );
  }

  Widget _appointmentsTab(Map<String, dynamic> doc) {
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
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(a, style: const TextStyle(fontSize: 14)),
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

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }
}
