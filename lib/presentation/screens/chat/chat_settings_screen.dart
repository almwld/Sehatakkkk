// ============================================================
// ⚙️ شاشة إعدادات الدردشة
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/cache_service.dart';

class ChatSettingsScreen extends StatefulWidget {
  const ChatSettingsScreen({super.key});

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final CacheService _cache = CacheService();
  
  bool _darkMode = false;
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;
  double _fontSize = 14.0;
  String _selectedBackground = 'افتراضي';

  final List<Map<String, dynamic>> _backgrounds = [
    {'name': 'افتراضي', 'color': null},
    {'name': 'داكن', 'color': const Color(0xFF0B1121)},
    {'name': 'فاتح', 'color': const Color(0xFFE8F5E9)},
    {'name': 'أزرق', 'color': const Color(0xFFE3F2FD)},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _cache.getJson('chat_settings');
      if (settings != null) {
        setState(() {
          _darkMode = settings['darkMode'] ?? false;
          _notifications = settings['notifications'] ?? true;
          _sound = settings['sound'] ?? true;
          _vibration = settings['vibration'] ?? true;
          _fontSize = settings['fontSize'] ?? 14.0;
          _selectedBackground = settings['background'] ?? 'افتراضي';
        });
      }
    } catch (e) {
      print('❌ Error loading settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      await _cache.saveJson('chat_settings', {
        'darkMode': _darkMode,
        'notifications': _notifications,
        'sound': _sound,
        'vibration': _vibration,
        'fontSize': _fontSize,
        'background': _selectedBackground,
      });
      ToastService.showSuccess('✅ تم حفظ الإعدادات');
    } catch (e) {
      ToastService.showError('❌ فشل حفظ الإعدادات: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(AppStrings.chatSettings),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'المظهر',
            children: [
              SwitchListTile(
                title: const Text('الوضع المظلم'),
                subtitle: const Text('تفعيل الوضع المظلم في الدردشة'),
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
                activeColor: AppColors.primary,
              ),
              ListTile(
                leading: const Icon(Icons.wallpaper, color: AppColors.primary),
                title: const Text('خلفية الدردشة'),
                subtitle: Text(_selectedBackground),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showBackgroundSelector,
              ),
              ListTile(
                leading: const Icon(Icons.text_fields, color: AppColors.primary),
                title: const Text('حجم الخط'),
                subtitle: Text('${_fontSize.toStringAsFixed(0)} بكسل'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () {
                        if (_fontSize > 10) {
                          setState(() => _fontSize--);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () {
                        if (_fontSize < 24) {
                          setState(() => _fontSize++);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          _buildSection(
            title: 'الإشعارات',
            children: [
              SwitchListTile(
                title: const Text('الإشعارات'),
                subtitle: const Text('تفعيل إشعارات الدردشة'),
                value: _notifications,
                onChanged: (value) => setState(() => _notifications = value),
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('الصوت'),
                subtitle: const Text('تشغيل صوت الإشعارات'),
                value: _sound,
                onChanged: (value) => setState(() => _sound = value),
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('الاهتزاز'),
                subtitle: const Text('تفعيل الاهتزاز مع الإشعارات'),
                value: _vibration,
                onChanged: (value) => setState(() => _vibration = value),
                activeColor: AppColors.primary,
              ),
            ],
          ),
          _buildSection(
            title: 'البيانات',
            children: [
              ListTile(
                leading: const Icon(Icons.ios_share, color: AppColors.primary),
                title: const Text('تصدير المحادثات'),
                subtitle: const Text('تصدير جميع المحادثات كملف نصي'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => ToastService.showInfo('📤 جاري تصدير المحادثات...'),
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('حذف جميع المحادثات', style: TextStyle(color: Colors.red)),
                subtitle: const Text('حذف جميع المحادثات نهائياً', style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                onTap: _showDeleteAllConfirmation,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  void _showBackgroundSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر خلفية الدردشة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _backgrounds.map((bg) {
                final isSelected = _selectedBackground == bg['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedBackground = bg['name']);
                    Navigator.pop(context);
                    ToastService.showSuccess('✅ تم تغيير الخلفية');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: bg['color'] ?? Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      bg['name'],
                      style: TextStyle(
                        color: bg['color'] != null ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع المحادثات'),
        content: const Text('هل أنت متأكد من حذف جميع المحادثات؟ هذا الإجراء لا يمكن التراجع عنه.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ToastService.showSuccess('✅ تم حذف جميع المحادثات');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }
}
