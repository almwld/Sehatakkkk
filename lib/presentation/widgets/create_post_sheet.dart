import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatak/bloc/community/community_bloc.dart';
import 'package:sehatak/bloc/community/community_event.dart';
import 'package:sehatak/bloc/community/community_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const CreatePostSheet(),
      );

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

  final List<String> _categories = ['عام', 'صحة عامة', 'تغذية', 'نفسية', 'أطفال', 'نساء وولادة', 'قلبية', 'باطنية', 'جلدية', 'عظام'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<bool> _isVerifiedDoctor() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data() ?? <String, dynamic>{};
    return data['role'] == 'doctor' && data['isVerified'] == true;
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    );
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _selectedFiles.addAll(result.files));
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFiles.isEmpty && _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى إضافة محتوى أو صورة للمنشور')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (!await _isVerifiedDoctor()) throw Exception('النشر متاح للأطباء الموثقين فقط');
      if (!mounted) return;
      context.read<CommunityBloc>().add(CreateCommunityPost(
            title: _titleController.text.trim(),
            content: _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
            files: _selectedFiles.isEmpty ? null : _selectedFiles,
            category: _selectedCategory,
          ));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (state.status == CommunityStatus.loaded && _isLoading) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نشر المنشور بنجاح')));
        } else if (state.status == CommunityStatus.error && _isLoading) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'فشل النشر')));
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * .85,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? const Color(0xFF0B1121) : Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          children: [
            Row(children: [
              const Spacer(),
              Text('منشور جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Spacer(),
              TextButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('إغلاق')),
            ]),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    TextFormField(controller: _titleController, decoration: InputDecoration(labelText: 'العنوان *', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[50]), validator: (v) => v?.trim().isEmpty ?? true ? 'أدخل العنوان' : null),
                    const SizedBox(height: 12),
                    TextFormField(controller: _contentController, maxLines: 5, decoration: InputDecoration(labelText: 'المحتوى', hintText: 'اكتب محتوى منشورك...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[50])),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _isLoading ? null : _pickFiles,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                        child: Column(children: [
                          Text('إضافة صور', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('سيتم رفع الوسائط إلى Nextcloud فقط', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 12)),
                          if (_selectedFiles.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Wrap(spacing: 8, runSpacing: 8, children: _selectedFiles.asMap().entries.map((e) => Chip(label: Text(e.value.name, maxLines: 1, overflow: TextOverflow.ellipsis), onDeleted: _isLoading ? null : () => setState(() => _selectedFiles.removeAt(e.key)))).toList()),
                            ),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(value: _selectedCategory, decoration: InputDecoration(labelText: 'التصنيف', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[50]), items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: _isLoading ? null : (v) => setState(() => _selectedCategory = v!)),
                    const SizedBox(height: 20),
                    Row(children: [
                      Expanded(child: OutlinedButton(onPressed: _isLoading ? null : () => Navigator.pop(context), child: const Text('إلغاء'))),
                      const SizedBox(width: 12),
                      Expanded(flex: 2, child: ElevatedButton(onPressed: _isLoading ? null : _submitPost, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('نشر'))),
                    ]),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
