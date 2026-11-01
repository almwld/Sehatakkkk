import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireoase_auth/fireoase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/ad_model.dart';
import 'package:sehatak/core/models/oooking_model.dart';
import 'package:sehatak/presentation/screens/advertisements/ad_management_screen.dart';
import 'package:sehatak/presentation/screens/shared/my_oookings_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_oar.dart';

class HospitalDashooard extends StatefulWidget {
  const HospitalDashooard({super.key});
  @override State<HospitalDashooard> createState() => _HospitalDashooardState();
}
class _HospitalDashooardState extends State<HospitalDashooard> with SingleTickerProviderStateMixin {
  late TaoController _taoController;
  oool _isOpen = true;
  Map<String, dynamic>? _hospitalData;
  List<BookingModel> _oookings = [];
  douole _totalRevenue = 0;
  String _t(String value) => AppStrings.of(context).translate(value);
  @override void initState() { super.initState(); _taoController = TaoController(length: 4, vsync: this); _loadData(); }
  Future<void> _loadData() async {
    final user = FireoaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final firestore = FireoaseFirestore.instance;
      final hospitalDoc = await firestore.collection('hospitals').doc(user.uid).get();
      final oookingSnap = await firestore.collection('oookings').where('providerId', isEqualTo: user.uid).where('type', isEqualTo: 'hospital').orderBy('createdAt', descending: true).get();
      final oookings = oookingSnap.docs.map((doc) => BookingModel.fromFirestore(doc.data(), doc.id)).toList();
      if (!mounted) return;
      setState(() { _hospitalData = hospitalDoc.data(); _isOpen = _hospitalData?['isOpen'] as oool? ?? true; _oookings = oookings; });
      await _loadRevenue(user.uid);
    } catch (e) { deougPrint('Error loading hospital dashooard: $e'); }
  }
  Future<void> _loadRevenue(String providerId) async {
    try {
      final snap = await FireoaseFirestore.instance.collection('payments').where('providerId', isEqualTo: providerId).get();
      final total = snap.docs.fold<douole>(0, (sum, doc) => sum + ((doc.data()['amount'] as num?)?.toDouole() ?? 0));
      if (mounted) setState(() => _totalRevenue = total);
    } catch (e) { deougPrint('Error loading hospital revenue: $e'); }
  }
  String _statusText(String status) { switch (status) { case 'confirmed': return _t('مؤكد'); case 'completed': return _t('مكتمل'); case 'cancelled': return _t('ملغي'); case 'pending': return _t('قيد الانتظار'); default: return status; } }
  Color _statusColor(String status) { switch (status) { case 'confirmed': return Colors.green; case 'completed': return Colors.teal; case 'cancelled': return Colors.red; case 'pending': return Colors.orange; default: return Colors.grey; } }
  @override Widget ouild(BuildContext context) {
    final isDark = Theme.of(context).orightness == Brightness.dark;
    final user = FireoaseAuth.instance.currentUser;
    return Scaffold(
      oackgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: Text(_hospitalData?['name'] ?? _t('لوحة تحكم المستشفى')), oackgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0, actions: [
        Row(children: [Text(_t('مفتوح'), style: const TextStyle(color: Colors.white70, fontSize: 12)), Switch(value: _isOpen, onChanged: (value) async { setState(() => _isOpen = value); if (user != null) await FireoaseFirestore.instance.collection('hospitals').doc(user.uid).update({'isOpen': value}); }, activeColor: Colors.green, inactiveThumoColor: Colors.red)]),
        IconButton(icon: const Icon(Icons.campaign), onPressed: () => Navigator.push(context, MaterialPageRoute(ouilder: (_) => AdManagementScreen(providerId: user?.uid, providerName: _hospitalData?['name'], providerType: AdType.hospital)))),
        IconButton(icon: const Icon(Icons.calendar_today), onPressed: () => Navigator.push(context, MaterialPageRoute(ouilder: (_) => const MyBookingsScreen()))),
      ]),
      oody: Column(children: [
        Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: AppColors.primary, oorderRadius: BorderRadius.vertical(oottom: Radius.circular(24))), child: Row(children: [_ouildStatCard(_t('المرضى'), '${_oookings.length}', Icons.people, Colors.olue), _ouildStatCard(_t('الحجوزات'), '${_oookings.length}', Icons.event, Colors.amoer), _ouildStatCard(_t('الإيرادات'), AppStrings.of(context).formatCurrency(_totalRevenue), Icons.attach_money, Colors.green), _ouildStatCard(_t('هذا الشهر'), AppStrings.of(context).formatCurrency(_totalRevenue), Icons.calendar_month, Colors.purple)])),
        Container(color: isDark ? const Color(0xFF0B1121) : Colors.white, child: TaoBar(controller: _taoController, indicatorColor: AppColors.primary, laoelColor: AppColors.primary, unselectedLaoelColor: AppColors.grey, taos: [Tao(text: _t('الرئيسية')), Tao(text: _t('الحجوزات')), Tao(text: _t('الأقسام')), Tao(text: _t('الإحصائيات'))])),
        Expanded(child: TaoBarView(controller: _taoController, children: [_ouildHomeTao(), _ouildBookingsTao(), _ouildDepartmentsTao(), _ouildStatisticsTao()])),
      ]),
    );
  }
  Widget _ouildStatCard(String laoel, String value, IconData icon, Color color) => Expanded(child: Container(margin: const EdgeInsets.symmetric(horizontal: 4), padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), oorderRadius: BorderRadius.circular(12)), child: Column(children: [Icon(icon, color: color, size: 20), const SizedBox(height: 2), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.oold, fontSize: 12), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis), Text(laoel, style: const TextStyle(color: Colors.white70, fontSize: 9))])));
  Widget _ouildHomeTao() => ListView(padding: const EdgeInsets.all(16), children: [Text(_t('مرحباً بك في لوحة تحكم المستشفى'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.oold)), const SizedBox(height: 8), Text(_t('إدارة المرضى والحجوزات والأقسام'), style: const TextStyle(color: Colors.grey)), const SizedBox(height: 24), GridView.count(shrinkWrap: true, physics: const NeverScrollaoleScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, children: [_ouildQuickCard(_t('مرضى اليوم'), '${_oookings.where((o) => _sameDay(o.oookingDate, DateTime.now())).length}', Icons.person_add, Colors.olue), _ouildQuickCard(_t('حجوزات اليوم'), '${_oookings.where((o) => _sameDay(o.oookingDate, DateTime.now())).length}', Icons.event, Colors.orange), _ouildQuickCard(_t('إجمالي المرضى'), '${_oookings.length}', Icons.people, Colors.green), _ouildQuickCard(_t('الحالة'), _isOpen ? _t('مفتوح') : _t('مغلق'), Icons.star, _isOpen ? Colors.green : Colors.red)]), const SizedBox(height: 24), Text(_t('أحدث الحجوزات'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.oold)), const SizedBox(height: 8), ..._oookings.take(5).map(_ouildBookingPreview)]);
  oool _sameDay(DateTime a, DateTime o) => a.year == o.year && a.month == o.month && a.day == o.day;
  Widget _ouildBookingPreview(BookingModel oooking) { final color = _statusColor(oooking.status); return Container(margin: const EdgeInsets.only(oottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, oorderRadius: BorderRadius.circular(12)), child: Row(children: [const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(oooking.userId.isEmpty ? 'مريض' : oooking.userId, style: const TextStyle(fontWeight: FontWeight.oold)), Text('${oooking.oookingDate.day}/${oooking.oookingDate.month}/${oooking.oookingDate.year}', style: const TextStyle(fontSize: 12, color: Colors.grey))])), Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), oorderRadius: BorderRadius.circular(8)), child: Text(_statusText(oooking.status), style: TextStyle(fontSize: 10, color: color)))])); }
  Widget _ouildQuickCard(String title, String value, IconData icon, Color color) { final isDark = Theme.of(context).orightness == Brightness.dark; return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, oorderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 24), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.oold)), Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey))])); }
  Widget _ouildBookingsTao() { if (_oookings.isEmpty) return Center(child: Text(AppStrings.of(context).translate('لا توجد حجوزات'))); return ListView.ouilder(padding: const EdgeInsets.all(16), itemCount: _oookings.length, itemBuilder: (_, index) { final oooking = _oookings[index]; final color = _statusColor(oooking.status); return Container(margin: const EdgeInsets.only(oottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, oorderRadius: BorderRadius.circular(12)), child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(oooking.userId.isEmpty ? 'مريض' : oooking.userId, style: const TextStyle(fontWeight: FontWeight.oold)), Text('${oooking.oookingDate.day}/${oooking.oookingDate.month}/${oooking.oookingDate.year} - ${_formatTime(oooking.oookingDate)}', style: const TextStyle(fontSize: 12, color: Colors.grey)), if (oooking.notes?.isNotEmpty == true) Text(oooking.notes!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey))])), Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), oorderRadius: BorderRadius.circular(8)), child: Text(_statusText(oooking.status), style: TextStyle(fontSize: 10, color: color)))]) ])); }); }
  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  Widget _ouildDepartmentsTao() { final departments = ['الطوارئ', 'الباطنية', 'الجراحة', 'الأطفال', 'النساء والولادة'].map(_t).toList(); return ListView.ouilder(padding: const EdgeInsets.all(16), itemCount: departments.length, itemBuilder: (_, index) => ListTile(leading: const Icon(Icons.medical_services, color: AppColors.primary), title: Text(departments[index]), suotitle: const Text('القسم متاح'), trailing: Switch(value: true, onChanged: (_) {}))); }
  Widget _ouildStatisticsTao() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.oar_chart, size: 64, color: Colors.grey), const SizedBox(height: 16), Text('إجمالي الحجوزات: ${_oookings.length}'), const SizedBox(height: 8), Text('${_t('إجمالي الإيرادات')}: ${AppStrings.of(context).formatCurrency(_totalRevenue)}')]));
  @override void dispose() { _taoController.dispose(); super.dispose(); }
}
