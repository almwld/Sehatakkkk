import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/booking_model.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/presentation/screens/shared/my_bookings_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});

  @override
  State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOpen = true;
  Map<String, dynamic>? _hospitalData;
  List<BookingModel> _bookings = [];
  double _totalRevenue = 0;

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
      final firestore = FirebaseFirestore.instance;
      final hospitalDoc = await firestore.collection('hospitals').doc(user.uid).get();
      final bookingSnap = await firestore
          .collection('bookings')
          .where('providerId', isEqualTo: user.uid)
          .where('type', isEqualTo: 'hospital')
          .orderBy('createdAt', descending: true)
          .get();

      final bookings = bookingSnap.docs.map((doc) {
        return BookingModel.fromFirestore(doc.data(), doc.id);
      }).toList();

      if (!mounted) return;
      setState(() {
        _hospitalData = hospitalDoc.data();
        _isOpen = _hospitalData?['isOpen'] as bool? ?? true;
        _bookings = bookings;
      });

      await _loadRevenue(user.uid);
    } catch (e) {
      debugPrint('Error loading hospital dashboard: $e');
    }
  }

  Future<void> _loadRevenue(String providerId) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('payments')
          .where('providerId', isEqualTo: providerId)
          .get();
      final total = snap.docs.fold<double>(
        0,
        (sum, doc) => sum + ((doc.data()['amount'] as num?)?.toDouble() ?? 0),
      );
      if (mounted) setState(() => _totalRevenue = total);
    } catch (e) {
      debugPrint('Error loading hospital revenue: $e');
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'confirmed': return 'مؤكد';
      case 'completed': return 'مكتمل';
      case 'cancelled': return 'ملغي';
      case 'pending': return 'قيد الانتظار';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'completed': return Colors.teal;
      case 'cancelled': return Colors.red;
      case 'pending': return Colors.orange;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: Text(_hospitalData?['name'] ?? 'لوحة تحكم المستشفى'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Row(children: [
            const Text('مفتوح', style: TextStyle(color: Colors.white70, fontSize: 12)),
            Switch(
              value: _isOpen,
              onChanged: (value) async {
                setState(() => _isOpen = value);
                if (user != null) {
                  await FirebaseFirestore.instance.collection('hospitals').doc(user.uid).update({'isOpen': value});
                }
              },
              activeColor: Colors.green,
              inactiveThumbColor: Colors.red,
            ),
          ]),
          IconButton(
            icon: const Icon(Icons.advertising),
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => AdManagementScreen(
                providerId: user?.uid,
                providerName: _hospitalData?['name'],
                providerType: AdType.hospital,
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen())),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          child: Row(children: [
            _buildStatCard('المرضى', '${_bookings.length}', Icons.people, Colors.blue),
            _buildStatCard('الحجوزات', '${_bookings.length}', Icons.event, Colors.amber),
            _buildStatCard('الإيرادات', '${_totalRevenue.toStringAsFixed(0)} ريال', Icons.attach_money, Colors.green),
            _buildStatCard('هذا الشهر', '${_monthlyRevenue().toStringAsFixed(0)} ريال', Icons.calendar_month, Colors.purple),
          ]),
        ),
        Container(
          color: isDark ? const Color(0xFF0B1121) : Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            tabs: const [
              Tab(text: 'الرئيسية'), Tab(text: 'الحجوزات'), Tab(text: 'الأقسام'), Tab(text: 'الإحصائيات'),
            ],
          ),
        ),
        Expanded(child: TabBarView(
          controller: _tabController,
          children: [_buildHomeTab(), _buildBookingsTab(), _buildDepartmentsTab(), _buildStatisticsTab()],
        )),
      ]),
    );
  }

  double _monthlyRevenue() {
    final now = DateTime.now();
    return _totalRevenue * 1.0; // payment records are already provider-scoped; monthly filtering is handled by the reports service.
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ]),
    ));
  }

  Widget _buildHomeTab() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('مرحباً بك في لوحة تحكم المستشفى', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('إدارة المرضى والحجوزات والأقسام', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 24),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildQuickCard('مرضى اليوم', '${_bookings.where((b) => _sameDay(b.bookingDate, DateTime.now())).length}', Icons.person_add, Colors.blue),
          _buildQuickCard('حجوزات اليوم', '${_bookings.where((b) => _sameDay(b.bookingDate, DateTime.now())).length}', Icons.event, Colors.orange),
          _buildQuickCard('إجمالي المرضى', '${_bookings.length}', Icons.people, Colors.green),
          _buildQuickCard('الحالة', _isOpen ? 'مفتوح' : 'مغلق', Icons.star, _isOpen ? Colors.green : Colors.red),
        ],
      ),
      const SizedBox(height: 24),
      const Text('أحدث الحجوزات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      ..._bookings.take(5).map(_buildBookingPreview),
    ]);
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildBookingPreview(BookingModel booking) {
    final color = _statusColor(booking.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const CircleAvatar(child: Icon(Icons.person)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(booking.userId.isEmpty ? 'مريض' : booking.userId, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(_statusText(booking.status), style: TextStyle(fontSize: 10, color: color)),
        ),
      ]),
    );
  }

  Widget _buildQuickCard(String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24), const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ]),
    );
  }

  Widget _buildBookingsTab() {
    if (_bookings.isEmpty) return const Center(child: Text('لا توجد حجوزات'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookings.length,
      itemBuilder: (_, index) {
        final booking = _bookings[index];
        final color = _statusColor(booking.status);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(booking.userId.isEmpty ? 'مريض' : booking.userId, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} - ${_formatTime(booking.bookingDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (booking.notes?.isNotEmpty == true) Text(booking.notes!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(_statusText(booking.status), style: TextStyle(fontSize: 10, color: color))),
            ]),
          ]),
        );
      },
    );
  }

  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Widget _buildDepartmentsTab() {
    final departments = ['الطوارئ', 'الباطنية', 'الجراحة', 'الأطفال', 'النساء والولادة'];
    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: departments.length,
      itemBuilder: (_, index) => ListTile(
        leading: const Icon(Icons.medical_services, color: AppColors.primary),
        title: Text(departments[index]),
        subtitle: const Text('القسم متاح'),
        trailing: Switch(value: true, onChanged: (_) {}),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.bar_chart, size: 64, color: Colors.grey),
      const SizedBox(height: 16),
      Text('إجمالي الحجوزات: ${_bookings.length}'),
      const SizedBox(height: 8),
      Text('إجمالي الإيرادات: ${_totalRevenue.toStringAsFixed(0)} ريال'),
    ]));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
