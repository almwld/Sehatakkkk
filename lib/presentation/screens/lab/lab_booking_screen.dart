import package:sehatak/core/models/lab/sample_collection_method.dart;
import package:sehatak/core/models/lab/sample_collection_method.dart;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/lab_booking_model.dart';
import 'package:sehatak/core/services/lab_service.dart';

class LabBookingScreen extends StatefulWidget {
  final String? consultationId;
  final String? labId;
  const LabBookingScreen({super.key, this.consultationId, this.labId});

  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

class _LabBookingScreenState extends State<LabBookingScreen> {
  final LabService _labService = LabService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  bool _isLoading = false;
  SampleCollectionMethod _collectionMethod = SampleCollectionMethod.atLab;
  List<Map<String, dynamic>> _selectedTests = [];
  String? _selectedLabId;
  String _selectedLabName = '';
  String _selectedLabAddress = '';
  double _totalPrice = 0;

  // ✅ الفحوصات المتاحة
  final List<Map<String, dynamic>> _availableTests = [
    {'id': 't1', 'name': 'تعداد دم كامل (CBC)', 'price': 150, 'category': 'دم', 'description': 'تقييم صحة الدم والخلايا'},
    {'id': 't2', 'name': 'السكر التراكمي (HbA1c)', 'price': 200, 'category': 'سكر', 'description': 'متوسط السكر في 3 أشهر'},
    {'id': 't3', 'name': 'وظائف الكبد', 'price': 180, 'category': 'كبد', 'description': 'فحص إنزيمات الكبد'},
    {'id': 't4', 'name': 'وظائف الكلى', 'price': 160, 'category': 'كلى', 'description': 'فحص وظائف الكلى'},
    {'id': 't5', 'name': 'فيتامين د', 'price': 250, 'category': 'فيتامينات', 'description': 'قياس مستوى فيتامين د'},
    {'id': 't6', 'name': 'الهرمونات الدرقية (TSH)', 'price': 220, 'category': 'هرمونات', 'description': 'فحص الغدة الدرقية'},
    {'id': 't7', 'name': 'فيتامين ب12', 'price': 180, 'category': 'فيتامينات', 'description': 'قياس مستوى فيتامين ب12'},
    {'id': 't8', 'name': 'الحديد', 'price': 130, 'category': 'دم', 'description': 'قياس مستوى الحديد في الدم'},
    {'id': 't9', 'name': 'الكالسيوم', 'price': 120, 'category': 'دم', 'description': 'قياس مستوى الكالسيوم'},
    {'id': 't10', 'name': 'الدهون الثلاثية', 'price': 140, 'category': 'دهون', 'description': 'قياس نسبة الدهون الثلاثية'},
  ];

  // ✅ المختبرات المتاحة
  final List<Map<String, dynamic>> _availableLabs = [
    {'id': 'lab1', 'name': 'مختبرات الذبحاني', 'address': 'صنعاء - شارع الأصبحي', 'rating': 4.9, 'phone': '01-234567'},
    {'id': 'lab2', 'name': 'مختبرات العولقي', 'address': 'صنعاء - شارع الستين', 'rating': 4.8, 'phone': '01-234568'},
    {'id': 'lab3', 'name': 'مختبرات المأمون', 'address': 'صنعاء - حدة', 'rating': 4.7, 'phone': '01-234569'},
    {'id': 'lab4', 'name': 'مختبر الرازي', 'address': 'صنعاء - باب اليمن', 'rating': 4.6, 'phone': '01-234570'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.labId != null) {
      final lab = _availableLabs.firstWhere(
        (l) => l['id'] == widget.labId,
        orElse: () => _availableLabs.first,
      );
      _selectedLabId = lab['id'];
      _selectedLabName = lab['name'];
      _selectedLabAddress = lab['address'];
    }
  }

  void _selectLab(String labId) {
    final lab = _availableLabs.firstWhere((l) => l['id'] == labId);
    setState(() {
      _selectedLabId = labId;
      _selectedLabName = lab['name'];
      _selectedLabAddress = lab['address'];
    });
  }

  void _toggleTest(Map<String, dynamic> test) {
    setState(() {
      final index = _selectedTests.indexWhere((t) => t['id'] == test['id']);
      if (index != -1) {
        _selectedTests.removeAt(index);
      } else {
        _selectedTests.add(test);
      }
      _totalPrice = _selectedTests.fold(0.0, (sum, t) => sum + (t['price'] as double));
    });
  }

  Future<void> _submitBooking() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تسجيل الدخول')),
      );
      return;
    }

    if (_selectedTests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار الفحوصات')),
      );
      return;
    }

    if (_selectedLabId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار المختبر')),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف')),
      );
      return;
    }

    if (_collectionMethod == SampleCollectionMethod.atHome && 
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال عنوان المنزل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final booking = await _labService.createLabBooking(
        consultationId: widget.consultationId ?? '',
        patientId: user.uid,
        patientName: user.displayName ?? 'مستخدم',
        patientPhone: _phoneController.text.trim(),
        patientAddress: _collectionMethod == SampleCollectionMethod.atHome 
            ? _addressController.text.trim() 
            : null,
        labId: _selectedLabId!,
        labName: _selectedLabName,
        labAddress: _selectedLabAddress,
        tests: _selectedTests,
        totalPrice: _totalPrice,
        collectionMethod: _collectionMethod,
        notes: _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم حجز الفحوصات بنجاح! رقم الحجز: #${booking.id.substring(0, 8)}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('حجز فحوصات مختبر'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ اختيار المختبر
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر المختبر',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._availableLabs.map((lab) {
                    final isSelected = _selectedLabId == lab['id'];
                    return GestureDetector(
                      onTap: () => _selectLab(lab['id']),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : (isDark ? const Color(0xFF0B1121) : Colors.grey.shade50),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lab['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    lab['address'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 12, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${lab['rating']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        lab['phone'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ اختيار الفحوصات
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'اختر الفحوصات',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_selectedTests.length} فحص',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._availableTests.map((test) {
                    final isSelected = _selectedTests.any((t) => t['id'] == test['id']);
                    return GestureDetector(
                      onTap: () => _toggleTest(test),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    test['name'],
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    test['description'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${test['price']} ر.ي',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : Colors.grey,
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 16,
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${_totalPrice.toStringAsFixed(0)} ر.ي',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ طريقة جمع العينة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'طريقة جمع العينة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCollectionOption(
                          label: 'زيارة المختبر',
                          icon: Icons.directions_walk,
                          method: SampleCollectionMethod.atLab,
                          isSelected: _collectionMethod == SampleCollectionMethod.atLab,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCollectionOption(
                          label: 'أخذ عينة للمنزل',
                          icon: Icons.home_work,
                          method: SampleCollectionMethod.atHome,
                          isSelected: _collectionMethod == SampleCollectionMethod.atHome,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildCollectionOption(
                          label: 'في العيادة',
                          icon: Icons.local_hospital,
                          method: SampleCollectionMethod.atLab,
                          isSelected: _collectionMethod == SampleCollectionMethod.atLab,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  if (_collectionMethod == SampleCollectionMethod.atHome) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addressController,
                      maxLines: 2,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'أدخل عنوان المنزل',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ معلومات التواصل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'معلومات التواصل',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'رقم الهاتف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'ملاحظات إضافية (اختياري)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ زر تأكيد الحجز
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'تأكيد الحجز',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionOption({
    required String label,
    required IconData icon,
    required SampleCollectionMethod method,
    required bool isSelected,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _collectionMethod = method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
