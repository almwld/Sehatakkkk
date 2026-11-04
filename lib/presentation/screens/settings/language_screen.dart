import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/providers/app_locale_controller.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const List<Map<String, String>> _languages = [
    {'code': 'ar', 'native': 'العربية', 'english': 'Arabic'},
    {'code': 'en', 'native': 'English', 'english': 'English'},
    {'code': 'fr', 'native': 'Français', 'english': 'French'},
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final localeController = context.watch<AppLocaleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: strings.language,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, bottom: 14),
            child: Text(
              strings.chooseLanguage,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF263238),
              ),
            ),
          ),
          ..._languages.map((language) {
            final code = language['code']!;
            final selected = localeController.languageCode == code;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? AppColors.primary : Colors.transparent,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                title: Text(
                  language['native']!,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  language['english']!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: selected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : Icon(Icons.circle_outlined, color: isDark ? Colors.white38 : Colors.black26),
                onTap: () async {
                  await localeController.setLanguage(code);
                  if (context.mounted) {
                    ToastService.showSuccess(code == 'en' ? 'Language preference saved' : code == 'fr' ? 'Préférence linguistique enregistrée' : 'تم حفظ اللغة');
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
