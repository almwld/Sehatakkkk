import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PulseCameraScreen extends StatefulWidget {
  const PulseCameraScreen({super.key});

  @override
  State<PulseCameraScreen> createState() => _PulseCameraScreenState();
}

class _PulseCameraScreenState extends State<PulseCameraScreen> {
  CameraController? _controller;
  StreamSubscription<CameraImage>? _imageSubscription;
  final List<double> _samples = <double>[];
  DateTime? _startedAt;
  Timer? _timer;
  int? _bpm;
  bool _measuring = false;
  String _status = 'ضع إصبعك برفق على الكاميرا الخلفية والعدسة معاً.';

  @override
  void initState() { super.initState(); _initCamera(); }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception('no camera');
      final camera = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
      final controller = CameraController(camera, ResolutionPreset.low, enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);
      await controller.initialize();
      if (!mounted) { await controller.dispose(); return; }
      setState(() => _controller = controller);
    } catch (_) {
      if (mounted) setState(() => _status = 'تعذر تشغيل الكاميرا. تحقق من صلاحية الكاميرا ثم حاول مرة أخرى.');
    }
  }

  Future<void> _startMeasurement() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _measuring) return;
    _samples.clear();
    _bpm = null;
    _startedAt = DateTime.now();
    setState(() { _measuring = true; _status = 'جاري القياس… ثبّت إصبعك ولا تحرك الهاتف.'; });
    await controller.startImageStream(_onFrame);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 20), _finishMeasurement);
  }

  void _onFrame(CameraImage image) {
    if (!_measuring || image.planes.isEmpty) return;
    final plane = image.planes.first;
    final bytes = plane.bytes;
    if (bytes.isEmpty) return;
    var sum = 0.0;
    final step = math.max(1, bytes.length ~/ 500);
    for (var i = 0; i < bytes.length; i += step) sum += bytes[i];
    _samples.add(sum / ((bytes.length + step - 1) / step));
    if (_samples.length > 600) _samples.removeAt(0);
  }

  Future<void> _finishMeasurement() async {
    if (!_measuring) return;
    _timer?.cancel();
    try { await _controller?.stopImageStream(); } catch (_) {}
    final elapsed = DateTime.now().difference(_startedAt ?? DateTime.now()).inMilliseconds / 1000;
    final bpm = _estimateBpm(elapsed);
    if (!mounted) return;
    setState(() { _measuring = false; _bpm = bpm; _status = bpm == null ? 'لم تكن الإشارة مستقرة بما يكفي. أعد القياس مع تثبيت الإصبع.' : 'تم القياس. للحصول على قراءة أدق أعد القياس عند الحاجة.'; });
  }

  int? _estimateBpm(double seconds) {
    if (_samples.length < 80 || seconds < 8) return null;
    var min = _samples.reduce(math.min);
    var max = _samples.reduce(math.max);
    final range = max - min;
    if (range < 2) return null;
    final threshold = min + range * .62;
    var peaks = 0;
    int? lastPeak;
    for (var i = 1; i < _samples.length - 1; i++) {
      final peak = _samples[i] > threshold && _samples[i] >= _samples[i - 1] && _samples[i] >= _samples[i + 1];
      if (!peak) continue;
      if (lastPeak == null || i - lastPeak > 5) { peaks++; lastPeak = i; }
    }
    final bpm = (peaks / seconds * 60).round();
    if (bpm < 40 || bpm > 180) return null;
    return bpm;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _imageSubscription?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('قياس النبض بالكاميرا'), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: controller == null || !controller.value.isInitialized
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(child: Column(children: [
              Expanded(child: Stack(alignment: Alignment.center, children: [
                CameraPreview(controller),
                Container(width: 190, height: 190, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 3), borderRadius: BorderRadius.circular(28))),
                Positioned(bottom: 20, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(14)), child: Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13)))),
              ])),
              Container(padding: const EdgeInsets.fromLTRB(20, 16, 20, 22), color: Colors.black, child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 26), const SizedBox(width: 8), Text(_bpm == null ? '--' : '$_bpm', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900)), const SizedBox(width: 8), const Text('BPM', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))]),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _measuring ? _finishMeasurement : _startMeasurement, icon: Icon(_measuring ? Icons.stop_rounded : Icons.monitor_heart_outlined), label: Text(_measuring ? 'إيقاف القياس' : 'بدء القياس'), style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)))),
                const SizedBox(height: 8),
                const Text('القياس بالكاميرا تقديري وليس بديلاً عن جهاز طبي معتمد. إذا شعرت بأعراض خطيرة فاطلب رعاية طبية فوراً.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 10)),
              ])),
            ])),
    );
  }
}
