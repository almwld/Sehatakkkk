import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

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
      ToastService.showError('يرجى إدخال وزن صحيح');
      return;
    }
    setState(() {
      _weightHistory.add({'weight': weight, 'date': DateTime.now(), 'note': _noteController.text.trim()});
      _weightHistory.sort((a, b) => a['date'].compareTo(b['date']));
      _currentWeight = weight;
    });
    _weightController.clear();
    _noteController.clear();
    _saveWeightData();
    ToastService.showSuccess('✅ تم تسجيل الوزن: $weight كجم');
  }

  void _deleteWeight(int index) {
    setState(() {
      _weightHistory.removeAt(index);
      _currentWeight = _weightHistory.isNotEmpty ? _weightHistory.last['weight'] : _initialWeight;
    });
    _saveWeightData();
    ToastService.showSuccess('🗑️ تم حذف السجل');
  }

  void _setTargetWeight() {
    final TextEditingController controller = TextEditingController(text: _targetWeight.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('الوزن المستهدف'),
          content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الوزن المستهدف (كجم)')),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(onPressed: () {
                final weight = double.tryParse(controller.text);
                if (weight != null && weight > 0) { setState(() => _targetWeight = weight); _saveWeightData(); }
                Navigator.pop(context);
            }, child: const Text('حفظ')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تتبع الوزن'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.track_changes), onPressed: _setTargetWeight)],
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : const Center(child: Text('تم تحميل البيانات')),
    );
  }
}
