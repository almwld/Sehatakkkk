/*
// ============================================================
// 📁 lib/presentation/screens/sleep_tracker/sleep_tracker_screen.dart
// Sleep شاشة تتبع النوم الرئيسية
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/sleep_tracker_service.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen> {
  final SleepTrackerService _service = SleepTrackerService();

  // OK بيانات النوم
  double _lastNightSleep = 7.5;
  double _sleepQuality = 7.0;
  String _sleepQualityText = 'جيد';
  String _sleepEmoji = '😊';
  int _snoreCount = 0;
  List<Map<String, dynamic>> _weekData = [];
  double _avg = 0.0;
  double _bestQuality = 0.0;
  int _totalSessions = 0;

  // OK حالة التتبع
  bool _isTracking = false;
  DateTime? _trackingStartTime;
  Timer? _trackingTimer;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPeriodicUpdate();
  }

  @override
  void dispose() {
    _trackingTimer?.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isTracking) {
        setState(() {});
      }
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastNightSleep = prefs.getDouble('last_duration') ?? 7.5;
      _sleepQuality = prefs.getDouble('last_quality') ?? 7.0;
      _snoreCount = prefs.getInt('last_snore') ?? 0;
      _sleepQualityText = _getQualityText(_sleepQuality);
      _sleepEmoji = _getQualityEmoji(_sleepQuality);
    });

    await _loadStats();
    await _loadWeekData();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _service.getStats();
      setState(() {
        _totalSessions = stats['total_sessions'] ?? 0;
        _bestQuality = stats['best_quality'] ?? 0.0;
      });
    } catch (e) {
      print('Warning خطأ في تحميل الإحصائيات: $e');
    }
  }

  Future<void> _loadWeekData() async {
    try {
      final data = await _service.getWeekData();
      setState(() {
        _weekData = data;
        if (_weekData.isNotEmpty) {
          double total = _weekData.fold(0.0, (s, d) => s + (d['hours'] as double));
          _avg = total / _weekData.length;
        }
      });
    } catch (e) {
      print('Warning خطأ في تحميل بيانات الأسبوع: $e');
      _generateDefaultWeekData();
    }
  }

  void _generateDefaultWeekData() {
    List<String> days = ['سبت', 'أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    _weekData = days.map((day) {
      return {
        'day': day,
        'hours': 6.0 + (DateTime.now().millisecondsSinceEpoch % 3).toDouble(),
        'quality': 6.0 + (DateTime.now().millisecondsSinceEpoch % 4).toDouble(),
        'snore': (DateTime.now().millisecondsSinceEpoch % 15).toInt(),
      };
    }).toList();
    _avg = _weekData.fold(0.0, (s, d) => s + (d['hours'] as double)) / _weekData.length;
  }

  String _getQualityText(double score) {
    if (score >= 8.0) return 'ممتاز';
    if (score >= 6.5) return 'جيد';
    if (score >= 5.0) return 'مقبول';
    return 'يحتاج تحسين';
  }

  String _getQualityEmoji(double score) {
    if (score >= 8.0) return '🌟';
    if (score >= 6.5) return '😊';
    if (score >= 5.0) return '😐';
    return '😫';
  }

  Future<void> _startTracking() async {
    setState(() {
      _isTracking = true;
      _trackingStartTime = DateTime.now();
    });

    _trackingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    // OK بدء التتبع في الخلفية
    await _service.startTracking();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🌙 بدأ تتبع النوم...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _stopTracking() async {
    _trackingTimer?.cancel();

    setState(() {
      _isTracking = false;
    });

    // OK إيقاف التتبع وجلب النتائج
    final result = await _service.stopTracking();

    await _loadData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('OK تم إيقاف التتبع - الجودة: ${result['quality'].toStringAsFixed(1)}/10'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    _showReportDialog(result);
  }

  void _showReportDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('🌙 تقرير النوم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReportRow('⏰ المدة', '${result['duration'].toStringAsFixed(1)} ساعة'),
            _buildReportRow('⭐ الجودة', '${result['quality'].toStringAsFixed(1)}/10'),
            _buildReportRow('🎤 الشخير', '${result['snore']} مرة'),
            const Divider(),
            _buildReportRow('Stats التقييم', '$_sleepQualityText $_sleepEmoji'),
            const SizedBox(height: 8),
            ..._getTips(result['quality']).map((tip) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 2),
              child: Row(
                children: [
                  const Text('Tip ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _loadData();
            },
            child: const Text('🔄 تحديث'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  List<String> _getTips(double quality) {
    if (quality >= 8) {
      return ['استمر على هذا النمط الرائع', 'حافظ على روتين النوم', 'أنت في أفضل حالاتك 🌟'];
    } else if (quality >= 6) {
      return ['حاول النوم مبكراً', 'قلل من الكافيين بعد الظهر', 'مارس تمارين التنفس قبل النوم'];
    } else {
      return ['نم في وقت ثابت يومياً', 'تجنب الشاشات قبل النوم بساعة', 'حسّن بيئة النوم (إضاءة، درجة حرارة)'];
    }
  }

  @override
  Widget build(BuildContext context) {
    Duration trackingDuration = Duration.zero;
    if (_isTracking && _trackingStartTime != null) {
      trackingDuration = DateTime.now().difference(_trackingStartTime!);
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('🌙 تتبع النوم'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================================
            // 💤 بطاقة النوم
            // ============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _isTracking ? Colors.orange.shade700 : Colors.blue.shade700,
                    _isTracking ? Colors.orange.shade400 : Colors.blue.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 32)),
                      if (_isTracking)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${trackingDuration.inHours}h ${trackingDuration.inMinutes % 60}m',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'نوم الليلة الماضية',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isTracking ? '...' : _lastNightSleep.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        ' ساعة',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isTracking
                              ? Colors.orange.withOpacity(0.3)
                              : _sleepQuality >= 6.5
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.red.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _isTracking ? '🔴 جاري التتبع...' : '$_sleepEmoji $_sleepQualityText',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_snoreCount > 0 && !_isTracking)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '🎤 $_snoreCount شخير',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 🔘 أزرار التحكم
            // ============================================================
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTracking ? _stopTracking : _startTracking,
                    icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
                    label: Text(_isTracking ? 'إيقاف' : 'بدء التتبع'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showStatsDialog,
                    icon: const Icon(Icons.analytics),
                    label: const Text('الإحصائيات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ============================================================
            // Stats الإحصائيات السريعة
            // ============================================================
            Row(
              children: [
                _statCard('المتوسط', '${_avg.toStringAsFixed(1)} س', Icons.bed, Colors.blue),
                const SizedBox(width: 8),
                _statCard('الجودة', '${_sleepQuality.toStringAsFixed(1)}/10', Icons.star, Colors.amber),
                const SizedBox(width: 8),
                _statCard('الجلسات', '$_totalSessions', Icons.history, Colors.green),
              ],
            ),

            const SizedBox(height: 16),

            // ============================================================
            // 📈 الرسم البياني الأسبوعي
            // ============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Stats تقدم النوم الأسبوعي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  if (_weekData.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text('لا توجد بيانات كافية'),
                      ),
                    )
                  else
                    SizedBox(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _weekData.map((d) {
                          final hours = d['hours'] as double;
                          final quality = d['quality'] as double;
                          final color = quality >= 7.0
                              ? Colors.green
                              : quality >= 5.0
                                  ? Colors.orange
                                  : Colors.red;
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '${hours.toStringAsFixed(0)}س',
                                  style: const TextStyle(fontSize: 9),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 24,
                                  height: hours * 14,
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d['day'] ?? '--',
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ============================================================
            // Tip نصائح
            // ============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💤 نصائح لنوم أفضل',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._getTips(_sleepQuality).map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Text('Tip ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsDialog() async {
    final stats = await _service.getStats();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stats الإحصائيات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('📈 عدد الجلسات', '${stats['total_sessions']}'),
            _buildStatRow('⭐ أفضل جودة', '${(stats['best_quality'] ?? 0).toStringAsFixed(1)}/10'),
            _buildStatRow('Stats متوسط الجودة', '${(stats['avg_quality'] ?? 0).toStringAsFixed(1)}/10'),
            _buildStatRow('⏰ متوسط المدة', '${(stats['avg_duration'] ?? 0).toStringAsFixed(1)} ساعة'),
            _buildStatRow('🎤 آخر شخير', '${stats['last_snore'] ?? 0} مرة'),
            const Divider(),
            _buildStatRow('💤 الجودة الحالية', '${_sleepQuality.toStringAsFixed(1)}/10'),
            _buildStatRow('⏱️ المدة الحالية', '${_lastNightSleep.toStringAsFixed(1)} ساعة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🗑️ حذف البيانات'),
        content: const Text('هل أنت متأكد من حذف جميع بيانات النوم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _service.deleteAllData();
              await _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OK تم حذف جميع البيانات'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
*/
