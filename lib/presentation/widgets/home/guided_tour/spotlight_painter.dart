import 'package:flutter/material.dart';

/// يرسم طبقة التعتيم مع فتحة شفافة وإطار مضيء حول العنصر.
class SpotlightPainter extends CustomPainter {
  const SpotlightPainter({
    required this.targetRect,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, .75),
    this.highlightColor = Colors.blue,
    this.radius = 16,
  });

  final Rect targetRect;
  final Color overlayColor;
  final Color highlightColor;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()..addRect(Offset.zero & size);
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(targetRect, Radius.circular(radius)));
    final cutout = Path.combine(PathOperation.difference, fullPath, holePath);

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
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.overlayColor != overlayColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.radius != radius;
  }
}
