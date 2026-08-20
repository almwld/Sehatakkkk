import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const DoctorsListScreen({super.key, this.scrollController});

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
    // ... بقية الأطباء
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
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverAppBar(
            title: const Text('الأطباء'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            floating: true,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () => _showFilterDialog(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
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
          ),
          SliverToBoxAdapter(
            child: SizedBox(
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
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: filtered.isEmpty
                ? SliverToBoxAdapter(
                    child: _buildEmptyState(isDark),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doctor = filtered[index];
                        return _buildDoctorCard(doctor, isDark);
                      },
                      childCount: filtered.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ... باقي الدوال كما هي
}
