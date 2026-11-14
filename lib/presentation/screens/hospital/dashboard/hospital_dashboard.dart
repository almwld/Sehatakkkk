import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/ad_model.dart';
import 'package:sehatak/core/models/booking_model.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/presentation/screens/shared/my_bookings_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_staff_affiliations_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class HospitalDashboard extends StatefulWidget {
  const HospitalDashboard({super.key});
  @override State<HospitalDashboard> createState() => _HospitalDashboardState();
}
class _HospitalDashboardState extends State<HospitalDashboard> with SingleTickerProviderStateMixin {
  String _t(String value) => AppStrings.of(context).translate(value);

  late TabController _tabController;
  bool _isOpen = true;
  Map<String, dynamic>? _hospitalData;
  List<BookingModel> _bookings = [];
  double _totalRevenue = 0;
  double _monthlyRevenue = 0;
  @override void initState() { super.initState(); _tabController = TabController(length: 4, vsync: this); _loadData(); }
  Future<void> _loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final hospitalDoc = await firestore.collection('hospitals').doc(user.uid).get();
      final bookingSnap = await firestore.collection('bookings').where('providerId', isEqualTo: user.uid).where('type', isEqualTo: 'hospital').orderBy('createdAt', descending: true).get();
      final bookings = bookingSnap.docs.map((doc) { final data = Map<String, dynamic>.from(doc.data()); for (final key in ['bookingDate', 'createdAt', 'updatedAt']) { final value = data[key]; if (value is Timestamp) data[key] = value.toDate().toIso8601String(); else if (value is DateTime) data[key] = value.toIso8601String(); } return BookingModel.fromFirestore(data, doc.id); }).toList();
      if (!mounted) return;
      setState(() { _hospitalData = hospitalDoc.data(); _isOpen = _hospitalData?['isOpen'] as bool? ?? true; _bookings = bookings; });
      await _loadRevenue(user.uid);
    } catch (e) { debugPrint('Error loading hospital dashboard: $e'); }
  }
  Future<void> _loadRevenue(String providerId) async {
    try {
      final snap = await FirebaseFirestore.instance.collection('payments').where('providerId', isEqualTo: providerId).get();
      final now = DateTime.now();
      double total = 0, month = 0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        total += amount;
        final rawDate = data['timestamp'] ?? data['createdAt'] ?? data['paidAt'];
        DateTime? date;
        if (rawDate is Timestamp) date = rawDate.toDate();
        else if (rawDate is DateTime) date = rawDate;
        else if (rawDate is String) date = DateTime.tryParse(rawDate);
        if (date != null && date.year == now.year && date.month == now.month) month += amount;
      }
      if (mounted) setState(() { _totalRevenue = total; _monthlyRevenue = month; });
    } catch (e) { debugPrint('Error loading hospital revenue: $e'); }
  }
  String _statusText(String status) { switch (status) { case 'confirmed': return _t('مؤكد'); case 'completed': return _t('مكتمل'); case 'cancelled': return _t('ملغي'); case 'pending': return _t('قيد الانتظار'); default: return status; } }
  Color _statusColor(String status) { switch (status) { case 'confirmed': return Colors.green; case 'completed': return Colors.teal; case 'cancelled': return Colors.red; case 'pending': return Colors.orange; default: return Colors.grey; } }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: Text(_hospitalData?['name'] ?? _t('لوحة تحكم المستشفى')), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [
        Row(children: [Text(_t('مفتوح'), style: TextStyle(color: Colors.white70, fontSize: 12)), Switch(value: _isOpen, onChanged: (value) async { final previous = _isOpen; setState(() => _isOpen = value); try { if (user != null) await FirebaseFirestore.instance.collection('hospitals').doc(user.uid).update({'isOpen': value, 'updatedAt': FieldValue.serverTimestamp()}); } catch (e) { if (mounted) { setState(() => _isOpen = previous); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تعذر تحديث حالة المستشفى')))); } debugPrint('Hospital status update failed: $e'); } }, activeColor: Colors.green, inactiveThumbColor: Colors.red)]),
        IconButton(icon: const Icon(Icons.campaign), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdManagementScreen(providerId: user?.uid, providerName: _hospitalData?['name'], providerType: AdType.hospital)))),
        IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBookingsScreen()))),
        IconButton(icon: const Icon(Icons.groups_2_outlined), tooltip: _t('إدارة الكادر الصحي'), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HospitalStaffAffiliationsScreen()))),
      ]),
      body: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.vertical(bottom: Radius.circular(24))), child: Row(children: [_buildStatCard(_t('المرضى'), '${_bookings.map((b) => b.userId).where((id) => id.isNotEmpty).toSet().length}', Icons.people, Colors.blue), _buildStatCard(_t('الحجوزات'), '${_bookings.length}', Icons.event, Colors.amber), _buildStatCard(_t('الإيرادات'), AppStrings.of(context).formatCurrency(_totalRevenue), Icons.attach_money, Colors.green), _buildStatCard(_t('هذا الشهر'), AppStrings.of(context).formatCurrency(_monthlyRevenue), Icons.calendar_month, Colors.purple)])),
        Container(color: isDark ? const Color(0xFF0B1121) : Colors.white, child: TabBar(controller: _tabController, indicatorColor: AppColors.primary, labelColor: AppColors.primary, unselectedLabelColor: AppColors.grey, tabs: [Tab(text: _t('الرئيسية')), Tab(text: _t('الحجوزات')), Tab(text: _t('الأقسام')), Tab(text: _t('الإحصائيات'))])),
        Expanded(child: TabBarView(controller: _tabController, children: [_buildHomeTab(), _buildBookingsTab(), _buildDepartmentsTab(), _buildStatisticsTab()])),
      ]),
    );
  }
  Widget _buildStatCard(String label, String value, IconData icon, Color color) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9))])));
  Widget _buildHomeTab() => ListView(padding: const EdgeInsets.all(16), children: [Text(_t('مرحباً بك في لوحة تحكم المستشفى'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(_t('إدارة المرضى والحجوزات والأقسام'), style: TextStyle(color: Colors.grey)), const SizedBox(height: 24), GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [_buildQuickCard(_t('مرضى اليوم'), '${_bookings.where((b) => _sameDay(b.bookingDate, DateTime.now())).length}', Icons.person_add, Colors.blue), _buildQuickCard(_t('حجوزات اليوم'), '${_bookings.where((b) => _sameDay(b.bookingDate, DateTime.now())).length}', Icons.event, Colors.orange), _buildQuickCard(_t('إجمالي المرضى'), '${_bookings.map((b) => b.userId).where((id) => id.isNotEmpty).toSet().length}', Icons.people, Colors.green), _buildQuickCard(_t('الحالة'), _isOpen ? _t('مفتوح') : _t('مغلق'), Icons.star, _isOpen ? Colors.green : Colors.red)]), const SizedBox(height: 24), Text(_t('أحدث الحجوزات'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 8), ..._bookings.take(5).map(_buildBookingPreview)]);
  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  Widget _buildBookingPreview(BookingModel booking) { final color = _statusColor(booking.status); return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(booking.userId.isEmpty ? _t('مريض') : booking.userId, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(_statusText(booking.status), style: TextStyle(fontSize: 10, color: color)))])); }
  Widget _buildQuickCard(String title, String value, IconData icon, Color color) { final isDark = Theme.of(context).brightness == Brightness.dark; return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 24), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))])); }
  Widget _buildBookingsTab() {
    if (_bookings.isEmpty) return Center(child: Text(_t('لا توجد حجوزات')));
    return ListView.builder(padding: const EdgeInsets.all(16), itemCount: _bookings.length, itemBuilder: (_, index) {
      final booking = _bookings[index]; final color = _statusColor(booking.status);
      return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(booking.userId.isEmpty ? _t('مريض') : booking.userId),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${booking.bookingDate.day}/${booking.bookingDate.month}/${booking.bookingDate.year} - ${_formatTime(booking.bookingDate)}'),
          if (booking.notes?.isNotEmpty == true) Text(booking.notes!, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(_statusText(booking.status), style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ]),
        trailing: PopupMenuButton<String>(
          tooltip: _t('تحديث حالة الحجز'),
          onSelected: (status) => _updateBookingStatus(booking, status),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'confirmed', child: Text(_t('تأكيد الحجز'))),
            PopupMenuItem(value: 'completed', child: Text(_t('تحديد كمكتمل'))),
            PopupMenuItem(value: 'cancelled', child: Text(_t('إلغاء الحجز'))),
          ],
        ),
      ));
    });
  }

  Future<void> _updateBookingStatus(BookingModel booking, String status) async {
    try {
      await FirebaseFirestore.instance.collection('bookings').doc(booking.id).update({
        'status': status, 'updatedAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      setState(() {
        final index = _bookings.indexWhere((item) => item.id == booking.id);
        if (index >= 0) {
          final old = _bookings[index];
          _bookings[index] = BookingModel(id: old.id, userId: old.userId, type: old.type,
            providerId: old.providerId, providerName: old.providerName, bookingDate: old.bookingDate,
            notes: old.notes, status: status, createdAt: old.createdAt, updatedAt: DateTime.now());
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تم تحديث حالة الحجز'))));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تعذر تحديث حالة الحجز'))));
      debugPrint('Update hospital booking status failed: $error');
    }
  }
  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  Widget _buildDepartmentsTab() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Center(child: Text(_t('يجب تسجيل الدخول')));
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('hospital_departments').where('hospitalId', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(_t('تعذر تحميل الأقسام')));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        return ListView(padding: const EdgeInsets.all(16), children: [
          Align(alignment: AlignmentDirectional.centerEnd, child: FilledButton.icon(onPressed: _showAddDepartment, icon: const Icon(Icons.add), label: Text(_t('إضافة قسم')))),
          if (docs.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Text(_t('لم تتم إضافة أقسام بعد'), textAlign: TextAlign.center)),
          ...docs.map((doc) {
            final data = doc.data(); final active = data['isActive'] != false;
            return Card(child: ListTile(leading: const Icon(Icons.medical_services, color: AppColors.primary),
              title: Text(data['name']?.toString() ?? ''),
              subtitle: Text(data['description']?.toString() ?? (active ? _t('القسم متاح') : _t('القسم متوقف'))),
              trailing: Switch(value: active, onChanged: (value) => _setDepartmentActive(doc.reference, value)),
              onLongPress: () => _deleteDepartment(doc.reference)));
          }),
        ]);
      },
    );
  }

  Future<void> _showAddDepartment() async {
    final name = TextEditingController(); final description = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final save = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(_t('إضافة قسم جديد')),
      content: Form(key: formKey, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: name, autofocus: true, decoration: InputDecoration(labelText: _t('اسم القسم')),
          validator: (value) => value == null || value.trim().isEmpty ? _t('هذا الحقل مطلوب') : null),
        TextFormField(controller: description, decoration: InputDecoration(labelText: _t('وصف القسم'))),
      ])),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_t('إلغاء'))),
        FilledButton(onPressed: () { if (formKey.currentState!.validate()) Navigator.pop(dialogContext, true); }, child: Text(_t('حفظ'))),
      ],
    ));
    if (save == true && name.text.trim().isNotEmpty) {
      try { await FirebaseFirestore.instance.collection('hospital_departments').add({
        'hospitalId': FirebaseAuth.instance.currentUser!.uid, 'name': name.text.trim(),
        'description': description.text.trim(), 'isActive': true,
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      }); } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تعذر حفظ القسم'))));
        debugPrint('Create hospital department failed: $error');
      }
    }
    name.dispose(); description.dispose();
  }

  Future<void> _setDepartmentActive(DocumentReference<Map<String, dynamic>> ref, bool value) async {
    try { await ref.update({'isActive': value, 'updatedAt': FieldValue.serverTimestamp()}); }
    catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تعذر تحديث القسم'))));
      debugPrint('Update hospital department failed: $error');
    }
  }

  Future<void> _deleteDepartment(DocumentReference<Map<String, dynamic>> ref) async {
    final confirm = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: Text(_t('حذف القسم')), content: Text(_t('هل تريد حذف هذا القسم؟')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_t('إلغاء'))),
        FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(_t('حذف'))),
      ],
    ));
    if (confirm == true) {
      try { await ref.delete(); } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('تعذر حذف القسم'))));
        debugPrint('Delete hospital department failed: $error');
      }
    }
  }
  Widget _buildStatisticsTab() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.bar_chart, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('${_t('إجمالي الحجوزات')}: ${_bookings.length}'), const SizedBox(height: 8), Text('${_t('إجمالي الإيرادات')}: ${AppStrings.of(context).formatCurrency(_totalRevenue)}')]));
  @override void dispose() { _tabController.dispose(); super.dispose(); }
}
