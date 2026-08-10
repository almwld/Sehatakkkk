import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/search/search_screen.dart';

class HomeSearchBar extends StatelessWidget {
  final bool isDark;

  const HomeSearchBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: isDark ? Colors.grey[400] : Colors.grey[500], size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ابحث عن طبيب، دواء، أو خدمة...',
                style: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.mic, color: isDark ? Colors.grey[500] : Colors.grey[400], size: 22),
          ],
        ),
      ),
    );
  }
}
