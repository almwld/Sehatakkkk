import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/mock/sample_labs.dart';

class LabBookingScreen extends StatefulWidget {
  final String labId;
  final String? testId;

  const LabBookingScreen({
    super.key,
    required this.labId,
    this.testId,
  });

  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

class _LabBookingScreenState extends State<LabBookingScreen> {
  Map<String, dynamic> _lab = {};
  List<Map<String, dynamic>> _availableTests = [];
  List<Map<String, dynamic>> _selectedTests = [];
  bool _isLoading = true;
  String? _selectedTestId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // ✅ البحث عن المختبر من البيانات المشتركة
    final lab = sampleLabs.firstWhere(
      (l) => l['id'] == widget.labId,
      orElse: () => sampleLabs[0],
    );
    
    setState(() {
      _lab = lab;
      _availableTests = List<Map<String, dynamic>>.from(lab['tests'] ?? []);
      
      // ✅ إذا تم تمرير testId، حدد هذا الفحص تلقائياً
      if (widget.testId != null) {
        _selectedTestId = widget.testId;
        final test = _availableTests.firstWhere(
          (t) => t['id'] == widget.testId,
          orElse: () => {},
        );
        if (test.isNotEmpty && !_selectedTests.contains(test)) {
          _selectedTests.add(test);
        }
      }
      
      _isLoading = false;
    });
  }

  // ✅ حساب السعر الإجمالي بطريقة آمنة
  double get _totalPrice {
    double total = 0;
    for (var test in _selectedTests) {
      // استخدام num بدلاً من double لتجنب TypeError
      total += (test['price'] as num).toDouble();
    }
    return total;
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
      appBar: CustomAppBar(
        title: 'حجز فحص',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ معلومات المختبر
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Icon(Icons.science, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lab['name'] ?? 'مختبر',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _lab['location'] ?? 'صنعاء',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _lab['open'] == true ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _lab['open'] == true ? 'مفتوح' : 'مغلق',
                    style: TextStyle(
                      fontSize: 10,
                      color: _lab['open'] == true ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ✅ قائمة الفحوصات
          Expanded(
            child: _availableTests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.science, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد فحوصات متاحة',
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _availableTests.length,
                    itemBuilder: (context, index) {
                      final test = _availableTests[index];
                      final isSelected = _selectedTests.contains(test);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2540) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedTests.remove(test);
                              } else {
                                _selectedTests.add(test);
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isSelected ? Icons.check_circle : Icons.science,
                                  color: isSelected ? AppColors.primary : AppColors.primary,
                                  size: 24,
                                ),
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
                              Text(
                                '${test['price']} ر.ي',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          // ✅ زر الحجز والإجمالي
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_totalPrice.toStringAsFixed(0)} ر.ي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${_selectedTests.length} فحص',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: ElevatedButton(
                    onPressed: _selectedTests.isEmpty
                        ? null
                        : () {
                            _bookAppointment();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: const Text(
                      'تأكيد الحجز',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _bookAppointment() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('جاري الحجز...'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('يتم تأكيد حجز الفحوصات...'),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ToastService.showSuccess(context, '✅ تم حجز الفحوصات بنجاح!');
      Navigator.pop(context);
    });
  }
}
