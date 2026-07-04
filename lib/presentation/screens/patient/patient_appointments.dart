import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'قادم', 'مكتمل', 'ملغي'];

  // ✅ بيانات المواعيد التجريبية
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'doctor': 'د. أحمد المولد',
      'specialty': 'استشاري باطنية',
      'date': '2026-07-10',
      'time': '10:00 صباحاً',
      'status': 'قادم',
      'image': '👨‍⚕️',
      'location': 'عيادة المولد الطبية، شارع الزبيري',
      'notes': 'جلب التحاليل السابقة',
      'color': Colors.green,
    },
    {
      'id': '2',
      'doctor': 'د. خالد النخلاني',
      'specialty': 'أمراض قلبية',
      'date': '2026-07-08',
      'time': '02:30 مساءً',
      'status': 'مكتمل',
      'image': '👨‍⚕️',
      'location': 'مركز قلب العاصمة، شارع الستين',
      'notes': 'متابعة ضغط الدم',
      'color': Colors.blue,
    },
    {
      'id': '3',
      'doctor': 'د. أسماء الهندي',
      'specialty': 'أطفال وحديثي الولادة',
      'date': '2026-07-05',
      'time': '09:00 صباحاً',
      'status': 'مكتمل',
      'image': '👩‍⚕️',
      'location': 'مستشفى السبعين، شارع الأربعين',
      'notes': 'تطعيمات دورية',
      'color': Colors.blue,
    },
    {
      'id': '4',
      'doctor': 'د. محمد العلاي',
      'specialty': 'أنف وأذن وحنجرة',
      'date': '2026-06-28',
      'time': '11:30 صباحاً',
      'status': 'ملغي',
      'image': '👨‍⚕️',
      'location': 'عيادة الأنف والأذن، شارع الخمسين',
      'notes': 'تم الإلغاء بسبب ظروف طارئة',
      'color': Colors.red,
    },
    {
      'id': '5',
      'doctor': 'د. سارة العمري',
      'specialty': 'نساء وولادة',
      'date': '2026-07-15',
      'time': '01:00 مساءً',
      'status': 'قادم',
      'image': '👩‍⚕️',
      'location': 'مركز زاد الطبي، شارع هائل',
      'notes': 'موعد متابعة الحمل',
      'color': Colors.green,
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments {
    if (_selectedFilter == 'الكل') return _appointments;
    return _appointments
        .where((a) => a['status'] == _selectedFilter)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredAppointments;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('مواعيدي'),
        backgroundColor: const Color(0xFF0D5257),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'المواعيد', icon: Icon(Icons.calendar_today_rounded)),
            Tab(text: 'التقويم', icon: Icon(Icons.calendar_month_rounded)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // ✅ فتح شاشة حجز موعد
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ تبويب المواعيد
          Column(
            children: [
              // ✅ فلتر الحالة
              _buildFilterChips(isDark),
              const SizedBox(height: 8),
              // ✅ قائمة المواعيد
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final appointment = filtered[index];
                          return _buildAppointmentCard(appointment, isDark);
                        },
                      ),
              ),
            ],
          ),
          // ✅ تبويب التقويم (سيتم إضافته لاحقاً)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 64,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'التقويم قيد التطوير',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 ويدجتس
  // ============================================================
  Widget _buildFilterChips(bool isDark) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0D5257)
                    : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0D5257)
                      : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
                ),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, bool isDark) {
    final status = appointment['status'] as String;
    final color = appointment['color'] as Color;
    final isPast = status == 'مكتمل' || status == 'ملغي';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(
              doctorId: appointment['id'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPast
                ? (isDark ? Colors.grey[700]! : Colors.grey[300]!)
                : color.withOpacity(0.2),
            width: isPast ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ أيقونة الطبيب
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  appointment['image'] ?? '👨‍⚕️',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['doctor'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment['specialty'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appointment['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ الحالة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (status == 'قادم')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'تبقى 3 أيام',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مواعيد ${_selectedFilter == 'الكل' ? '' : _selectedFilter}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'احجز موعداً جديداً مع أحد الأطباء',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // ✅ فتح شاشة حجز موعد
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('حجز موعد جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D5257),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
