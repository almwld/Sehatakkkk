// ============================================================
// 📁 lib/presentation/screens/templates/templates_screen.dart
// 🎨 شاشة اختيار وعرض القوالب
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  String _selectedTemplate = 'slope';
  final TextEditingController _primaryController = TextEditingController();
  final TextEditingController _secondaryController = TextEditingController();

  final List<Map<String, dynamic>> _templates = [
    {
      'id': 'slope',
      'name': 'منحدر',
      'icon': Icons.trending_up_rounded,
      'preview': 'assets/templates/template_slope_preview.svg',
      'bg': 'assets/templates/template_slope.svg',
    },
    {
      'id': 'descent',
      'name': 'نزول',
      'icon': Icons.trending_down_rounded,
      'preview': 'assets/templates/template_descent_preview.svg',
      'bg': 'assets/templates/template_descent.svg',
    },
    {
      'id': 'swell',
      'name': 'انتفاخ',
      'icon': Icons.waves_rounded,
      'preview': 'assets/templates/template_swell_preview.svg',
      'bg': 'assets/templates/template_swell.svg',
    },
    {
      'id': 'drop',
      'name': 'قطرة',
      'icon': Icons.water_drop_rounded,
      'preview': 'assets/templates/template_drop_preview.svg',
      'bg': 'assets/templates/template_drop.svg',
    },
    {
      'id': 'frame',
      'name': 'إطار',
      'icon': Icons.crop_7_5_rounded,
      'preview': 'assets/templates/template_frame_preview.svg',
      'bg': 'assets/templates/template_generic_box.svg',
    },
    {
      'id': 'cover',
      'name': 'غلاف',
      'icon': Icons.photo_library_rounded,
      'preview': 'assets/templates/template_cover_preview.svg',
      'bg': 'assets/templates/template_cover_outer.svg',
    },
    {
      'id': 'slide',
      'name': 'انزلاق',
      'icon': Icons.slideshow_rounded,
      'preview': 'assets/templates/template_slide_preview.svg',
      'bg': 'assets/templates/template_generic_box.svg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _primaryController.text = 'مرحباً بك في صحتك';
    _secondaryController.text = 'منصة صحتك الشاملة';
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
                child: _buildTemplatePreview(),
              ),
            ),
          ),

          // ✅ قائمة القوالب
          Container(
            height: 110,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                final isSelected = _selectedTemplate == template['id'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTemplate = template['id'];
                    });
                  },
                  child: Container(
                    width: 70,
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
                          template['icon'] as IconData,
                          color: isSelected ? AppColors.primary : Colors.grey,
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          template['name'] as String,
                          style: TextStyle(
                            fontSize: 10,
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
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'النص الرئيسي',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _secondaryController,
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'النص الثانوي',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.subtitles_rounded),
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

  // ✅ بناء معاينة القالب
  Widget _buildTemplatePreview() {
    final template = _templates.firstWhere(
      (t) => t['id'] == _selectedTemplate,
      orElse: () => _templates.first,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // ✅ الخلفية
        Container(
          color: Colors.grey[900],
          child: Image.asset(
            template['bg'] as String,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.image_rounded,
                  size: 80,
                  color: Colors.grey[700],
                ),
              );
            },
          ),
        ),
        // ✅ النصوص
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _primaryController.text,
                style: const TextStyle(
                  fontFamily: 'ElMessiri',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _secondaryController.text,
                style: const TextStyle(
                  fontFamily: 'NotoNaskhArabic',
                  fontSize: 18,
                  color: Colors.white70,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // ✅ علامة القالب
        Positioned(
          bottom: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              template['name'] as String,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareTemplate() {
    ToastService.showSuccess('📤 جاري المشاركة...');
  }

  void _saveTemplate() {
    ToastService.showSuccess('✅ تم حفظ القالب');
  }

  void _downloadTemplate() {
    ToastService.showSuccess('📥 جاري تحميل الصورة...');
  }
}
