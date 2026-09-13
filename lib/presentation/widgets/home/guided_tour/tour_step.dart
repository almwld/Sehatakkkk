import 'package:flutter/material.dart';

enum TooltipPosition { top, bottom, left, right, center }

/// بيانات خطوة واحدة من الجولة التعريفية داخل الشاشة الرئيسية.
class TourStep {
  const TourStep({
    required this.key,
    required this.title,
    required this.description,
    this.emoji = '✨',
    this.position = TooltipPosition.bottom,
    this.showPulse = true,
  });

  final GlobalKey key;
  final String title;
  final String description;
  final String emoji;
  final TooltipPosition position;
  final bool showPulse;
}
