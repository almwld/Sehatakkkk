import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/lab/lab_booking_model.dart';
import 'package:sehatak/core/models/lab/sample_collection_method.dart';
import 'package:sehatak/core/services/lab_service.dart';

class LabBookingScreen extends StatefulWidget {
  final String? consultationId;
  final String? labId;
  final String? testId;

  const LabBookingScreen({
    super.key,
    this.consultationId,
    this.labId,
    this.testId,
  });

  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

class _LabBookingScreenState extends State<LabBookingScreen> {
  final LabService _labService = LabService();
  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _patientPhoneController = TextEditingController();
  final TextEditingController _patientAddressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  SampleCollectionMethod _collectionMethod = SampleCollectionMethod.atLab;
  List<Map<String, dynamic>> _selectedTests = [];
  bool _isLoading = false;
  bool _isSuccess = false;

  // ✅ بيانات الفحوصات
  final List<Map<String, dynamic>> _availableTests = [
    {'id': 't1', 'name': 'CBC', 'price': 150},
    {'id': 't2', 'name': 'سكر الدم', 'price': 100},
    {'id': 't3', 'name': 'دهون ثلاثية', 'price': 120},
    {'id': 't4', 'name': 'فيتامين د', 'price': 250},
    {'id': 't5', 'name': 'وظائف الكبد', 'price': 180},
    {'id': 't6', 'name': 'وظائف الكلى', 'price': 160},
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientData();
    
    // ✅ إذا تم تمرير testId، تحديده تلقائياً
    if (widget.testId != null) {
      final test = _availableTests.firstWhere(
        (t) => t['id'] == widget.testId,
        orElse: () => _availableTests.first,
      );
      _selectedTests.add(test);
    }
  }

  Future<void> _loadPatientData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _patientNameController.text = user.displayName ?? '';
      _patientPhoneController.text = user.phoneNumber ?? '';
    }
  }

  double get _totalPrice {
    double total = 0;
    for (var test in _selectedTests) {
      total += test['price'] as double;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('حجز مختبر'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isSuccess
              ? _buildSuccessScreen(isDark)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildPatientInfo(isDark),
                      const SizedBox(height: 16),
                      _buildTestsSelection(isDark),
                      const SizedBox(height: 16),
                      _buildCollectionMethod(isDark),
                      const SizedBox(height: 16),
                      _buildNotes(isDark),
                      const SizedBox(height: 16),
                      _buildSubmitButton(isDark),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSuccessScreen(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            '✅ تم الحجز بنجاح!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم التواصل معك قريباً',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('العودة'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('معلومات المريض', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
          TextField(
            controller: _patientNameController,
            decoration: const InputDecoration(labelText: 'اسم المريض'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _patientPhoneController,
            decoration: const InputDecoration(labelText: 'رقم الهاتف'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _patientAddressController,
            decoration: const InputDecoration(labelText: 'العنوان (اختياري)'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestsSelection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('الفحوصات المطلوبة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
          ..._availableTests.map((test) {
            final isSelected = _selectedTests.contains(test);
            return CheckboxListTile(
              value: isSelected,
              onChanged: (_) {
                setState(() {
                  if (isSelected) {
                    _selectedTests.remove(test);
                  } else {
                    _selectedTests.add(test);
                  }
                });
              },
              title: Text(test['name'] as String),
              subtitle: Text('${test['price']} ريال'),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
            );
          }).toList(),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '${_totalPrice.toStringAsFixed(0)} ريال',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionMethod(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('طريقة جمع العينة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('في المختبر'),
                  selected: _collectionMethod == SampleCollectionMethod.atLab,
                  onSelected: (_) => setState(() => _collectionMethod = SampleCollectionMethod.atLab),
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[200],
                  labelStyle: TextStyle(
                    color: _collectionMethod == SampleCollectionMethod.atLab 
                        ? Colors.white 
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text('في المنزل'),
                  selected: _collectionMethod == SampleCollectionMethod.atHome,
                  onSelected: (_) => setState(() => _collectionMethod = SampleCollectionMethod.atHome),
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[200],
                  labelStyle: TextStyle(
                    color: _collectionMethod == SampleCollectionMethod.atHome 
                        ? Colors.white 
                        : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
            ],
          ),
          if (_collectionMethod == SampleCollectionMethod.atHome)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'سيتم إرسال فريق لأخذ العينة من المنزل',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotes(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: const InputDecoration(
          labelText: 'ملاحظات إضافية (اختياري)',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _selectedTests.isEmpty ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: _selectedTests.isEmpty ? Colors.grey : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _selectedTests.isEmpty 
              ? 'اختر فحصاً أولاً' 
              : 'تأكيد الحجز (${_totalPrice.toStringAsFixed(0)} ريال)',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (_patientNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم المريض'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_patientPhoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });

      // ✅ إظهار رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم حجز المختبر بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
