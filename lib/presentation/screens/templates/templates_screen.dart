// ============================================================
// 📁 lib/presentation/screens/templates/templates_screen.dart
// 🎨 شاشة اختيار القوالب
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/template_model.dart';
import 'package:sehatak/core/services/template_service.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final TemplateService _templateService = TemplateService();
  TemplateModel? _selectedTemplate;
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTemplate = TemplateData.templates.first;
    _primaryController.text = _selectedTemplate?.primaryText ?? '';
    _secondaryController.text = _selectedTemplate?.secondaryText ?? '';
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('قوالب الصور'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _downloadTemplate,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ معاينة القالب
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _selectedTemplate != null
                    ? _templateService.buildTemplateWidget(
                        template: _selectedTemplate!,
                        primaryText: _primaryController.text,
                        secondaryText: _secondaryController.text,
                        width: MediaQuery.of(context).size.width - 32,
                        height: 300,
                      )
                    : const Center(child: Text('اختر قالباً')),
              ),
            ),
          ),

          // ✅ قائمة القوالب
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: TemplateData.templates.length,
              itemBuilder: (context, index) {
                final template = TemplateData.templates[index];
                final isSelected = _selectedTemplate?.id == template.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTemplate = template;
                      _primaryController.text = template.primaryText ?? '';
                      _secondaryController.text = template.secondaryText ?? '';
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getTemplateIcon(template.id),
                          color: isSelected ? AppColors.primary : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template.name,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ✅ تحرير النصوص
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                TextField(
                  controller: _primaryController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'النص الرئيسي',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _secondaryController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    labelText: 'النص الثانوي',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareTemplate,
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('مشاركة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveTemplate,
                        icon: const Icon(Icons.save_rounded),
                        label: const Text('حفظ'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTemplateIcon(String id) {
    switch (id) {
      case 'slope':
        return Icons.trending_up_rounded;
      case 'descent':
        return Icons.trending_down_rounded;
      case 'swell':
        return Icons.waves_rounded;
      case 'drop':
        return Icons.water_drop_rounded;
      case 'frame':
        return Icons.crop_7_5_rounded;
      case 'cover':
        return Icons.photo_library_rounded;
      case 'slide':
        return Icons.slideshow_rounded;
      default:
        return Icons.image_rounded;
    }
  }

  void _shareTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📤 جاري المشاركة...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _saveTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حفظ القالب'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _downloadTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📥 جاري تحميل الصورة...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}
