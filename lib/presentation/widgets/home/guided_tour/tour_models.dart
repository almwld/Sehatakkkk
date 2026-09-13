import 'package:flutter/material.dart';

enum TooltipPosition { top, bottom, left, right, center }

/// بيانات خطوة واحدة من الجولة التعريفية.
class TourStep {
  const TourStep({
    required this.key,
    required this.title,
    required this.description,
    required this.accentColor,
    this.emoji = '✨',
    this.position = TooltipPosition.bottom,
    this.showPulse = true,
    this.actionHint,
  });

  final GlobalKey key;
  final String title;
  final String description;
  final String emoji;
  final Color accentColor;
  final TooltipPosition position;
  final bool showPulse;
  final String? actionHint;
}
