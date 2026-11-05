import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: _localizedUiText(context, 'سجل الأدوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(_localizedUiText(context, 'سجل الأدوية قيد التطوير')),
      ),
    );
  }
}

String _localizedUiText(BuildContext context, String value) =>
    AppStrings.of(context).translate(value);
