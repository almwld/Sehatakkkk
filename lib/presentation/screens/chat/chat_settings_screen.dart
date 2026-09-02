import 'package:flutter/material.dart';

class ChatSettingsScreen extends StatelessWidget {
  const ChatSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات الدردشة'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: null,
            title: const Text('الإشعارات'),
            subtitle: const Text(
              'تتم إدارة الإشعارات عبر FCM.',
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.wallpaper_rounded,
            ),
            title: const Text('خلفية الدردشة'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
