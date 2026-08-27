// ============================================================
// 📁 lib/presentation/screens/heart_rate/heart_rate_screen.dart
// Heart Rate شاشة قياس نبضات القلب مع تعليم متحرك
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sehatak/presentation/widgets/animated_heart.dart';
import 'package:lottie/lottie.dart';
import 'package:sehatak/services/heart_rate_service.dart';
import 'package:sehatak/presentation/widgets/educational/camera_tutorial_overlay.dart';
import 'package:sehatak/presentation/widgets/educational/animated_tutorial_widget.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen>
    with SingleTickerProviderStateMixin {
  final HeartRateService _service = HeartRateService();
  
  // ============================================================
  // Stats متغيرات الحالة
  // ============================================================
  int _currentBPM = 0;
  double _oxygenSaturation = 98.0;
  double _signalQuality = 0.0;
  double _averageBPM = 0.0;
  List<double> _waveformData = [];
  bool _isMeasuring = false;
  bool _isInitializing = false;
  bool _showTutorial = true;
  int _statusCode = 0;
  bool _showEducationalHint = false;
  
  String get _statusText {
    switch (_statusCode) {
      case 0: return 'اضغط "ابدأ" لقياس نبضك';
      case 1: return 'جاري القياس... حافظ على ثبات إصبعك';
      case 2: return 'OK قياس مستقر';
      default: return 'جاري التهيئة...';
    }
  }
  
  Color get _statusColor {
    switch (_statusCode) {
      case 0: return Colors.grey;
      case 1: return Colors.orange;
      case 2: return Colors.green;
      default: return Colors.grey;
    }
  }
  
  // 🎬 الرسوم المتحركة
  late AnimationController _heartController;
  late Animation<double> _heartScale;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  double _heartSize = 80.0;
  
  // 📡 Streams
  StreamSubscription<int>? _bpmSubscription;
  StreamSubscription<double>? _signalSubscription;
  StreamSubscription<double>? _oxygenSubscription;
  StreamSubscription<List<double>>? _waveformSubscription;
  StreamSubscription<int>? _statusSubscription;
  Timer? _updateTimer;
  Timer? _hintTimer;

  // ============================================================
  // 🔄 دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initializeService();
    _showEducationalHintAfterDelay();
  }

  void _initAnimations() {
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartController,
        curve: Curves.easeInOut,
      ),
    );
    
    _breathController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    
    _breathAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _breathController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _showEducationalHintAfterDelay() {
    _hintTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_isMeasuring) {
        setState(() => _showEducationalHint = true);
      }
    });
  }

  Future<void> _initializeService() async {
    setState(() {
      _isInitializing = true;
      _statusCode = -1;
    });
    
    try {
      await _service.initializeCamera();
      setState(() {
        _isInitializing = false;
        _statusCode = 0;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _statusCode = 0;
      });
      _showSnackBar('Error فشل التهيئة: $e', Colors.red);
    }
  }

  // ============================================================
  🎮 التحكم في القياس
  // ============================================================
  Future<void> _toggleMeasurement() async {
    if (_isMeasuring) {
      await _stopMeasurement();
    } else {
      await _startMeasurement();
    }
  }

  Future<void> _startMeasurement() async {
    try {
      setState(() {
        _isMeasuring = true;
        _statusCode = 1;
        _currentBPM = 0;
        _showEducationalHint = false;
      });
      
      await _service.startMeasurement();
      
      _bpmSubscription = _service.bpmStream.listen((bpm) {
        setState(() => _currentBPM = bpm);
        _heartController.forward(from: 0.0);
      });
      
      _signalSubscription = _service.signalStream.listen((quality) {
        setState(() => _signalQuality = quality);
      });
      
      _oxygenSubscription = _service.oxygenStream.listen((oxygen) {
        setState(() => _oxygenSaturation = oxygen);
      });
      
      _waveformSubscription = _service.waveformStream.listen((data) {
        setState(() => _waveformData = data);
      });
      
      _statusSubscription = _service.statusStream.listen((code) {
        setState(() => _statusCode = code);
      });
      
      _updateTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        setState(() {});
      });
      
    } catch (e) {
      setState(() {
        _isMeasuring = false;
        _statusCode = 0;
      });
      _showSnackBar('Error فشل بدء القياس: $e', Colors.red);
    }
  }

  Future<void> _stopMeasurement() async {
    await _service.stopMeasurement();
    
    _bpmSubscription?.cancel();
    _signalSubscription?.cancel();
    _oxygenSubscription?.cancel();
    _waveformSubscription?.cancel();
    _statusSubscription?.cancel();
    _updateTimer?.cancel();
    
    setState(() {
      _isMeasuring = false;
      _statusCode = 0;
      _heartController.stop();
    });
    
    if (_currentBPM > 0) {
      _showResultsDialog();
    }
  }

  // ============================================================
  Stats عرض النتائج
  // ============================================================
  void _showResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Heart Rate نتائج القياس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow(Icons.favorite, 'نبضات القلب', '$_currentBPM BPM', Colors.red),
            const SizedBox(height: 8),
            _buildResultRow(Icons.air, 'تشبع الأوكسجين', '${_oxygenSaturation.toStringAsFixed(1)}%', Colors.blue),
            const SizedBox(height: 8),
            _buildResultRow(Icons.signal_cellular_alt, 'جودة الإشارة', '${(_signalQuality * 100).toStringAsFixed(0)}%', Colors.green),
            const SizedBox(height: 8),
            _buildResultRow(Icons.timeline, 'متوسط النبض', '${_averageBPM.toStringAsFixed(0)} BPM', Colors.purple),
            const Divider(),
            _buildHealthAdvice(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildHealthAdvice() {
    String advice;
    IconData icon;
    Color color;
    
    if (_currentBPM < 60) {
      advice = '💪 نبضك في المعدل الطبيعي للرياضيين';
      icon = Icons.fitness_center;
      color = Colors.green;
    } else if (_currentBPM < 80) {
      advice = '😊 نبضك في المعدل الطبيعي';
      icon = Icons.sentiment_satisfied;
      color = Colors.blue;
    } else if (_currentBPM < 100) {
      advice = '🧘 حاول التنفس بعمق لتهدئة نبضك';
      icon = Icons.self_improvement;
      color = Colors.orange;
    } else {
      advice = 'Warning نبضك مرتفع، استشر طبيباً إذا استمر';
      icon = Icons.warning;
      color = Colors.red;
    }
    
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            advice,
            style: TextStyle(fontSize: 14, color: color),
          ),
        ),
      ],
    );
  }

  // ============================================================
  Stats الرسم البياني
  // ============================================================
  Widget _buildWaveformChart() {
    if (_waveformData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/wave_animation.json',
              height: 60,
              width: 60,
              errorBuilder: (_, __, ___) => Icon(
                Icons.waves,
                size: 40,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '⏳ انتظار الإشارة...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    List<FlSpot> spots = [];
    for (int i = 0; i < _waveformData.length; i++) {
      spots.add(FlSpot(i.toDouble(), _waveformData[i]));
    }

    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
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
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.red.shade700,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.red.withOpacity(0.1),
              ),
            ),
          ],
          minY: -0.5,
          maxY: 0.5,
        ),
      ),
    );
  }

  // ============================================================
  📱 بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heart Rate نبضات القلب'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => setState(() => _showTutorial = true),
            tooltip: 'تعليمات',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
            tooltip: 'السجل',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ❤️ القلب المتحرك
                Center(
                  child: AnimatedBuilder(
                    animation: _breathAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _breathAnimation.value,
                        child: AnimatedBuilder(
                          animation: _heartScale,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isMeasuring ? _heartScale.value : 1.0,
                              child: AnimatedHeart(
                                size: _heartSize,
                                color: _isMeasuring ? Colors.red : Colors.grey.shade400,
                                animated: _isMeasuring,
                                animationDuration: const Duration(milliseconds: 600),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Stats قيمة BPM
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: TextStyle(
                        fontSize: _currentBPM == 0 ? 36 : 64,
                        fontWeight: FontWeight.bold,
                        color: _currentBPM == 0 ? Colors.grey : Colors.red,
                      ),
                      child: Text(
                        _currentBPM == 0 ? '--' : '$_currentBPM',
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'BPM',
                      style: TextStyle(fontSize: 24, color: Colors.grey),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Stats معلومات إضافية
                Row(
                  children: [
                    _buildInfoCard(
                      'تشبع الأوكسجين',
                      '${_oxygenSaturation.toStringAsFixed(1)}%',
                      Icons.air,
                      Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoCard(
                      'جودة الإشارة',
                      '${(_signalQuality * 100).toStringAsFixed(0)}%',
                      Icons.signal_cellular_alt,
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoCard(
                      'متوسط النبض',
                      '${_averageBPM.toStringAsFixed(0)} BPM',
                      Icons.timeline,
                      Colors.purple,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 📝 حالة القياس
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 500),
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 14,
                        ),
                        child: Text(_statusText),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 📈 الرسم البياني
                _buildWaveformChart(),
                
                const SizedBox(height: 20),
                
                // 🎮 زر التحكم
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isInitializing ? null : _toggleMeasurement,
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isMeasuring ? Icons.stop : Icons.play_arrow,
                        key: ValueKey(_isMeasuring),
                      ),
                    ),
                    label: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isMeasuring ? 'إيقاف القياس' : 'بدء القياس',
                        key: ValueKey(_isMeasuring),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isMeasuring ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Tip الإرشادات السريعة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.lightbulb, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Tip إرشادات سريعة', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('• ضع إصبعك برفق على الكاميرا الخلفية', style: TextStyle(fontSize: 12)),
                      const Text('• تأكد من تغطية الفلاش بإصبعك', style: TextStyle(fontSize: 12)),
                      const Text('• حافظ على ثبات إصبعك أثناء القياس', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // OK تراكب التعليم
          if (_showTutorial)
            CameraTutorialOverlay(
              onDismiss: () => setState(() => _showTutorial = false),
              isMeasuring: _isMeasuring,
            ),
          
          // OK رسالة تعليمية منبثقة
          if (_showEducationalHint && !_isMeasuring)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '📖 كيفية القياس',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'اضغط "بدء القياس" ثم ضع إصبعك على الكاميرا',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _showEducationalHint = false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  🧩 ويدجت مساعدة
  // ============================================================
  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: value.contains('%') ? 12 : 14,
                color: color,
              ),
              child: Text(value),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  Stats عرض السجل
  // ============================================================
  void _showHistory() async {
    final stats = await _service.getStatistics();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stats سجل القياسات'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatRow('متوسط النبض', '${(stats['avg_bpm'] ?? 0).toStringAsFixed(0)} BPM'),
            _buildStatRow('متوسط الأوكسجين', '${(stats['avg_oxygen'] ?? 0).toStringAsFixed(1)}%'),
            _buildStatRow('أعلى نبض', '${stats['max_bpm'] ?? 0} BPM'),
            _buildStatRow('أدنى نبض', '${stats['min_bpm'] ?? 0} BPM'),
            _buildStatRow('متوسط الجودة', '${((stats['avg_quality'] ?? 0) * 100).toStringAsFixed(0)}%'),
            _buildStatRow('عدد القياسات', '${stats['count'] ?? 0}'),
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
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ============================================================
  📢 عرض إشعار
  // ============================================================
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ============================================================
  🧹 التنظيف
  // ============================================================
  @override
  void dispose() {
    _bpmSubscription?.cancel();
    _signalSubscription?.cancel();
    _oxygenSubscription?.cancel();
    _waveformSubscription?.cancel();
    _statusSubscription?.cancel();
    _updateTimer?.cancel();
    _hintTimer?.cancel();
    _heartController.dispose();
    _breathController.dispose();
    _service.dispose();
    super.dispose();
  }
}
