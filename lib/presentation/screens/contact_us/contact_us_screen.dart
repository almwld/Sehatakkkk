import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_images.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC), appBar: AppBar(title: const Text('اتصل بنا'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0), body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: isDark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]), child: Column(children: [Image.asset(AppImages.uiContactUs, width: 60, height: 60, fit: BoxFit.contain), const SizedBox(height: 12), const Text('تواصل مع فريق الدعم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('نحن هنا لمساعدتك في أي وقت', style: TextStyle(fontSize: 14, color: Colors.grey)), const SizedBox(height: 16), _buildContactItem('assets/images/chat/phone_call.webp', 'هاتف', '+967 1 234 567', () => launchUrl(Uri.parse('tel:+9671234567')), isDark), _buildContactItem('assets/images/chat/chat_bubble.webp', 'البريد الإلكتروني', 'info@sehatak.com', () => launchUrl(Uri.parse('mailto:info@sehatak.com')), isDark), _buildContactItem('assets/images/services/map_location.webp', 'العنوان', 'صنعاء - اليمن', () {}, isDark)]))])));
  }
  Widget _buildContactItem(String icon, String label, String value, VoidCallback onTap, bool isDark) {
    final borderColor = isDark ? const Color(0xFF2D3A54) : Colors.grey[200]!;
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Image.asset(icon, width: 20, height: 20, fit: BoxFit.contain)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])), Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black87))])), Image.asset('assets/images/ui/arrow_right.png', width: 16, height: 16, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox(width: 16, height: 16))])));
  }
}
