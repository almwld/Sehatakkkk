import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/reports/reports_service.dart';
import 'package:sehatak/data/models/reports/report_model.dart';

class ReportsDashboard extends StatefulWidget {
  const ReportsDashboard({super.key});

  @override
  State<ReportsDashboard> createState() => _ReportsDashboardState();
}

class _ReportsDashboardState extends State<ReportsDashboard> {
  final ReportsService _reportsService = ReportsService();
  
  UserStatsModel? _stats;
  List<ChartDataModel> _chartData = [];
  List<MedicalReportModel> _medicalReports = [];
  List<MedicationReportModel> _medicationReports = [];
  
  bool _isLoading = true;
  ChartType _selectedChart = ChartType.appointments;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _stats = await _reportsService.getUserStats('user_123');
      _chartData = await _reportsService.getChartData('user_123', _selectedChart);
      _medicalReports = await _reportsService.getMedicalReports('user_123');
      _medicationReports = await _reportsService.getMedicationReports('user_123');
    } catch (e) {
      print('❌ Error loading reports: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'التقارير والإحصائيات',
        backgroundColor: const Color(0xFF0D5257),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? _buildErrorWidget(isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ بطاقة الإحصائيات
                      _buildStatsCards(isDark),
                      const SizedBox(height: 16),

                      // ✅ الرسم البياني
                      _buildChartSection(isDark),
                      const SizedBox(height: 16),

                      // ✅ تبويبات التقارير
                      _buildTabs(isDark),
                      const SizedBox(height: 16),

                      // ✅ المحتوى حسب التبويب
                      _buildTabContent(isDark),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDark ? Colors.grey : Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل التقارير',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
              foregroundColor: Colors.white,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 بطاقات الإحصائيات
  // ============================================================
  Widget _buildStatsCards(bool isDark) {
    final stats = _stats!;
    final cards = [
      {
        'label': 'المواعيد',
        'value': '${stats.totalAppointments}',
        'icon': Icons.calendar_today_rounded,
        'color': const Color(0xFF0D5257),
      },
      {
        'label': 'المكتملة',
        'value': '${stats.completedAppointments}',
        'icon': Icons.check_circle_rounded,
        'color': Colors.green,
      },
      {
        'label': 'الطلبات',
        'value': '${stats.totalOrders}',
        'icon': Icons.shopping_bag_rounded,
        'color': Colors.orange,
      },
      {
        'label': 'المصروف',
        'value': '${stats.totalSpent.toStringAsFixed(0)} ر.ي',
        'icon': Icons.payment_rounded,
        'color': Colors.blue,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final color = card['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                card['icon'] as IconData,
                color: color,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                card['value'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                card['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey : Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 📈 الرسم البياني
  // ============================================================
  Widget _buildChartSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الرسم البياني',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              DropdownButton<ChartType>(
                value: _selectedChart,
                dropdownColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                items: ChartType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getChartLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedChart = value;
                      _loadData();
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: _chartData.map((e) => e.value).reduce((a, b) => a > b ? a : b) * 1.2,
                barGroups: _chartData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.value,
                        color: const Color(0xFF0D5257),
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < _chartData.length) {
                          return Text(
                            _chartData[index].label,
                            style: TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getChartLabel(ChartType type) {
    switch (type) {
      case ChartType.appointments:
        return 'المواعيد';
      case ChartType.orders:
        return 'الطلبات';
      case ChartType.spending:
        return 'المصروف';
      case ChartType.consultations:
        return 'الاستشارات';
    }
  }

  // ============================================================
  // 📋 تبويبات التقارير
  // ============================================================
  Widget _buildTabs(bool isDark) {
    final tabs = ['التقارير الطبية', 'الأدوية'];
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTab == index
                      ? const Color(0xFF0D5257)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: _selectedTab == index
                          ? Colors.white
                          : (isDark ? Colors.grey : Colors.grey),
                      fontWeight: _selectedTab == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(bool isDark) {
    return _selectedTab == 0
        ? _buildMedicalReports(isDark)
        : _buildMedicationReports(isDark);
  }

  // ============================================================
  // 📋 التقارير الطبية
  // ============================================================
  Widget _buildMedicalReports(bool isDark) {
    if (_medicalReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'لا توجد تقارير طبية',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicalReports.length,
      itemBuilder: (context, index) {
        final report = _medicalReports[index];
        return _buildMedicalReportCard(report, isDark);
      },
    );
  }

  Widget _buildMedicalReportCard(MedicalReportModel report, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey! : Colors.grey!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: report.status == 'مكتمل'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: report.status == 'مكتمل' ? Colors.green : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            report.summary,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 12,
                color: isDark ? Colors.grey : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                report.doctor,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: isDark ? Colors.grey : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${report.date.day}/${report.date.month}/${report.date.year}',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 💊 تقارير الأدوية
  // ============================================================
  Widget _buildMedicationReports(bool isDark) {
    if (_medicationReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Text(
            'لا توجد أدوية',
            style: TextStyle(
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _medicationReports.length,
      itemBuilder: (context, index) {
        final medication = _medicationReports[index];
        return _buildMedicationCard(medication, isDark);
      },
    );
  }

  Widget _buildMedicationCard(MedicationReportModel medication, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: medication.status == 'نشط'
              ? Colors.green.withOpacity(0.3)
              : (isDark ? Colors.grey! : Colors.grey!),
          width: medication.status == 'نشط' ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medication.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: medication.status == 'نشط'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  medication.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: medication.status == 'نشط' ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.medical_services_rounded, size: 14, color: Color(0xFF0D5257)),
              const SizedBox(width: 4),
              Text(
                'الجرعة: ${medication.dosage}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF0D5257)),
              const SizedBox(width: 4),
              Text(
                'المدة: ${medication.duration}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey : Colors.grey,
                ),
              ),
              const SizedBox(width: 12),
              if (medication.status == 'نشط')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'متبقي ${medication.remainingDays} يوم',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
