import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/consultation/consultation_model.dart';
import 'package:sehatak/core/models/consultation/consultation_status.dart';
import 'package:sehatak/core/models/lab/lab_choice.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  ConsultationModel? _consultation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'الاستشارات الطبية',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.medical_services, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'الاستشارات الطبية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'استشر الأطباء المتخصصين',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _selectLabOption(LabChoice.home),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('طلب استشارة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLabOption(LabChoice choice) async {
    ToastService.showSuccess(context, 'تم اختيار خيار المختبر: ${choice.name}');
  }
}
