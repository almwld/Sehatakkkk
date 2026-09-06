import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportService _reportService = ReportService();
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReport();
  }

  Future<void> _loadReport() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      _reportData = await _reportService.generateFullReport(
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      debugPrint('Error loading report: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'التقارير والإحصائيات',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReport),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportReport),
        ],
      ),
      body: Column(
        children: [
          _buildDateBar(),
          Container(
            color: isDark ? const Color(0xFF0B1121) : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              tabs: const [
                Tab(text: 'الإيرادات'),
                Tab(text: 'الحجوزات'),
                Tab(text: 'المستخدمين'),
                Tab(text: 'مخصص'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRevenueTab(),
                      _buildBookingsTab(),
                      _buildUsersTab(),
                      _buildCustomTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(child: _dateButton(_startDate, _selectStartDate)),
          const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 16)),
          Expanded(child: _dateButton(_endDate, _selectEndDate)),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _loadReport,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  Widget _dateButton(DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          const Icon(Icons.calendar_today, size: 16),
          const SizedBox(width: 8),
          Text('${date.day}/${date.month}/${date.year}', style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildRevenueTab() {
    final revenue = _reportData?['revenue'] as Map<String, dynamic>?;
    if (revenue == null) return const Center(child: Text('لا توجد بيانات'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          _buildStatCard('إجمالي الإيرادات', '${revenue['totalRevenue'] ?? 0} ريال', Icons.attach_money, Colors.green),
          _buildStatCard('عمولة المنصة', '${revenue['platformCommission'] ?? 0} ريال', Icons.percent, Colors.orange),
        ]),
        Row(children: [
          _buildStatCard('صافي المقدمين', '${revenue['providerRevenue'] ?? 0} ريال', Icons.business, Colors.blue),
          _buildStatCard('عدد المعاملات', '${revenue['totalPayments'] ?? 0}', Icons.payment, Colors.purple),
        ]),
      ]),
    );
  }

  Widget _buildBookingsTab() {
    final bookings = _reportData?['bookings'] as Map<String, dynamic>?;
    if (bookings == null) return const Center(child: Text('لا توجد بيانات'));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Row(children: [
          _buildStatCard('إجمالي الحجوزات', '${bookings['totalBookings'] ?? 0}', Icons.calendar_today, Colors.blue),
          _buildStatCard('مؤكدة', '${bookings['confirmed'] ?? 0}', Icons.check_circle, Colors.green),
        ]),
        Row(children: [
          _buildStatCard('مكتملة', '${bookings['completed'] ?? 0}', Icons.done_all, Colors.teal),
          _buildStatCard('ملغية', '${bookings['cancelled'] ?? 0}', Icons.cancel, Colors.red),
        ]),
        Row(children: [
          _buildStatCard('قيد الانتظار', '${bookings['pending'] ?? 0}', Icons.hourglass_empty, Colors.orange),
        ]),
      ]),
    );
  }

  Widget _buildUsersTab() {
    final users = _reportData?['users'] as Map<String, dynamic>?;
    if (users == null) return const Center(child: Text('لا توجد بيانات'));
    final roles = users['roles'] as Map<String, dynamic>? ?? {};
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildStatCard('إجمالي المستخدمين', '${users['totalUsers'] ?? 0}', Icons.people, Colors.blue),
        const SizedBox(height: 16),
        const Text('توزيع الأدوار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...roles.entries.map((entry) => ListTile(
          leading: Icon(_getRoleIcon(entry.key), color: _getRoleColor(entry.key)),
          title: Text(_getRoleName(entry.key)),
          trailing: Text('${entry.value}'),
        )),
      ]),
    );
  }

  Widget _buildCustomTab() => const Center(child: Text('تخصيص التقارير قيد التطوير'));

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ]),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'doctor': return Icons.local_hospital;
      case 'pharmacist': return Icons.local_pharmacy;
      case 'lab': return Icons.science;
      case 'veterinarian': return Icons.pets;
      case 'admin': return Icons.admin_panel_settings;
      default: return Icons.person_outline;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'doctor': return Colors.teal;
      case 'pharmacist': return Colors.green;
      case 'lab': return Colors.purple;
      case 'veterinarian': return Colors.brown;
      case 'admin': return Colors.red;
      default: return Colors.blue;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'doctor': return 'طبيب';
      case 'pharmacist': return 'صيدلي';
      case 'lab': return 'مختبر';
      case 'veterinarian': return 'بيطري';
      case 'admin': return 'مشرف';
      default: return 'مستخدم';
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2020), lastDate: _endDate);
    if (date != null) { setState(() => _startDate = date); await _loadReport(); }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(context: context, initialDate: _endDate, firstDate: _startDate, lastDate: DateTime.now());
    if (date != null) { setState(() => _endDate = date); await _loadReport(); }
  }

  Future<void> _exportReport() async {
    if (_reportData == null) return;
    ToastService.showSuccess(context, '📥 جاري تصدير التقرير...');
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
}
