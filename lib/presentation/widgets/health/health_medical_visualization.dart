import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sehatak/core/constants/app_colors.dart';

enum HealthMedicalModel { heart, bloodPressure, glucose, sleep, steps, weight, oxygen, temperature }

class HealthMedicalVisualization extends StatefulWidget {
  final HealthMedicalModel model;
  final double size;
  final bool active;
  const HealthMedicalVisualization({super.key, required this.model, this.size = 150, this.active = true});
  @override State<HealthMedicalVisualization> createState() => _HealthMedicalVisualizationState();
}

class _HealthMedicalVisualizationState extends State<HealthMedicalVisualization> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

  @override void initState() { super.initState(); if (widget.active) _controller.repeat(reverse: true); }
  @override void didUpdateWidget(covariant HealthMedicalVisualization oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !_controller.isAnimating) _controller.repeat(reverse: true);
    if (!widget.active && _controller.isAnimating) { _controller.stop(); _controller.value = 0; }
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }

  String? get _lottieAsset {
    switch (widget.model) {
      case HealthMedicalModel.heart:
        return 'assets/animations/medical/heart.json';
      case HealthMedicalModel.steps:
        return 'assets/animations/medical/activity.json';
      default:
        return null;
    }
  }

  String get _imageAsset {
    switch (widget.model) {
      case HealthMedicalModel.bloodPressure: return 'assets/images/tracking/blood_pressure.webp';
      case HealthMedicalModel.glucose: return 'assets/images/tracking/blood_sugar.webp';
      case HealthMedicalModel.sleep: return 'assets/images/tracking/sleep_tracking.webp';
      case HealthMedicalModel.steps: return 'assets/images/tracking/walking.webp';
      case HealthMedicalModel.weight: return 'assets/images/tracking/weight_tracking.webp';
      case HealthMedicalModel.oxygen: return 'assets/images/tracking/blood_pressure.webp';
      case HealthMedicalModel.temperature: return 'assets/images/tracking/fitness.webp';
      case HealthMedicalModel.heart: return 'assets/images/tracking/fitness.webp';
    }
  }

  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final scale = 0.96 + (_controller.value * 0.04);
    final content = _lottieAsset != null
        ? Lottie.asset(_lottieAsset!, width: widget.size, height: widget.size, fit: BoxFit.contain, repeat: true)
        : Image.asset(_imageAsset, width: widget.size * .82, height: widget.size * .82, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(Icons.health_and_safety_rounded, size: widget.size * .52, color: AppColors.primary));
    return Container(
      width: widget.size + 20, height: widget.size + 20, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: dark ? AppColors.primary.withOpacity(.08) : AppColors.primary.withOpacity(.045),
        shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withOpacity(.12)),
      ),
      child: AnimatedBuilder(animation: _controller, builder: (_, child) => Transform.scale(scale: scale, child: child), child: content),
    );
  }
}
