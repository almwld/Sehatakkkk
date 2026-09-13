import 'package:flutter/material.dart';

/// وميض مزدوج مستمر حول العنصر المستهدف.
/// الـAnimationController مملوك للجولة الرئيسية حتى لا يحدث تسريب عند تبديل الخطوات.
class PulseWidget extends StatelessWidget {
  const PulseWidget({
    super.key,
    required this.controller,
    required this.color,
    required this.size,
  });

  final AnimationController controller;
  final Color color;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final primary = Curves.easeOut.transform(controller.value);
          final secondary = Curves.easeOut.transform(
            (controller.value + .30) % 1.0,
          );
          return Stack(
            alignment: Alignment.center,
            children: [
              _ring(primary, .60),
              _ring(secondary, .42),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double progress, double baseOpacity) {
    return Transform.scale(
      scale: 1 + (progress * .40),
      child: Opacity(
        opacity: baseOpacity * (1 - progress),
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color, width: 3),
          ),
        ),
      ),
    );
  }
}
