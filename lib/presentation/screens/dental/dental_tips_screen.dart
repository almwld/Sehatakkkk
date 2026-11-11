import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/core/services/dental_service.dart';

class DentalTipsScreen extends StatelessWidget {
  const DentalTipsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(_localizedUiText(context, 'نصائح صحة الأسنان'))),
      body: StreamBuilder(
        stream: DentalService().streamTips(limit: 30),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: data.map((tip) => Card(
              child: ExpansionTile(
                title: Text(localizedField(tip.sourceData, 'title', strings.locale, fallback: strings.translate(tip.title))),
                subtitle: Text(localizedField(tip.sourceData, 'category', strings.locale, fallback: strings.translate(tip.category))),
                children: [Padding(padding: const EdgeInsets.all(16), child: Text(localizedField(tip.sourceData, 'body', strings.locale, fallback: strings.translate(tip.body))))],
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}


String _localizedUiText(BuildContext context, String value) =>
    AppStrings.of(context).translate(value);
