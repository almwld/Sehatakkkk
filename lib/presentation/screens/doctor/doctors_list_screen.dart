import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const DoctorsListScreen({super.key, this.scrollController});
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  String _searchQuery = '';
  String _selectedSpecialty = 'الكل';
  bool _isLoading = false;

  final List<String> _specialties = [
    'الكل', 'باطنية', 'قلبية', 'أطفال', 'نساء وولادة', 'عظام',
    'أنف وأذن وحنجرة', 'جلدية', 'عيون', 'نفسية', 'جراحة', 'مسالك بولية'
  ];

  final List<Map<String, dynamic>> _allDoctors = [
    {
      'id': '1',
      'name': 'د. أحمد المولد',
      'specialty': 'باطنية',
      'experience': '20+ سنة',
      'rating': 4.9,
      'reviews': 328,
      'price': 500,
      'available': true,
      'image': ImageKit.doctor1,
      'hospital': 'مستشفى الثورة العام',
      'online': true,
      'gender': 'male',
      'badge': 'استشاري'
    },
    {
      'id': '2',
      'name': 'د. خالد النخلاني',
      'specialty': 'قلبية',
      'experience': '15 سنة',
      'rating': 4.8,
      'reviews': 256,
      'price': 600,
      'available': true,
      'image': ImageKit.doctor2,
      'hospital': 'مركز قلب العاصمة',
      'online': false,
      'gender': 'male',
      'badge': 'أستاذ'
    },
    {
      'id': '3',
      'name': 'د. أسماء الهندي',
      'specialty': 'أطفال',
      'experience': '12 سنة',
      'rating': 4.9,
      'reviews': 189,
      'price': 450,
      'available': true,
      'image': ImageKit.doctor3,
      'hospital': 'مستشفى السبعين',
      'online': true,
      'gender': 'female',
      'badge': 'استشارية'
    },
    {
      'id': '4',
      'name': 'د. محمد العلاي',
      'specialty': 'أنف وأذن وحنجرة',
      'experience': '8 سنوات',
      'rating': 4.7,
      'reviews': 89,
      'price': 400,
      'available': false,
      'image': ImageKit.doctor4,
      'hospital': 'مستشفى الأنف والأذن',
      'online': false,
      'gender': 'male',
      'badge': 'أخصائي'
    },
    {
      'id': '5',
      'name': 'د. فاطمة صديقي',
      'specialty': 'نساء وولادة',
      'experience': '18 سنة',
      'rating': 4.8,
      'reviews': 210,
      'price': 550,
      'available': true,
      'image': ImageKit.doctor5,
      'hospital': 'مستشفى الولادة',
      'online': true,
      'gender': 'female',
      'badge': 'استشارية'
    },
  ];

  List<Map<String, dynamic>> get _filteredDoctors {
    var list = _allDoctors;
    if (_searchQuery.isNotEmpty) {
      list = list.where((d) =>
          d['name'].toString().contains(_searchQuery) ||
          d['specialty'].toString().contains(_searchQuery) ||
          d['hospital'].toString().contains(_searchQuery)
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
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
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
          ),
          // التصنيفات
          SizedBox(
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
          ),
          // القائمة
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

  // ✅ دالة بناء بطاقة الطبيب
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
                imageUrl: doctor['image'],
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
                          doctor['name'],
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
                            doctor['rating'].toString(),
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
                          doctor['specialty'],
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
                          doctor['experience'],
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
                    doctor['hospital'],
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
                          color: doctor['available'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: doctor['available'] ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor['available'] ? 'متاح' : 'غير متاح',
                              style: TextStyle(
                                color: doctor['available'] ? Colors.green : Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${doctor['price']} ر.ي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // ✅ دالة عرض حالة فارغة
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أطباء',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير البحث أو التصفية',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedSpecialty = 'الكل';
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة تعيين'),
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

  // ✅ دالة عرض حوار التصفية
  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ترتيب حسب',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...['التقييم', 'السعر (منخفض)', 'السعر (مرتفع)'].map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: 'التقييم',
                  onChanged: (value) {
                    Navigator.pop(context);
                  },
                  activeColor: AppColors.primary,
                );
              }).toList(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
