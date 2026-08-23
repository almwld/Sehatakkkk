import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

// ✅ بيانات Mock للأطباء
class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int totalReviews;
  final String? imageUrl;
  final bool isAvailableToday;
  final int consultationFee;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.totalReviews,
    this.imageUrl,
    this.isAvailableToday = true,
    this.consultationFee = 100,
  });
}

class DoctorsListScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final String? specialty;
  final String? hospitalId;

  const DoctorsListScreen({
    super.key,
    this.scrollController,
    this.specialty,
    this.hospitalId,
  });

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = true;
  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  String? _selectedSpecialty;
  bool _showAvailableOnly = false;

  final List<String> _specialties = [
    'الكل',
    'طب عام',
    'أطفال',
    'نساء وتوليد',
    'جلدية',
    'عظام',
    'قلب',
    'أعصاب',
    'نفسي',
    'أسنان',
    'عيون',
    'أنف وأذن وحنجرة',
  ];

  // ✅ بيانات Mock
  final List<DoctorModel> _mockDoctors = [
    DoctorModel(
      id: '1',
      name: 'د. أحمد المولد',
      specialty: 'باطنية',
      rating: 4.9,
      totalReviews: 328,
      consultationFee: 500,
      isAvailableToday: true,
    ),
    DoctorModel(
      id: '2',
      name: 'د. خالد النخلاني',
      specialty: 'قلبية',
      rating: 4.8,
      totalReviews: 256,
      consultationFee: 450,
      isAvailableToday: true,
    ),
    DoctorModel(
      id: '3',
      name: 'د. أسماء الهندي',
      specialty: 'أطفال',
      rating: 4.7,
      totalReviews: 189,
      consultationFee: 420,
      isAvailableToday: true,
    ),
    DoctorModel(
      id: '4',
      name: 'د. محمد العلاي',
      specialty: 'أنف وأذن وحنجرة',
      rating: 4.6,
      totalReviews: 89,
      consultationFee: 400,
      isAvailableToday: false,
    ),
    DoctorModel(
      id: '5',
      name: 'د. فاطمة صديقي',
      specialty: 'نساء وولادة',
      rating: 4.8,
      totalReviews: 210,
      consultationFee: 480,
      isAvailableToday: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _selectedSpecialty = widget.specialty ?? 'الكل';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDoctors() {
    setState(() {
      _doctors = _mockDoctors;
      _filteredDoctors = _mockDoctors;
      _isLoading = false;
    });
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _doctors.where((doctor) {
        bool matchesSearch = _searchQuery.isEmpty ||
            doctor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doctor.specialty.toLowerCase().contains(_searchQuery.toLowerCase());
        bool matchesSpecialty = _selectedSpecialty == 'الكل' ||
            doctor.specialty == _selectedSpecialty;
        bool matchesAvailability = !_showAvailableOnly || doctor.isAvailableToday;
        return matchesSearch && matchesSpecialty && matchesAvailability;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأطباء'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildQuickFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredDoctors.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildDoctorsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterDoctors();
          });
        },
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: '🔍 ابحث عن طبيب...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _filterDoctors();
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  _filterDoctors();
                });
              },
              backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : (isDark ? Colors.grey[400] : Colors.grey[700]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _filteredDoctors.length,
      itemBuilder: (context, index) {
        final doctor = _filteredDoctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                ),
                child: Icon(Icons.person, size: 40, color: isDark ? Colors.grey[600] : Colors.grey[400]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 2),
                            Text(
                              doctor.rating.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' (${doctor.totalReviews})',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${doctor.consultationFee} ﷼',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: doctor.isAvailableToday ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.isAvailableToday ? 'متاح اليوم' : 'غير متاح',
                          style: TextStyle(
                            color: doctor.isAvailableToday ? Colors.green : Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: isDark ? Colors.grey[600] : Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medical_services, size: 80, color: isDark ? Colors.grey[600] : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'لا يوجد أطباء',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'حاول تغيير خيارات البحث أو التصفية',
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تصفية الأطباء',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('الأطباء المتاحون فقط'),
                    value: _showAvailableOnly,
                    onChanged: (value) {
                      setState(() => _showAvailableOnly = value);
                      _filterDoctors();
                      Navigator.pop(context);
                    },
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showAvailableOnly = false;
                          _selectedSpecialty = 'الكل';
                          _searchController.clear();
                          _searchQuery = '';
                          _filterDoctors();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.red.shade100,
                        foregroundColor: isDark ? Colors.white : Colors.red.shade700,
                      ),
                      child: const Text('إعادة تعيين الفلاتر'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToDoctorDetails(DoctorModel doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailsScreen(doctorId: doctor.id),
      ),
    );
  }
}
