import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class DoctorCard extends StatelessWidget {
  final String name, specialty, experience;
  final double rating;
  final int reviews;
  final VoidCallback onTap;
  const DoctorCard({required this.name, required this.specialty, required this.experience, this.rating = 4.5, this.reviews = 100, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4))),
        child: Row(children: [
          CircleAvatar(radius: 26, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person, color: AppColors.primary, size: 28)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(specialty, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
            Text(experience, style: const TextStyle(color: AppColors.darkGrey, fontSize: 10)),
            Row(children: [
              const Icon(Icons.star, color: AppColors.amber, size: 13),
              Text(' $rating ($reviews تقييم)', style: const TextStyle(fontSize: 10, color: AppColors.darkGrey)),
            ]),
          ])),
          const Icon(Icons.chevron_left, color: AppColors.grey),
        ]),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final String hint;
  const CustomSearchBar({super.key, this.hint = 'بحث...'});
  @override
  Widget build(BuildContext context) {
    return TextField(
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.grey),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 13),
      ),
    );
  }
}

// ========== HeroBannerCard ==========
class HeroBannerCard extends StatelessWidget {
  final VoidCallback onTap;
  const HeroBannerCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF00796B), Color(0xFF004D40)]),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: const Color(0xFF00796B).withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('منصة صحتك، أولويتنا', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('رعاية موثوقة في أي وقت وأي مكان', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: onTap, icon: const Icon(Icons.explore, size: 18), label: const Text('استكشف الآن'), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0)),
        ]),
      ),
    );
  }
}

// ========== QuickServiceCard ==========
class QuickServiceCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickServiceCard({super.key, required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 52, height: 52, decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.15))), child: Icon(icon, color: color, size: 24)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ========== LoginPromptBar ==========
class LoginPromptBar extends StatelessWidget {
  final VoidCallback onTap;
  const LoginPromptBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 10)],
      ),
      child: Row(children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.person, color: Colors.white, size: 22)),
        const SizedBox(width: 12),
        const Expanded(child: Text('مرحباً بك في منصة صحتك\nسجل دخولك للاستفادة من جميع الخدمات', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white, fontSize: 13))),
        ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), elevation: 0), child: const Text('تسجيل', style: TextStyle(fontWeight: FontWeight.bold))),
      ]),
    );
  }
}
