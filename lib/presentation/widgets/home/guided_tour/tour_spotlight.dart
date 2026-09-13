import 'package:flutter/material.dart';

/// يرسم التعتيم الكامل مع فتحة Spotlight وإطار ملون.
class SpotlightPainter extends CustomPainter {
  const SpotlightPainter({
    required this.targetRect,
    required this.highlightColor,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, .78),
    this.radius = 16,
  });

  final Rect targetRect;
  final Color highlightColor;
  final Color overlayColor;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(targetRect, Radius.circular(radius)),
      );
    final cutout = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );

    canvas.drawPath(cutout, Paint()..color = overlayColor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(targetRect, Radius.circular(radius)),
      Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) =>
      oldDelegate.targetRect != targetRect ||
      oldDelegate.highlightColor != highlightColor ||
      oldDelegate.overlayColor != overlayColor ||
      oldDelegate.radius != radius;
}
