import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  String _searchQuery = '';
  String _selectedSpecialty = 'الكل';
  String _selectedSort = 'التقييم';

  final List<String> _specialties = [
    'الكل',
    'باطنية',
    'قلبية',
    'أطفال',
    'نساء وولادة',
    'عظام',
    'أنف وأذن وحنجرة',
    'جلدية',
    'عيون',
    'نفسية',
  ];

  final List<String> _sortOptions = [
    'التقييم',
    'السعر (منخفض)',
    'السعر (مرتفع)',
    'الأكثر خبرة',
  ];

  // ✅ 15 طبيب
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
      'image': ImageService.doctor1,
      'hospital': 'مستشفى الثورة العام',
      'online': true,
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
      'image': ImageService.doctor2,
      'hospital': 'مركز قلب العاصمة',
      'online': false,
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
      'image': ImageService.doctor3,
      'hospital': 'مستشفى السبعين',
      'online': true,
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
      'image': ImageService.doctor4,
      'hospital': 'مستشفى الأنف والأذن',
      'online': false,
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
      'image': ImageService.doctor1,
      'hospital': 'مستشفى الولادة',
      'online': true,
    },
    {
      'id': '6',
      'name': 'د. عمر الجابري',
      'specialty': 'عظام',
      'experience': '10 سنوات',
      'rating': 4.6,
      'reviews': 145,
      'price': 520,
      'available': true,
      'image': ImageService.doctor2,
      'hospital': 'مركز العظام',
      'online': false,
    },
    {
      'id': '7',
      'name': 'د. ليلى الكبسي',
      'specialty': 'جلدية',
      'experience': '14 سنة',
      'rating': 4.7,
      'reviews': 178,
      'price': 480,
      'available': true,
      'image': ImageService.doctor3,
      'hospital': 'مركز الجلدية',
      'online': true,
    },
    {
      'id': '8',
      'name': 'د. ناصر الحمزي',
      'specialty': 'عيون',
      'experience': '22 سنة',
      'rating': 4.9,
      'reviews': 312,
      'price': 580,
      'available': true,
      'image': ImageService.doctor4,
      'hospital': 'مركز العيون',
      'online': false,
    },
    {
      'id': '9',
      'name': 'د. رنا الحوثي',
      'specialty': 'نفسية',
      'experience': '9 سنوات',
      'rating': 4.5,
      'reviews': 98,
      'price': 420,
      'available': true,
      'image': ImageService.doctor1,
      'hospital': 'مركز الصحة النفسية',
      'online': true,
    },
    {
      'id': '10',
      'name': 'د. ياسر القبلي',
      'specialty': 'قلبية',
      'experience': '25 سنة',
      'rating': 4.9,
      'reviews': 456,
      'price': 650,
      'available': true,
      'image': ImageService.doctor2,
      'hospital': 'مركز قلب العاصمة',
      'online': false,
    },
    {
      'id': '11',
      'name': 'د. منى العرشي',
      'specialty': 'أطفال',
      'experience': '11 سنة',
      'rating': 4.7,
      'reviews': 167,
      'price': 430,
      'available': true,
      'image': ImageService.doctor3,
      'hospital': 'مستشفى السبعين',
      'online': true,
    },
    {
      'id': '12',
      'name': 'د. هاني الدباء',
      'specialty': 'عظام',
      'experience': '16 سنة',
      'rating': 4.8,
      'reviews': 234,
      'price': 560,
      'available': false,
      'image': ImageService.doctor4,
      'hospital': 'مركز العظام',
      'online': false,
    },
    {
      'id': '13',
      'name': 'د. سامية الحكيمي',
      'specialty': 'باطنية',
      'experience': '19 سنة',
      'rating': 4.6,
      'reviews': 198,
      'price': 490,
      'available': true,
      'image': ImageService.doctor1,
      'hospital': 'مستشفى الثورة العام',
      'online': true,
    },
    {
      'id': '14',
      'name': 'د. جميل السقاف',
      'specialty': 'جلدية',
      'experience': '13 سنة',
      'rating': 4.6,
      'reviews': 156,
      'price': 460,
      'available': true,
      'image': ImageService.doctor2,
      'hospital': 'مركز الجلدية',
      'online': false,
    },
    {
      'id': '15',
      'name': 'د. نديم البكير',
      'specialty': 'نفسية',
      'experience': '7 سنوات',
      'rating': 4.4,
      'reviews': 76,
      'price': 390,
      'available': true,
      'image': ImageService.doctor3,
      'hospital': 'مركز الصحة النفسية',
      'online': true,
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
    switch (_selectedSort) {
      case 'التقييم':
        list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'السعر (منخفض)':
        list.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
        break;
      case 'السعر (مرتفع)':
        list.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
        break;
      case 'الأكثر خبرة':
        list.sort((a, b) => (b['experience'].length).compareTo(a['experience'].length));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final filtered = _filteredDoctors;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأطباء'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // ✅ زر الفلتر
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              _showFilterDialog();
            },
          ),
          // ✅ زر البحث
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              _showSearchBar();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط البحث (إذا كان مفعلاً)
          if (_searchQuery.isNotEmpty)
            _buildSearchBar(isDark),
          // ✅ الفلاتر السريعة
          _buildSpecialtyChips(),
          // ✅ قائمة الأطباء
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doctor = filtered[index];
                      return _buildDoctorCard(doctor, isDark, primaryColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
                autofocus: true,
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

  Widget _buildSpecialtyChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = _selectedSpecialty == specialty;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(specialty),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedSpecialty = selected ? specialty : 'الكل';
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF0D5257),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF0D5257),
                fontSize: 11,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
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
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isDark, Color primaryColor) {
    final isAvailable = doctor['available'] as bool;
    final isOnline = doctor['online'] as bool;

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
        ),
        child: Row(
          children: [
            // ✅ صورة الطبيب
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl: doctor['image'],
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _shimmerPlaceholder(70, 70, 14),
                    errorWidget: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      child: Icon(Icons.person, color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF0B1121) : Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // ✅ معلومات الطبيب
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
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '(${doctor['reviews']})',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doctor['specialty'],
                          style: TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
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
                  const SizedBox(height: 4),
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
                      // ✅ الحالة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAvailable ? 'متاح' : 'غير متاح',
                              style: TextStyle(
                                color: isAvailable ? Colors.green : Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // ✅ السعر
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${doctor['price']} ر.ي',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ سهم
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerPlaceholder(double width, double height, double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ترتيب حسب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._sortOptions.map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedSort,
                      onChanged: (value) {
                        setStateSheet(() {
                          _selectedSort = value!;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                      activeColor: const Color(0xFF0D5257),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

  // ✅ دالة البحث
  void _showSearchBar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('بحث عن طبيب'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'أدخل اسم الطبيب أو التخصص...',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }
