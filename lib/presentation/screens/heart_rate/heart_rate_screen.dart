import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/services/heart_rate_service.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen>
    with SingleTickerProviderStateMixin {
  final HeartRateService _service = HeartRateService();

  StreamSubscription<int>? _bpmSub;
  StreamSubscription<double>? _qualitySub;
  StreamSubscription<List<double>>? _waveformSub;
  StreamSubscription<int>? _statusSub;

  int _bpm = 0;
  double _quality = 0;
  double _averageBpm = 0;
  List<double> _waveform = <double>[];
  bool _measuring = false;
  bool _initializing = true;
  int _status = -1;
  String? _error;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.92,
    upperBound: 1.0,
  );

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _service.initializeCamera();
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _status = 0;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _status = 0;
        _error = e.toString();
      });
    }
  }

  void _subscribe() {
    _bpmSub?.cancel();
    _qualitySub?.cancel();
    _waveformSub?.cancel();
    _statusSub?.cancel();

    _bpmSub = _service.bpmStream.listen((value) {
      if (!mounted) return;
      setState(() {
        _bpm = value;
        _averageBpm = _service.averageBPM;
      });
    });
    _qualitySub = _service.signalStream.listen((value) {
      if (!mounted) return;
      setState(() => _quality = value);
    });
    _waveformSub = _service.waveformStream.listen((value) {
      if (!mounted) return;
      setState(() => _waveform = value);
    });
    _statusSub = _service.statusStream.listen((value) {
      if (!mounted) return;
      setState(() => _status = value);
    });
  }

  Future<void> _toggle() async {
    if (_measuring) {
      await _stop();
    } else {
      await _start();
    }
  }

  Future<void> _start() async {
    if (_initializing) return;
    try {
      _subscribe();
      await _service.startMeasurement();
      if (!mounted) return;
      setState(() {
        _measuring = true;
        _bpm = 0;
        _averageBpm = 0;
        _quality = 0;
        _waveform = <double>[];
        _status = 1;
        _error = null;
      });
      _pulseController.repeat(reverse: true);
    } catch (e) {
      _bpmSub?.cancel();
      _qualitySub?.cancel();
      _waveformSub?.cancel();
      _statusSub?.cancel();
      if (!mounted) return;
      setState(() {
        _measuring = false;
        _status = 0;
        _error = e.toString();
      });
    }
  }

  Future<void> _stop() async {
    await _service.stopMeasurement();
    _bpmSub?.cancel();
    _qualitySub?.cancel();
    _waveformSub?.cancel();
    _statusSub?.cancel();
    _pulseController.stop();
    if (!mounted) return;
    setState(() {
      _measuring = false;
      _status = 0;
    });
    if (_bpm > 0) _showResult();
  }

  void _showResult() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نتيجة القياس'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$_bpm BPM', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('متوسط القياس: ${_averageBpm.toStringAsFixed(0)} BPM'),
            Text('جودة الإشارة: ${(_quality * 100).round()}%'),
            const SizedBox(height: 12),
            const Text(
              'هذه قراءة تقديرية من كاميرا الهاتف وليست بديلاً عن جهاز طبي معتمد أو تقييم الطبيب.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
        ],
      ),
    );
  }

  Future<void> _showHistory() async {
    final rows = await _service.getHistory();
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('سجل قياسات النبض', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: rows.isEmpty
                    ? const Center(child: Text('لا توجد قياسات محفوظة بعد'))
                    : ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final row = rows[index];
                          final timestamp = DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int);
                          final bpm = row['bpm'] as int;
                          final quality = ((row['signal_quality'] as num).toDouble() * 100).round();
                          return ListTile(
                            leading: const Icon(Icons.favorite, color: Colors.red),
                            title: Text('$bpm BPM'),
                            subtitle: Text('${timestamp.day}/${timestamp.month}/${timestamp.year} • جودة $quality%'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _statusText {
    if (_error != null) return 'تعذر تشغيل الكاميرا أو القياس';
    switch (_status) {
      case 1:
        return _quality < 0.35 ? 'حافظ على ثبات إصبعك وحسّن الإضاءة' : 'جاري القياس...';
      case 2:
        return 'إشارة مستقرة';
      case 0:
        return 'جاهز لبدء القياس';
      default:
        return 'جاري التهيئة...';
    }
  }

  Color get _statusColor {
    if (_error != null) return Colors.red;
    if (_status == 2) return Colors.green;
    if (_status == 1) return Colors.orange;
    return Colors.grey;
  }

  Widget _buildWaveform() {
    if (_waveform.length < 2) {
      return const SizedBox(
        height: 140,
        child: Center(child: Text('ستظهر الإشارة هنا أثناء القياس', style: TextStyle(color: Colors.grey))),
      );
    }
    final spots = <FlSpot>[];
    for (var i = 0; i < _waveform.length; i++) {
      spots.add(FlSpot(i.toDouble(), _waveform[i]));
    }
    return SizedBox(
      height: 140,
      child: LineChart(
        LineChartData(
          minY: -0.08,
          maxY: 0.08,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              barWidth: 2,
              color: Colors.red,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نبض القلب'),
        actions: [
          IconButton(onPressed: _showHistory, icon: const Icon(Icons.history), tooltip: 'السجل'),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_error != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!)),
                        TextButton(onPressed: _initialize, child: const Text('إعادة المحاولة')),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ScaleTransition(
                scale: _pulseController,
                child: Icon(Icons.favorite, size: 86, color: _measuring ? Colors.red : Colors.grey.shade400),
              ),
              const SizedBox(height: 12),
              Text(
                _bpm == 0 ? '--' : '$_bpm',
                style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: _bpm == 0 ? Colors.grey : Colors.red),
              ),
              const Text('BPM', style: TextStyle(fontSize: 20, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _metric('جودة الإشارة', '${(_quality * 100).round()}%', Icons.signal_cellular_alt)),
                  const SizedBox(width: 10),
                  Expanded(child: _metric('المتوسط', _averageBpm == 0 ? '--' : '${_averageBpm.round()} BPM', Icons.timeline)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _statusColor.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: _statusColor),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_statusText)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(padding: const EdgeInsets.all(12), child: _buildWaveform()),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _initializing ? null : _toggle,
                  icon: Icon(_measuring ? Icons.stop : Icons.play_arrow),
                  label: Text(_measuring ? 'إيقاف القياس' : 'بدء القياس'),
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
              const SizedBox(height: 14),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('طريقة القياس', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('ضع طرف إصبعك برفق على عدسة الكاميرا الخلفية مع تغطية العدسة والضوء، وابقَ ثابتاً لمدة كافية للحصول على إشارة واضحة.'),
                      SizedBox(height: 8),
                      Text('مهم: قياس الكاميرا تقديري ولا يُستخدم لتشخيص حالة صحية أو لاتخاذ قرار علاجي.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 22),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 3),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bpmSub?.cancel();
    _qualitySub?.cancel();
    _waveformSub?.cancel();
    _statusSub?.cancel();
    _pulseController.dispose();
    _service.dispose();
    super.dispose();
  }
}
