import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicalImageAnalysisScreen extends StatefulWidget {
  const MedicalImageAnalysisScreen({super.key});

  @override
  State<MedicalImageAnalysisScreen> createState() => _MedicalImageAnalysisScreenState();
}

class _MedicalImageAnalysisScreenState extends State<MedicalImageAnalysisScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String _result = '';
  double _confidence = 0;

  final List<Map<String, dynamic>> _analysisTypes = [
    {'name': 'تحليل الجلد', 'icon': Icons.face, 'color': AppColors.info},
    {'name': 'تحليل الأشعة', 'icon': Icons.visibility, 'color': AppColors.primary},
    {'name': 'تحليل العين', 'icon': Icons.visibility_off, 'color': AppColors.purple},
    {'name': 'تحليل الأسنان', 'icon': Icons.cleaning_services, 'color': AppColors.success},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _result = '';
        _confidence = 0;
      });
    }
  }

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _result = '';
        _confidence = 0;
      });
    }
  }

  void _analyzeImage() {
    if (_selectedImage == null) return;
    
    setState(() {
      _isAnalyzing = true;
      _result = 'جاري التحليل...';
    });

    Future.delayed(const Duration(seconds: 3), () {
      final results = [
        {'result': 'طبيعي ✅', 'confidence': 0.95},
        {'result': 'مشتبه به ⚠️', 'confidence': 0.78},
        {'result': 'يحتاج فحص 🔴', 'confidence': 0.65},
        {'result': 'آمن ✅', 'confidence': 0.92},
      ];
      
      final random = results[DateTime.now().millisecond % results.length];
      setState(() {
        _isAnalyzing = false;
        _result = random['result'];
        _confidence = random['confidence'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تحليل الصور الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اختر نوع التحليل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: _analysisTypes.map((type) {
                final color = type['color'] as Color;
                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(type['icon'], color: color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        type['name'],
                        style: TextStyle(fontSize: 8, color: color),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('اختر صورة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _captureImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('تصوير'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            if (_selectedImage != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isAnalyzing ? null : _analyzeImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isAnalyzing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تحليل الصورة', style: TextStyle(fontSize: 16)),
                ),
              ),
            const SizedBox(height: 16),
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _result.contains('طبيعي') || _result.contains('آمن')
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _result.contains('طبيعي') || _result.contains('آمن')
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _result,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _result.contains('طبيعي') || _result.contains('آمن')
                            ? AppColors.success
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'دقة: ${(_confidence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _confidence,
                      backgroundColor: Colors.grey[300],
                      color: _confidence > 0.8 ? AppColors.success : AppColors.warning,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
