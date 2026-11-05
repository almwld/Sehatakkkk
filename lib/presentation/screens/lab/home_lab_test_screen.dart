import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class HomeLabTestScreen extends StatelessWidget {
  const HomeLabTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('فحص مخبري منزلي'))),
      body: Center(
        child: Text(strings.translate('احجز فحصاً مخبرياً من المنزل')),
      ),
    );
  }
}
