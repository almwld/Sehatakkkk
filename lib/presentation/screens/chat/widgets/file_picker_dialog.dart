import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/text_styles.dart';

class FilePickerDialog extends StatelessWidget {
  final Function(FilePickerResult) onFilePicked;

  const FilePickerDialog({
    super.key,
    required this.onFilePicked,
  });

  final List<Map<String, dynamic>> _fileTypes = [
    {'icon': Icons.picture_as_pdf, 'label': 'PDF', 'extensions': ['pdf'], 'color': Colors.red},
    {'icon': Icons.description, 'label': 'Word', 'extensions': ['doc', 'docx'], 'color': Colors.blue},
    {'icon': Icons.table_chart, 'label': 'Excel', 'extensions': ['xls', 'xlsx'], 'color': Colors.green},
    {'icon': Icons.slideshow, 'label': 'PowerPoint', 'extensions': ['ppt', 'pptx'], 'color': Colors.orange},
    {'icon': Icons.text_snippet, 'label': 'نص', 'extensions': ['txt'], 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اختر نوع الملف',
            style: TextStyles.subtitle1.copyWith(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _fileTypes.length,
            itemBuilder: (context, index) {
              final fileType = _fileTypes[index];
              return GestureDetector(
                onTap: () => _pickFile(fileType['extensions'] as List<String>),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        fileType['icon'] as IconData,
                        color: fileType['color'] as Color,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        fileType['label'] as String,
                        style: TextStyles.body2.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _pickFile(['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt']),
              child: const Text('جميع الملفات'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(List<String> extensions) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions,
      );

      if (result != null) {
        // إغلاق الحوار وإرجاع النتيجة
        Navigator.pop(context);
        onFilePicked(result);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل اختيار الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
