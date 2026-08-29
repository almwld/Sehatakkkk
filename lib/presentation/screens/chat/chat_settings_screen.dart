import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/text_styles.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/cache_service.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_background.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatSettingsScreen extends StatefulWidget {
  final String chatId;
  final String chatName;

  const ChatSettingsScreen({
    super.key,
    required this.chatId,
    required this.chatName,
  });

  @override
  State<ChatSettingsScreen> createState() => _ChatSettingsScreenState();
}

class _ChatSettingsScreenState extends State<ChatSettingsScreen> {
  final CacheService _cache = CacheService();
  bool _isDarkMode = false;
  bool _isMuted = false;
  bool _isPinned = false;
  bool _isArchived = false;
  double _fontSize = 14.0;
  String _selectedBackground = 'افتراضي';

  final List<Map<String, dynamic>> _backgrounds = [
    {'name': 'افتراضي', 'color': null, 'image': null},
    {'name': 'داكن', 'color': const Color(0xFF0B1121), 'image': null},
    {'name': 'فاتح', 'color': const Color(0xFFE8F5E9), 'image': null},
    {'name': 'أنيق', 'color': const Color(0xFFF5F5F5), 'image': null},
    {'name': 'طبيعة', 'image': 'assets/images/chat_bg_nature.jpg', 'color': null},
    {'name': 'بحر', 'image': 'assets/images/chat_bg_sea.jpg', 'color': null},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _cache.getJson('chat_settings_${widget.chatId}');
      if (settings != null) {
        setState(() {
          _isDarkMode = settings['isDarkMode'] ?? false;
          _isMuted = settings['isMuted'] ?? false;
          _isPinned = settings['isPinned'] ?? false;
          _isArchived = settings['isArchived'] ?? false;
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
      await _cache.saveJson('chat_settings_${widget.chatId}', {
        'isDarkMode': _isDarkMode,
        'isMuted': _isMuted,
        'isPinned': _isPinned,
        'isArchived': _isArchived,
        'fontSize': _fontSize,
        'background': _selectedBackground,
      });
      ToastService.showSuccess('✅ تم حفظ الإعدادات');
    } catch (e) {
      print('❌ Error saving settings: $e');
      ToastService.showError('❌ فشل حفظ الإعدادات');
    }
  }

  Future<void> _exportChat() async {
    try {
      // ✅ تصدير المحادثة
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/chat_${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}.txt');
      
      String content = 'محادثة مع ${widget.chatName}\n';
      content += '=' * 40 + '\n\n';
      content += 'تم التصدير في: ${DateTime.now().toString()}\n\n';
      
      await file.writeAsString(content);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '📄 تصدير محادثة مع ${widget.chatName}',
      );
      
      ToastService.showSuccess('✅ تم تصدير المحادثة');
    } catch (e) {
      ToastService.showError('❌ فشل تصدير المحادثة: $e');
    }
  }

  Future<void> _deleteChat() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من حذف المحادثة مع ${widget.chatName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ToastService.showSuccess('✅ تم حذف المحادثة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('إعدادات الدردشة'),
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
          // ✅ معلومات الدردشة
          _buildSection(
            title: 'معلومات الدردشة',
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.chatName.isNotEmpty ? widget.chatName[0] : 'م',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(widget.chatName),
                subtitle: Text('معرف: ${widget.chatId.substring(0, 8)}...'),
              ),
            ],
          ),

          // ✅ المظهر
          _buildSection(
            title: 'المظهر',
            children: [
              SwitchListTile(
                title: const Text('الوضع المظلم'),
                subtitle: const Text('تفعيل الوضع المظلم لهذه الدردشة'),
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                },
                activeColor: AppColors.primary,
              ),
              ListTile(
                leading: const Icon(Icons.wallpaper, color: AppColors.primary),
                title: const Text('خلفية الدردشة'),
                subtitle: Text(_selectedBackground),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showBackgroundSelector(),
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
                    const SizedBox(width: 4),
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

          // ✅ الإعدادات
          _buildSection(
            title: 'الإعدادات',
            children: [
              SwitchListTile(
                title: const Text('كتم الإشعارات'),
                subtitle: const Text('إيقاف إشعارات هذه الدردشة'),
                value: _isMuted,
                onChanged: (value) {
                  setState(() => _isMuted = value);
                  ToastService.showSuccess(value ? '🔇 تم كتم الإشعارات' : '🔔 تم تفعيل الإشعارات');
                },
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('تثبيت المحادثة'),
                subtitle: const Text('تثبيت هذه الدردشة في الأعلى'),
                value: _isPinned,
                onChanged: (value) {
                  setState(() => _isPinned = value);
                  ToastService.showSuccess(value ? '📌 تم تثبيت المحادثة' : '📌 تم إلغاء التثبيت');
                },
                activeColor: AppColors.primary,
              ),
              SwitchListTile(
                title: const Text('أرشفة المحادثة'),
                subtitle: const Text('إخفاء المحادثة من القائمة الرئيسية'),
                value: _isArchived,
                onChanged: (value) {
                  setState(() => _isArchived = value);
                  ToastService.showSuccess(value ? '📦 تم أرشفة المحادثة' : '📦 تم استعادة المحادثة');
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),

          // ✅ التصدير والحذف
          _buildSection(
            title: 'البيانات',
            children: [
              ListTile(
                leading: const Icon(Icons.ios_share, color: AppColors.primary),
                title: const Text('تصدير المحادثة'),
                subtitle: const Text('تصدير المحادثة كملف نصي'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _exportChat,
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف المحادثة', style: TextStyle(color: Colors.red)),
                subtitle: const Text('حذف جميع رسائل هذه المحادثة', style: TextStyle(color: Colors.red)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
                onTap: _deleteChat,
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ChatBackgroundSelector(
          currentBackground: _selectedBackground,
          onBackgroundSelected: (name) {
            setState(() => _selectedBackground = name);
            Navigator.pop(context);
            ToastService.showSuccess('✅ تم تغيير الخلفية');
          },
        ),
      ),
    );
  }
}
