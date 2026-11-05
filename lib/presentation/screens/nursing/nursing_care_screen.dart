import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class NursingCareScreen extends StatelessWidget {
  const NursingCareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('تمريض منزلي'))),
      body: Center(child: Text(strings.translate('خدمة التمريض المنزلي'))),
    );
  }
}
