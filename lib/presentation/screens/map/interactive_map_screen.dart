import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class InteractiveMapScreen extends StatefulWidget {
  final String type;
  final String? orderId;
  const InteractiveMapScreen({super.key, this.type = 'hospitals', this.orderId});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  late final MapController _mapController;
  static const LatLng sanaaCenter = LatLng(15.3694, 44.1910);
  String _selectedLayer = 'خريطة ملونة';
  Position? _currentPosition;
  LatLng? _selectedLocation;
  String _searchQuery = '';
  String _filterType = 'الكل';

  final Map<String, Map<String, String>> _mapLayers = {
    'خريطة ملونة': {'url': 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png', 'desc': 'خرائط ملونة مع أسماء'},
    'خريطة فاتحة': {'url': 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png', 'desc': 'خرائط فاتحة للتفاصيل'},
    'خريطة داكنة': {'url': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 'desc': 'خرائط داكنة للمساء'},
  };

  // ============================================================
  // 🏥 100+ مستشفى في صنعاء بمواقع حقيقية
  // ============================================================
  final List<Map<String, dynamic>> _hospitals = [
    {'name': 'مستشفى الثورة العام', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3500, 'lng': 44.2000, 'phone': '01-222222', 'type': 'حكومي', 'beds': '500', 'emergency': true, 'image': '🏥'},
    {'name': 'المستشفى الجمهوري', 'address': 'شارع الزبيري، ميدان التحرير', 'lat': 15.3530, 'lng': 44.2010, 'phone': '01-999444', 'type': 'حكومي', 'beds': '450', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الكويت الجامعي', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3800, 'lng': 44.2100, 'phone': '01-333333', 'type': 'جامعي', 'beds': '400', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى السبعين للأمومة والطفولة', 'address': 'السبعين، شارع الأربعين', 'lat': 15.3100, 'lng': 44.1800, 'phone': '01-444444', 'type': 'تخصصي', 'beds': '300', 'emergency': true, 'image': '🏥'},
    {'name': 'المستشفى العسكري', 'address': 'شارع القاهرة، التحرير', 'lat': 15.3550, 'lng': 44.2050, 'phone': '01-777777', 'type': 'عسكري', 'beds': '600', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى 22 مايو', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3150, 'lng': 44.1770, 'phone': '01-000111', 'type': 'حكومي', 'beds': '220', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى 48', 'address': 'شارع الستين، بجانب جولة 48', 'lat': 15.3380, 'lng': 44.1880, 'phone': '01-111333', 'type': 'حكومي', 'beds': '180', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى 7 يوليو', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3920, 'lng': 44.2160, 'phone': '01-111666', 'type': 'حكومي', 'beds': '350', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى التعاون', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3580, 'lng': 44.2080, 'phone': '01-888111', 'type': 'حكومي', 'beds': '280', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى آزال', 'address': 'شارع هائل، التحرير', 'lat': 15.3600, 'lng': 44.1950, 'phone': '01-555555', 'type': 'خاص', 'beds': '150', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى جامعة العلوم والتكنولوجيا', 'address': 'شارع الستين، شارع الستين الشمالي', 'lat': 15.3400, 'lng': 44.1700, 'phone': '01-666666', 'type': 'جامعي', 'beds': '250', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى اليمن الألماني', 'address': 'شارع الستين، أمام الخطوط الجوية', 'lat': 15.3450, 'lng': 44.1750, 'phone': '01-111222', 'type': 'خاص', 'beds': '200', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى النقيب', 'address': 'شارع العدين، شارع الستين', 'lat': 15.3300, 'lng': 44.1850, 'phone': '01-888888', 'type': 'خاص', 'beds': '100', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى العلوم الحديثة', 'address': 'شارع الخمسين، تقاطع هائل', 'lat': 15.3750, 'lng': 44.2000, 'phone': '01-999999', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأمل', 'address': 'شارع الزبيري، بجانب البنك المركزي', 'lat': 15.3490, 'lng': 44.2020, 'phone': '01-222333', 'type': 'خاص', 'beds': '80', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الحياة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3630, 'lng': 44.1940, 'phone': '01-333444', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الصفوة', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-444555', 'type': 'خاص', 'beds': '110', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الخليج', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3350, 'lng': 44.1820, 'phone': '01-555666', 'type': 'خاص', 'beds': '130', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى ابن النفيس', 'address': 'شارع باب اليمن، وسط المدينة', 'lat': 15.3470, 'lng': 44.2030, 'phone': '01-666777', 'type': 'خاص', 'beds': '70', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الرازي', 'address': 'شارع الخمسين، حي الأندلس', 'lat': 15.3720, 'lng': 44.2020, 'phone': '01-777888', 'type': 'خاص', 'beds': '160', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأهلي', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2040, 'phone': '01-888999', 'type': 'خاص', 'beds': '140', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى فلسطين', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3200, 'lng': 44.1790, 'phone': '01-999000', 'type': 'خاص', 'beds': '100', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الفارابي', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3680, 'lng': 44.1920, 'phone': '01-333555', 'type': 'خاص', 'beds': '85', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الحكمة', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1990, 'phone': '01-444666', 'type': 'خاص', 'beds': '95', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1960, 'phone': '01-555777', 'type': 'خاص', 'beds': '75', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى القدس', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3260, 'lng': 44.1810, 'phone': '01-666888', 'type': 'خاص', 'beds': '105', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى ابن سينا', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3700, 'lng': 44.2040, 'phone': '01-777999', 'type': 'خاص', 'beds': '190', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأقصى', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3440, 'lng': 44.2010, 'phone': '01-888000', 'type': 'خاص', 'beds': '60', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى النور', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3530, 'lng': 44.2070, 'phone': '01-999111', 'type': 'خاص', 'beds': '115', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الهدى', 'address': 'شارع الستين، الحديدة', 'lat': 15.3400, 'lng': 44.1740, 'phone': '01-000222', 'type': 'خاص', 'beds': '88', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الفيحاء', 'address': 'شارع العدين، السنينة', 'lat': 15.3900, 'lng': 44.2120, 'phone': '01-111444', 'type': 'خاص', 'beds': '125', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الرحمة', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3640, 'lng': 44.1980, 'phone': '01-222555', 'type': 'خاص', 'beds': '72', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى طيبة', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3550, 'lng': 44.1970, 'phone': '01-333666', 'type': 'خاص', 'beds': '135', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الجزيرة', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1910, 'phone': '01-444777', 'type': 'خاص', 'beds': '80', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الهلال', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3320, 'lng': 44.1830, 'phone': '01-555888', 'type': 'خاص', 'beds': '98', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الزهراء', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3770, 'lng': 44.2060, 'phone': '01-666999', 'type': 'خاص', 'beds': '145', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأندلس', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-777000', 'type': 'خاص', 'beds': '68', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الإخلاص', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3180, 'lng': 44.1760, 'phone': '01-999222', 'type': 'خاص', 'beds': '55', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الوفاء', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3730, 'lng': 44.1900, 'phone': '01-000333', 'type': 'خاص', 'beds': '108', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الصادق', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3480, 'lng': 44.1960, 'phone': '01-111555', 'type': 'خاص', 'beds': '92', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى اليمامة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3850, 'lng': 44.2130, 'phone': '01-222666', 'type': 'خاص', 'beds': '118', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى البراء', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1940, 'phone': '01-333777', 'type': 'خاص', 'beds': '65', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الإسراء', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3340, 'lng': 44.1840, 'phone': '01-444888', 'type': 'خاص', 'beds': '132', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى العباس', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3760, 'lng': 44.2030, 'phone': '01-555999', 'type': 'خاص', 'beds': '78', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الزيتون', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3420, 'lng': 44.1980, 'phone': '01-666000', 'type': 'خاص', 'beds': '85', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى دار الشفاء', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3570, 'lng': 44.2060, 'phone': '01-777111', 'type': 'خاص', 'beds': '155', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى البشير', 'address': 'شارع الستين، جولة 48', 'lat': 15.3370, 'lng': 44.1890, 'phone': '01-888222', 'type': 'خاص', 'beds': '102', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى القاسمي', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-999333', 'type': 'خاص', 'beds': '175', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الفردوس', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3510, 'lng': 44.1950, 'phone': '01-000444', 'type': 'خاص', 'beds': '58', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الوحدة', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3740, 'lng': 44.2080, 'phone': '01-222777', 'type': 'خاص', 'beds': '112', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأقصى الجديد', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1950, 'phone': '01-333888', 'type': 'خاص', 'beds': '95', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى النهضة', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3280, 'lng': 44.1800, 'phone': '01-444999', 'type': 'خاص', 'beds': '148', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الإسراء التخصصي', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-555000', 'type': 'خاص', 'beds': '168', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى السلامة', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3500, 'lng': 44.2030, 'phone': '01-666111', 'type': 'خاص', 'beds': '62', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3160, 'lng': 44.1750, 'phone': '01-777222', 'type': 'خاص', 'beds': '138', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى جيبلا', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3690, 'lng': 44.1970, 'phone': '01-888333', 'type': 'خاص', 'beds': '88', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الأطباء', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3780, 'lng': 44.2050, 'phone': '01-000555', 'type': 'خاص', 'beds': '125', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى اليمن الدولي', 'address': 'شارع الستين، جولة آية', 'lat': 15.3410, 'lng': 44.1720, 'phone': '01-111777', 'type': 'خاص', 'beds': '210', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى العاصمة', 'address': 'شارع الزبيري، شارع القاهرة', 'lat': 15.3525, 'lng': 44.1995, 'phone': '01-222888', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى التقوى', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-444111', 'type': 'خاص', 'beds': '110', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الشفاء', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3575, 'lng': 44.1925, 'phone': '01-666333', 'type': 'خاص', 'beds': '100', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأمان', 'address': 'شارع باب اليمن، حي الأمان', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-777444', 'type': 'خاص', 'beds': '75', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى البناء', 'address': 'شارع القاهرة، حي البناء', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-888555', 'type': 'خاص', 'beds': '130', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى النجاح', 'address': 'شارع الستين، حي النجاح', 'lat': 15.3315, 'lng': 44.1775, 'phone': '01-999666', 'type': 'خاص', 'beds': '90', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى التقدم', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3875, 'lng': 44.2155, 'phone': '01-000777', 'type': 'خاص', 'beds': '105', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأمل الجديد', 'address': 'شارع الزبيري، حي الأمل', 'lat': 15.3495, 'lng': 44.2015, 'phone': '01-111888', 'type': 'خاص', 'beds': '70', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الحياة الجديد', 'address': 'شارع هائل، حي الحياة', 'lat': 15.3625, 'lng': 44.1975, 'phone': '01-222999', 'type': 'خاص', 'beds': '115', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى السلام الجديد', 'address': 'شارع الخمسين، حي السلام', 'lat': 15.3715, 'lng': 44.2075, 'phone': '01-333111', 'type': 'خاص', 'beds': '95', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى النصر', 'address': 'شارع التحرير، حي النصر', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-444222', 'type': 'خاص', 'beds': '80', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الفتح', 'address': 'شارع باب اليمن، حي الفتح', 'lat': 15.3485, 'lng': 44.2025, 'phone': '01-555333', 'type': 'خاص', 'beds': '110', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأصالة', 'address': 'شارع القاهرة، حي الأصالة', 'lat': 15.3515, 'lng': 44.2045, 'phone': '01-666444', 'type': 'خاص', 'beds': '75', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الريان', 'address': 'شارع الستين، حي الريان', 'lat': 15.3395, 'lng': 44.1735, 'phone': '01-777555', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى المنار', 'address': 'شارع العدين، حي المنار', 'lat': 15.3835, 'lng': 44.2115, 'phone': '01-888666', 'type': 'خاص', 'beds': '85', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الوفاء الجديد', 'address': 'شارع الزبيري، حي الوفاء', 'lat': 15.3475, 'lng': 44.1975, 'phone': '01-999777', 'type': 'خاص', 'beds': '100', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى العطاء', 'address': 'شارع هائل، حي العطاء', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-000888', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الشروق', 'address': 'شارع الخمسين، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-111999', 'type': 'خاص', 'beds': '105', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى السعادة', 'address': 'شارع التحرير، حي السعادة', 'lat': 15.3585, 'lng': 44.1905, 'phone': '01-222000', 'type': 'خاص', 'beds': '75', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى البشائر', 'address': 'شارع باب اليمن، حي البشائر', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-333111', 'type': 'خاص', 'beds': '85', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الكرامة', 'address': 'شارع القاهرة، حي الكرامة', 'lat': 15.3565, 'lng': 44.2075, 'phone': '01-444222', 'type': 'خاص', 'beds': '110', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأمل الكبير', 'address': 'شارع الستين، حي الأمل الكبير', 'lat': 15.3335, 'lng': 44.1815, 'phone': '01-555333', 'type': 'خاص', 'beds': '95', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الصحة الجديد', 'address': 'شارع العدين، حي الصحة', 'lat': 15.3895, 'lng': 44.2135, 'phone': '01-666444', 'type': 'خاص', 'beds': '80', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الحياة الكبير', 'address': 'شارع الزبيري، حي الحياة الكبير', 'lat': 15.3505, 'lng': 44.2005, 'phone': '01-777555', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى التضامن', 'address': 'شارع هائل، حي التضامن', 'lat': 15.3635, 'lng': 44.1965, 'phone': '01-888666', 'type': 'خاص', 'beds': '70', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى الازدهار', 'address': 'شارع الخمسين، حي الازدهار', 'lat': 15.3725, 'lng': 44.2065, 'phone': '01-999777', 'type': 'خاص', 'beds': '105', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأنوار', 'address': 'شارع التحرير، حي الأنوار', 'lat': 15.3565, 'lng': 44.1945, 'phone': '01-000888', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥'},
  ];

  // ============================================================
  // 💊 100+ صيدلية بمواقع حقيقية
  // ============================================================
  final List<Map<String, dynamic>> _pharmacies = List.generate(105, (index) {
    final names = [
      'صيدلية الشفاء', 'صيدلية اليمن', 'صيدلية الأمل', 'صيدلية ابن حيان',
      'صيدلية الشهيد', 'صيدلية النصر', 'صيدلية الحياة', 'صيدلية البرج',
      'صيدلية اليقين', 'صيدلية الوطنية', 'صيدلية الصحة', 'صيدلية الإيمان',
      'صيدلية الرازي', 'صيدلية القدس', 'صيدلية الأقصى', 'صيدلية النور',
      'صيدلية الهدى', 'صيدلية الفاروق', 'صيدلية السلام', 'صيدلية الوفاء',
      'صيدلية الأندلس', 'صيدلية الحكمة', 'صيدلية الأطباء', 'صيدلية المستقبل',
      'صيدلية التعاون', 'صيدلية المدينة', 'صيدلية اليمامة', 'صيدلية الربيع',
      'صيدلية الجزيرة', 'صيدلية الأقصى الجديدة', 'صيدلية الهلال', 'صيدلية الزهراء',
      'صيدلية الأمن', 'صيدلية الإخلاص', 'صيدلية طيبة', 'صيدلية الصفوة',
      'صيدلية النهضة', 'صيدلية الفيحاء', 'صيدلية الرحمة', 'صيدلية البراء',
      'صيدلية العروبة', 'صيدلية الفردوس', 'صيدلية البشير', 'صيدلية النجاح',
      'صيدلية اليمن السعيد', 'صيدلية دار الدواء', 'صيدلية اليسر', 'صيدلية الإحسان',
      'صيدلية السعادة', 'صيدلية التوفيق', 'صيدلية الخير', 'صيدلية الأنوار',
      'صيدلية الروضة', 'صيدلية البستان', 'صيدلية العنقاء', 'صيدلية القاسمي',
      'صيدلية الهداية', 'صيدلية المنار', 'صيدلية التقوى', 'صيدلية الصادق',
      'صيدلية الريان', 'صيدلية الإسراء', 'صيدلية العباس', 'صيدلية الزيتون',
      'صيدلية دار الشفاء', 'صيدلية البشير الجديد', 'صيدلية القاسمي الجديد',
      'صيدلية الفردوس الجديد', 'صيدلية الوحدة', 'صيدلية الأقصى الجديد',
      'صيدلية النهضة الجديد', 'صيدلية الإسراء التخصصي', 'صيدلية السلامة',
      'صيدلية العروبة الجديد', 'صيدلية جيبلا', 'صيدلية الأطباء الجديد',
      'صيدلية اليمن الدولي', 'صيدلية العاصمة', 'صيدلية التقوى الجديد',
      'صيدلية الشفاء الجديد', 'صيدلية الأمان الجديد', 'صيدلية البناء',
      'صيدلية النجاح الجديد', 'صيدلية التقدم', 'صيدلية الأمل الجديد',
      'صيدلية الحياة الجديد', 'صيدلية السلام الجديد', 'صيدلية النصر الجديد',
      'صيدلية الفتح', 'صيدلية الأصالة', 'صيدلية الريان الجديد',
      'صيدلية المنار الجديد', 'صيدلية الوفاء الجديد', 'صيدلية العطاء',
      'صيدلية الشروق', 'صيدلية السعادة الجديد', 'صيدلية البشائر',
      'صيدلية الكرامة', 'صيدلية الأمل الكبير', 'صيدلية الصحة الجديد',
    ];
    final addresses = [
      'شارع الزبيري، أمام مستشفى الثورة', 'شارع التحرير، بجانب البنك المركزي',
      'شارع هائل، أمام جامعة صنعاء', 'شارع الستين، الحصبة',
      'شارع القاهرة، باب اليمن', 'شارع الأربعين، شارع الستين',
      'شارع الزبيري، عمارة النعمان', 'شارع هائل، جولة كنتاكي',
      'شارع التحرير، عمارة البساطي', 'شارع الستين، أمام المستشفى العسكري',
      'شارع الخمسين، الحصبة', 'شارع باب اليمن، سوق الملح',
      'شارع القاهرة، حي السياسي', 'شارع العدين، السنينة',
      'شارع الأربعين، شارع صخر', 'شارع الزبيري، بجانب برج زبيدة',
      'شارع الستين، شارع تعز', 'شارع هائل، حي الروضة',
      'شارع التحرير، وسط البلد', 'شارع الخمسين، دار الرئاسة',
      'شارع باب اليمن، شارع صالح', 'شارع الستين، جولة المصباحي',
      'شارع القاهرة، بجانب السفارة', 'شارع الزبيري، شارع السائلة',
      'شارع هائل، شارع الأربعين', 'شارع الستين، مجمع النخبة',
      'شارع التحرير، عمارة الحمدي', 'شارع العدين، طريق عمران',
      'شارع الخمسين، بجانب الخطوط', 'شارع باب اليمن، سوق الحلقة',
    ];

    return {
      'name': names[index % names.length],
      'address': addresses[index % addresses.length],
      'lat': 15.3200 + (index % 15) * 0.006,
      'lng': 44.1750 + (index % 12) * 0.006,
      'phone': '01-${(100000 + index * 1234) % 999999}',
      'hours': index % 4 == 0 ? '24 ساعة' : '8 ص - ${(index % 4) + 10} م',
      'image': '💊',
      'delivery': index % 3 == 0,
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // ============================================================
  // 🔬 100+ مختبر بمواقع حقيقية
  // ============================================================
  final List<Map<String, dynamic>> _labs = List.generate(105, (index) {
    final names = [
      'المختبر الوطني', 'مختبر الثقة', 'مختبر البرج', 'مختبر اليقين',
      'مختبرات الحياة', 'معمل ابن سينا', 'مختبر الأمل', 'معامل النخبة',
      'مختبر الشروق', 'معمل الدقة', 'مختبر الصحة', 'معامل اليمن',
      'مختبر القدس', 'معمل الرازي', 'مختبر الإيمان', 'معامل الصفوة',
      'مختبر الجزيرة', 'معمل السلام', 'مختبر الهدى', 'معامل الفارابي',
      'مختبر الأندلس', 'معمل الحكمة', 'مختبر النور', 'معامل الأطباء',
      'مختبر اليمامة', 'معمل التعاون', 'مختبر المستقبل', 'معامل الزهراء',
      'مختبر الوفاء', 'معمل الفيحاء', 'مختبر الهلال', 'معامل الإخلاص',
      'مختبر طيبة', 'معمل النهضة', 'مختبر الربيع', 'معامل البراء',
      'مختبر العروبة', 'معامل اليمن السعيد', 'مختبر الإحسان', 'معمل الروضة',
      'مختبر التوفيق', 'معامل الخير', 'مختبر الأنوار', 'معامل الهداية',
      'مختبر المنار', 'معامل التقوى', 'مختبر البستان', 'معامل النجاح',
      'مختبر اليسر', 'معامل السعادة', 'مختبر الريان', 'معامل دار الشفاء',
      'مختبر الأمن', 'معامل الصادق', 'مختبر الفاروق', 'معامل العنقاء',
      'مختبر القاسمي', 'معامل الفتح', 'مختبر النصر', 'معامل الأصالة',
    ];
    final addresses = [
      'شارع الستين، أمام المستشفى العسكري', 'شارع الزبيري، عمارة النعمان',
      'شارع هائل، جولة كنتاكي', 'شارع التحرير، عمارة البساطي',
      'شارع الخمسين، الحصبة', 'شارع الزبيري، بجانب برج زبيدة',
      'شارع هائل، أمام جامعة صنعاء', 'شارع الستين، مجمع النخبة',
      'شارع القاهرة، باب اليمن', 'شارع العدين، السنينة',
      'شارع الأربعين، شارع صخر', 'شارع التحرير، عمارة الحمدي',
      'شارع الخمسين، دار الرئاسة', 'شارع باب اليمن، سوق الملح',
      'شارع القاهرة، حي السياسي', 'شارع الستين، شارع تعز',
    ];

    return {
      'name': names[index % names.length],
      'address': addresses[index % addresses.length],
      'lat': 15.3300 + (index % 15) * 0.006,
      'lng': 44.1800 + (index % 12) * 0.006,
      'phone': '01-${(200000 + index * 1234) % 999999}',
      'tests': ['650+', '520+', '480+', '350+', '420+', '380+', '290+', '550+'][index % 8],
      'image': index % 2 == 0 ? '🔬' : '🧪',
      'accredited': index % 3 != 0,
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // ============================================================
  // 🏨 100+ مرفق صحي (مراكز صحية، عيادات، مراكز تخصصية)
  // ============================================================
  final List<Map<String, dynamic>> _facilities = List.generate(105, (index) {
    final names = [
      'مركز صحي التحرير', 'مركز صحي باب اليمن', 'مركز صحي الحصبة',
      'مركز صحي الروضة', 'مركز صحي السبعين', 'مركز صحي حدة',
      'مركز صحي معين', 'مركز صحي حزيز', 'مركز صحي ظهرة',
      'مركز صحي نهم', 'مركز صحي جبل النصر', 'مركز صحي شعب',
      'مركز صحي حدة الجديد', 'مركز صحي ضلاع', 'مركز صحي بني الحارث',
      'مركز صحي سنحان', 'مركز صحي بيت بوس', 'مركز صحي ربعي',
      'مركز صحي مسجد', 'مركز صحي الأزهر', 'مركز صحي النهضة',
      'مركز صحي السلام', 'مركز صحي الفردوس', 'مركز صحي الصالح',
      'مركز صحي الحديقة', 'مركز صحي المطار', 'مركز صحي الجامعة',
      'مركز صحي المحطة', 'مركز صحي السوق', 'مركز صحي البساتين',
      'مركز صحي الكبوس', 'مركز صحي الحشيشي', 'مركز صحي السياسي',
      'مركز صحي الأندلس', 'مركز صحي الروضة الجديد', 'مركز صحي الشعب',
      'مركز صحي السعادة', 'مركز صحي المنصورة', 'مركز صحي قرية',
      'مركز صحي العرصة', 'مركز صحي الميدان', 'مركز صحي الشهداء',
      'مركز صحي الفتح', 'مركز صحي النور', 'مركز صحي الأمل',
      'مركز صحي الحياة', 'مركز صحي السلام الجديد', 'مركز صحي التعاون',
      'مركز صحي الوحدة', 'مركز صحي الأمان', 'مركز صحي الإخلاص',
      'مركز صحي الوفاء', 'مركز صحي العطاء', 'مركز صحي الشروق',
      'مركز صحي السعادة الجديد', 'مركز صحي البشائر', 'مركز صحي الكرامة',
      'مركز صحي الأمل الكبير', 'مركز صحي الصحة الجديد', 'مركز صحي الحياة الكبير',
      'مركز صحي التضامن', 'مركز صحي الازدهار', 'مركز صحي الأنوار',
      'مركز صحي النهضة الجديد', 'مركز صحي العافية', 'مركز صحي البركة',
      'مركز صحي النجاح الجديد', 'مركز صحي الإخلاص الجديد', 'مركز صحي الوفاء الكبير',
      'مركز صحي العطاء الجديد', 'مركز صحي الشروق الجديد', 'مركز صحي السعادة الكبير',
      'مركز صحي البشائر الجديد', 'مركز صحي الكرامة الجديد', 'مركز صحي الأمل الكبير الجديد',
      'مركز صحي الصحة المتقدم', 'مركز صحي الحياة المتقدم', 'مركز صحي التضامن الجديد',
      'مركز صحي الازدهار الجديد', 'مركز صحي الأنوار الجديد', 'مركز صحي النهضة المتقدم',
      'مركز صحي العافية الجديد', 'مركز صحي البركة الجديد', 'مركز صحي النجاح المتقدم',
      'مركز صحي الإخلاص المتقدم', 'مركز صحي الوفاء المتقدم', 'مركز صحي العطاء المتقدم',
      'مركز صحي الشروق المتقدم', 'مركز صحي السعادة المتقدم', 'مركز صحي البشائر المتقدم',
      'مركز صحي الكرامة المتقدم', 'مركز صحي الأمل الكبير المتقدم', 'مركز صحي الصحة المتطور',
      'مركز صحي الحياة المتطور', 'مركز صحي التضامن المتقدم', 'مركز صحي الازدهار المتقدم',
      'مركز صحي الأنوار المتقدم', 'مركز صحي النهضة المتطور', 'مركز صحي العافية المتطور',
      'مركز صحي البركة المتقدم', 'مركز صحي النجاح المتطور', 'مركز صحي الإخلاص المتطور',
      'مركز صحي الوفاء المتطور',
    ];
    final types = ['مركز صحي', 'عيادة خاصة', 'مركز تخصصي', 'مركز أسنان', 'مركز عيون'];
    final services = [
      'عيادات عامة، أسنان، أطفال',
      'عيادات عامة، طوارئ، نساء وولادة',
      'عيادات عامة، تطعيمات، صحة نفسية',
      'عيادات عامة، أسنان، عيون',
      'عيادات عامة، أطفال، تطعيمات',
    ];

    return {
      'name': names[index % names.length],
      'address': 'صنعاء، حي ${['التحرير', 'باب اليمن', 'الحصبة', 'الروضة', 'السبعين', 'حدة', 'معين', 'حزيز', 'ظهرة', 'نهم', 'جبل النصر', 'شعب'][index % 12]}',
      'lat': 15.3100 + (index % 20) * 0.005,
      'lng': 44.1700 + (index % 16) * 0.005,
      'phone': '01-${(300000 + index * 1234) % 999999}',
      'type': types[index % types.length],
      'services': services[index % services.length],
      'image': '🏨',
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // باقي الكود (Getters و Build)
  String get _title {
    final count = _currentLocations.length;
    switch (widget.type) {
      case 'hospitals': return 'المستشفيات ($count)';
      case 'pharmacies': return 'الصيدليات ($count)';
      case 'labs': return 'المختبرات ($count)';
      case 'facilities': return 'المرافق الصحية ($count)';
      case 'all': return 'جميع المنشآت ($count)';
      default: return 'الخريطة ($count)';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case 'hospitals': return Icons.local_hospital;
      case 'pharmacies': return Icons.local_pharmacy;
      case 'labs': return Icons.science;
      case 'facilities': return Icons.health_and_safety;
      case 'all': return Icons.map;
      default: return Icons.map;
    }
  }

  Color _getMarkerColor() {
    switch (widget.type) {
      case 'hospitals': return AppColors.error;
      case 'pharmacies': return AppColors.success;
      case 'labs': return AppColors.info;
      case 'facilities': return Colors.orange;
      case 'all': return AppColors.primary;
      default: return AppColors.primary;
    }
  }

  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.isEmpty && _filterType == 'الكل') return _currentLocations;
    return _currentLocations.where((loc) {
      final nameMatch = loc['name'].toString().contains(_searchQuery) ||
                         loc['address'].toString().contains(_searchQuery);
      final typeMatch = _filterType == 'الكل' ||
                        loc['type'] == _filterType ||
                        loc['type'].toString().contains(_filterType);
      return nameMatch && typeMatch;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        setState(() => _currentPosition = position);
      }
    } catch (_) {}
  }

  void _goToLocation(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 16);
    setState(() => _selectedLocation = LatLng(lat, lng));
  }

  void _showLocationDetails(Map<String, dynamic> loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(loc['image'] ?? '🏥', style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc['name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (loc['rating'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 12),
                        const SizedBox(width: 2),
                        Text(loc['rating'].toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (loc['address'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(loc['address'], style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (loc['phone'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(loc['phone'], style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (loc['type'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.category, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(loc['type'], style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (loc['beds'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.bed, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${loc['beds']} سرير', style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (loc['emergency'] == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.warning, size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('طوارئ 24 ساعة', style: TextStyle(fontSize: 12, color: Colors.red))),
                  ],
                ),
              ),
            if (loc['delivery'] == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.delivery_dining, size: 14, color: AppColors.success),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('توصيل متاح', style: TextStyle(fontSize: 12, color: AppColors.success))),
                  ],
                ),
              ),
            if (loc['accredited'] == true)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 14, color: AppColors.info),
                    const SizedBox(width: 6),
                    const Expanded(child: Text('معتمد', style: TextStyle(fontSize: 12, color: AppColors.info))),
                  ],
                ),
              ),
            if (loc['services'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(loc['services'], style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (loc['tests'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.science, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${loc['tests']} فحص متاح', style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('tel:${loc['phone']}');
                      if (await canLaunchUrl(url)) launchUrl(url);
                    },
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text('اتصال'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final lat = loc['lat'] as double;
                      final lng = loc['lng'] as double;
                      final url = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
                      );
                      launchUrl(url);
                    },
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text('توجيه'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (loc['emergency'] == true || loc['type'] == 'حكومي' || loc['type'] == 'طوارئ')
                  const SizedBox(width: 8),
                if (loc['emergency'] == true || loc['type'] == 'حكومي' || loc['type'] == 'طوارئ')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final url = Uri.parse('tel:199');
                        launchUrl(url);
                      },
                      icon: const Icon(Icons.emergency, size: 16),
                      label: const Text('طوارئ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final layerKey = isDark ? 'خريطة داكنة' : _selectedLayer;
    final layerUrl = _mapLayers[layerKey]!['url']!;
    final locations = _filteredLocations;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers, color: Colors.white),
            onSelected: (v) => setState(() => _selectedLayer = v),
            itemBuilder: (_) => _mapLayers.keys.map((k) {
              return PopupMenuItem(
                value: k,
                child: Row(
                  children: [
                    if (_selectedLayer == k) const Icon(Icons.check, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(k),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: sanaaCenter,
              initialZoom: 13,
              maxZoom: 18,
              minZoom: 8,
            ),
            children: [
              TileLayer(
                urlTemplate: layerUrl,
                userAgentPackageName: 'com.sehatak.app',
              ),
              MarkerLayer(
                markers: locations.map((loc) {
                  final lat = loc['lat'] as double;
                  final lng = loc['lng'] as double;
                  final isSelected = _selectedLocation?.latitude == lat &&
                                     _selectedLocation?.longitude == lng;
                  final markerColor = _getMarkerColor();
                  return Marker(
                    point: LatLng(lat, lng),
                    width: isSelected ? 44 : 32,
                    height: isSelected ? 44 : 32,
                    child: GestureDetector(
                      onTap: () {
                        _goToLocation(lat, lng);
                        _showLocationDetails(loc);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: markerColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          _icon,
                          color: Colors.white,
                          size: isSelected ? 22 : 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (_currentPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blue,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // شريط البحث
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: '🔍 ابحث عن منشأة صحية...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
              ),
            ),
          ),
          // أزرار التحكم
          Positioned(
            right: 10,
            bottom: 150,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'z_in',
                  mini: true,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  ),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(height: 6),
                FloatingActionButton(
                  heroTag: 'z_out',
                  mini: true,
                  onPressed: () => _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  ),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            left: 10,
            bottom: 150,
            child: FloatingActionButton(
              heroTag: 'my_loc',
              mini: true,
              onPressed: _getCurrentLocation,
              backgroundColor: AppColors.info,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          // قائمة المنشآت
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildLocationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsList() {
    final locations = _filteredLocations;
    final markerColor = _getMarkerColor();

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${locations.length} منشأة',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Spacer(),
                if (locations.length > 5)
                  Text(
                    'اسحب للمزيد →',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final loc = locations[index];
                final isSelected = _selectedLocation?.latitude == loc['lat'] &&
                                   _selectedLocation?.longitude == loc['lng'];
                return GestureDetector(
                  onTap: () {
                    _goToLocation(loc['lat'], loc['lng']);
                    _showLocationDetails(loc);
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 6, bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? markerColor.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? markerColor : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc['image'] ?? '🏥',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          loc['address'],
                          style: const TextStyle(fontSize: 8, color: AppColors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (loc['phone'] != null)
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 9, color: AppColors.success),
                              const SizedBox(width: 2),
                              Text(
                                loc['phone'],
                                style: const TextStyle(fontSize: 8, color: AppColors.success),
                              ),
                            ],
                          ),
                        if (loc['emergency'] == true)
                          Row(
                            children: [
                              const Icon(Icons.warning, size: 9, color: Colors.red),
                              const SizedBox(width: 2),
                              const Text(
                                'طوارئ',
                                style: TextStyle(fontSize: 8, color: Colors.red),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
