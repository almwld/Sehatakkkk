import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/report_model.dart';
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

  final List<String> _tabs = ['الإيرادات', 'الحجوزات', 'المستخدمين', 'مخصص'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      _reportData = await _reportService.generateFullReport(
        startDate: _startDate,
        endDate: _endDate,
      );
    } catch (e) {
      print('Error loading report: $e');
    }
    setState(() => _isLoading = false);
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReport,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ اختيار الفترة
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectStartDate,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectEndDate,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('تحديث'),
                ),
              ],
            ),
          ),
          // ✅ التبويبات
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
          // ✅ المحتوى
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

  // ✅ تبويب الإيرادات
  Widget _buildRevenueTab() {
    final revenue = _reportData?['revenue'] as Map<String, dynamic>?;

    if (revenue == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ البطاقات
          Row(
            children: [
              _buildStatCard('إجمالي الإيرادات', '${revenue['totalRevenue'] ?? 0} ريال', Icons.attach_money, Colors.green),
              _buildStatCard('عمولة المنصة', '${revenue['platformCommission'] ?? 0} ريال', Icons.percent, Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard('صافي المقدمين', '${revenue['providerRevenue'] ?? 0} ريال', Icons.business, Colors.blue),
              _buildStatCard('عدد المعاملات', '${revenue['totalPayments'] ?? 0}', Icons.payment, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          // ✅ الرسم البياني
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text('الرسم البياني للإيرادات (قيد التطوير)'),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ تبويب الحجوزات
  Widget _buildBookingsTab() {
    final bookings = _reportData?['bookings'] as Map<String, dynamic>?;

    if (bookings == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildStatCard('إجمالي الحجوزات', '${bookings['totalBookings'] ?? 0}', Icons.calendar_today, Colors.blue),
              _buildStatCard('مؤكدة', '${bookings['confirmed'] ?? 0}', Icons.check_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard('مكتملة', '${bookings['completed'] ?? 0}', Icons.done_all, Colors.teal),
              _buildStatCard('ملغية', '${bookings['cancelled'] ?? 0}', Icons.cancel, Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard('قيد الانتظار', '${bookings['pending'] ?? 0}', Icons.hourglass_empty, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ تبويب المستخدمين
  Widget _buildUsersTab() {
    final users = _reportData?['users'] as Map<String, dynamic>?;

    if (users == null) {
      return const Center(child: Text('لا توجد بيانات'));
    }

    final roles = users['roles'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCard('إجمالي المستخدمين', '${users['totalUsers'] ?? 0}', Icons.people, Colors.blue),
          const SizedBox(height: 16),
          const Text('توزيع الأدوار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...roles.entries.map((entry) {
            final icon = _getRoleIcon(entry.key);
            final color = _getRoleColor(entry.key);
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getRoleName(entry.key),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${entry.value}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ✅ تبويب مخصص
  Widget _buildCustomTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('تخصيص التقارير', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('قيد التطوير', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: فتح صفحة تخصيص التقارير
            },
            child: const Text('طلب تقرير مخصص'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'user': return Icons.person_outline;
      case 'doctor': return Icons.local_hospital;
      case 'pharmacist': return Icons.local_pharmacy;
      case 'lab': return Icons.science;
      case 'veterinarian': return Icons.pets;
      case 'admin': return Icons.admin_panel_settings;
      default: return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'user': return Colors.blue;
      case 'doctor': return Colors.teal;
      case 'pharmacist': return Colors.green;
      case 'lab': return Colors.purple;
      case 'veterinarian': return Colors.brown;
      case 'admin': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getRoleName(String role) {
    switch (role) {
      case 'user': return 'مستخدم';
      case 'doctor': return 'طبيب';
      case 'pharmacist': return 'صيدلي';
      case 'lab': return 'مختبر';
      case 'veterinarian': return 'بيطري';
      case 'admin': return 'مشرف';
      default: return role;
    }
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
      await _loadReport();
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
      await _loadReport();
    }
  }

  Future<void> _exportReport() async {
    // TODO: تصدير التقرير
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📥 جاري تصدير التقرير...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
