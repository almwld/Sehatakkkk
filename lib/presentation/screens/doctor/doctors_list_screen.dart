import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class DoctorsListScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const DoctorsListScreen({super.key, this.scrollController});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  String _searchQuery = '';
  String _selectedSpecialty = 'الكل';
  bool _isLoading = true;
  List<Map<String, dynamic>> _allDoctors = [];

  final List<String> _specialties = [
    'الكل', 'باطنية', 'قلبية', 'أطفال', 'نساء وولادة', 'عظام',
    'أنف وأذن وحنجرة', 'جلدية', 'عيون', 'نفسية', 'جراحة', 'مسالك بولية'
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctorsFromFirestore();
  }

  // ✅ جلب الأطباء من Firestore
  Future<void> _fetchDoctorsFromFirestore() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .get();

      if (snapshot.docs.isEmpty) {
        print('⚠️ لا يوجد أطباء في Firestore');
        setState(() => _isLoading = false);
        return;
      }

      _allDoctors = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'دكتور',
          'specialty': data['specialty'] ?? 'طبيب عام',
          'experience': data['experience']?.toString() ?? 'غير محدد',
          'rating': data['rating']?.toDouble() ?? 0.0,
          'reviews': data['reviews'] ?? 0,
          'fee': data['consultationFee']?.toDouble() ?? data['fee'] ?? 0,
          'available': data['isAvailable'] ?? data['available'] ?? true,
          'image': data['image'] ?? data['photoUrl'] ?? ImageKit.doctor1,
          'hospital': data['clinicAddress'] ?? data['hospital'] ?? 'مستشفى',
          'online': data['isOnline'] ?? data['online'] ?? false,
          'gender': data['gender'] ?? 'male',
          'badge': data['badge'] ?? 'طبيب',
          'about': data['about'] ?? data['bio'] ?? '',
          'availability': data['workingHours'] ?? data['availability'] ?? '',
        };
      }).toList();

      setState(() => _isLoading = false);
      print('✅ تم جلب ${_allDoctors.length} طبيب من Firestore');
    } catch (e) {
      print('❌ Error fetching doctors: $e');
      setState(() => _isLoading = false);
      ToastService.showError('❌ فشل في جلب بيانات الأطباء');
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    var list = _allDoctors;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((d) =>
          (d['name']?.toString().toLowerCase().contains(query) ?? false) ||
          (d['specialty']?.toString().toLowerCase().contains(query) ?? false) ||
          (d['hospital']?.toString().toLowerCase().contains(query) ?? false)
      ).toList();
    }
    if (_selectedSpecialty != 'الكل') {
      list = list.where((d) => d['specialty'] == _selectedSpecialty).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredDoctors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: 16),
              Text('جاري تحميل الأطباء...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأطباء'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDoctorsFromFirestore,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildSpecialties(isDark),
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doctor = filtered[index];
                      return _buildDoctorCard(doctor, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(25),
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
            Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'ابحث عن طبيب...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, size: 18, color: isDark ? Colors.grey[400] : Colors.grey),
                onPressed: () => setState(() => _searchQuery = ''),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialties(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = _selectedSpecialty == specialty;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(specialty, style: const TextStyle(fontSize: 11)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSpecialty = selected ? specialty : 'الكل';
                });
              },
              backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white : AppColors.primary),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey.shade300),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctorId: doctor['id']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                imageUrl: doctor['image'] ?? ImageKit.doctor1,
                width: 70,
                height: 70,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doctor['name'] ?? 'طبيب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 2),
                          Text(
                            (doctor['rating'] ?? 0).toStringAsFixed(1),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doctor['specialty'] ?? 'طبيب عام',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          doctor['experience'] ?? 'غير محدد',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor['hospital'] ?? 'مستشفى',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (doctor['available'] ?? false) ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: (doctor['available'] ?? false) ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (doctor['available'] ?? false) ? 'متاح' : 'غير متاح',
                              style: TextStyle(
                                fontSize: 10,
                                color: (doctor['available'] ?? false) ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(doctor['fee'] ?? 0).toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تصفية الأطباء'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر التخصص'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _specialties.map((specialty) {
                return FilterChip(
                  label: Text(specialty),
                  selected: _selectedSpecialty == specialty,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialty = selected ? specialty : 'الكل';
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
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
            Icons.medical_services_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أطباء',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تأكد من وجود أطباء في قاعدة البيانات',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchDoctorsFromFirestore,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة تحميل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
