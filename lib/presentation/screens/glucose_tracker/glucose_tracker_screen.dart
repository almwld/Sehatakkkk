import 'package:flutter/material.dart';

import 'package:sehatak/core/services/health_tracking_service.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_app_bar.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_background.dart';
import 'package:sehatak/presentation/widgets/futuristic/futuristic_line_chart.dart';
import 'package:sehatak/presentation/widgets/futuristic/glass_bottom_sheet.dart';
import 'package:sehatak/presentation/widgets/futuristic/glass_card.dart';
import 'package:sehatak/presentation/widgets/futuristic/holographic_number.dart';

class GlucoseTrackerScreen extends StatefulWidget {
  const GlucoseTrackerScreen({super.key});
  @override
  State<GlucoseTrackerScreen> createState() => _GlucoseTrackerScreenState();
}

class _GlucoseTrackerScreenState extends State<GlucoseTrackerScreen> {
  List<double> _history = const [];
  double _latest = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final rows = await HealthTrackingService.history('glucose', days: 30);
    if (!mounted) return;
    setState(() {
      _history = rows
          .map((row) => (row['value'] as num?)?.toDouble() ?? 0)
          .where((value) => value > 0)
          .toList()
          .reversed
          .toList();
      if (_history.isNotEmpty) _latest = _history.last;
    });
  }

  String get _status {
    if (_latest < 70) return 'منخفض';
    if (_latest <= 140) return 'طبيعي';
    if (_latest <= 200) return 'مرتفع';
    return 'خطر';
  }

  Future<void> _add() async {
    _controller.clear();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlassBottomSheet(
        title: 'إضافة قياس السكر',
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'mg/dL',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final value = double.tryParse(_controller.text);
                  if (value == null || value <= 0) return;
                  await HealthTrackingService.save({
                    'blood_sugar': value,
                    'blood_sugar_at': DateTime.now().toIso8601String(),
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  await _load();
                },
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: FuturisticAppBar(
        title: 'تتبع السكر',
        actions: [
          IconButton(onPressed: _add, icon: const Icon(Icons.add)),
        ],
      ),
      body: FuturisticBackground(
        glowColor: const Color(0xFFFF9F43),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            GlassCard(
              glowColor: const Color(0xFFFF9F43),
              child: Column(
                children: [
                  const Icon(
                    Icons.water_drop_rounded,
                    color: Color(0xFFFF9F43),
                    size: 52,
                  ),
                  HolographicNumber(
                    value: _latest == 0 ? '--' : _latest.round().toString(),
                    unit: 'mg/dL • ' + _status,
                    color: const Color(0xFFFF9F43),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              child: _history.length > 1
                  ? FuturisticLineChart(
                      values: _history,
                      color: const Color(0xFFFF9F43),
                    )
                  : const SizedBox(
                      height: 130,
                      child: Center(
                        child: Text(
                          'أضف قياسات فعلية لعرض الرسم',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
