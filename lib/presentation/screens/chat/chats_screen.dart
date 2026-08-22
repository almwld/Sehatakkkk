// ✅ أضف في chats_screen.dart - زر المجموعات في شريط التطبيق
// ✅ وأضف التاب في FloatingActionButton

// ✅ في AppBar إضافة زر المجموعات
actions: [
  IconButton(
    icon: Icon(Icons.group, color: isDark ? Colors.white : Colors.black87),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GroupsScreen()),
      );
    },
    tooltip: 'المجموعات',
  ),
  // ✅ زر البحث الموجود
  IconButton(
    icon: Icon(Icons.search, color: isDark ? Colors.white : Colors.black87),
    onPressed: _showSearch,
  ),
],

// ✅ تعديل FloatingActionButton
floatingActionButton: FloatingActionButton(
  onPressed: _startNewChat,
  backgroundColor: AppColors.primary,
  child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
),
// ✅ إضافة FloatingActionButton.extended للمجموعات
floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroupsScreen()),
        );
      },
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.group_add, color: Colors.white),
    ),
    const SizedBox(height: 8),
    FloatingActionButton.small(
      onPressed: _startNewChat,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
    ),
  ],
),
