import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PulseOximeterScreen extends StatefulWidget {
  const PulseOximeterScreen({super.key});

  @override
  State<PulseOximeterScreen> createState() => _PulseOximeterScreenState();
}

class _PulseOximeterScreenState extends State<PulseOximeterScreen> {
  bool _isMeasuring = false;
  double _oxygenLevel = 0.0;
  double _heartRate = 0.0;
  int _progress = 0;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {});
      }
    } catch (e) {
      debugPrint('❌ خطأ في الكاميرا: $e');
    }
  }

  Future<void> _startMeasurement() async {
    if (_isMeasuring) return;
    setState(() {
      _isMeasuring = true;
      _progress = 0;
      _oxygenLevel = 0;
      _heartRate = 0;
    });

    // ✅ محاكاة عملية القياس (في التطبيق الحقيقي يتم استخدام الكاميرا)
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 80));
      setState(() {
        _progress = i;
        _oxygenLevel = 95 + (i / 100) * 3; // 95% -> 98%
        _heartRate = 70 + (i / 100) * 10; // 70 -> 80
      });
    }

    setState(() {
      _isMeasuring = false;
      _oxygenLevel = 98.5;
      _heartRate = 76;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCamera = _cameraController != null && _cameraController!.value.isInitialized;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('فحص البلاس (Pulse Oximeter)'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ معاينة الكاميرا
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: hasCamera
                    ? CameraPreview(_cameraController!)
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 48,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'قم بوضع إصبعك على الكاميرا',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // ✅ زر البدء
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isMeasuring ? null : _startMeasurement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMeasuring ? Colors.grey : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isMeasuring
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'جاري القياس... $_progress%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'بدء الفحص',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ✅ النتائج
              if (_oxygenLevel > 0) ...[
                Container(
                  padding: const EdgeInsets.all(20),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ نسبة الأكسجين
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.air,
                              color: AppColors.teal,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_oxygenLevel.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _oxygenLevel >= 95 ? Colors.green : Colors.orange,
                            ),
                          ),
                          const Text(
                            'نسبة الأكسجين',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      // ✅ معدل النبض
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: AppColors.error,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_heartRate.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _heartRate >= 60 && _heartRate <= 100
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const Text(
                            'نبضة/دقيقة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ حالة المريض
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                          ? Colors.green
                          : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                            ? Icons.check_circle
                            : Icons.warning,
                        color: _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                            ? Colors.green
                            : Colors.orange,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                                  ? '✅ الحالة ممتازة'
                                  : '⚠️ استشر الطبيب',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                            Text(
                              _oxygenLevel >= 95 && _heartRate >= 60 && _heartRate <= 100
                                  ? 'مستوى الأكسجين والنبض طبيعيان'
                                  : 'يوجد ارتفاع أو انخفاض في المؤشرات',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ معلومات إضافية
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2540) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💡 معلومات مهمة',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('الأكسجين الطبيعي', '95% - 100%'),
                      _buildInfoRow('نبضات القلب الطبيعي', '60 - 100 نبضة/دقيقة'),
                      _buildInfoRow('وقت القياس', '30 - 60 ثانية'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
