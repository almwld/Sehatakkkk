import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class VisitHistoryScreen extends StatefulWidget {
  const VisitHistoryScreen({super.key});

  @override
  State<VisitHistoryScreen> createState() => _VisitHistoryScreenState();
}

class _VisitHistoryScreenState extends State<VisitHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _visits = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'مكتملة', 'ملغاة', 'قادمة'];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final visits = List<Map<String, dynamic>>.from(data['visits'] ?? []);
          setState(() => _visits = visits);
        } else {
          _loadMockVisits();
        }
      } catch (e) {
        print('❌ Error loading visits: $e');
        _loadMockVisits();
      }
    } else {
      _loadMockVisits();
    }

    setState(() => _isLoading = false);
  }

  void _loadMockVisits() {
    _visits = [
      {
        'id': '1',
        'doctor': 'د. أحمد المولد',
        'specialty': 'باطنية',
        'date': '2026-07-01',
        'time': '10:00 ص',
        'status': 'مكتملة',
        'notes': 'متابعة ضغط الدم - تحسن ملحوظ',
        'prescription': ['أملوديبين 5mg', 'هيدروكلوروتيازيد 25mg'],
        'hospital': 'مستشفى الثورة العام',
      },
      {
        'id': '2',
        'doctor': 'د. فاطمة صديقي',
        'specialty': 'أطفال',
        'date': '2026-06-25',
        'time': '2:30 م',
        'status': 'مكتملة',
        'notes': 'تطعيمات دورية - الحالة جيدة',
        'prescription': ['فيتامين د 1000IU'],
        'hospital': 'مستشفى المتحدون التخصصي',
      },
      {
        'id': '3',
        'doctor': 'د. خالد النخلاني',
        'specialty': 'قلب',
        'date': '2026-07-10',
        'time': '11:00 ص',
        'status': 'قادمة',
        'notes': 'متابعة قلبية',
        'prescription': [],
        'hospital': 'مركز قلب العاصمة',
      },
      {
        'id': '4',
        'doctor': 'د. علي البراشي',
        'specialty': 'جلدية',
        'date': '2026-06-20',
        'time': '9:00 ص',
        'status': 'ملغاة',
        'notes': 'تم الإلغاء بسبب الظروف',
        'prescription': [],
        'hospital': 'مركز البراشي للجلدية',
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredVisits {
    if (_selectedFilter == 'الكل') return _visits;
    return _visits.where((v) => v['status'] == _selectedFilter).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مكتملة':
        return AppColors.success;
      case 'قادمة':
        return AppColors.info;
      case 'ملغاة':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'مكتملة':
        return Icons.check_circle_rounded;
      case 'قادمة':
        return Icons.access_time_rounded;
      case 'ملغاة':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  void _showVisitDetails(Map<String, dynamic> visit) {
    final isPast = visit['status'] == 'مكتملة' || visit['status'] == 'ملغاة';
    final statusColor = _getStatusColor(visit['status']);
    final statusIcon = _getStatusIcon(visit['status']);

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
                  child: const Icon(Icons.history_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit['doctor'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        visit['specialty'],
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
                  child: Row(
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        visit['status'],
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _detailRow(Icons.calendar_today_rounded, 'التاريخ', visit['date']),
            _detailRow(Icons.access_time_rounded, 'الوقت', visit['time']),
            _detailRow(Icons.location_on_rounded, 'المستشفى', visit['hospital']),
            _detailRow(Icons.note_rounded, 'ملاحظات', visit['notes']),
            if (visit['prescription'].isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'الوصفات الطبية',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              ...visit['prescription'].map((med) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medication_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(med, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              )),
            ],
            const SizedBox(height: 16),
            if (!isPast)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // الانتقال إلى الدردشة
                      },
                      icon: const Icon(Icons.chat_rounded),
                      label: const Text('محادثة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // إعادة حجز الموعد
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('إعادة حجز'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredVisits;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: const Text('سجل الزيارات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ فلترة الزيارات
                _buildFilterTabs(),
                // ✅ قائمة الزيارات
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final visit = filtered[index];
                            return _buildVisitCard(visit, isDark);
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
              Icons.history_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد زيارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ستظهر هنا سجل زياراتك للأطباء',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // الانتقال إلى حجز موعد
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('حجز موعد جديد'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Map<String, dynamic> visit, bool isDark) {
    final statusColor = _getStatusColor(visit['status']);
    final statusIcon = _getStatusIcon(visit['status']);

    return GestureDetector(
      onTap: () => _showVisitDetails(visit),
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
            // ✅ أيقونة الطبيب
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
            // ✅ معلومات الزيارة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit['doctor'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    visit['specialty'],
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
                        visit['date'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.grey),
                      const SizedBox(width: 4),
                      Text(
                        visit['time'],
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
            // ✅ الحالة
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        visit['status'],
                        style: TextStyle(
                          fontSize: 10,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'تفاصيل',
                    style: TextStyle(fontSize: 9, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
