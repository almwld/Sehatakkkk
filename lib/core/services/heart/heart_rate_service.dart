import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
  double? analyzeFrame(CameraImage image) { try { final pixels = _convertImageToPixels(image); if (pixels.isEmpty) return null; final avgBrightness = _calculateAverageBrightness(pixels); _samples.add(avgBrightness); if (_samples.length > SAMPLE_WINDOW) _samples.removeAt(0); return _samples.length >= MIN_SAMPLES ? _calculateHeartRate(_samples) : null; } catch (_) { return null; } }
  List<int> _convertImageToPixels(CameraImage image) { final pixels = <int>[]; try { if (image.format.group == ImageFormatGroup.yuv420) { final y = image.planes[0].bytes; final u = image.planes[1].bytes; final v = image.planes[2].bytes; for (int i = 0; i < y.length; i += 4) { final yy = y[i]; final uu = u[i ~/ 4]; final vv = v[i ~/ 4]; final r = (yy + 1.402 * (vv - 128)).toInt().clamp(0, 255); final g = (yy - .344 * (uu - 128) - .714 * (vv - 128)).toInt().clamp(0, 255); final b = (yy + 1.772 * (uu - 128)).toInt().clamp(0, 255); pixels.add((.299 * r + .587 * g + .114 * b).toInt()); } } } catch (_) {} return pixels; }
  double _calculateAverageBrightness(List<int> pixels) => pixels.isEmpty ? 0 : pixels.reduce((a,b) => a+b) / pixels.length;
  double _calculateHeartRate(List<double> samples) { try { final peaks = <int>[]; final threshold = samples.reduce((a,b) => a>b?a:b)*.7; for (int i=1;i<samples.length-1;i++) if(samples[i]>threshold && samples[i]>samples[i-1] && samples[i]>samples[i+1]) peaks.add(i); if(peaks.length<2) return 0; final intervals=<double>[]; for(int i=1;i<peaks.length;i++) intervals.add((peaks[i]-peaks[i-1]).toDouble()); final avg=intervals.reduce((a,b)=>a+b)/intervals.length; return (60/(avg/30)).clamp(30,200); } catch (_) { return 0; } }
  static String getHeartRateStatus(double heartRate) { if (heartRate<NORMAL_MIN) return 'منخفض'; if(heartRate>NORMAL_MAX) return 'مرتفع'; return 'طبيعي'; }
  static Color getHeartRateColor(double heartRate) => switch(getHeartRateStatus(heartRate)) {'طبيعي'=>Colors.green,'مرتفع'=>Colors.red,'منخفض'=>Colors.orange,_=>Colors.grey};
  static String getOxygenStatus(double oxygen) { if(oxygen<OXYGEN_MIN) return 'منخفض'; if(oxygen>OXYGEN_MAX) return 'مرتفع'; return 'طبيعي'; }
  void reset(){_samples.clear();_sampleCount=0;_isDetecting=false;}
}
