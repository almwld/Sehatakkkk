import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class GlucoseTrackerScreen extends StatefulWidget {
  const GlucoseTrackerScreen({super.key});

  @override
  State<GlucoseTrackerScreen> createState() => _GlucoseTrackerScreenState();
}

class _GlucoseTrackerScreenState extends State<GlucoseTrackerScreen> {
  final TextEditingController _glucoseCtrl = TextEditingController();
  String _selectedMeal = 'قبل الفطور';
  bool _isAdding = false;

  final List<String> _mealOptions = [
    'قبل الفطور',
    'بعد الفطور',
    'قبل الغداء',
    'بعد الغداء',
    'قبل العشاء',
    'بعد العشاء',
  ];

  final List<Map<String, dynamic>> _readings = [
    {'meal': 'قبل الفطور', 'value': 95, 'status': 'طبيعي', 'time': '6:30 ص'},
    {'meal': 'بعد الفطور', 'value': 140, 'status': 'مرتفع', 'time': '8:00 ص'},
    {'meal': 'قبل الغداء', 'value': 88, 'status': 'طبيعي', 'time': '12:30 م'},
    {'meal': 'بعد الغداء', 'value': 155, 'status': 'مرتفع', 'time': '2:00 م'},
    {'meal': 'قبل العشاء', 'value': 102, 'status': 'طبيعي', 'time': '6:30 م'},
    {'meal': 'بعد العشاء', 'value': 180, 'status': 'عالي', 'time': '8:00 م'},
  ];

  void _saveReading() {
    if (_glucoseCtrl.text.isEmpty) return;

    setState(() {
      _readings.insert(0, {
        'meal': _selectedMeal,
        'value': int.parse(_glucoseCtrl.text),
        'status': _getStatus(int.parse(_glucoseCtrl.text)),
        'time': '${DateTime.now().hour}:${DateTime.now().minute}',
      });
      _isAdding = false;
      _glucoseCtrl.clear();
    });
  }

  String _getStatus(int value) {
    if (value < 100) return 'طبيعي';
    if (value < 126) return 'مرتفع';
    return 'عالي';
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'طبيعي': return AppColors.success;
      case 'مرتفع': return AppColors.warning;
      case 'عالي': return AppColors.error;
      default: return AppColors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('تتبع السكر', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => setState(() => _isAdding = true),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ المحتوى الرئيسي
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ متوسط السكر التراكمي
                _buildAverageCard(isDark),
                const SizedBox(height: 20),
                // ✅ قراءات اليوم
                _buildReadingsList(isDark),
              ],
            ),
          ),
          // ✅ حقل الإدخال في منتصف الشاشة (عند الضغط على إضافة)
          if (_isAdding) _buildAddReadingDialog(isDark),
        ],
      ),
    );
  }

  Widget _buildAverageCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'متوسط السكر التراكمي',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '7.0%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'مستوى طبيعي',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingsList(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'قراءات اليوم',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._readings.map((reading) => Container(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reading['meal'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        reading['time'],
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(reading['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    reading['status'],
                    style: TextStyle(
                      fontSize: 10,
                      color: _getStatusColor(reading['status']),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${reading['value']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ✅ حقل الإدخال في منتصف الشاشة
  Widget _buildAddReadingDialog(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isAdding = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة قراءة',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedMeal,
                    items: _mealOptions.map((meal) {
                      return DropdownMenuItem<String>(
                        value: meal,
                        child: Text(meal),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedMeal = value!),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _glucoseCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      labelText: 'القراءة (mg/dL)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'المستوى: ${_glucoseCtrl.text.isNotEmpty ? _getStatus(int.parse(_glucoseCtrl.text)) : ''}',
                    style: TextStyle(
                      color: _glucoseCtrl.text.isNotEmpty
                          ? _getStatusColor(_getStatus(int.parse(_glucoseCtrl.text)))
                          : AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => setState(() => _isAdding = false),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveReading,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('حفظ'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
