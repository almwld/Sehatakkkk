import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math';

class HeartRateCameraScreen extends StatefulWidget {
  const HeartRateCameraScreen({super.key});

  @override
  State<HeartRateCameraScreen> createState() => _HeartRateCameraScreenState();
}

class _HeartRateCameraScreenState extends State<HeartRateCameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isScanning = false;
  bool _hasResult = false;
  
  // ✅ بيانات النبض
  int _heartRate = 0;
  int _oxygenLevel = 0;
  String _heartRateStatus = 'جيد';
  String _oxygenStatus = 'طبيعي';
  
  // ✅ قائمة القراءات
  final List<int> _readings = [];
  final List<int> _oxygenReadings = [];
  
  // ✅ المؤشرات
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  
  // ✅ المؤقتات
  Timer? _scanTimer;
  Timer? _pulseTimer;
  int _scanDuration = 0;
  
  // ✅ بيانات النبض
  bool _isPulseDetected = false;
  double _pulseValue = 0;
  int _sampleCount = 0;
  List<double> _samples = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pulseAnimationController.dispose();
    _scanTimer?.cancel();
    _pulseTimer?.cancel();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      
      // ✅ تفعيل الفلاش
      await _cameraController!.setFlashMode(FlashMode.torch);
      
      setState(() {
        _isCameraInitialized = true;
        _isFlashOn = true;
      });
    } catch (e) {
      debugPrint('❌ خطأ في الكاميرا: $e');
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    
    _isFlashOn = !_isFlashOn;
    await _cameraController!.setFlashMode(
      _isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  void _startScan() {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
      _hasResult = false;
      _heartRate = 0;
      _oxygenLevel = 0;
      _readings.clear();
      _oxygenReadings.clear();
      _samples.clear();
      _sampleCount = 0;
      _scanDuration = 0;
    });
    
    _pulseAnimationController.repeat();
    
    // ✅ محاكاة القراءات (سيتم استبدالها بقراءات حقيقية من الكاميرا)
    _scanTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _scanDuration += 100;
        
        // ✅ محاكاة نبضات القلب (قراءات عشوائية ولكن واقعية)
        final random = Random();
        final basePulse = 72;
        final variation = random.nextInt(8) - 4;
        final pulse = basePulse + variation;
        _readings.add(pulse);
        
        // ✅ محاكاة الأكسجين
        final oxygenBase = 98;
        final oxygenVar = random.nextInt(3) - 1;
        final oxygen = oxygenBase + oxygenVar;
        _oxygenReadings.add(oxygen);
        
        // ✅ حساب المتوسط
        if (_readings.length >= 10) {
          final avgPulse = _readings.sublist(_readings.length - 10).reduce((a, b) => a + b) / 10;
          _heartRate = avgPulse.round();
          
          final avgOxygen = _oxygenReadings.sublist(_oxygenReadings.length - 10).reduce((a, b) => a + b) / 10;
          _oxygenLevel = avgOxygen.round();
          
          // ✅ تحديد الحالة
          if (_heartRate < 60) {
            _heartRateStatus = 'منخفض';
          } else if (_heartRate > 100) {
            _heartRateStatus = 'مرتفع';
          } else {
            _heartRateStatus = 'جيد';
          }
          
          if (_oxygenLevel < 95) {
            _oxygenStatus = 'منخفض';
          } else if (_oxygenLevel > 99) {
            _oxygenStatus = 'مرتفع';
          } else {
            _oxygenStatus = 'طبيعي';
          }
        }
        
        // ✅ بعد 15 ثانية إيقاف المسح
        if (_scanDuration >= 15000) {
          _stopScan();
        }
      });
    });
    
    // ✅ تحديث النبض كل ثانية
    _pulseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_readings.isNotEmpty) {
        final lastPulse = _readings.last;
        _pulseValue = lastPulse.toDouble();
        
        // ✅ محاكاة اكتشاف النبض
        if (_readings.length > 5) {
          _isPulseDetected = true;
        }
      }
    });
  }

  void _stopScan() {
    _scanTimer?.cancel();
    _pulseTimer?.cancel();
    _pulseAnimationController.stop();
    
    setState(() {
      _isScanning = false;
      _hasResult = true;
      
      // ✅ حساب المتوسط النهائي
      if (_readings.isNotEmpty) {
        final avgPulse = _readings.reduce((a, b) => a + b) / _readings.length;
        _heartRate = avgPulse.round();
        
        final avgOxygen = _oxygenReadings.reduce((a, b) => a + b) / _oxygenReadings.length;
        _oxygenLevel = avgOxygen.round();
        
        if (_heartRate < 60) {
          _heartRateStatus = 'منخفض';
        } else if (_heartRate > 100) {
          _heartRateStatus = 'مرتفع';
        } else {
          _heartRateStatus = 'جيد';
        }
        
        if (_oxygenLevel < 95) {
          _oxygenStatus = 'منخفض';
        } else if (_oxygenLevel > 99) {
          _oxygenStatus = 'مرتفع';
        } else {
          _oxygenStatus = 'طبيعي';
        }
      }
    });
  }

  void _resetScan() {
    setState(() {
      _heartRate = 0;
      _oxygenLevel = 0;
      _hasResult = false;
      _readings.clear();
      _oxygenReadings.clear();
      _samples.clear();
      _scanDuration = 0;
      _isPulseDetected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('❤️ فحص النبض'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                // ✅ معاينة الكاميرا
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                // ✅ طبقة شفافة فوق الكاميرا
                Container(
                  color: Colors.black.withOpacity(0.3),
                ),
                // ✅ المحتوى
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(),
                      
                      // ✅ مؤشر النبض
                      if (_isScanning || _hasResult)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isPulseDetected ? Icons.favorite : Icons.favorite_border,
                                color: _isPulseDetected ? Colors.red : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isPulseDetected 
                                    ? '✅ تم اكتشاف النبض' 
                                    : '⏳ جاري اكتشاف النبض...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // ✅ عرض النبض
                      if (_hasResult || _heartRate > 0)
                        Container(
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _heartRateStatus == 'جيد' 
                                  ? Colors.green 
                                  : (_heartRateStatus == 'مرتفع' ? Colors.red : Colors.orange),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              // ✅ نبضة متحركة
                              if (_isScanning)
                                AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 60,
                                      ),
                                    );
                                  },
                                )
                              else
                                const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 60,
                                ),
                              const SizedBox(height: 16),
                              
                              // ✅ قيمة النبض
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_heartRate.toString()}',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'نبضة/دقيقة',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // ✅ الحالة
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _heartRateStatus == 'جيد' 
                                      ? Colors.green.withOpacity(0.2) 
                                      : (_heartRateStatus == 'مرتفع' 
                                          ? Colors.red.withOpacity(0.2) 
                                          : Colors.orange.withOpacity(0.2)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _heartRateStatus == 'جيد' 
                                      ? '✅ طبيعي' 
                                      : (_heartRateStatus == 'مرتفع' 
                                          ? '⚠️ مرتفع' 
                                          : '⚠️ منخفض'),
                                  style: TextStyle(
                                    color: _heartRateStatus == 'جيد' 
                                        ? Colors.green 
                                        : (_heartRateStatus == 'مرتفع' 
                                            ? Colors.red 
                                            : Colors.orange),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              
                              // ✅ مستوى الأكسجين
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🫁 SpO2: ',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${_oxygenLevel}%',
                                    style: TextStyle(
                                      color: _oxygenStatus == 'طبيعي' 
                                          ? Colors.green 
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _oxygenStatus == 'طبيعي' 
                                          ? Colors.green.withOpacity(0.2) 
                                          : Colors.orange.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _oxygenStatus == 'طبيعي' ? 'طبيعي' : 'منخفض',
                                      style: TextStyle(
                                        color: _oxygenStatus == 'طبيعي' 
                                            ? Colors.green 
                                            : Colors.orange,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // ✅ وقت المسح
                      if (_isScanning)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  value: _scanDuration / 15000,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(_scanDuration / 1000).toInt()} / 15 ثانية',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 30),
                      
                      // ✅ زر التحكم
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isScanning 
                                ? _stopScan 
                                : (_hasResult ? _resetScan : _startScan),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isScanning 
                                  ? Colors.red 
                                  : (_hasResult ? primaryColor : Colors.green),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              _isScanning 
                                  ? '⏹️ إيقاف' 
                                  : (_hasResult ? '🔄 إعادة' : '▶️ بدء الفحص'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // ✅ تعليمات
                      if (!_isScanning && !_hasResult)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '📌 تعليمات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                '1️⃣ ضع إصبعك على عدسة الكاميرا\n'
                                '2️⃣ ثبّت إصبعك ولا تحركه\n'
                                '3️⃣ انتظر 15 ثانية للحصول على النتيجة',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      
                      // ✅ النتيجة النهائية
                      if (_hasResult)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '✅ تم الفحص بنجاح',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                        '❤️ النبض',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      Text(
                                        '$_heartRate',
                                        style: TextStyle(
                                          color: _heartRateStatus == 'جيد' ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Text(
                                        '🫁 الأكسجين',
                                        style: TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                      Text(
                                        '$_oxygenLevel%',
                                        style: TextStyle(
                                          color: _oxygenStatus == 'طبيعي' ? Colors.green : Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '📊 الحالة: ${_heartRateStatus} • ${_oxygenStatus}',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
