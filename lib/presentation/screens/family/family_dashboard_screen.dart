import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/child_model.dart';
import 'package:sehatak/core/services/child_service.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/health/child_health_screen.dart';

class FamilyDashboardScreen extends StatelessWidget {
  const FamilyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('حساب العائلة'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: StreamBuilder<List<ChildModel>>(
        stream: ChildService.instance.streamChildren(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('تعذر تحميل الأطفال: '+snapshot.error.toString()));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final children = snapshot.data!;
          if (children.isEmpty) {
            return Center(child: ElevatedButton.icon(
              onPressed: () => _addChild(context),
              icon: const Icon(Icons.add), label: const Text('إضافة طفل'),
            ));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final initial = child.name.isEmpty ? 'ط' : child.name.substring(0, 1);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(.12),
                    backgroundImage: child.photoUrl?.isNotEmpty == true ? NetworkImage(child.photoUrl!) : null,
                    child: child.photoUrl?.isNotEmpty == true ? null : Text(initial),
                  ),
                  title: Text(child.name),
                  subtitle: Text(child.ageLabel + ' • ' + (child.gender == 'male' ? 'ذكر' : 'أنثى')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChildHealthScreen(childId: child.id))),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addChild(context),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('إضافة طفل'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _addChild(BuildContext context) async {
    if (FirebaseAuth.instance.currentUser == null) {
      ToastService.showError('يجب تسجيل الدخول أولاً');
      return;
    }
    final name = TextEditingController();
    final weight = TextEditingController();
    final height = TextEditingController();
    final head = TextEditingController();
    DateTime? birthDate;
    String gender = 'male';
    File? photo;
    bool saving = false;
    final childId = 'child_${DateTime.now().microsecondsSinceEpoch}';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setState) => Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('إضافة طفل', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 500);
                  if (picked != null) setState(() => photo = File(picked.path));
                },
                child: CircleAvatar(radius: 45, backgroundImage: photo == null ? null : FileImage(photo!), child: photo == null ? const Icon(Icons.add_a_photo) : null),
              ),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'اسم الطفل', border: OutlineInputBorder())),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.cake),
                title: Text(birthDate == null ? 'تاريخ الميلاد مطلوب' : birthDate!.toString().split(' ').first),
                onTap: () async {
                  final picked = await showDatePicker(context: sheetContext, initialDate: DateTime.now().subtract(const Duration(days: 365)), firstDate: DateTime(2000), lastDate: DateTime.now());
                  if (picked != null) setState(() => birthDate = picked);
                },
              ),
              Row(children: [
                Expanded(child: RadioListTile<String>(value: 'male', groupValue: gender, onChanged: (v) => setState(() => gender = v ?? 'male'), title: const Text('ذكر'))),
                Expanded(child: RadioListTile<String>(value: 'female', groupValue: gender, onChanged: (v) => setState(() => gender = v ?? 'female'), title: const Text('أنثى'))),
              ]),
              Row(children: [
                Expanded(child: TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الوزن (كجم)', border: OutlineInputBorder()))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: height, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'الطول (سم)', border: OutlineInputBorder()))),
              ]),
              const SizedBox(height: 10),
              TextField(controller: head, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'محيط الرأس (سم)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saving ? null : () async {
                    if (name.text.trim().isEmpty || birthDate == null) {
                      ToastService.showError('اسم الطفل وتاريخ الميلاد مطلوبان');
                      return;
                    }
                    setState(() => saving = true);
                    try {
                      String? photoUrl;
                      if (photo != null) {
                        final nc = NextcloudService();
                        await nc.loadConfig();
                        final upload = await nc.uploadFile(
                          file: photo!,
                          path: 'children',
                          fileName: '$childId.jpg',
                        );
                        if (!upload.success) {
                          throw StateError(upload.error ?? 'تعذر رفع الصورة');
                        }
                        photoUrl = upload.url;
                      }
                      await ChildService.instance.addChild(
                        childId: childId,
                        name: name.text,
                        birthDate: birthDate!,
                        gender: gender,
                        weight: double.tryParse(weight.text),
                        height: double.tryParse(height.text),
                        headCircumference: double.tryParse(head.text),
                        photoUrl: photoUrl,
                      );
                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                      ToastService.showSuccess('تم إضافة الطفل بنجاح');
                    } catch (e) {
                      ToastService.showError('تعذر إضافة الطفل: '+e.toString().replaceFirst('StateError: ', ''));
                    } finally {
                      if (sheetContext.mounted) setState(() => saving = false);
                    }
                  },
                  child: Text(saving ? 'جاري الحفظ...' : 'حفظ'),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
    name.dispose(); weight.dispose(); height.dispose(); head.dispose();
  }
}
