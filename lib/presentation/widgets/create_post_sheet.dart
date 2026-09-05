// ============================================================
// 📁 lib/presentation/widgets/create_post_sheet.dart
// 📝 شيت إنشاء منشور جديد
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sehatak/bloc/community/community_bloc.dart';
import 'package:sehatak/bloc/community/community_event.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreatePostSheet(),
    );
  }

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'عام';
  List<PlatformFile> _selectedFiles = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'عام', 'صحة عامة', 'تغذية', 'نفسية', 'أطفال',
    'نساء وولادة', 'قلبية', 'باطنية', 'جلدية', 'عظام',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(result.files);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFiles.isEmpty && _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة محتوى أو صورة للمنشور'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      context.read<CommunityBloc>().add(CreateCommunityPost(
        title: _titleController.text,
        content: _contentController.text.isNotEmpty ? _contentController.text : null,
        files: _selectedFiles.isNotEmpty ? _selectedFiles : null,
        category: _selectedCategory,
      ));

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم نشر المنشور بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل النشر: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 📌 رأس
          Row(
            children: [
              const Spacer(),
              Text(
                'منشور جديد',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),

          // 📝 النموذج
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // العنوان
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'العنوان *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[50],
                      ),
                      validator: (v) => v?.isEmpty ?? true ? 'أدخل العنوان' : null,
                    ),
                    const SizedBox(height: 12),

                    // المحتوى
                    TextFormField(
                      controller: _contentController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'المحتوى',
                        hintText: 'اكتب محتوى منشورك...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // اختيار الملفات
                    GestureDetector(
                      onTap: _pickFiles,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1A2540) : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.upload_file, color: AppColors.primary, size: 30),
                            const SizedBox(height: 4),
                            Text(
                              'اضغط لإضافة صور',
                              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                            ),
                            if (_selectedFiles.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedFiles.asMap().entries.map((e) {
                                    final index = e.key;
                                    final file = e.value;
                                    return Chip(
                                      label: Text(file.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      onDeleted: () => _removeFile(index),
                                      deleteIcon: const Icon(Icons.close, size: 14),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // التصنيف
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'التصنيف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[50],
                      ),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 20),

                    // أزرار
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('إلغاء'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitPost,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.send, size: 18),
                                      SizedBox(width: 8),
                                      Text('نشر'),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
