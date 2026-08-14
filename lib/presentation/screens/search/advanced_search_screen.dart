import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/search_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class AdvancedSearchScreen extends StatefulWidget {
  final String? initialQuery;
  const AdvancedSearchScreen({super.key, this.initialQuery});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SearchService _searchService = SearchService();
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, List<dynamic>> _results = {};
  List<String> _suggestions = [];
  List<String> _searchHistory = [];
  String _selectedCategory = 'الكل';
  String _selectedFilter = 'الكل';
  double _minRating = 0;
  double _maxPrice = 1000;
  bool _showFilters = false;

  final List<String> _categories = ['الكل', 'أطباء', 'صيدليات', 'مختبرات', 'مستشفيات', 'خدمات'];
  final List<String> _filters = ['الكل', 'الأكثر تقييماً', 'الأقرب', 'الأقل سعراً', 'الأعلى سعراً'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _performSearch();
    }
    
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final history = await _searchService.getSearchHistory(user.uid);
      setState(() => _searchHistory = history);
    }
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _searchService.saveSearchHistory(user.uid, query);
      }

      final results = await _searchService.searchAll(query);
      
      setState(() {
        _results = results;
        _isLoading = false;
      });

      final suggestions = await _searchService.getSuggestions(query);
      setState(() => _suggestions = suggestions);

      await _loadSearchHistory();

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _results = {};
      _suggestions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'بحث متقدم',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _performSearch(),
                            onChanged: (value) {
                              if (value.isEmpty) {
                                _clearSearch();
                              } else {
                                _getSuggestions(value);
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'ابحث عن طبيب، صيدلية، مختبر...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _clearSearch,
                          ),
                        IconButton(
                          icon: Icon(
                            Icons.filter_list,
                            color: _showFilters ? AppColors.primary : Colors.grey,
                          ),
                          onPressed: () => setState(() => _showFilters = !_showFilters),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_suggestions.isNotEmpty && _results.isEmpty)
            Container(
              height: 200,
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.search, color: Colors.grey),
                    title: Text(suggestion),
                    onTap: () {
                      _searchController.text = suggestion;
                      _performSearch();
                    },
                  );
                },
              ),
            ),
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16),
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('التصنيف:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((category) {
                              final isSelected = _selectedCategory == category;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCategory = category),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  margin: const EdgeInsets.only(right: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.grey,
                                    ),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.grey,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('التقييم:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            return IconButton(
                              icon: Icon(
                                star <= _minRating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () {
                                setState(() {
                                  _minRating = _minRating == star ? 0 : star.toDouble();
                                });
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('السعر:'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'حتى ${_maxPrice.toInt()} ريال',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              child: Slider(
                                value: _maxPrice,
                                min: 0,
                                max: 10000,
                                divisions: 100,
                                onChanged: (value) => setState(() => _maxPrice = value),
                                activeColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('بحث'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? _buildEmptyState(isDark)
                    : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث عن ما تريد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب كلمة البحث أعلاه',
            style: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          if (_searchHistory.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'عمليات البحث الأخيرة:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._searchHistory.map((query) => ListTile(
                  leading: const Icon(Icons.history, size: 16, color: Colors.grey),
                  title: Text(query, style: const TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    _searchController.text = query;
                    _performSearch();
                  },
                )),
                TextButton(
                  onPressed: _clearSearchHistory,
                  child: const Text('مسح سجل البحث'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'الكل (${_getTotalCount()})'),
                if (_results.containsKey('doctors') && _results['doctors']!.isNotEmpty)
                  Tab(text: 'أطباء (${_results['doctors']!.length})'),
                if (_results.containsKey('pharmacies') && _results['pharmacies']!.isNotEmpty)
                  Tab(text: 'صيدليات (${_results['pharmacies']!.length})'),
                if (_results.containsKey('labs') && _results['labs']!.isNotEmpty)
                  Tab(text: 'مختبرات (${_results['labs']!.length})'),
                if (_results.containsKey('hospitals') && _results['hospitals']!.isNotEmpty)
                  Tab(text: 'مستشفيات (${_results['hospitals']!.length})'),
                if (_results.containsKey('services') && _results['services']!.isNotEmpty)
                  Tab(text: 'خدمات (${_results['services']!.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildAllResults(),
                if (_results.containsKey('doctors') && _results['doctors']!.isNotEmpty)
                  _buildDoctorResults(),
                if (_results.containsKey('pharmacies') && _results['pharmacies']!.isNotEmpty)
                  _buildPharmacyResults(),
                if (_results.containsKey('labs') && _results['labs']!.isNotEmpty)
                  _buildLabResults(),
                if (_results.containsKey('hospitals') && _results['hospitals']!.isNotEmpty)
                  _buildHospitalResults(),
                if (_results.containsKey('services') && _results['services']!.isNotEmpty)
                  _buildServiceResults(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalCount() {
    int count = 0;
    _results.forEach((key, value) {
      count += value.length;
    });
    return count;
  }

  Widget _buildAllResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _getTotalCount(),
      itemBuilder: (context, index) {
        int currentIndex = 0;
        for (final entry in _results.entries) {
          if (index < currentIndex + entry.value.length) {
            final item = entry.value[index - currentIndex];
            return _buildResultCard(item, entry.key);
          }
          currentIndex += entry.value.length;
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildResultCard(dynamic item, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String title = '';
    String subtitle = '';
    IconData icon = Icons.medical_services;
    Color color = Colors.blue;

    switch (type) {
      case 'doctors':
        title = item['name'] ?? '';
        subtitle = item['specialty'] ?? '';
        icon = Icons.local_hospital;
        color = Colors.blue;
        break;
      case 'pharmacies':
        title = item['name'] ?? '';
        subtitle = item['address'] ?? '';
        icon = Icons.local_pharmacy;
        color = Colors.green;
        break;
      case 'labs':
        title = item['name'] ?? '';
        subtitle = item['location'] ?? '';
        icon = Icons.science;
        color = Colors.purple;
        break;
      case 'hospitals':
        title = item['name'] ?? '';
        subtitle = item['location'] ?? '';
        icon = Icons.medical_services;
        color = Colors.red;
        break;
      case 'services':
        title = item['name'] ?? '';
        subtitle = item['category'] ?? '';
        icon = Icons.stars;
        color = Colors.orange;
        break;
    }

    return GestureDetector(
      onTap: () {
        if (type == 'doctors') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DoctorDetailsScreen(
                doctorId: item['id'] ?? '1',
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorResults() {
    final doctors = _results['doctors'] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildResultCard(doctor, 'doctors');
      },
    );
  }

  Widget _buildPharmacyResults() {
    final pharmacies = _results['pharmacies'] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pharmacies.length,
      itemBuilder: (context, index) {
        final pharmacy = pharmacies[index];
        return _buildResultCard(pharmacy, 'pharmacies');
      },
    );
  }

  Widget _buildLabResults() {
    final labs = _results['labs'] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: labs.length,
      itemBuilder: (context, index) {
        final lab = labs[index];
        return _buildResultCard(lab, 'labs');
      },
    );
  }

  Widget _buildHospitalResults() {
    final hospitals = _results['hospitals'] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: hospitals.length,
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        return _buildResultCard(hospital, 'hospitals');
      },
    );
  }

  Widget _buildServiceResults() {
    final services = _results['services'] ?? [];
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildResultCard(service, 'services');
      },
    );
  }

  Future<void> _getSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    final suggestions = await _searchService.getSuggestions(query);
    setState(() => _suggestions = suggestions);
  }

  Future<void> _clearSearchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _searchService.clearSearchHistory(user.uid);
      setState(() => _searchHistory = []);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
