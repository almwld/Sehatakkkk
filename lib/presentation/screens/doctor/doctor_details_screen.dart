import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_booking_screen.dart';

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
          'about': 'استشاري باطنية وأطفال مع خبرة واسعة',
          'hospital': 'مستشفى الثورة العام',
          'availability': ['السبت - الأربعاء: 9 ص - 5 م'],
          'image': "assets/images/doctors/doctor_1.png",
          'doctorId': 'doc_1',
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
          'about': 'أخصائي أنف وأذن وحنجرة',
          'hospital': 'مستشفى الأنف والأذن',
          'availability': ['الأحد - الخميس: 9 ص - 3 م'],
          'image': "assets/images/doctors/doctor_4.png",
          'doctorId': 'doc_4',
        };
    }
  }

  // ✅ أيقونات التواصل مع الطبيب
  final List<Map<String, dynamic>> _contactIcons = [
    {'icon': 'assets/images/chat/phone_call.png', 'label': 'اتصال', 'color': Colors.green},
    {'icon': 'assets/images/chat/video_call.png', 'label': 'مكالمة فيديو', 'color': Colors.blue},
    {'icon': 'assets/images/chat/chat_bubble.png', 'label': 'رسالة', 'color': AppColors.primary},
    {'icon': 'assets/images/chat/calendar_booking.png', 'label': 'حجز موعد', 'color': Colors.orange},
  ];

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

  void _openChat() {
    final doc = _doctor;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً'), backgroundColor: Colors.orange),
      );
      return;
    }
    final chatId = 'chat_${user.uid}_${doc['doctorId']}_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          chatId: chatId,
          userName: doc['name'],
          userId: doc['doctorId'],
          isDoctor: true,
        ),
      ),
    );
  }

  void _callDoctor() {
    final doc = _doctor;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً'), backgroundColor: Colors.orange),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: 'call_${user.uid}_${doc['doctorId']}_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: doc['name'],
          doctorId: doc['doctorId'],
          isVideo: false,
        ),
      ),
    );
  }

  void _videoCallDoctor() {
    final doc = _doctor;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً'), backgroundColor: Colors.orange),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: 'video_${user.uid}_${doc['doctorId']}_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: doc['name'],
          doctorId: doc['doctorId'],
          isVideo: true,
        ),
      ),
    );
  }

  void _bookAppointment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DoctorBookingScreen(doctorId: widget.doctorId ?? '1'),
      ),
    );
  }

  // ✅ دالة عرض عنصر تواصل فردي
  Widget _buildContactActionItem(Map<String, dynamic> item, bool isDark) {
    return GestureDetector(
      onTap: () {
        final label = item['label'] as String;
        if (label == 'اتصال') _callDoctor();
        else if (label == 'مكالمة فيديو') _videoCallDoctor();
        else if (label == 'رسالة') _openChat();
        else if (label == 'حجز موعد') _bookAppointment();
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Image.asset(
                  item['icon'] as String,
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.circle, color: item['color'] as Color, size: 28);
                  },
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
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
          // ✅ أيقونات التواصل - استخدام الأيقونات الجديدة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primary,
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _contactIcons.length,
                itemBuilder: (context, index) {
                  final item = _contactIcons[index];
                  return _buildContactActionItem(item, isDark);
                },
              ),
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
          const Text('المستشفى', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(doc['hospital'], style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700])),
          const SizedBox(height: 16),
          const Text('الخبرة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(doc['experience'], style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[300] : Colors.grey[700])),
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
              onPressed: _bookAppointment,
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
