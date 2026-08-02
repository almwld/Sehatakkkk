import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
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
  bool _isLoading = false;
  
  // ✅ للتحكم في الشريط السفلي
  final ScrollController _scrollController = ScrollController();
  bool _isBottomBarVisible = true;

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
    'جراحة',
    'مسالك بولية',
  ];

  // ✅ أطباء محسّنين مع صور متنوعة
  final List<Map<String, dynamic>> _allDoctors = [
    {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'experience': '20+ سنة', 'rating': 4.9, 'reviews': 328, 'price': 500, 'available': true, 'image': ImageKit.doctor1, 'hospital': 'مستشفى الثورة العام', 'online': true, 'gender': 'male', 'badge': 'استشاري'},
    {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'experience': '15 سنة', 'rating': 4.8, 'reviews': 256, 'price': 600, 'available': true, 'image': ImageKit.doctor2, 'hospital': 'مركز قلب العاصمة', 'online': false, 'gender': 'male', 'badge': 'أستاذ'},
    {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'experience': '12 سنة', 'rating': 4.9, 'reviews': 189, 'price': 450, 'available': true, 'image': ImageKit.doctor3, 'hospital': 'مستشفى السبعين', 'online': true, 'gender': 'female', 'badge': 'استشارية'},
    {'id': '4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'experience': '8 سنوات', 'rating': 4.7, 'reviews': 89, 'price': 400, 'available': false, 'image': ImageKit.doctor4, 'hospital': 'مستشفى الأنف والأذن', 'online': false, 'gender': 'male', 'badge': 'أخصائي'},
    {'id': '5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'experience': '18 سنة', 'rating': 4.8, 'reviews': 210, 'price': 550, 'available': true, 'image': ImageKit.doctor5, 'hospital': 'مستشفى الولادة', 'online': true, 'gender': 'female', 'badge': 'استشارية'},
    {'id': '6', 'name': 'د. سعيد العمري', 'specialty': 'جلدية', 'experience': '14 سنة', 'rating': 4.7, 'reviews': 178, 'price': 480, 'available': true, 'image': ImageKit.doctor1, 'hospital': 'مركز الجلدية', 'online': true, 'gender': 'male', 'badge': 'استشاري'},
    {'id': '7', 'name': 'د. ناصر الحمزي', 'specialty': 'عيون', 'experience': '22 سنة', 'rating': 4.9, 'reviews': 312, 'price': 580, 'available': true, 'image': ImageKit.doctor2, 'hospital': 'مركز العيون', 'online': false, 'gender': 'male', 'badge': 'أستاذ'},
    {'id': '8', 'name': 'د. رنا الحوثي', 'specialty': 'نفسية', 'experience': '9 سنوات', 'rating': 4.5, 'reviews': 98, 'price': 420, 'available': true, 'image': ImageKit.doctor3, 'hospital': 'مركز الصحة النفسية', 'online': true, 'gender': 'female', 'badge': 'أخصائية'},
    {'id': '9', 'name': 'د. ياسر القبلي', 'specialty': 'جراحة', 'experience': '25 سنة', 'rating': 4.9, 'reviews': 456, 'price': 650, 'available': true, 'image': ImageKit.doctor4, 'hospital': 'مستشفى الجراحة', 'online': false, 'gender': 'male', 'badge': 'بروفيسور'},
    {'id': '10', 'name': 'د. ليلى الكبسي', 'specialty': 'مسالك بولية', 'experience': '16 سنة', 'rating': 4.6, 'reviews': 134, 'price': 520, 'available': true, 'image': ImageKit.doctor5, 'hospital': 'مركز المسالك البولية', 'online': true, 'gender': 'female', 'badge': 'استشارية'},
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
      case 'السعر (منخفض)':
        list.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
        break;
      case 'السعر (مرتفع)':
        list.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
        break;
      case 'التقييم':
      default:
        list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
    }
    
    return list;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final direction = _scrollController.position.userScrollDirection;
      if (direction == ScrollDirection.reverse) {
        if (_isBottomBarVisible) {
          setState(() => _isBottomBarVisible = false);
        }
      } else if (direction == ScrollDirection.forward) {
        if (!_isBottomBarVisible) {
          setState(() => _isBottomBarVisible = true);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredDoctors;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('👨‍⚕️ الأطباء'),
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
          // ✅ شريط البحث المحسّن
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
                        hintText: 'ابحث عن طبيب بالاسم أو التخصص...',
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
                  IconButton(
                    icon: Icon(Icons.mic, color: isDark ? Colors.grey[400] : Colors.grey),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎤 البحث الصوتي قريباً'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // ✅ التصنيفات مع تمرير
          SizedBox(
            height: 42,
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
          // ✅ عدد النتائج
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${filtered.length} طبيب',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'نتيجة بحث: $_searchQuery',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          // ✅ قائمة الأطباء
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
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
      // ✅ شريط سفلي متحرك
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _isBottomBarVisible ? 68 : 0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(Icons.home_rounded, 'الرئيسية', 0),
                _buildNavItem(Icons.person_search_rounded, 'الأطباء', 1, selected: true),
                _buildNavItem(Icons.local_pharmacy_rounded, 'الصيدلية', 2),
                _buildChatButton(),
                _buildNavItem(Icons.science_rounded, 'مختبرات', 4),
                _buildNavItem(Icons.folder_rounded, 'صحتي', 5),
                _buildNavItem(Icons.grid_view_rounded, 'المزيد', 6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool selected = false}) {
    final color = selected ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pop(context);
        }
      },
      child: SizedBox(
        width: 48,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
            if (selected)
              Container(
                width: 32,
                height: 3,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }

  Widget _buildChatButton() {
    return GestureDetector(
      onTap: () {},
      child: SizedBox(
        width: 56,
        height: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'الدردشة',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 7),
          ],
        ),
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
          border: Border.all(
            color: doctor['available'] 
                ? Colors.transparent 
                : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(
                    url: doctor['image'],
                    width: 70,
                    height: 70,
                  ),
                ),
                if (doctor['online'] == true)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.circle,
                        color: Colors.green,
                        size: 12,
                      ),
                    ),
                  ),
                if (doctor['badge'] != null)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        doctor['badge'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
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
                          Text(
                            ' (${doctor['reviews']})',
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
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          doctor['hospital'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: doctor['available'] 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.red.withOpacity(0.1),
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
                        child: Row(
                          children: [
                            Text(
                              '${doctor['price']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'ر.ي',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
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

  void _showFilterDialog(BuildContext context) {
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...['التقييم', 'السعر (منخفض)', 'السعر (مرتفع)'].map((option) {
                    return RadioListTile<String>(
                      title: Text(option),
                      value: option,
                      groupValue: _selectedSort,
                      onChanged: (value) {
                        setStateSheet(() => _selectedSort = value!);
                        setState(() {});
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
      },
    );
  }
}
