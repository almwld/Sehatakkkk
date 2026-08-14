import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WeightTrackerScreen extends StatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  State<WeightTrackerScreen> createState() => _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends State<WeightTrackerScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  List<Map<String, dynamic>> _weightHistory = [];
  double _currentWeight = 0;
  double _targetWeight = 0;
  double _initialWeight = 0;
  bool _isLoading = true;
  String _selectedPeriod = 'أسبوع';

  final List<String> _periods = ['أسبوع', 'شهر', '3 أشهر', 'سنة'];

  @override
  void initState() {
    super.initState();
    _loadWeightData();
  }

  Future<void> _loadWeightData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('weight_history') ?? '';
    final target = prefs.getDouble('target_weight') ?? 70.0;
    final initial = prefs.getDouble('initial_weight') ?? 75.0;

    if (historyJson.isNotEmpty) {
      try {
        _weightHistory = List<Map<String, dynamic>>.from(
          historyJson.split('|').map((item) {
            final parts = item.split(',');
            return {
              'weight': double.parse(parts[0]),
              'date': DateTime.parse(parts[1]),
              'note': parts.length > 2 ? parts[2] : '',
            };
          }),
        );
        _weightHistory.sort((a, b) => a['date'].compareTo(b['date']));
      } catch (e) {
        _weightHistory = [];
      }
    }

    _targetWeight = target;
    _initialWeight = initial;
    _currentWeight = _weightHistory.isNotEmpty ? _weightHistory.last['weight'] : initial;

    setState(() => _isLoading = false);
  }

  Future<void> _saveWeightData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyStr = _weightHistory.map((item) {
      return '${item['weight']},${item['date'].toIso8601String()},${item['note'] ?? ''}';
    }).join('|');
    await prefs.setString('weight_history', historyStr);
    await prefs.setDouble('target_weight', _targetWeight);
    await prefs.setDouble('initial_weight', _initialWeight);
  }

  void _addWeight() {
    if (_weightController.text.isEmpty) return;

    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال وزن صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _weightHistory.add({
        'weight': weight,
        'date': DateTime.now(),
        'note': _noteController.text.trim(),
      });
      _currentWeight = weight;
      _weightHistory.sort((a, b) => a['date'].compareTo(b['date']));
    });

    _weightController.clear();
    _noteController.clear();
    _saveWeightData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم تسجيل الوزن: $weight كجم'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteWeight(int index) {
    setState(() {
      _weightHistory.removeAt(index);
      if (_weightHistory.isNotEmpty) {
        _currentWeight = _weightHistory.last['weight'];
      } else {
        _currentWeight = _initialWeight;
      }
    });
    _saveWeightData();
  }

  void _setTargetWeight() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _targetWeight.toString());
        return AlertDialog(
          title: 'الوزن المستهدف',
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'الوزن المستهدف (كجم)',
              prefixIcon: Icon(Icons.fitness_center),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final weight = double.tryParse(controller.text);
                if (weight != null && weight > 0) {
                  setState(() => _targetWeight = weight);
                  _saveWeightData();
                }
                Navigator.pop(context);
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  List<FlSpot> _getWeightSpots() {
    final now = DateTime.now();
    final filtered = _weightHistory.where((item) {
      final diff = now.difference(item['date']).inDays;
      switch (_selectedPeriod) {
        case 'أسبوع':
          return diff <= 7;
        case 'شهر':
          return diff <= 30;
        case '3 أشهر':
          return diff <= 90;
        case 'سنة':
          return diff <= 365;
        default:
          return true;
      }
    }).toList();

    if (filtered.isEmpty) return [];

    final minWeight = filtered.map((e) => e['weight'] as double).reduce((a, b) => a < b ? a : b);
    final maxWeight = filtered.map((e) => e['weight'] as double).reduce((a, b) => a > b ? a : b);
    final range = maxWeight - minWeight;

    return filtered.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final weight = item['weight'] as double;
      final normalizedY = range > 0 ? (weight - minWeight) / range : 0.5;
      return FlSpot(index.toDouble(), normalizedY);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = _initialWeight > 0
        ? ((_initialWeight - _currentWeight) / (_initialWeight - _targetWeight)).clamp(0.0, 1.0)
        : 0.0;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'تتبع الوزن',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.track_changes),
            onPressed: _setTargetWeight,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الوزن الحالي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الوزن الحالي',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_currentWeight.toStringAsFixed(1)} كجم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _currentWeight < _initialWeight
                                ? Icons.trending_down
                                : Icons.trending_up,
                            color: _currentWeight < _initialWeight ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(_currentWeight - _initialWeight).abs().toStringAsFixed(1)} كجم',
                            style: TextStyle(
                              color: _currentWeight < _initialWeight ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'الوزن المستهدف',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_targetWeight.toStringAsFixed(1)} كجم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ شريط التقدم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_initialWeight.toStringAsFixed(1)} كجم',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${_targetWeight.toStringAsFixed(1)} كجم',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey[300],
                      color: progress >= 0.8 ? Colors.green : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ إضافة وزن جديد
            Container(
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
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'الوزن (كجم)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _noteController,
                          decoration: const InputDecoration(
                            labelText: 'ملاحظة (اختياري)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addWeight,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ✅ الرسم البياني
            if (_weightHistory.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'تقدم الوزن',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedPeriod,
                    items: _periods.map((period) {
                      return DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPeriod = value);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 200,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _getWeightSpots().length > 1
                    ? LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getWeightSpots(),
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withOpacity(0.1),
                              ),
                            ),
                          ],
                          minX: 0,
                          maxX: _getWeightSpots().length - 1,
                          minY: 0,
                          maxY: 1,
                        ),
                      )
                    : Center(
                        child: Text(
                          'بيانات غير كافية للرسم البياني',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],

            // ✅ سجل الوزن
            const Text(
              'سجل الوزن',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_weightHistory.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.fitness_center,
                        size: 48,
                        color: isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'لا توجد سجلات وزن',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weightHistory.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _weightHistory.length - 1 - index;
                  final item = _weightHistory[reversedIndex];
                  final date = item['date'] as DateTime;
                  final weight = item['weight'] as double;
                  final note = item['note'] as String?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            DateFormat('dd/MM').format(date),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${weight.toStringAsFixed(1)} كجم',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (note != null && note.isNotEmpty)
                                Text(
                                  note,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _deleteWeight(reversedIndex),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
