// ============================================================
// 📁 lib/core/services/performance/performance_service.dart
// 📊 مراقبة أداء التطبيق
// ============================================================

class PerformanceService {
  static final PerformanceService _instance = PerformanceService._internal();
  factory PerformanceService() => _instance;
  PerformanceService._internal();

  final Map<String, Stopwatch> _stopwatches = {};
  final Map<String, List<int>> _metrics = {};

  // ============================================================
  // ⏱️ بدء القياس
  // ============================================================
  void start(String key) {
    if (_stopwatches.containsKey(key)) {
      _stopwatches[key]?.reset();
    } else {
      _stopwatches[key] = Stopwatch();
    }
    _stopwatches[key]?.start();
  }

  // ============================================================
  // ⏹️ إيقاف القياس
  // ============================================================
  int stop(String key) {
    final stopwatch = _stopwatches[key];
    if (stopwatch == null) return 0;
    stopwatch.stop();
    final elapsed = stopwatch.elapsedMilliseconds;
    
    if (!_metrics.containsKey(key)) {
      _metrics[key] = [];
    }
    _metrics[key]!.add(elapsed);
    
    return elapsed;
  }

  // ============================================================
  // 📊 الحصول على الإحصائيات
  // ============================================================
  Map<String, dynamic> getStats(String key) {
    final data = _metrics[key] ?? [];
    if (data.isEmpty) {
      return {
        'count': 0,
        'average': 0,
        'min': 0,
        'max': 0,
      };
    }
    
    final sum = data.reduce((a, b) => a + b);
    final avg = sum / data.length;
    
    return {
      'count': data.length,
      'average': avg.round(),
      'min': data.reduce((a, b) => a < b ? a : b),
      'max': data.reduce((a, b) => a > b ? a : b),
    };
  }

  // ============================================================
  // 🗑️ مسح البيانات
  // ============================================================
  void clear(String key) {
    _metrics.remove(key);
    _stopwatches.remove(key);
  }

  void clearAll() {
    _metrics.clear();
    _stopwatches.clear();
  }
}
