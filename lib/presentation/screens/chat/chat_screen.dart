import 'package:flutter/material.dart';
import 'package:sehatak/core/theme/app_theme.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _activeTab = 0;
  final List<String> _tabs = ['الكل', 'الأطباء', 'الصيدليات', 'الذكاء الاصطناعي'];

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'المساعد الصحي الذكي',
      'message': 'كيف يمكنني مساعدتك اليوم؟ أنا في انتظارك.',
      'time': 'الآن',
      'unreadCount': 0,
      'isVerified': true,
      'label': 'ذكاء اصطناعي',
      'labelColor': AppTheme.accentColor,
      'icon': Icons.smart_toy_outlined,
      'type': 'ai',
    },
    {
      'name': 'د. خالد النخلاني',
      'message': 'شكراً على الاستشارة، يرجى الالتزام بالجرعات المحددة.',
      'time': 'أمس',
      'unreadCount': 0,
      'isVerified': true,
      'label': 'استشاري',
      'labelColor': AppTheme.primaryColor,
      'icon': Icons.healing_outlined,
      'type': 'doctor',
    },
    {
      'name': 'صيدلية الشفاء',
      'message': '📢 عرض خاص: خصم 30% على مستحضرات العناية بالبشرة.',
      'time': 'أمس',
      'unreadCount': 0,
      'isVerified': true,
      'label': 'صيدلية',
      'labelColor': Colors.orange,
      'icon': Icons.local_pharmacy_outlined,
      'type': 'pharmacy',
    },
    {
      'name': 'مجموعة الأطباء (مستشاري الباطنية)',
      'message': 'د. علي: تم تحديث مواعيد الفحص الدوري للجماعة.',
      'time': 'الثلاثاء',
      'unreadCount': 8,
      'isVerified': false,
      'label': 'مجموعة',
      'labelColor': Colors.purple,
      'icon': Icons.group_outlined,
      'type': 'group',
    },
  ];

  List<Map<String, dynamic>> get _filteredChats {
    if (_activeTab == 0) return _chats;
    final typeMap = ['', 'doctor', 'pharmacy', 'ai'];
    final type = typeMap[_activeTab];
    return _chats.where((c) => c['type'] == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1121) : AppTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0.5,
        title: const Text(
          'المحادثات الطبية',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
      body: Column(
        children: [
          _buildFilterTabs(isDark),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filteredChats.length,
              itemBuilder: (context, index) {
                return _buildChatCard(_filteredChats[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isDark) {
    return Container(
      height: 56,
      color: isDark ? const Color(0xFF0B1121) : Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _activeTab == index;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : (isDark ? const Color(0xFF1A2540) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontFamily: 'Tajawal',
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatCard(Map<String, dynamic> chat) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = chat['labelColor'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey[800]! : AppTheme.cardBorderColor, width: 0.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: labelColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(chat['icon'] as IconData, color: labelColor, size: 26),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat['name'] as String,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 15, fontFamily: 'Tajawal'),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: labelColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text(chat['label'] as String, style: TextStyle(color: labelColor, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Text(
            chat['message'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[500], fontSize: 13, fontFamily: 'Tajawal'),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatRoomScreen(
                contactName: chat['name'] as String,
                contactType: chat['label'] as String,
              ),
            ),
          );
        },
      ),
    );
  }
}
