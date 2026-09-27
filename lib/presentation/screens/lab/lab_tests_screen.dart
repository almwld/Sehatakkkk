import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/lab/test_booking_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class LabTestsScreen extends StatefulWidget {
  const LabTestsScreen({super.key});
  @override
  State<LabTestsScreen> createState() => _LabTestsScreenState();
}

class _LabTestsScreenState extends State<LabTestsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _query = '';

  Stream<List<Map<String, dynamic>>> _testsStream() =>
      _firestore.collection('lab_tests').snapshots().map((snapshot) {
        final tests = snapshot.docs
            .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
            .where((test) =>
                test['isActive'] != false && test['isAvailable'] != false)
            .toList();
        tests.sort((a, b) => _text(a['name']).compareTo(_text(b['name'])));
        return tests;
      });

  String _text(dynamic value) => value?.toString().trim() ?? '';
  double _number(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse(_text(value)) ?? 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'فحوصات المختبر',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _testsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _state(
              'تعذر تحميل الفحوصات الحالية. تحقق من الاتصال وحاول مرة أخرى.',
              isDark,
              icon: Icons.error_outline,
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final query = _query.toLowerCase().trim();
          final tests = snapshot.data!.where((test) {
            if (query.isEmpty) return true;
            final haystack = [
              test['name'],
              test['category'],
              test['description'],
              test['sampleType'],
            ].map(_text).join(' ').toLowerCase();
            return haystack.contains(query);
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن فحص أو تخصص...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () => setState(() => _query = ''),
                            icon: const Icon(Icons.clear),
                          ),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: tests.isEmpty
                    ? _state(
                        snapshot.data!.isEmpty
                            ? 'لا توجد فحوصات منشورة حاليًا.'
                            : 'لا توجد نتائج مطابقة للبحث.',
                        isDark,
                        icon: Icons.science_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          if (mounted) setState(() {});
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: tests.length,
                          itemBuilder: (context, index) =>
                              _buildTestCard(tests[index], isDark, context),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _state(String message, bool isDark, {required IconData icon}) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildTestCard(
      Map<String, dynamic> test, bool isDark, BuildContext context) {
    final name = _text(test['name']).isEmpty ? 'فحص طبي' : _text(test['name']);
    final category = _text(test['category']);
    final description = _text(test['description']);
    final sampleType = _text(test['sampleType']);
    final duration = _text(test['turnaroundTime']).isNotEmpty
        ? _text(test['turnaroundTime'])
        : _text(test['duration']);
    final price = _number(test['price']);

    return Card(
      color: isDark ? const Color(0xFF1A2540) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestBookingScreen(testId: _text(test['id'])),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.science_outlined,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (category.isNotEmpty)
                          _badge(category, AppColors.info),
                        if (sampleType.isNotEmpty)
                          _badge(sampleType, AppColors.primary),
                        if (duration.isNotEmpty)
                          _badge(duration, Colors.blueGrey),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      price > 0
                          ? '${price.toStringAsFixed(0)} ريال'
                          : 'السعر حسب المختبر',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: AppColors.primary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
