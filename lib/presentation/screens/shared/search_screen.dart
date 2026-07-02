import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _isSearching = false;
  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _recentSearches = [];

  final List<String> _filters = ['الكل', 'أطباء', 'صيدليات', 'مختبرات', 'خدمات'];

  final List<Map<String, dynamic>> _popularSearches = [
    {'icon': Icons.medical_services_rounded, 'label': 'أطباء باطنية', 'color': AppColors.primary},
    {'icon': Icons.local_pharmacy_rounded, 'label': 'صيدلية 24 ساعة', 'color': AppColors.success},
    {'icon': Icons.science_rounded, 'label': 'تحاليل الدم', 'color': AppColors.purple},
    {'icon': Icons.favorite_rounded, 'label': 'تتبع السكر', 'color': AppColors.pink},
  ];

  final List<Map<String, dynamic>> _categories = [
    {'icon': Icons.medical_services_rounded, 'label': 'الأطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': Icons.local_pharmacy_rounded, 'label': 'الصيدلية', 'color': AppColors.success, 'screen': const PharmacyScreen()},
    {'icon': Icons.science_rounded, 'label': 'المختبرات', 'color': AppColors.purple, 'screen': const LabsListScreen()},
    {'icon': Icons.map_rounded, 'label': 'المرافق الصحية', 'color': AppColors.info, 'screen': const Placeholder()},
    {'icon': Icons.emergency_rounded, 'label': 'الطوارئ', 'color': AppColors.error, 'screen': const Placeholder()},
    {'icon': Icons.favorite_rounded, 'label': 'الصحة', 'color': AppColors.pink, 'screen': const Placeholder()},
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    // ✅ محاكاة جلب البحث الأخير (سيتم ربطه بـ SharedPreferences لاحقاً)
    _recentSearches = [
      {'query': 'د. أحمد', 'time': 'منذ 5 دقائق'},
      {'query': 'صيدلية اليمن', 'time': 'منذ ساعة'},
      {'query': 'تحليل سكر', 'time': 'منذ 3 ساعات'},
    ];
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _results = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchQuery = query;
    });

    final results = <Map<String, dynamic>>[];

    // ✅ البحث في الأطباء
    try {
      final doctorsSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(5)
          .get();

      for (final doc in doctorsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        results.add({
          'type': 'طبيب',
          'id': doc.id,
          'name': data['name'] ?? 'طبيب',
          'subtitle': data['specialty'] ?? 'طبيب عام',
          'icon': Icons.medical_services_rounded,
          'color': AppColors.primary,
          'data': data,
        });
      }
    } catch (e) {
      print('⚠️ Error searching doctors: $e');
    }

    // ✅ البحث في الصيدليات (محاكاة)
    // يمكن إضافة بحث حقيقي من Firestore لاحقاً

    setState(() => _results = results);
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _results = [];
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              const Icon(Icons.search_rounded, color: AppColors.grey, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  onChanged: _performSearch,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن أطباء، صيدليات، خدمات...',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isSearching) {
      return _buildResults(isDark);
    }

    if (_searchQuery.isNotEmpty) {
      return _buildResults(isDark);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ البحث الأخير
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'البحث الأخير',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('مسح الكل', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._recentSearches.map((search) => GestureDetector(
              onTap: () {
                _searchController.text = search['query'];
                _performSearch(search['query']);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? const Color(0xFF2D3A54) : Colors.grey.shade100,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.history_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        search['query'],
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    Text(
                      search['time'],
                      style: TextStyle(fontSize: 11, color: AppColors.grey),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 24),
          ],

          // ✅ الأكثر بحثاً
          const Text(
            'الأكثر بحثاً',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _popularSearches.map((item) {
              final color = item['color'] as Color;
              return GestureDetector(
                onTap: () {
                  _searchController.text = item['label'] as String;
                  _performSearch(item['label'] as String);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item['icon'] as IconData, color: color, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        item['label'] as String,
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ✅ التصنيفات
          const Text(
            'التصنيفات',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final color = category['color'] as Color;
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => category['screen'] as Widget,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        category['label'] as String,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    if (_results.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'لم نعثر على أي نتائج لـ "$_searchQuery"',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        final color = result['color'] as Color;
        final icon = result['icon'] as IconData;

        return GestureDetector(
          onTap: () {
            if (result['type'] == 'طبيب') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailsScreen(
                    doctorId: result['id'],
                  ),
                ),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        result['subtitle'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    result['type'],
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
