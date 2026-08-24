// ============================================================
// 📁 lib/presentation/screens/templates/template_preview.dart
// 🎨 معاينة القالب الفردي
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class TemplatePreview extends StatelessWidget {
  final String templateId;
  final String primaryText;
  final String secondaryText;

  const TemplatePreview({
    super.key,
    required this.templateId,
    required this.primaryText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('معاينة القالب'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildTemplateContent(),
        ),
      ),
    );
  }

  Widget _buildTemplateContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            primaryText,
            style: const TextStyle(
              fontFamily: 'ElMessiri',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            secondaryText,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 20,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
