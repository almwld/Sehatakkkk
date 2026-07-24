import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/booking_model.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/presentation/screens/shared/my_bookings_screen.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOpen = true;
  Map<String, dynamic>? _hospitalData;
  List<BookingModel> _bookings = [];
  int _totalPatients = 0;
  int _totalRevenue = 0;
  int _monthlyRevenue = 0;

  final List<String> _tabs = ['الرئيسية', 'الحجوزات', 'الأقسام', 'الإحصائيات'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // جلب بيانات المستشفى
      final doc = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          _hospitalData = doc.data();
          _isOpen = _hospitalData?['isOpen'] ?? true;
        });
      }

      // جلب الحجوزات
      final bookingsSnap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'hospital')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _bookings = bookingsSnap.docs.map((doc) {
          return BookingModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();
        _totalPatients = _bookings.length;
        _totalRevenue = _bookings.fold(0, (sum, b) => sum + (b.amount.toInt()));
      });
    } catch (e) {
      print('Error loading hospital data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_hospitalData?['name'] ?? 'لوحة تحكم المستشفى'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ حالة المستشفى
          Row(
            children: [
              const Text('مفتوح', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Switch(
                value: _isOpen,
                onChanged: (value) async {
                  setState(() => _isOpen = value);
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('hospitals')
                        .doc(user.uid)
                        .update({'isOpen': value});
                  }
                },
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
              ),
            ],
          ),
          // ✅ زر الإعلانات
          IconButton(
            icon: const Icon(Icons.advertising),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdManagementScreen(
                  providerId: user?.uid,
                  providerName: _hospitalData?['name'],
                  providerType: AdType.hospital,
                ),
              ),
            ),
          ),
          // ✅ زر الحجوزات
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyBookingsScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ بطاقة الإحصائيات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                _buildStatCard('المرضى', '$_totalPatients', Icons.people, Colors.blue),
                _buildStatCard('الحجوزات', '${_bookings.length}', Icons.event, Colors.amber),
                _buildStatCard('الإيرادات', '$_totalRevenue ريال', Icons.attach_money, Colors.green),
                _buildStatCard('الشهر', '$_monthlyRevenue ريال', Icons.calendar_month, Colors.purple),
              ],
            ),
          ),
          // ✅ تبويبات
          Container(
            color: isDark ? const Color(0xFF0B1121) : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              tabs: const [
                Tab(text: 'الرئيسية'),
                Tab(text: 'الحجوزات'),
                Tab(text: 'الأقسام'),
                Tab(text: 'الإحصائيات'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHomeTab(),
                _buildBookingsTab(),
                _buildDepartmentsTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مرحباً بك في لوحة تحكم المستشفى', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('إدارة المرضى والحجوزات والأقسام', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          // ✅ إحصائيات سريعة
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _buildQuickCard('مرضى اليوم', '5', Icons.person_add, Colors.blue),
              _buildQuickCard('حجوزات اليوم', '3', Icons.event, Colors.orange),
              _buildQuickCard('مرضى هذا الأسبوع', '25', Icons.people, Colors.green),
              _buildQuickCard('تقييم', '4.7 ★', Icons.star, Colors.amber),
            ],
          ),
          const SizedBox(height: 24),
          const Text('أحدث الحجوزات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._bookings.take(3).map((booking) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${booking.date.day}/${booking.date.month}/${booking.date.year}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.statusText,
                    style: TextStyle(fontSize: 10, color: booking.statusColor),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildQuickCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildBookingsTab() {
    if (_bookings.isEmpty) {
      return const Center(child: Text('لا توجد حجوزات'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (context, index) {
        final booking = _bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${booking.date.day}/${booking.date.month}/${booking.date.year} - ${booking.time ?? ''}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (booking.notes != null)
                      Text(
                        booking.notes!,
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: booking.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.statusText,
                      style: TextStyle(fontSize: 10, color: booking.statusColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.amount.toInt()} ريال',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDepartmentsTab() {
    final departments = [
      {'name': 'الطوارئ', 'patients': 12, 'doctors': 5, 'active': true},
      {'name': 'الباطنية', 'patients': 8, 'doctors': 4, 'active': true},
      {'name': 'الجراحة', 'patients': 6, 'doctors': 3, 'active': true},
      {'name': 'الأطفال', 'patients': 4, 'doctors': 2, 'active': true},
      {'name': 'النساء والولادة', 'patients': 5, 'doctors': 2, 'active': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final dept = departments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
            border: Border.all(
              color: dept['active'] ? AppColors.primary : Colors.grey,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.medical_services, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dept['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${dept['patients']} مرضى - ${dept['doctors']} أطباء',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Switch(
                value: dept['active'],
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('الإحصائيات قيد التطوير'),
          SizedBox(height: 8),
          Text('سيتم عرض الرسوم البيانية قريباً', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
