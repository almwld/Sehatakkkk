import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PharmacyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> pharmacy;

  const PharmacyDetailsScreen({super.key, required this.pharmacy});

  String _text(String key, [String fallback = 'غير متوفر']) {
    final value = pharmacy[key];
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  bool _bool(String key, {bool fallback = false}) {
    final value = pharmacy[key];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final name = _text('name', 'الصيدلية');
    final image = _text('image', '');
    final isOpen = _bool('open');
    final delivery = _bool('delivery');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF4F6F7),
      appBar: AppBar(title: Text(name), backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (image.isNotEmpty)
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network(image, height: 190, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _imageFallback(isDark)))
          else
            _imageFallback(isDark),
          const SizedBox(height: 16),
          Text(name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 19), const SizedBox(width: 5), Text(_text('rating', '--')), const SizedBox(width: 6), Text('(${_text('reviews', '0')} تقييم)', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600))]),
          const SizedBox(height: 16),
          _info(context, Icons.location_on_outlined, 'العنوان', _text('address')),
          _info(context, Icons.phone_outlined, 'الهاتف', _text('phone')),
          _info(context, Icons.location_searching_rounded, 'المسافة', _text('distance')),
          _info(context, Icons.access_time_rounded, 'الحالة', isOpen ? 'مفتوحة الآن' : 'مغلقة الآن'),
          _info(context, Icons.delivery_dining_rounded, 'التوصيل', delivery ? 'متوفر' : 'غير متوفر'),
          const SizedBox(height: 14),
          Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded, color: isOpen ? Colors.green : Colors.red), const SizedBox(width: 10), Expanded(child: Text(isOpen ? 'الصيدلية تستقبل الطلبات حالياً.' : 'الصيدلية مغلقة حالياً. تحقق من ساعات العمل قبل الطلب.', style: const TextStyle(fontSize: 13, height: 1.4)))]))),
        ],
      ),
    );
  }

  Widget _imageFallback(bool isDark) => Container(height: 190, decoration: BoxDecoration(color: isDark ? const Color(0xFF182238) : Colors.grey.shade200, borderRadius: BorderRadius.circular(16)), child: Icon(Icons.local_pharmacy_rounded, size: 72, color: isDark ? Colors.grey.shade500 : Colors.grey.shade500));

  Widget _info(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, size: 20, color: AppColors.primary), const SizedBox(width: 10), Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade300 : Colors.grey.shade700)))]));
  }
}
