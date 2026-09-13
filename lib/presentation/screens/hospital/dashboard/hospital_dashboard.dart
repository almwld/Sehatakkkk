import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/ad_model.dart';
import 'package:sehatak/core/models/booking_model.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/presentation/screens/shared/my_bookings_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});
  @override State<HospitalDashboard> createState() => _HospitalDashboardState();
}

class _HospitalDashboardState extends State<HospitalDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOpen = true;
  Map<String, dynamic>? _hospitalData;
  List<BookingModel> _bookings = [];
  double _totalRevenue = 0;
  double _monthlyRevenue = 0;

  @override
  void initState() { super.initState(); _tabController = TabController(length: 4, vsync: this); _loadData(); }

  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final hospitalDoc = await firestore.collection('hospitals').doc(user.uid).get();
      final bookingSnap = await firestore.collection('bookings').where('providerId', isEqualTo: user.uid).where('type', isEqualTo: 'hospital').orderBy('createdAt', descending: true).get();
      final bookings = bookingSnap.docs.map((doc) => BookingModel.fromFirestore(doc.data(), doc.id)).toList();
      if (!mounted) return;
      setState(() { _hospitalData = hospitalDoc.data(); _isOpen = _hospitalData?['isOpen'] as bool? ?? true; _bookings = bookings; });
      await _loadRevenue(user.uid);
    } catch (e) { debugPrint('Error loading hospital dashboard: $e'); }
  }

  Future<void> _loadRevenue(String providerId) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('payments').where('providerId', isEqualTo: providerId).get();
      final now = DateTime.now();
      double total = 0;
      double month = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        total += amount;
        final rawDate = data['createdAt'];
        DateTime? createdAt;
        if (rawDate is Timestamp) createdAt = rawDate.toDate();
        if (rawDate is DateTime) createdAt = rawDate;
        if (createdAt != null && createdAt.year == now.year && createdAt.month == now.month) month += amount;
      }
      if (mounted) setState(() { _totalRevenue = total; _monthlyRevenue = month; });
    } catch (e) { debugPrint('Error loading hospital revenue: $e'); }
  }

  String _statusText(String status) { switch (status) { case 'confirmed': return 'مؤكد'; case 'completed': return 'مكتمل'; case 'cancelled': return 'ملغي'; case 'pending': return 'قيد الانتظار'; default: return status; } }
  Color _statusColor(String status) { switch (status) { case 'confirmed': return Colors.green; case 'completed': return Colors.teal; case 'cancelled': return Colors.red; case 'pending': return Colors.orange; default: return Colors.grey; } }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: Text(_hospitalData?['name'] ?? 'لوحة تحكم المستشفى'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [
        Row(children: [const Text('مفتوح', style: TextStyle(color: Colors.white70, fontSize: 12)), Switch(value: _isOpen, onChanged: (value) async { setState(() => _isOpen = value); if (user != null) await FirebaseFirestore.instance.collection('hospitals').doc(user.uid).update({'isOpen': value}); }, activeColor: Colors.green, inactiveThumbColor: Colors.red)]),
        IconButton(icon: const Icon(Icons.campaign), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdManagementScreen(providerId: user?.uid, providerName: _hospitalData?['name'], providerType: AdType.hospital)))),
        IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()))),
      ]),
      body: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))), child: Row(children: [_buildStatCard('المرضى', '${_uniquePatientCount()}', Icons.people, Colors.blue), _buildStatCard('الحجوزات', '${_bookings.length}', Icons.event, Colors.amber), _buildStatCard('الإيرادات', '${_totalRevenue.toStringAsFixed(0)} ريال', Icons.attach_money, Colors.green), _buildStatCard('هذا الشهر', '${_monthlyRevenue.toStringAsFixed(0)} ريال', Icons.calendar_month, Colors.purple)])),
        Container(color: isDark ? const Color(0xFF0B1121) : Colors.white, child: TabBar(controller: _tabController, indicatorColor: AppColors.primary, labelColor: AppColors.primary, unselectedLabelColor: AppColors.grey, tabs: const [Tab(text: 'الرئيسية'), Tab(text: 'الحجوزات'), Tab(text: 'الأقسام'), Tab(text: 'الإحصائيات')])),
        Expanded(child: TabBarView(controller: _tabController, children: [_buildHomeTab(), _buildBookingsTab(), _buildDepartmentsTab(), _buildStatisticsTab()])),
      ]),
    );
  }

  int _uniquePatientCount() => _bookings.map((b) => b.userId).where((id) => id.isNotEmpty).toSet().length;

  Widget _buildStatCard(String label, String value, IconData icon, Color color) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9))])));

  Widget _buildHomeTab() => ListView(padding: const EdgeInsets.all(16), children: [const Text('مرحباً بك في لوحة تحكم المستشفى', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('إدارة المرضى والحجوزات والأقسام', style: TextStyle(color: Colors.grey)), const SizedBox(height: 24), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [_buildQuickCard('مرضى اليوم', '${_uniquePatientsToday()}', Icons.person_add, Colors.blue), _buildQuickCard('حجوزات اليوم', '${_bookings.where((b) => _sameDay(b.bookingDate, DateTime.now())).length}', Icons.event, Colors.orange), _buildQuickCard('إجمالي المرضى', '${_uniquePatientCount()}', Icons.people, Colors.green), _buildQuickCard('الحالة', _isOpen ? 'مفتوح' : 'مغلق', Icons.star, _isOpen ? Colors.green : Colors.red)]), const SizedBox(height: 24), const Text('أحدث الحجوزات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ..._bookings.take(5).map(_buildBookingPreview)]);

  int _uniquePatientsToday() => _bookings.where((b) => _sameDay(b.bookingDate, DateTime.now())).map((b) => b.userId).where((id) => id.isNotEmpty).toSet().length;
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildBookingPreview(BookingModel booking) { final color = _statusColor(booking.status); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.userId.isEmpty ? 'مريض' : booking.userId, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(_statusText(booking.status), style: TextStyle(fontSize: 10, color: color)))])); }
  Widget _buildQuickCard(String title, String value, IconData icon, Color color) { final isDark = Theme.of(context).brightness == Brightness.dark; return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 24), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))])); }

  Widget _buildBookingsTab() { if (_bookings.isEmpty) return const Center(child: Text('لا توجد حجوزات')); return ListView.builder(padding: const EdgeInsets.all(16), itemCount: _bookings.length, itemBuilder: (_, index) { final booking = _bookings[index]; final color = _statusColor(booking.status); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.userId.isEmpty ? 'مريض' : booking.userId, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} - ${_formatTime(booking.bookingDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)), if (booking.notes?.isNotEmpty == true) Text(booking.notes!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(_statusText(booking.status), style: TextStyle(fontSize: 10, color: color)))]) ])); }); }
  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

  Map<String, bool> _departments() {
    const defaults = ['الطوارئ', 'الباطنية', 'الجراحة', 'الأطفال', 'النساء والولادة'];
    final raw = _hospitalData?['departments'];
    if (raw is Map) {
      return {for (final entry in raw.entries) entry.key.toString(): entry.value == true};
    }
    if (raw is List) return {for (final item in raw) item.toString(): true};
    return {for (final name in defaults) name: true};
  }

  Future<void> _setDepartment(String name, bool enabled) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final updated = _departments()..[name] = enabled;
    await FirebaseFirestore.instance.collection('hospitals').doc(user.uid).set({'departments': updated}, SetOptions(merge: true));
    if (mounted) setState(() => _hospitalData = {...?_hospitalData, 'departments': updated});
  }

  Widget _buildDepartmentsTab() {
    final departments = _departments();
    return ListView(padding: const EdgeInsets.all(16), children: departments.entries.map((entry) => SwitchListTile(
      secondary: const Icon(Icons.medical_services, color: AppColors.primary),
      title: Text(entry.key),
      subtitle: Text(entry.value ? 'القسم متاح' : 'القسم غير متاح'),
      value: entry.value,
      onChanged: (value) => _setDepartment(entry.key, value),
    )).toList());
  }

  Widget _buildStatisticsTab() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.bar_chart, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('إجمالي الحجوزات: ${_bookings.length}'), const SizedBox(height: 8), Text('المرضى الفريدون: ${_uniquePatientCount()}'), const SizedBox(height: 8), Text('إجمالي الإيرادات: ${_totalRevenue.toStringAsFixed(0)} ريال'), const SizedBox(height: 8), Text('إيرادات هذا الشهر: ${_monthlyRevenue.toStringAsFixed(0)} ريال')]));

  @override void dispose() { _tabController.dispose(); super.dispose(); }
}
