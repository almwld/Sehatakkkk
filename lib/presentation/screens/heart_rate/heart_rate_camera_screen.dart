import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/heart_rate/heart_rate_screen.dart';

/// Legacy route kept for compatibility. The previous implementation generated
/// synthetic BPM/SpO2 values; all heart-rate measurement now uses the unified
/// camera signal implementation.
class HeartRateCameraScreen extends StatelessWidget {
  const HeartRateCameraScreen({super.key});

  @override
  Widget build(BuildContext context) => const HeartRateScreen();
}
