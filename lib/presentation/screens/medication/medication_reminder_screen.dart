import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  bool _isAdding = false;

  // ✅ قائمة الأدوية
  final List<Map<String, dynamic>> _medications = [
    {
      'name': 'أملوديبين',
      'dose': '5mg',
      'frequency': 'يومياً',
      'time': '8:00 ص',
      'remaining': '25/30',
      'icon': Icons.medication,
      'color': AppColors.primary,
    },
    {
      'name': 'أوميبازول',
      'dose': '40mg',
      'frequency': 'قبل الأكل',
      'time': '9:00 ص',
      'remaining': '8/14',
      'icon': Icons.medication,
      'color': AppColors.warning,
    },
    {
      'name': 'فيتامين د',
      'dose': '1000IU',
      'frequency': 'أحد/أربعاء/جمعة',
      'time': '2:00 م',
      'remaining': '45/60',
      'icon': Icons.medication,
      'color': AppColors.success,
    },
    {
      'name': 'سيستريزين',
      'dose': '10mg',
      'frequency': 'عند اللزوم',
      'time': '10:00 م',
      'remaining': '12/20',
      'icon': Icons.medication,
      'color': AppColors.purple,
    },
  ];

  // ✅ متغيرات الإضافة
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _doseCtrl = TextEditingController();
  final TextEditingController _remainingCtrl = TextEditingController();
  String _selectedFrequency = 'يومياً';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  Color _selectedColor = AppColors.primary;

  final List<String> _frequencyOptions = [
    'يومياً',
    'مرتين يومياً',
    'ثلاث مرات يومياً',
    'أسبوعياً',
    'عند اللزوم',
    'قبل الأكل',
    'بعد الأكل',
  ];

  final List<Color> _colorOptions = [
    AppColors.primary,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
    AppColors.purple,
    AppColors.info,
    AppColors.pink,
    AppColors.orange,
  ];

  void _saveMedication() {
    if (_nameCtrl.text.isEmpty || _doseCtrl.text.isEmpty) return;

    setState(() {
      _medications.insert(0, {
        'name': _nameCtrl.text,
        'dose': _doseCtrl.text,
        'frequency': _selectedFrequency,
        'time': _selectedTime.format(context),
        'remaining': _remainingCtrl.text.isNotEmpty ? _remainingCtrl.text : '0/0',
        'icon': Icons.medication,
        'color': _selectedColor,
      });
      _isAdding = false;
      _nameCtrl.clear();
      _doseCtrl.clear();
      _remainingCtrl.clear();
    });
  }

  void _showAddDialog() {
    _nameCtrl.clear();
    _doseCtrl.clear();
    _remainingCtrl.clear();
    _selectedFrequency = 'يومياً';
    _selectedTime = const TimeOfDay(hour: 8, minute: 0);
    _selectedColor = AppColors.primary;
    setState(() => _isAdding = true);
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('تذكير الأدوية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ✅ جرعات اليوم
                _buildDailyProgress(),
                const SizedBox(height: 20),
                // ✅ قائمة الأدوية
                ..._medications.map((med) => _buildMedicationCard(med, isDark)),
                const SizedBox(height: 20),
                // ✅ زر إضافة دواء
                _buildAddButton(),
              ],
            ),
          ),
          // ✅ نافذة إضافة دواء (في منتصف الشاشة)
          if (_isAdding) _buildAddMedicationDialog(isDark),
        ],
      ),
    );
  }

  Widget _buildDailyProgress() {
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
            'جرعات اليوم',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '4/4',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(Map<String, dynamic> med, bool isDark) {
    final color = med['color'] as Color;
    final icon = med['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF2D3A54) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // ✅ أيقونة الدواء
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          // ✅ معلومات الدواء
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${med['dose']} • ${med['frequency']}',
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          // ✅ الوقت والجرعة المتبقية
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  med['time'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'متبقي: ${med['remaining']}',
                style: TextStyle(fontSize: 11, color: AppColors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'إضافة دواء',
          style: TextStyle(fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ✅ نافذة إضافة دواء (في منتصف الشاشة)
  Widget _buildAddMedicationDialog(bool isDark) {
    return GestureDetector(
      onTap: () => setState(() => _isAdding = false),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'إضافة دواء جديد',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ✅ اسم الدواء
                    TextField(
                      controller: _nameCtrl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'اسم الدواء',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medication),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ الجرعة
                    TextField(
                      controller: _doseCtrl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'الجرعة (مثال: 5mg)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ التكرار
                    DropdownButtonFormField<String>(
                      value: _selectedFrequency,
                      items: _frequencyOptions.map((freq) {
                        return DropdownMenuItem<String>(
                          value: freq,
                          child: Text(freq),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedFrequency = value!),
                      decoration: const InputDecoration(
                        labelText: 'التكرار',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ اختيار الوقت (زر مع الوقت المكتوب)
                    GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ الكمية المتبقية
                    TextField(
                      controller: _remainingCtrl,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        labelText: 'المتبقي (مثال: 25/30)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ✅ اختيار اللون
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _colorOptions.map((color) {
                        final isSelected = _selectedColor == color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedColor = color),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: color.withOpacity(0.4),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
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
                            onPressed: _saveMedication,
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
      ),
    );
  }
}
