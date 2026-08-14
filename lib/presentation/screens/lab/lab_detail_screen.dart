import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/mock/sample_labs.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';

class LabDetailScreen extends StatefulWidget {
  final String labId;
  const LabDetailScreen({super.key, required this.labId});

  @override
  State<LabDetailScreen> createState() => _LabDetailScreenState();
}

class _LabDetailScreenState extends State<LabDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _lab = {};
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLabData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLabData() {
    // ✅ استخدام بيانات المختبرات من الملف المشترك
    final lab = sampleLabs.firstWhere(
      (l) => l['id'] == widget.labId,
      orElse: () => sampleLabs[0],
    );
    setState(() {
      _lab = lab;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_lab['name'] ?? 'مختبر'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black87),
            ),
            onPressed: () => setState(() => _isFavorite = !_isFavorite),
          ),
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نبذة'),
            Tab(text: 'الفحوصات'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDark),
          _buildTestsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نبذة عن المختبر',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  _lab['description'] ?? 'مختبر يقدم خدمات مخبرية متكاملة.',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600], height: 1.6),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.location_on, 'العنوان', _lab['location'] as String? ?? 'صنعاء', isDark),
                _buildInfoRow(Icons.phone, 'الهاتف', _lab['phone'] as String? ?? '+967 1 234 567', isDark),
                _buildInfoRow(Icons.email, 'البريد الإلكتروني', _lab['email'] as String? ?? 'info@lab.com', isDark),
                _buildInfoRow(
                  Icons.access_time,
                  'الحالة',
                  _lab['open'] == true ? 'مفتوح الآن' : 'مغلق',
                  isDark,
                  color: _lab['open'] == true ? Colors.green : Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التقييم',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      _lab['rating'].toString(),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${_lab['reviews']} تقييم)',
                      style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTestsTab(bool isDark) {
    final tests = _lab['tests'] as List<dynamic>? ?? [];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tests.length,
            itemBuilder: (context, index) {
              final test = tests[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    // ✅ الانتقال إلى شاشة الحجز مع تمرير labId و testId
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LabBookingScreen(
                          labId: _lab['id'] as String,
                          testId: test['id'] as String,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.science, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test['name'] as String? ?? 'فحص',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              test['description'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${test['price']} ر.ي',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'حجز',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // ✅ الانتقال إلى شاشة الحجز مع labId فقط (بدون testId محدد)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LabBookingScreen(
                      labId: _lab['id'] as String,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_today, color: Colors.white),
              label: const Text('حجز فحص', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color ?? (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
