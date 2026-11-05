import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class DeliveryHealthInfoScreen extends StatefulWidget {
  const DeliveryHealthInfoScreen({super.key});
  @override State<DeliveryHealthInfoScreen> createState() => _DeliveryHealthInfoScreenState();
}

class _DeliveryHealthInfoScreenState extends State<DeliveryHealthInfoScreen> {
  String _t(BuildContext context, String value) => AppStrings.of(context).translate(value);

  String _area = ''; String _address = ''; String _phone = '';
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { _area = prefs.getString('delivery_area') ?? ''; _address = prefs.getString('delivery_address') ?? ''; _phone = prefs.getString('delivery_phone') ?? ''; });
  }
  @override Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final address = _address.isEmpty ? _t(context, 'لم يتم تحديد عنوان التوصيل') : '${_area.isEmpty ? '' : '$_area — ' }$_address';
    return Scaffold(backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC), appBar: CustomAppBar(title: _t(context, 'معلومات التوصيل الصحي'), backgroundColor: AppColors.primary, foregroundColor: Colors.white), body: ListView(padding: const EdgeInsets.all(16), children: [
      _card(context, dark, Icons.location_on_outlined, 'عنوان التسليم', address),
      _card(context, dark, Icons.phone_outlined, 'رقم التواصل', _phone.isEmpty ? _t(context, 'أضف رقم التواصل من إعدادات الحساب') : _phone),
      _card(context, dark, Icons.medication_outlined, 'تعليمات صحية مهمة', 'عند توصيل الأدوية، اذكر للمندوب أي تعليمات خاصة بالحفظ أو التسليم. الأدوية الحساسة للحرارة تُحفظ وتُنقل وفق تعليمات الصيدلية.'),
      _card(context, dark, Icons.verified_user_outlined, 'سلامة التسليم', 'تحقق من اسم المستلم والطلب قبل الاستلام، ولا تستلم دواءً بعبوة تالفة أو غير مطابقة للطلب.'),
      const SizedBox(height: 8),
      SizedBox(height: 50, child: ElevatedButton.icon(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.edit_location_alt_outlined), label: Text(_t(context, 'تحديث عنوان التوصيل')), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white))),
    ]));
  }
  Widget _card(BuildContext context, bool dark, IconData icon, String title, String value) => Card(margin: const EdgeInsets.only(bottom: 12), elevation: 0, child: Padding(padding: const EdgeInsets.all(16), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.primary, size: 24), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_t(context, title), style: TextStyle(fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)), const SizedBox(height: 6), Text(_t(context, value), style: TextStyle(height: 1.45, color: dark ? Colors.grey[300] : Colors.grey[700]))]))])));
}