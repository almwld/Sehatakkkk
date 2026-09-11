import 'package:flutter/material.dart';

class TemplateModel {
  final String id, name;
  final String? primaryText, secondaryText;
  final Color primaryColor, secondaryColor;
  const TemplateModel({required this.id, required this.name, this.primaryText, this.secondaryText, this.primaryColor = Colors.teal, this.secondaryColor = Colors.white});
}

class TemplateData {
  static const templates = <TemplateModel>[
    TemplateModel(id: 'medical', name: 'طبي', primaryText: 'صحتك', secondaryText: 'منصة الرعاية الصحية'),
    TemplateModel(id: 'simple', name: 'بسيط', primaryText: 'صحتك', secondaryText: 'رعاية أفضل'),
    TemplateModel(id: 'classic', name: 'كلاسيكي', primaryText: 'صحتك', secondaryText: 'صحتك أولاً'),
  ];
}
