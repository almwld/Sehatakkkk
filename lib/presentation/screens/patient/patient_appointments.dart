import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments> {
  String _selectedFilter = 'جميع';
  final List<String> _filters = ['جميع', 'قادمة', 'منتهية', 'ملغاة'];

  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'doctor': 'د. عبدالله الأصبحي',
      'specialty': 'عظام',
      'date': '2026-07-10',
      'time': '10:00 ص',
      'status': 'قادم',
      'hospital': 'مستشفى الثورة العام',
      'notes': 'يرجى إحضار الأشعة السابقة',
    },
    {
      'id': '2',
      'doctor': 'د. روضة المنصوب',
      'specialty': 'نسائية',
      'date': '2026-07-08',
      'time': '2:30 م',
      'status': 'قادم',
      'hospital': 'مركز زاد الطبي',
      'notes': 'متابعة حمل',
    },
    {
      'id': '3',
      'doctor': 'د. أسماء الهندي',
      'specialty': 'أطفال',
      'date': '2026-07-05',
      'time': '9:00 ص',
      'status': 'منتهي',
      'hospital': 'مستشفى المتحدون التخصصي',
      'notes': 'تطعيمات دورية',
    },
    {
      'id': '4',
      'doctor': 'د. خالد النخلاني',
      'specialty': 'قلب',
      'date': '2026-06-28',
      'time': '4:00 م',
      'status': 'منتهي',
      'hospital': 'مركز قلب العاصمة',
      'notes': 'متابعة ضغط الدم',
    },
    {
      'id': '5',
      'doctor': 'د. علي البراشي',
      'specialty': 'جلدية',
      'date': '2026-07-15',
      'time': '11:00 ص',
      'status': 'قادم',
      'hospital': 'مركز البراشي للجلدية',
      'notes': 'علاج حب الشباب',
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments {
    if (_selectedFilter == 'جميع') return _appointments;
    return _appointments.where((a) => a['status'] == _selectedFilter).toList();
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    final isPast = appointment['status'] == 'منتهي';
    final statusColor = appointment['status'] == 'قادم'
        ? AppColors.success
        : appointment['status'] == 'منتهي'
            ? AppColors.grey
            : AppColors.error;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment['doctor'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        appointment['specialty'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      fontSize: 11,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _detailRow(Icons.calendar_today_rounded, 'التاريخ', appointment['date']),
            _detailRow(Icons.access_time_rounded, 'الوقت', appointment['time']),
            _detailRow(Icons.location_on_rounded, 'المستشفى', appointment['hospital']),
            _detailRow(Icons.note_rounded, 'ملاحظات', appointment['notes']),
            const SizedBox(height: 16),
            if (!isPast) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('📧 تم إرسال تذكير للموعد'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('تذكير'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _cancelAppointment(appointment);
                      },
                      icon: const Icon(Icons.cancel_rounded),
                      label: const Text('إلغاء'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // الانتقال إلى الدردشة مع الطبيب
                  },
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('محادثة مع الطبيب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('إلغاء الموعد'),
        content: Text('هل أنت متأكد من إلغاء موعدك مع ${appointment['doctor']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تراجع'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _appointments.indexWhere((a) => a['id'] == appointment['id']);
                if (index != -1) {
                  _appointments[index]['status'] = 'ملغاة';
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إلغاء الموعد بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredAppointments;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'مواعيدي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // الانتقال إلى شاشة حجز موعد جديد
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ فلترة المواعيد
          _buildFilterTabs(),
          // ✅ قائمة المواعيد
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final appointment = filtered[index];
                      return _buildAppointmentCard(appointment, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : AppColors.grey,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد مواعيد',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'قم بحجز موعد مع طبيبك',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // الانتقال إلى شاشة حجز موعد
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('حجز موعد جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment, bool isDark) {
    final isPast = appointment['status'] == 'منتهي';
    final statusColor = appointment['status'] == 'قادم'
        ? AppColors.success
        : appointment['status'] == 'منتهي'
            ? AppColors.grey
            : AppColors.error;

    return GestureDetector(
      onTap: () => _showAppointmentDetails(appointment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF2D3A54) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.person, color: AppColors.primary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment['doctor'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    appointment['specialty'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        appointment['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        appointment['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment['status'],
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                if (!isPast)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // محادثة مع الطبيب
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.info.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.chat_rounded, color: AppColors.info, size: 16),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
