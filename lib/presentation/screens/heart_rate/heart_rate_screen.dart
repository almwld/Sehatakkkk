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
  List<Map<String, dynamic>> _history = <Map<String, dynamic>>[];
  int _analyticsDays = 7;
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
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final rows = await _service.getHistory(limit: 30);
      if (!mounted) return;
      setState(() => _history = rows);
    } catch (_) {}
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
    await _loadHistory();
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


  Widget _buildAnalytics() {
    final now = DateTime.now();
    final periodStart = now.subtract(Duration(days: _analyticsDays - 1));
    final periodRows = _history.where((row) {
      final raw = row['timestamp'];
      if (raw is! int) return false;
      return DateTime.fromMillisecondsSinceEpoch(raw).isAfter(periodStart);
    }).toList();
    final values = periodRows.map((r) => (r['bpm'] as num?)?.toDouble() ?? 0).where((v) => v > 0).toList();
    if (values.isEmpty) {
      return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('تحليل النبض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8), Text('بعد أول قياس محفوظ ستظهر هنا الاتجاهات والإحصاءات وجودة الإشارة.'),
      ])));
    }
    final avg = values.reduce((a, b) => a + b) / values.length;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final qualityValues = periodRows.map((r) => (r['signal_quality'] as num?)?.toDouble() ?? 0).where((v) => v >= 0).toList();
    final avgQuality = qualityValues.isEmpty ? 0.0 : qualityValues.reduce((a, b) => a + b) / qualityValues.length;
    final recent = periodRows.reversed.take(20).toList();
    final spots = <FlSpot>[];
    final movingSpots = <FlSpot>[];
    for (var i = 0; i < recent.length; i++) {
      final bpm = (recent[i]['bpm'] as num?)?.toDouble() ?? avg;
      spots.add(FlSpot(i.toDouble(), bpm));
      final from = i > 2 ? i - 2 : 0;
      final window = recent.sublist(from, i + 1).map((r) => (r['bpm'] as num?)?.toDouble() ?? bpm).toList();
      movingSpots.add(FlSpot(i.toDouble(), window.reduce((a, b) => a + b) / window.length));
    }
    final low = (minValue - 8).clamp(35, 180).toDouble();
    final high = (maxValue + 8).clamp(50, 220).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1), duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(opacity: value, child: Transform.translate(offset: Offset(0, 18 * (1 - value)), child: child)),
      child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.fromLTRB(14, 16, 14, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('اتجاه النبض', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Text('${values.length} قياس', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ]),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [7, 14, 30].map((days) {
            final selected = _analyticsDays == days;
            return Padding(padding: const EdgeInsetsDirectional.only(end: 8), child: ChoiceChip(
              label: Text(days == 7 ? '7 أيام' : '$days يوم'), selected: selected,
              onSelected: (_) => setState(() => _analyticsDays = days),
            ));
          }).toList())),
          const SizedBox(height: 14),
          SizedBox(height: 205, child: LineChart(LineChartData(
            minY: low, maxY: high,
            gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: ((high - low) / 4).clamp(1, 50)),
            titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(enabled: true, touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touched) => touched.map((spot) => LineTooltipItem('${spot.y.round()} BPM', const TextStyle(fontWeight: FontWeight.bold))).toList(),
            )),
            lineBarsData: [
              LineChartBarData(spots: spots, isCurved: true, curveSmoothness: 0.25, barWidth: 3, color: Colors.red,
                dotData: FlDotData(show: spots.length <= 10), belowBarData: BarAreaData(show: true, color: Colors.red.withOpacity(0.08))),
              LineChartBarData(spots: movingSpots, isCurved: true, barWidth: 2, color: Colors.orange,
                dotData: const FlDotData(show: false), dashArray: [6, 4]),
            ],
          ))),
          const SizedBox(height: 4),
          const Text('الخط البرتقالي = متوسط متحرك لآخر 3 قياسات', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ]))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _analysisMetric('المتوسط', '${avg.round()} BPM', Icons.analytics_outlined)),
          const SizedBox(width: 8), Expanded(child: _analysisMetric('الأعلى', '${maxValue.round()} BPM', Icons.arrow_upward_rounded)),
          const SizedBox(width: 8), Expanded(child: _analysisMetric('الأدنى', '${minValue.round()} BPM', Icons.arrow_downward_rounded)),
        ]),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('جودة الإشارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
          TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: avgQuality.clamp(0, 1)), duration: const Duration(milliseconds: 900),
            builder: (_, value, __) => ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: value, minHeight: 10))),
          const SizedBox(height: 7), Text('${(avgQuality * 100).round()}% متوسط جودة الإشارة • ${qualityValues.length} قياس'),
          if (avgQuality < 0.5) const Padding(padding: EdgeInsets.only(top: 6), child: Text('حاول تثبيت الإصبع وتحسين الإضاءة للحصول على قراءة أوضح.', style: TextStyle(fontSize: 12, color: Colors.grey))),
        ]))),
        const SizedBox(height: 12), _buildTimeDistribution(periodRows),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(children: [
          AnimatedBuilder(animation: _pulseController, builder: (_, child) => Transform.scale(scale: _measuring ? 1 + ((_pulseController.value - 0.92) * 1.8) : 1, child: child),
          child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 30)),
          const SizedBox(width: 12), Expanded(child: Text(_measuring
            ? 'يتم تحديث التحليل أثناء القياس. ثبّت إصبعك للحصول على إشارة أكثر استقراراً.'
            : 'يُبنى التحليل من القياسات المحفوظة على الجهاز، ويمكنك متابعة التغيرات مع الوقت.',
            style: const TextStyle(fontSize: 13, height: 1.5))),
        ]))),
      ]),
    );
  }

  Widget _buildTimeDistribution(List<Map<String, dynamic>> rows) {
    final buckets = List<int>.filled(4, 0);
    for (final row in rows) {
      final raw = row['timestamp'];
      if (raw is! int) continue;
      final hour = DateTime.fromMillisecondsSinceEpoch(raw).hour;
      if (hour < 6) { buckets[3]++; } else if (hour < 12) { buckets[0]++; } else if (hour < 18) { buckets[1]++; } else { buckets[2]++; }
    }
    final labels = ['صباح', 'ظهر', 'مساء', 'ليل'];
    final maxCount = buckets.reduce((a, b) => a > b ? a : b);
    return Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('توزيع القياسات خلال اليوم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 14),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(4, (index) {
        final fraction = maxCount == 0 ? 0.0 : buckets[index] / maxCount;
        return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Column(children: [
          Text('${buckets[index]}', style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 6),
          TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: fraction), duration: Duration(milliseconds: 500 + index * 100), curve: Curves.easeOutCubic,
            builder: (_, value, __) => Container(height: 70 * value + 4, decoration: BoxDecoration(color: Colors.red.withOpacity(0.75), borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 7), Text(labels[index], style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ])));
      })),
    ])));
  }

  Widget _analysisMetric(String label, String value, IconData icon) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.75, end: 1), duration: const Duration(milliseconds: 550), curve: Curves.easeOutBack,
      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
      child: Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4), child: Column(children: [
        Icon(icon, size: 20, color: Colors.red), const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)), const SizedBox(height: 3),
        FittedBox(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
      ]))),
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
              const SizedBox(height: 22),
              _buildAnalytics(),
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
