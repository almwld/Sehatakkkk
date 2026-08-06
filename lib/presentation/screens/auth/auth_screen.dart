// ============================================================
// 🔧 تبويبات إنشاء الحساب - نفس حجم شاشة تسجيل الدخول
// ============================================================
Widget _buildSignUpRoleTabs(bool isDark, Color primaryColor) {
  final scrollableRoles = _showAdminTab
      ? _allRoles.where((r) => r['id'] != 'admin').toList().sublist(2)
      : _secondaryRoles;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ✅ التبويبان الرئيسيان (نفس حجم شاشة تسجيل الدخول)
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540).withOpacity(0.5) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: _primaryRoles.map((role) {
            final isSelected = _selectedRole == role['id'];
            final color = Color(role['color'] as int);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRole = role['id'] as String;
                    _selectedSpecialty = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(role['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        role['name'] as String,
                        style: TextStyle(
                          color: isSelected ? color : Colors.grey,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontFamily: 'NotoSansArabicUI',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      // ✅ الأدوار الإضافية - تمرير أفقي (دورين في كل صف)
      if (scrollableRoles.isNotEmpty) ...[
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: scrollableRoles.length,
            itemBuilder: (context, index) {
              final role = scrollableRoles[index];
              final isSelected = _selectedRole == role['id'];
              final color = Color(role['color'] as int);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRole = role['id'] as String;
                      _selectedSpecialty = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(role['icon'] as IconData, color: isSelected ? color : Colors.grey, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          role['name'] as String,
                          style: TextStyle(
                            color: isSelected ? color : Colors.grey,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'NotoSansArabicUI',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ],
  );
}
