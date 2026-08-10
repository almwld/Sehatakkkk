import 'package:flutter/material.dart';

class DailyTipModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String content;

  const DailyTipModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.content,
  });

  factory DailyTipModel.fromJson(Map<String, dynamic> json) => DailyTipModel(
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    icon: IconData(json['iconCode'] ?? 0, fontFamily: 'MaterialIcons'),
    color: Color(json['color'] ?? 0xFF4CAF50),
    content: json['content'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'iconCode': icon.codePoint,
    'color': color.value,
    'content': content,
  };
}
