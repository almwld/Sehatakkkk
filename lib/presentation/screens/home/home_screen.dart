// ... باقي الكود كما هو ...

// ✅ في _HomeScreenState، تأكد من أن _screens تحتوي على 7 شاشات
final List<Widget> _screens = [
  const HomeTab(),              // 1️⃣ الرئيسية
  const DoctorsListScreen(),    // 2️⃣ الأطباء
  const PharmacyScreen(),       // 3️⃣ الصيدلية
  const ChatScreen(),           // 4️⃣ الدردشة ✅
  const PatientAppointments(),  // 5️⃣ مواعيدي
  const PatientDashboard(),     // 6️⃣ صحتي ✅
  const MoreScreen(),           // 7️⃣ المزيد
];

// ✅ في build، navItems تأتي من ImageService مع 7 أيقونات
final navItems = ImageService.navItems; // ← 7 أيقونات

// ✅ في BottomNavigationBar
items: navItems.asMap().entries.map((entry) {
  final index = entry.key;
  final item = entry.value;
  final isSelected = _selectedIndex == index;
  final color = isSelected ? AppColors.primary : Colors.grey;
  final isSpecial = index == 3; // الدردشة (أيقونة خاصة)
  
  return BottomNavigationBarItem(
    icon: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(top: isSpecial ? 8 : 0),
      transform: Matrix4.identity()..scale(isSelected ? 1.1 : 1.0),
      child: ImageService.svgIcon(
        item['icon'] as String,
        size: isSpecial ? 30 : 24,
        color: color,
      ),
    ),
    label: item['label'] as String,
  );
}).toList(),
