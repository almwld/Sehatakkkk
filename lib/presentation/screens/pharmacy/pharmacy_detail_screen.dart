import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_icons.dart';
import 'package:sehatak/presentation/screens/pharmacy/product_request_screen.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/map/interactive_map_screen.dart';

class PharmacyDetailScreen extends StatelessWidget {
  final Map<String, dynamic> pharmacy;
  const PharmacyDetailScreen({super.key, required this.pharmacy});

  String _text(String key, [String fallback = 'غير متوفر']) {
    final value = pharmacy[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool _bool(String key) {
    final value = pharmacy[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _text('name', 'الصيدلية');
    final image = _text('image', 'https://ik.imagekit.io/fqcynk86c/images/pharmacies/pharmacy_1.png');
    final open = _bool('open');
    final delivery = _bool('delivery');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF4F6F7),
        appBar: AppBar(
          title: Text(name),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(tabs: [Tab(text: 'المعلومات'), Tab(text: 'الطلب')]),
        ),
        body: TabBarView(children: [_infoTab(context, isDark, name, image, open, delivery), _orderTab(context, isDark, name, delivery)]),
      ),
    );
  }

  Widget _infoTab(BuildContext context, bool isDark, String name, String image, bool open, bool delivery) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      if (image.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(image, height: 180, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(isDark))) else _fallback(isDark),
      const SizedBox(height: 16),
      Text(name, style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
      const SizedBox(height: 12),
      _row('assets/icons/map_pins/pharmacy.svg', 'العنوان', _text('address'), isDark),
      _row('assets/icons/services/medical.svg', 'الهاتف', _text('phone'), isDark),
      _row('assets/icons/mini_specialties/heart.svg', 'التقييم', _text('rating', '--'), isDark),
      _row('assets/icons/social/chat_modern.svg', 'التقييمات', _text('reviews', '0'), isDark),
      _row(AppIcons.navPharmacy, 'المسافة', _text('distance'), isDark),
      _row(AppIcons.offerHealthCheck, 'الحالة', open ? 'مفتوحة الآن' : 'مغلقة الآن', isDark),
      _row(AppIcons.serviceMedical, 'التوصيل', delivery ? 'متوفر' : 'غير متوفر', isDark),
      const SizedBox(height: 8),
      OutlinedButton.icon(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InteractiveMapScreen(type: 'pharmacies'))), icon: SvgPicture.asset(AppIcons.navPharmacy, width: 22, height: 22), label: const Text('عرض الصيدليات على الخريطة')),
    ]);
  }

  Widget _orderTab(BuildContext context, bool isDark, String name, bool delivery) {
    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('طلب من $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(delivery ? 'يمكنك رفع الوصفة أو صورة الدواء وإرسال طلبك للصيدلية.' : 'التوصيل غير متاح لهذه الصيدلية حالياً.', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, height: 1.4)), const SizedBox(height: 14), SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: delivery ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductRequestScreen(pharmacyId: '${pharmacy['id'] ?? ''}', pharmacyName: name))) : null, icon: SvgPicture.asset('assets/icons/mini_specialties/pill.svg', width: 22, height: 22, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)), label: const Text('رفع/تصوير الصنف وطلب مثله'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)))]))),
    ]);
  }

  Widget _fallback(bool isDark) => Container(height: 180, decoration: BoxDecoration(color: isDark ? const Color(0xFF182238) : Colors.grey.shade200, borderRadius: BorderRadius.circular(16)), child: SvgPicture.asset('assets/icons/map_pins/pharmacy.svg', width: 70, height: 70, colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn)));

  Widget _row(String icon, String label, String value, bool isDark) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SvgPicture.asset(icon, width: 20, height: 20), const SizedBox(width: 10), Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)))]));
}
