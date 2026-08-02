import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class HeartRateService {
  static const int SAMPLE_WINDOW = 30;
  static const int MIN_SAMPLES = 10;
  static const double NORMAL_MIN = 60;
  static const double NORMAL_MAX = 100;
  static const double OXYGEN_MIN = 95;
  static const double OXYGEN_MAX = 100;

  final List<double> _samples = [];
  int _sampleCount = 0;
  bool _isDetecting = false;

  // ✅ تحليل الصورة من الكاميرا
  double? analyzeFrame(CameraImage image) {
    try {
      // ✅ تحويل الصورة إلى بيانات بكسل
      final pixels = _convertImageToPixels(image);
      if (pixels.isEmpty) return null;
      
      // ✅ حساب متوسط السطوع
      final avgBrightness = _calculateAverageBrightness(pixels);
      
      // ✅ إضافة العينة
      _samples.add(avgBrightness);
      if (_samples.length > SAMPLE_WINDOW) {
        _samples.removeAt(0);
      }
      
      // ✅ حساب النبض
      if (_samples.length >= MIN_SAMPLES) {
        return _calculateHeartRate(_samples);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<int> _convertImageToPixels(CameraImage image) {
    // ✅ تحويل صورة الكاميرا إلى مصفوفة بكسل
    final pixels = <int>[];
    try {
      if (image.format.group == ImageFormatGroup.yuv420) {
        // ✅ معالجة صيغة YUV
        final yPlane = image.planes[0];
        final uPlane = image.planes[1];
        final vPlane = image.planes[2];
        
        final yBytes = yPlane.bytes;
        final uBytes = uPlane.bytes;
        final vBytes = vPlane.bytes;
        
        for (int i = 0; i < yBytes.length; i += 4) {
          final y = yBytes[i];
          final u = uBytes[i ~/ 4];
          final v = vBytes[i ~/ 4];
          
          // ✅ تحويل YUV إلى RGB
          final r = (y + 1.402 * (v - 128)).toInt().clamp(0, 255);
          final g = (y - 0.344 * (u - 128) - 0.714 * (v - 128)).toInt().clamp(0, 255);
          final b = (y + 1.772 * (u - 128)).toInt().clamp(0, 255);
          
          // ✅ حساب السطوع
          final brightness = (0.299 * r + 0.587 * g + 0.114 * b).toInt();
          pixels.add(brightness);
        }
      }
    } catch (e) {
      // تجاهل
    }
    return pixels;
  }

  double _calculateAverageBrightness(List<int> pixels) {
    if (pixels.isEmpty) return 0;
    return pixels.reduce((a, b) => a + b) / pixels.length;
  }

  double _calculateHeartRate(List<double> samples) {
    try {
      // ✅ اكتشاف القمم (Peak Detection)
      final peaks = <double>[];
      final threshold = samples.reduce((a, b) => a > b ? a : b) * 0.7;
      
      for (int i = 1; i < samples.length - 1; i++) {
        if (samples[i] > threshold && 
            samples[i] > samples[i - 1] && 
            samples[i] > samples[i + 1]) {
          peaks.add(samples[i]);
        }
      }
      
      if (peaks.length < 2) return 0;
      
      // ✅ حساب متوسط المسافة بين القمم
      final intervals = <double>[];
      for (int i = 1; i < peaks.length; i++) {
        intervals.add(peaks[i] - peaks[i - 1]);
      }
      
      final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
      
      // ✅ حساب النبض (بافتراض 30 عينة في الثانية)
      final heartRate = 60 / (avgInterval / 30);
      
      return heartRate.clamp(30, 200);
    } catch (e) {
      return 0;
    }
  }

  // ✅ الحصول على حالة النبض
  static String getHeartRateStatus(double heartRate) {
    if (heartRate < NORMAL_MIN) return 'منخفض';
    if (heartRate > NORMAL_MAX) return 'مرتفع';
    return 'طبيعي';
  }

  // ✅ الحصول على لون الحالة
  static Color getHeartRateColor(double heartRate) {
    final status = getHeartRateStatus(heartRate);
    switch (status) {
      case 'طبيعي': return Colors.green;
      case 'مرتفع': return Colors.red;
      case 'منخفض': return Colors.orange;
      default: return Colors.grey;
    }
  }

  // ✅ الحصول على حالة الأكسجين
  static String getOxygenStatus(double oxygen) {
    if (oxygen < OXYGEN_MIN) return 'منخفض';
    if (oxygen > OXYGEN_MAX) return 'مرتفع';
    return 'طبيعي';
  }

  // ✅ إعادة تعيين
  void reset() {
    _samples.clear();
    _sampleCount = 0;
    _isDetecting = false;
  }
}
