import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SymptomCheckerScreen extends StatefulWidget {
  const SymptomCheckerScreen({super.key});

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final List<String> _commonSymptoms = [
    'صداع',
    'حمى',
    'سعال',
    'ضيق تنفس',
    'ألم في الصدر',
    'غثيان',
    'دوخة',
    'تعب',
    'ألم عضلي',
    'احتقان أنف',
    'تهاب الحلق',
    'فقدان حاسة الشم',
    'فقدان حاسة التذوق',
    'إسهال',
    'قيء',
    'ألم في البطن',
  ];

  final List<Map<String, dynamic>> _bodyParts = [
    {'name': 'الرأس', 'icon': Icons.face, 'color': Colors.blue},
    {'name': 'الصدر', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'البطن', 'icon': Icons.circle, 'color': Colors.orange},
    {'name': 'الظهر', 'icon': Icons.person, 'color': Colors.purple},
    {'name': 'الأطراف', 'icon': Icons.fitness_center, 'color': Colors.green},
  ];

  final List<Map<String, dynamic>> _severities = [
    {'label': 'خفيف', 'color': Colors.green, 'value': 1},
    {'label': 'متوسط', 'color': Colors.orange, 'value': 2},
    {'label': 'شديد', 'color': Colors.red, 'value': 3},
  ];

  List<String> _selectedSymptoms = [];
  Map<String, int> _symptomSeverity = {};
  int? _selectedBodyPart;
  String? _selectedSeverity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('فحص الأعراض 🩺'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          if (_selectedSymptoms.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                setState(() {
                  _selectedSymptoms.clear();
                  _symptomSeverity.clear();
                });
                ToastService.showSuccess('✅ تم مسح جميع الأعراض');
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ العناوين
            Text(
              'اختر منطقة الجسم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            // ✅ أجزاء الجسم
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _bodyParts.length,
                itemBuilder: (context, index) {
                  final part = _bodyParts[index];
                  final isSelected = _selectedBodyPart == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBodyPart = index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (part['color'] as Color)
                            : (isDark ? const Color(0xFF1A2540) : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? (part['color'] as Color)
                              : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            part['icon'] as IconData,
                            color: isSelected ? Colors.white : (part['color'] as Color),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            part['name'],
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            // ✅ الأعراض الشائعة
            Text(
              'الأعراض الشائعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اختر الأعراض التي تشعر بها',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonSymptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                        _symptomSeverity[symptom] = 2;
                      } else {
                        _selectedSymptoms.remove(symptom);
                        _symptomSeverity.remove(symptom);
                      }
                    });
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey.shade100,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.grey.shade300 : Colors.black87),
                  ),
                );
              }).toList(),
            ),
            if (_selectedSymptoms.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'شدة الأعراض',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // ✅ اختيار شدة الأعراض
              ..._selectedSymptoms.map((symptom) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2540) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: _severities.map((severity) {
                          final isSelected = _symptomSeverity[symptom] == severity['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _symptomSeverity[symptom] = severity['value'] as int;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? severity['color'] as Color
                                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    severity['label'] as String,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showAnalysisResult();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تحليل الأعراض',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            // ✅ نصائح سريعة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        'نصائح سريعة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._getQuickTips().map((tip) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 14)),
                          Expanded(
                            child: Text(
                              tip,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<String> _getQuickTips() {
    return [
      'احصل على قسط كافٍ من النوم (7-8 ساعات)',
      'اشرب 8 أكواب من الماء يومياً',
      'تناول وجبات صحية متوازنة',
      'مارس الرياضة بانتظام',
      'تجنب التوتر والقلق',
    ];
  }

  void _showAnalysisResult() {
    final severityCount = _symptomSeverity.values.where((v) => v >= 2).length;
    final hasSevere = _symptomSeverity.values.any((v) => v >= 3);
    
    String result;
    String advice;
    Color color;

    if (hasSevere) {
      result = '⚠️ حالة تستدعي الانتباه';
      advice = 'يُنصح بزيارة الطبيب فوراً لتقييم حالتك الصحية بشكل دقيق.';
      color = Colors.red;
    } else if (severityCount >= 3) {
      result = '🟡 حالة متوسطة';
      advice = 'نوصي بمراجعة الطبيب قريباً، مع متابعة الأعراض عن كثب.';
      color = Colors.orange;
    } else if (_selectedSymptoms.isNotEmpty) {
      result = '🟢 حالة خفيفة';
      advice = 'يمكنك تجربة الراحة وشرب السوائل، ومراقبة الأعراض.';
      color = Colors.green;
    } else {
      result = '💚 لا توجد أعراض';
      advice = 'أنت بحالة جيدة! استمر في الحفاظ على صحتك.';
      color = Colors.blue;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.analytics, color: color),
            const SizedBox(width: 8),
            Text(result),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              advice,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'الأعراض المحددة: ${_selectedSymptoms.join('، ')}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ToastService.showSuccess('📋 تم حفظ تحليل الأعراض');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ التقرير'),
          ),
        ],
      ),
    );
  }
}
