import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class HomeVisitScreen extends StatelessWidget {
  const HomeVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.translate('زيارة طبية منزلية'))),
      body: Center(
        child: Text(strings.translate('احجز زيارة طبيب إلى المنزل')),
      ),
    );
  }
}
