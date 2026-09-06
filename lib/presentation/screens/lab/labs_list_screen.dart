import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/mock/sample_labs.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/lab/lab_detail_screen.dart';

class LabsListScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const LabsListScreen({super.key, this.scrollController});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  bool _usingDemoData = false;
  List<Map<String, dynamic>> _labs = [];
  late final TabController _tabController;

  final List<String> _categories = const [
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLabs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLabs() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('labs').get();
      final remote = snapshot.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .where((lab) => _string(lab['name']).isNotEmpty)
          .toList();
      final labs = remote.isEmpty
          ? sampleLabs.map((lab) => Map<String, dynamic>.from(lab)).toList()
          : remote;
      _sort(labs);
      if (!mounted) return;
      setState(() {
        _labs = labs;
        _usingDemoData = remote.isEmpty;
        _isLoading = false;
      });
    } catch (_) {
      final labs =
          sampleLabs.map((lab) => Map<String, dynamic>.from(lab)).toList();
      _sort(labs);
      if (!mounted) return;
      setState(() {
        _labs = labs;
        _usingDemoData = true;
        _isLoading = false;
      });
    }
  }

  void _sort(List<Map<String, dynamic>> labs) {
    labs.sort((a, b) => _number(b['rating']).compareTo(_number(a['rating'])));
  }

  String _string(dynamic value) => value?.toString().trim() ?? '';
  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(_string(value)) ?? 0;
  List<dynamic> _list(dynamic value) => value is List ? value : const [];
  bool _bool(dynamic value) => value == true;

  List<Map<String, dynamic>> _filtered({bool home = false, bool top = false}) {
    Iterable<Map<String, dynamic>> result = _labs;
    if (home) result = result.where((lab) => _bool(lab['homeService']));

    if (_selectedCategory != 'الكل') {
      result = result.where((lab) {
        final category = _string(lab['category']);
        final specialties = _list(lab['specialties']);
        return category == _selectedCategory ||
            specialties.any((item) => _string(item) == _selectedCategory);
      });
    }

    final query = _searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((lab) {
        final name = _string(lab['name']).toLowerCase();
        final address =
            _string(lab['address'] ?? lab['location']).toLowerCase();
        final specialties = _list(lab['specialties']);
        final tests = _list(lab['tests']);
        return name.contains(query) ||
            address.contains(query) ||
            specialties.any((item) => _string(item).toLowerCase().contains(query)) ||
            tests.any((item) {
              final name = item is Map ? item['name'] : item;
              return _string(name).toLowerCase().contains(query);
            });
      });
    }

    final list = result.toList();
    _sort(list);
    return top ? list.take(4).toList() : list;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المختبرات'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'الأفضل'),
            Tab(text: 'خدمة منزلية'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Column(
              children: [
                if (_usingDemoData)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    color: AppColors.primary.withOpacity(.08),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'يتم عرض بيانات تجريبية لمختبرات صنعاء إلى أن تتوفر البيانات الفعلية في النظام.',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: TextStyle(color: dark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مختبر، تخصص، أو فحص...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                      filled: true,
                      fillColor: dark ? const Color(0xFF1A2540) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final selected = _selectedCategory == category;
                      return ChoiceChip(
                        label: Text(category),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : (dark ? Colors.white : Colors.black87),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _listView(_filtered(), dark),
                      _listView(_filtered(top: true), dark),
                      _listView(_filtered(home: true), dark),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _listView(List<Map<String, dynamic>> labs, bool dark) {
    if (labs.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.science_outlined,
              size: 64,
              color: dark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'لا توجد نتائج مطابقة للبحث.'
                  : 'لا توجد مختبرات مسجلة حاليًا.',
              style: TextStyle(
                color: dark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLabs,
      child: ListView.builder(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: labs.length,
        itemBuilder: (context, index) {
          final lab = labs[index];
          final image = _string(lab['imageUrl'] ?? lab['image']);
          final tests = _list(lab['tests']);
          return Card(
            color: dark ? const Color(0xFF1A2540) : Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        LabDetailScreen(labId: _string(lab['id'])),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 76,
                      height: 76,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: image.isNotEmpty
                            ? AppImage(imageUrl: image, fit: BoxFit.cover)
                            : Container(
                                color: AppColors.primary.withOpacity(.1),
                                child: const Icon(
                                  Icons.science,
                                  color: AppColors.primary,
                                  size: 34,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _string(lab['name']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: dark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _string(
                              lab['address'] ?? lab['location'] ?? 'صنعاء',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  dark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 17,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _number(lab['rating']).toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: dark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_number(lab['reviews'] ?? lab['reviewsCount']).toInt()} تقييم',
                                style: TextStyle(
                                  color:
                                      dark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              if (tests.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${tests.length} فحص',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
