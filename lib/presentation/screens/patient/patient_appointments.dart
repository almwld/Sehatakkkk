import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
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

  final List<String> _filters = [
    'الكل',
    'اليوم',
    'هذا الأسبوع',
    'هذا الشهر',
  ];

  // ✅ بيانات المواعيد (ملاحظة: يجب ربطها مع Firebase لاحقاً)
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '1',
      'doctorName': 'د. أحمد المولد',
      'doctorImage': ImageService.doctor1,
      'specialty': 'استشاري باطنية',
      'date': DateTime.now().add(const Duration(days: 1)),
      'time': '10:00 ص',
      'status': 'قادم',
      'type': 'استشارة فيديو',
      'hospital': 'مستشفى الثورة العام',
      'notes': 'يرجى التحضير قبل الموعد بـ 10 دقائق',
      'price': '500 ر.ي',
    },
    {
      'id': '2',
      'doctorName': 'د. خالد النخلاني',
      'doctorImage': ImageService.doctor2,
      'specialty': 'أمراض قلبية',
      'date': DateTime.now().add(const Duration(days: 3)),
      'time': '02:30 م',
      'status': 'قادم',
      'type': 'استشارة صوتية',
      'hospital': 'مركز قلب العاصمة',
      'notes': 'يجب إجراء تخطيط قلب قبل الموعد',
      'price': '600 ر.ي',
    },
    {
      'id': '3',
      'doctorName': 'د. أسماء الهندي',
      'doctorImage': ImageService.doctor3,
      'specialty': 'أطفال وحديثي الولادة',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'time': '09:00 ص',
      'status': 'منتهي',
      'type': 'استشارة فيديو',
      'hospital': 'مستشفى السبعين',
      'notes': 'تم متابعة حالة الطفل',
      'price': '450 ر.ي',
    },
    {
      'id': '4',
      'doctorName': 'د. محمد العلاي',
      'doctorImage': ImageService.doctor4,
      'specialty': 'أنف وأذن وحنجرة',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'time': '11:30 ص',
      'status': 'منتهي',
      'type': 'استشارة صوتية',
      'hospital': 'مستشفى الأنف والأذن',
      'notes': 'تم وصف علاج مناسب',
      'price': '400 ر.ي',
    },
    {
      'id': '5',
      'doctorName': 'د. فاطمة صديقي',
      'doctorImage': ImageService.doctor1,
      'specialty': 'نساء وولادة',
      'date': DateTime.now().add(const Duration(days: 7)),
      'time': '04:00 م',
      'status': 'قادم',
      'type': 'استشارة فيديو',
      'hospital': 'مستشفى الولادة',
      'notes': 'متابعة الحمل الشهرية',
      'price': '550 ر.ي',
    },
    {
      'id': '6',
      'doctorName': 'د. عمر الجابري',
      'doctorImage': ImageService.doctor2,
      'specialty': 'عظام ومفاصل',
      'date': DateTime.now().add(const Duration(days: 10)),
      'time': '01:00 م',
      'status': 'قادم',
      'type': 'استشارة فيديو',
      'hospital': 'مركز العظام',
      'notes': 'إحضار الأشعة السابقة',
      'price': '500 ر.ي',
    },
  ];

  List<Map<String, dynamic>> get _filteredAppointments {
    var list = _appointments;
    if (_selectedFilter != 'الكل') {
      final now = DateTime.now();
      switch (_selectedFilter) {
        case 'اليوم':
          list = list.where((a) =>
            a['date'].year == now.year &&
            a['date'].month == now.month &&
            a['date'].day == now.day
          ).toList();
          break;
        case 'هذا الأسبوع':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 7));
          list = list.where((a) =>
            a['date'].isAfter(weekStart) &&
            a['date'].isBefore(weekEnd)
          ).toList();
          break;
        case 'هذا الشهر':
          list = list.where((a) =>
            a['date'].year == now.year &&
            a['date'].month == now.month
          ).toList();
          break;
      }
    }
    return list;
  }

  List<Map<String, dynamic>> get _upcomingAppointments {
    return _filteredAppointments.where((a) => a['status'] == 'قادم').toList();
  }

  List<Map<String, dynamic>> get _pastAppointments {
    return _filteredAppointments.where((a) => a['status'] == 'منتهي').toList();
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
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('مواعيدي'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // TODO: فتح شاشة حجز موعد
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'قادمة'),
            Tab(text: 'سابقة'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: Column(
        children: [
          // ✅ الفلاتر
          _buildFilters(),
          // ✅ المحتوى حسب التبويب
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentsList(_upcomingAppointments, isDark, primaryColor),
                _buildAppointmentsList(_pastAppointments, isDark, primaryColor),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: فتح شاشة حجز موعد
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? filter : 'الكل';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0D5257),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0D5257),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0D5257) : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(
    List<Map<String, dynamic>> appointments,
    bool isDark,
    Color primaryColor,
  ) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد مواعيد',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بحجز موعد جديد',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // TODO: فتح شاشة حجز موعد
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('حجز موعد جديد'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        final isUpcoming = appointment['status'] == 'قادم';
        return _buildAppointmentCard(appointment, isDark, primaryColor, isUpcoming);
      },
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    bool isDark,
    Color primaryColor,
    bool isUpcoming,
  ) {
    final date = appointment['date'] as DateTime;
    final dateFormat = DateFormat('EEEE، d MMMM y', 'ar');
    final formattedDate = dateFormat.format(date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        border: isUpcoming
            ? Border.all(color: primaryColor.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ رأس البطاقة
          Row(
            children: [
              // ✅ صورة الطبيب
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: appointment['doctorImage'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 50,
                    height: 50,
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(Icons.person, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment['doctorName'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      appointment['specialty'],
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // ✅ الحالة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isUpcoming ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment['status'],
                      style: TextStyle(
                        color: isUpcoming ? Colors.green : Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ✅ التفاصيل
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          appointment['time'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.medical_services, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          appointment['type'],
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✅ السعر
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment['price'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          if (appointment['notes'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.note, size: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      appointment['notes'],
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // ✅ الأزرار
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailsScreen(
                          doctorId: appointment['id'],
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.info_outline, size: 16),
                  label: const Text('تفاصيل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isUpcoming)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showCancelDialog(appointment['id']);
                    },
                    icon: Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('إلغاء'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              if (!isUpcoming)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: إعادة حجز
                    },
                    icon: Icon(Icons.replay_outlined, size: 16),
                    label: const Text('إعادة حجز'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: BorderSide(color: primaryColor.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إلغاء الموعد'),
        content: const Text('هل أنت متأكد من رغبتك في إلغاء هذا الموعد؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إلغاء الموعد بنجاح'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تأكيد الإلغاء'),
          ),
        ],
      ),
    );
  }
}
