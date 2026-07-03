import 'package:flutter/material.dart';
import 'package:sehatak/core/theme/app_theme.dart';
import 'package:sehatak/presentation/screens/more/more_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/map/medical_map_screen.dart';
import 'package:sehatak/presentation/screens/payment/payment_invoice_screen.dart';

void main() {
  runApp(const SehatakApp());
}

class SehatakApp extends StatelessWidget {
  const SehatakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'صحتك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainNavigationScreen(),
      routes: {
        '/chat': (context) => const ChatScreen(),
        '/chat_room': (context) => const ChatRoomScreen(
              contactName: 'د. خالد النخلاني',
              contactType: 'استشاري قلبية',
            ),
        '/map': (context) => const MedicalMapScreen(),
        '/payment': (context) => const PaymentInvoiceScreen(),
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    MoreScreen(),
    ChatScreen(),
    MedicalMapScreen(),
    PaymentInvoiceScreen(),
  ];

  final List<String> _titles = [
    'الرئيسية',
    'المحادثات',
    'الخريطة',
    'الدفع',
  ];

  final List<IconData> _icons = [
    Icons.home_rounded,
    Icons.chat_rounded,
    Icons.map_rounded,
    Icons.payment_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Tajawal',
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontFamily: 'Tajawal',
        ),
        elevation: 8,
        items: List.generate(4, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_icons[index]),
            label: _titles[index],
          );
        }),
      ),
    );
  }
}
