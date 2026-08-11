// ============================================================
// 📱 _buildSignUpRoleTabs - تبويبات الأدوار الموحدة
// ============================================================
Widget _buildSignUpRoleTabs(bool isDark, Color primaryColor) {
  // ✅ تحديد الأدوار المتاحة (إخفاء admin إذا لزم الأمر)
  final availableRoles = _allRoles.where((r) => _showAdminTab || r['id'] != 'admin').toList();

  return SizedBox(
    height: 56,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: availableRoles.length,
      itemBuilder: (context, index) {
        final role = availableRoles[index];
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
                color: isSelected 
                    ? color.withOpacity(0.15) 
                    : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected 
                      ? color 
                      : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    role['icon'] as IconData, 
                    color: isSelected ? color : (isDark ? Colors.grey[500] : Colors.grey[500]), 
                    size: 18, // ✅ تصغير حجم الأيقونة
                  ),
                  const SizedBox(width: 6),
                  Text(
                    role['name'] as String,
                    style: TextStyle(
                      color: isSelected ? color : (isDark ? Colors.white70 : Colors.grey[700]),
                      fontSize: 12, // ✅ تصغير حجم النص قليلاً
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
  );
}
