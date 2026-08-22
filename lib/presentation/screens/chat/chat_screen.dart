import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/data/repositories/chat_repository.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';
import 'package:sehatak/presentation/screens/chat/calls_screen.dart';
import 'package:sehatak/presentation/screens/chat/updates_screen.dart';
import 'package:sehatak/presentation/screens/chat/search_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:sehatak/core/services/haptic_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ChatRepository _chatRepo = ChatRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HapticService _haptic = HapticService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _chatRepo.updateUserStatus(true);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatRepo.updateUserStatus(false);
    super.dispose();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'م';
    final parts = name.split(' ');
    if (parts.length >= 2) return parts[0][0] + parts[1][0];
    return name[0];
  }

  Color _getUserColor(String userId) {
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];
    final index = userId.hashCode.abs() % colors.length;
    return colors[index];
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${time.day}/${time.month}';
  }

  void _navigateToChat(ChatModel chat) {
    _haptic.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ChatDetailScreen(
              chatId: chat.id,
              userName: chat.getOtherName(_auth.currentUser?.uid ?? ''),
              userId: _auth.currentUser?.uid ?? '',
              isDoctor: chat.isDoctor(_auth.currentUser?.uid ?? ''),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _onTabChange(int index) {
    _haptic.selectionClick();
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      // ✅ AppBar ظاهر مع التبويبات
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
            onPressed: _showSearch,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: isDark ? Colors.white : AppColors.primary,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          onTap: _onTabChange,
          tabs: const [
            Tab(text: 'المحادثات'),
            Tab(text: 'المكالمات'),
            Tab(text: 'الحالات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(isDark),
          const CallsScreen(),
          const UpdatesScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  Widget _buildChatsTab(bool isDark) {
    return StreamBuilder<List<ChatModel>>(
      stream: _chatRepo.getChats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ChatShimmer(isDark: isDark);
        }

        if (snapshot.hasError) {
          return _buildErrorState(isDark);
        }

        final chats = snapshot.data ?? [];
        if (chats.isEmpty) {
          return _buildEmptyState(isDark);
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _buildChatTile(chat, isDark, index);
          },
        );
      },
    );
  }

  Widget _buildChatTile(ChatModel chat, bool isDark, int index) {
    final userId = _auth.currentUser?.uid ?? '';
    final name = chat.getOtherName(userId);
    final unreadCount = chat.getUnreadCount(userId);
    final time = _formatTime(chat.lastMessageTime);
    final color = _getUserColor(chat.id);

    return GestureDetector(
      onTap: () => _navigateToChat(chat),
      onLongPress: () {
        _haptic.heavyImpact();
        _showChatOptions(chat);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: unreadCount > 0
                                ? (isDark ? Colors.white : Colors.black87)
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatOptions(ChatModel chat) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.push_pin, color: AppColors.primary),
              title: const Text('تثبيت المحادثة'),
              onTap: () {
                _haptic.mediumImpact();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: AppColors.primary),
              title: const Text('كتم الإشعارات'),
              onTap: () {
                _haptic.mediumImpact();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: AppColors.primary),
              title: const Text('أرشفة المحادثة'),
              onTap: () {
                _haptic.mediumImpact();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('حذف المحادثة', style: TextStyle(color: Colors.red)),
              onTap: () {
                _haptic.heavyImpact();
                Navigator.pop(context);
                _showDeleteConfirmation(chat);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ChatModel chat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: Text('هل أنت متأكد من حذف المحادثة مع ${chat.getOtherName(_auth.currentUser?.uid ?? '')}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              _haptic.heavyImpact();
              _chatRepo.deleteChat(chat.id);
              Navigator.pop(context);
              // ✅ استخدام Toast بدلاً من SnackBar
              _showToast('✅ تم حذف المحادثة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ✅ دالة Toast بدلاً من SnackBar
  void _showToast(String message) {
    // ✅ استخدام BotToast أو FlutterToast
    // مؤقتاً نستخدم SnackBar لكن بخلفية مختلفة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد محادثات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ محادثة جديدة مع طبيبك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('محادثة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ في تحميل المحادثات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    _haptic.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _startNewChat() {
    _haptic.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0b141a),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'بدء محادثة جديدة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildNewChatOption(
              icon: Icons.person_add,
              title: 'محادثة فردية',
              subtitle: 'ابدأ محادثة مع طبيب',
              onTap: () {
                Navigator.pop(context);
                _showToast('🔍 ابحث عن طبيب لبدء محادثة');
              },
            ),
            const SizedBox(height: 12),
            _buildNewChatOption(
              icon: Icons.group_add,
              title: 'مجموعة جديدة',
              subtitle: 'أنشئ مجموعة دردشة',
              onTap: () {
                Navigator.pop(context);
                _showToast('👥 جاري إنشاء مجموعة...');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNewChatOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF202c33),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 14),
          ],
        ),
      ),
    );
  }
}
