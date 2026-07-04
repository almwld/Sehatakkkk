import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languages = [
      {'name': 'العربية', 'code': 'ar', 'flag': '🇸🇦', 'selected': true},
      {'name': 'English', 'code': 'en', 'flag': '🇬🇧', 'selected': false},
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('اللغة'),
        backgroundColor: const Color(0xFF0D5257),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          return Card(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: lang['selected'] as bool ? const Color(0xFF0D5257) : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              leading: Text(lang['flag'] as String, style: const TextStyle(fontSize: 32)),
              title: Text(
                lang['name'] as String,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              trailing: lang['selected'] as bool
                  ? const Icon(Icons.check_circle, color: Color(0xFF0D5257))
                  : null,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم تغيير اللغة'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
