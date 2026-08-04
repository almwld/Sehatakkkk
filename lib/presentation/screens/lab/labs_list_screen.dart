import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_detail_screen.dart';

class LabsListScreen extends StatefulWidget {
  const LabsListScreen({super.key});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String _selectedSort = 'التقييم';
  bool _isLoading = true;
  List<Map<String, dynamic>> _labs = [];
  late TabController _tabController;

  final List<String> _categories = [
    'الكل',
    'دم',
    'بول',
    'هرمونات',
    'فيتامينات',
    'أشعة',
    'تحاليل عامة',
    'ميكروبيولوجي',
    'جينية',
    'أورام',
  ];

  final List<Map<String, dynamic>> _mockLabs = [
    {
      'id': '1',
      'name': 'مختبرات الذبحاني',
      'category': 'تحاليل عامة',
      'address': 'صنعاء - شارع الأصبحي',
      'rating': 4.9,
      'reviews': 328,
      'phone': '01-234567',
      'image': ImageKit.lab1,
      'open': true,
      'price': '100-500',
      'tests': ['CBC', 'سكر', 'دهون', 'وظائف كبد', 'وظائف كلى'],
      'equipment': ['ميكروسكوب رقمي', 'جهاز تحليل كيميائي', 'جهاز PCR'],
      'specialties': ['تحاليل عامة', 'كيمياء حيوية'],
      'homeService': true,
      'urgent': true,
      'established': '2005',
      'description': 'أحد أقدم المختبرات في صنعاء مع كادر طبي متخصص'
    },
    {
      'id': '2',
      'name': 'مختبرات العولقي',
      'category': 'دم',
      'address': 'صنعاء - شارع الستين',
      'rating': 4.8,
      'reviews': 256,
      'phone': '01-234568',
      'image': ImageKit.lab2,
      'open': true,
      'price': '150-600',
      'tests': ['CBC', 'حديد', 'فيتامين د', 'فيريتين', 'ترانسفيرين'],
      'equipment': ['جهاز تعداد الدم الآلي', 'جهاز تحليل الحديد', 'ميكروسكوب متطور'],
      'specialties': ['أمراض الدم', 'فقر الدم'],
      'homeService': false,
      'urgent': true,
      'established': '2010',
      'description': 'متخصص في تحاليل الدم وأمراض فقر الدم'
    },
    {
      'id': '3',
      'name': 'مختبرات المأمون',
      'category': 'هرمونات',
      'address': 'صنعاء - حدة',
      'rating': 4.7,
      'reviews': 189,
      'phone': '01-234569',
      'image': ImageKit.lab3,
      'open': true,
      'price': '200-800',
      'tests': ['TSH', 'T3', 'T4', 'كورتيزول', 'أنسولين', 'هرمون نمو'],
      'equipment': ['جهاز ELISA', 'جهاز مناعة', 'جهاز هرمونات'],
      'specialties': ['هرمونات', 'غدة درقية', 'سكري'],
      'homeService': true,
      'urgent': false,
      'established': '2008',
      'description': 'متخصص في تحاليل الهرمونات والغدد الصماء'
    },
    {
      'id': '4',
      'name': 'مختبر الرازي',
      'category': 'فيتامينات',
      'address': 'صنعاء - باب اليمن',
      'rating': 4.6,
      'reviews': 89,
      'phone': '01-234570',
      'image': ImageKit.lab1,
      'open': false,
      'price': '100-400',
      'tests': ['فيتامين د', 'فيتامين ب12', 'فيتامين أ', 'فيتامين هـ', 'فيتامين ك'],
      'equipment': ['جهاز HPLC', 'جهاز طيف ضوئي', 'جهاز كروماتوغرافيا'],
      'specialties': ['فيتامينات', 'تغذية', 'مكملات غذائية'],
      'homeService': false,
      'urgent': false,
      'established': '2015',
      'description': 'متخصص في تحاليل الفيتامينات والمعادن'
    },
    {
      'id': '5',
      'name': 'مختبرات النخبة',
      'category': 'دم',
      'address': 'صنعاء - التحرير',
      'rating': 4.5,
      'reviews': 145,
      'phone': '01-234571',
      'image': ImageKit.lab2,
      'open': true,
      'price': '120-550',
      'tests': ['CBC', 'سكر', 'دهون', 'كوليسترول', 'دهون ثلاثية'],
      'equipment': ['جهاز كيمياء آلي', 'جهاز طيف ضوئي', 'جهاز تحليل دهون'],
      'specialties': ['دهون', 'كوليسترول', 'أمراض القلب'],
      'homeService': true,
      'urgent': true,
      'established': '2012',
      'description': 'متخصص في تحاليل الدهون وأمراض القلب'
    },
    {
      'id': '6',
      'name': 'مختبرات اليمن الحديثة',
      'category': 'أشعة',
      'address': 'صنعاء - شارع الزبيري',
      'rating': 4.4,
      'reviews': 112,
      'phone': '01-234572',
      'image': ImageKit.lab3,
      'open': true,
      'price': '200-900',
      'tests': ['أشعة سينية', 'سونار', 'مقطعية', 'رنين مغناطيسي', 'أشعة ملونة'],
      'equipment': ['جهاز أشعة رقمي', 'جهاز سونار 4D', 'جهاز مقطعي محوسب', 'جهاز رنين مغناطيسي'],
      'specialties': ['أشعة', 'سونار', 'تصوير طبي'],
      'homeService': false,
      'urgent': true,
      'established': '2018',
      'description': 'أحدث أجهزة الأشعة والتصوير الطبي في اليمن'
    },
    {
      'id': '7',
      'name': 'مختبرات الجينية المتقدم',
      'category': 'جينية',
      'address': 'صنعاء - حي الجامعة',
      'rating': 4.9,
      'reviews': 234,
      'phone': '01-234573',
      'image': ImageKit.lab1,
      'open': true,
      'price': '300-1200',
      'tests': ['تحليل DNA', 'تحليل كروموسومات', 'فحص جيني', 'تطابق الحمض النووي'],
      'equipment': ['جهاز تسلسل جيني', 'جهاز PCR متقدم', 'جهاز تحليل جيني'],
      'specialties': ['جينات', 'وراثة', 'تحليل DNA'],
      'homeService': false,
      'urgent': false,
      'established': '2020',
      'description': 'أول مختبر جيني متخصص في اليمن'
    },
    {
      'id': '8',
      'name': 'مختبرات الأورام',
      'category': 'أورام',
      'address': 'صنعاء - شارع الستين',
      'rating': 4.8,
      'reviews': 178,
      'phone': '01-234574',
      'image': ImageKit.lab2,
      'open': true,
      'price': '250-1000',
      'tests': ['علامات أورام', 'CA 19-9', 'CA 125', 'AFP', 'CEA', 'PSA'],
      'equipment': ['جهاز مناعة', 'جهاز ELISA', 'جهاز تحليل أورام'],
      'specialties': ['أورام', 'سرطان', 'علامات ورمية'],
      'homeService': true,
      'urgent': true,
      'established': '2016',
      'description': 'متخصص في الكشف المبكر عن الأورام والسرطانات'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLabs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLabs() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    _labs = _mockLabs;
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredLabs {
    var filtered = _labs;
    if (_selectedCategory != 'الكل') {
      filtered = filtered.where((l) => l['category'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((l) =>
        l['name'].contains(_searchQuery) ||
        l['address'].contains(_searchQuery) ||
        l['specialties'].any((s) => s.contains(_searchQuery))
      ).toList();
    }
    // ترتيب حسب التقييم
    filtered.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    return filtered;
  }

  List<Map<String, dynamic>> get _topRatedLabs {
    var list = _labs;
    list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    return list.take(4).toList();
  }

  List<Map<String, dynamic>> get _homeServiceLabs {
    return _labs.where((l) => l['homeService'] == true).toList();
  }

  List<Map<String, dynamic>> get _urgentLabs {
    return _labs.where((l) => l['urgent'] == true).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredLabs;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(' المختبرات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: ' الكل'),
            Tab(text: ' الأفضل'),
            Tab(text: ' خدمة منزلية'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ شريط البحث المدمج
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
                            onChanged: (value) => setState(() => _searchQuery = value),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'ابحث عن مختبر، تخصص، أو فحص...',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: Icon(Icons.clear, size: 18, color: isDark ? Colors.grey[400] : Colors.grey),
                            onPressed: () => setState(() => _searchQuery = ''),
                          ),
                      ],
                    ),
                  ),
                ),
                // ✅ التصنيفات
                Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: FilterChip(
                          label: Text(category, style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedCategory = category),
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
                // ✅ المحتوى حسب التبويب
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // ✅ تبويب الكل
                      filtered.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final lab = filtered[index];
                                return _buildLabCard(lab, isDark);
                              },
                            ),
                      // ✅ تبويب الأفضل
                      _topRatedLabs.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _topRatedLabs.length,
                              itemBuilder: (context, index) {
                                final lab = _topRatedLabs[index];
                                return _buildLabCard(lab, isDark, isTopRated: true);
                              },
                            ),
                      // ✅ تبويب خدمة منزلية
                      _homeServiceLabs.isEmpty
                          ? _buildEmptyState(isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _homeServiceLabs.length,
                              itemBuilder: (context, index) {
                                final lab = _homeServiceLabs[index];
                                return _buildLabCard(lab, isDark, isHomeService: true);
                              },
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLabCard(Map<String, dynamic> lab, bool isDark, {bool isTopRated = false, bool isHomeService = false}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LabDetailScreen(labId: lab['id'] as String),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isTopRated
              ? Border.all(color: Colors.amber, width: 2)
              : (isHomeService ? Border.all(color: Colors.green, width: 1.5) : null),
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
            // ✅ صورة المختبر
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppImage(
                    url: lab['image'],
                    width: 80,
                    height: 80,
                  ),
                ),
                if (isTopRated)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        ' ممتاز',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (lab['urgent'] == true)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '⚡ عاجل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // ✅ معلومات المختبر
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lab['name'],
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
                            lab['rating'].toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            ' (${lab['reviews']})',
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
                  Text(
                    lab['address'],
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // ✅ التخصصات
                  Wrap(
                    spacing: 4,
                    children: (lab['specialties'] as List).take(3).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // ✅ الحالة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: lab['open'] ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: lab['open'] ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lab['open'] ? 'مفتوح' : 'مغلق',
                              style: TextStyle(
                                color: lab['open'] ? Colors.green : Colors.red,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // ✅ خدمة منزلية
                      if (lab['homeService'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.home, size: 10, color: Colors.green),
                              const SizedBox(width: 2),
                              Text(
                                'منزلي',
                                style: TextStyle(
                                  color: Colors.green,
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lab['price'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.science_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مختبرات',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب تغيير البحث أو التصنيف',
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
                _selectedCategory = 'الكل';
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

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String tempSearch = '';
        return AlertDialog(
          title: const Text('🔍 البحث عن مختبر'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => tempSearch = value,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'ابحث بالاسم، التخصص، أو الفحص...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                ' ابحث عن أفضل المختبرات في منطقتك',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _searchQuery = tempSearch);
                Navigator.pop(context);
              },
              child: const Text('بحث'),
            ),
          ],
        );
      },
    );
  }
}
