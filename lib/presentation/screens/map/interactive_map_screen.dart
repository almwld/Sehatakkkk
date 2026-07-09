import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

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
  String _selectedLayer = 'خريطة داكنة';
  Position? _currentPosition;
  LatLng? _selectedLocation;
  int _currentStep = 2;
  String _searchQuery = '';
  String _filterType = 'الكل';

  final Map<String, Map<String, String>> _mapLayers = {
    'خريطة داكنة': {'url': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png', 'desc': 'خريطة داكنة احترافية'},
  };

  // ============================================================
  // 🏥 100+ مستشفى
  // ============================================================
  final List<Map<String, dynamic>> _hospitals = [
    {'name': 'مستشفى الثورة العام', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3500, 'lng': 44.2000, 'phone': '01-222222', 'type': 'حكومي', 'beds': '500', 'emergency': true, 'image': '🏥', 'rating': 4.5},
    {'name': 'المستشفى الجمهوري', 'address': 'شارع الزبيري، ميدان التحرير', 'lat': 15.3530, 'lng': 44.2010, 'phone': '01-999444', 'type': 'حكومي', 'beds': '450', 'emergency': true, 'image': '🏥', 'rating': 4.3},
    {'name': 'مستشفى الكويت الجامعي', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3800, 'lng': 44.2100, 'phone': '01-333333', 'type': 'جامعي', 'beds': '400', 'emergency': true, 'image': '🏥', 'rating': 4.4},
    {'name': 'مستشفى السبعين للأمومة', 'address': 'السبعين، شارع الأربعين', 'lat': 15.3100, 'lng': 44.1800, 'phone': '01-444444', 'type': 'تخصصي', 'beds': '300', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'المستشفى العسكري', 'address': 'شارع القاهرة، التحرير', 'lat': 15.3550, 'lng': 44.2050, 'phone': '01-777777', 'type': 'عسكري', 'beds': '600', 'emergency': true, 'image': '🏥', 'rating': 4.6},
    {'name': 'مستشفى آزال', 'address': 'شارع هائل، التحرير', 'lat': 15.3600, 'lng': 44.1950, 'phone': '01-555555', 'type': 'خاص', 'beds': '150', 'emergency': true, 'image': '🏥', 'rating': 4.7},
    {'name': 'مستشفى اليمن الألماني', 'address': 'شارع الستين، أمام الخطوط الجوية', 'lat': 15.3450, 'lng': 44.1750, 'phone': '01-111222', 'type': 'خاص', 'beds': '200', 'emergency': true, 'image': '🏥', 'rating': 4.8},
    {'name': 'مستشفى النقيب', 'address': 'شارع العدين، شارع الستين', 'lat': 15.3300, 'lng': 44.1850, 'phone': '01-888888', 'type': 'خاص', 'beds': '100', 'emergency': false, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى العلوم الحديثة', 'address': 'شارع الخمسين، تقاطع هائل', 'lat': 15.3750, 'lng': 44.2000, 'phone': '01-999999', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى الأمل', 'address': 'شارع الزبيري، بجانب البنك المركزي', 'lat': 15.3490, 'lng': 44.2020, 'phone': '01-222333', 'type': 'خاص', 'beds': '80', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى الحياة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3630, 'lng': 44.1940, 'phone': '01-333444', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥', 'rating': 4.3},
    {'name': 'مستشفى الصفوة', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-444555', 'type': 'خاص', 'beds': '110', 'emergency': false, 'image': '🏥', 'rating': 3.8},
    {'name': 'مستشفى الخليج', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3350, 'lng': 44.1820, 'phone': '01-555666', 'type': 'خاص', 'beds': '130', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى ابن النفيس', 'address': 'شارع باب اليمن، وسط المدينة', 'lat': 15.3470, 'lng': 44.2030, 'phone': '01-666777', 'type': 'خاص', 'beds': '70', 'emergency': false, 'image': '🏥', 'rating': 3.7},
    {'name': 'مستشفى الرازي', 'address': 'شارع الخمسين، حي الأندلس', 'lat': 15.3720, 'lng': 44.2020, 'phone': '01-777888', 'type': 'خاص', 'beds': '160', 'emergency': true, 'image': '🏥', 'rating': 4.4},
    {'name': 'مستشفى الأهلي', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2040, 'phone': '01-888999', 'type': 'خاص', 'beds': '140', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى فلسطين', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3200, 'lng': 44.1790, 'phone': '01-999000', 'type': 'خاص', 'beds': '100', 'emergency': false, 'image': '🏥', 'rating': 3.6},
    {'name': 'مستشفى 22 مايو', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3150, 'lng': 44.1770, 'phone': '01-000111', 'type': 'حكومي', 'beds': '220', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى 48', 'address': 'شارع الستين، بجانب جولة 48', 'lat': 15.3380, 'lng': 44.1880, 'phone': '01-111333', 'type': 'حكومي', 'beds': '180', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى جامعة الإيمان', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3800, 'lng': 44.2150, 'phone': '01-222444', 'type': 'جامعي', 'beds': '300', 'emergency': true, 'image': '🏥', 'rating': 4.4},
    {'name': 'مستشفى الفارابي', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3680, 'lng': 44.1920, 'phone': '01-333555', 'type': 'خاص', 'beds': '85', 'emergency': false, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى الحكمة', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1990, 'phone': '01-444666', 'type': 'خاص', 'beds': '95', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1960, 'phone': '01-555777', 'type': 'خاص', 'beds': '75', 'emergency': false, 'image': '🏥', 'rating': 3.5},
    {'name': 'مستشفى القدس', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3260, 'lng': 44.1810, 'phone': '01-666888', 'type': 'خاص', 'beds': '105', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى ابن سينا', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3700, 'lng': 44.2040, 'phone': '01-777999', 'type': 'خاص', 'beds': '190', 'emergency': true, 'image': '🏥', 'rating': 4.6},
    {'name': 'مستشفى الأقصى', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3440, 'lng': 44.2010, 'phone': '01-888000', 'type': 'خاص', 'beds': '60', 'emergency': false, 'image': '🏥', 'rating': 3.4},
    {'name': 'مستشفى النور', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3530, 'lng': 44.2070, 'phone': '01-999111', 'type': 'خاص', 'beds': '115', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى الهدى', 'address': 'شارع الستين، الحديدة', 'lat': 15.3400, 'lng': 44.1740, 'phone': '01-000222', 'type': 'خاص', 'beds': '88', 'emergency': false, 'image': '🏥', 'rating': 3.7},
    {'name': 'مستشفى الفيحاء', 'address': 'شارع العدين، السنينة', 'lat': 15.3900, 'lng': 44.2120, 'phone': '01-111444', 'type': 'خاص', 'beds': '125', 'emergency': true, 'image': '🏥', 'rating': 4.3},
    {'name': 'مستشفى الرحمة', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3640, 'lng': 44.1980, 'phone': '01-222555', 'type': 'خاص', 'beds': '72', 'emergency': false, 'image': '🏥', 'rating': 3.6},
    {'name': 'مستشفى طيبة', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3550, 'lng': 44.1970, 'phone': '01-333666', 'type': 'خاص', 'beds': '135', 'emergency': true, 'image': '🏥', 'rating': 4.4},
    {'name': 'مستشفى الجزيرة', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1910, 'phone': '01-444777', 'type': 'خاص', 'beds': '80', 'emergency': false, 'image': '🏥', 'rating': 3.8},
    {'name': 'مستشفى الهلال', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3320, 'lng': 44.1830, 'phone': '01-555888', 'type': 'خاص', 'beds': '98', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى الزهراء', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3770, 'lng': 44.2060, 'phone': '01-666999', 'type': 'خاص', 'beds': '145', 'emergency': true, 'image': '🏥', 'rating': 4.5},
    {'name': 'مستشفى الأندلس', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-777000', 'type': 'خاص', 'beds': '68', 'emergency': false, 'image': '🏥', 'rating': 3.5},
    {'name': 'مستشفى التعاون', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3580, 'lng': 44.2080, 'phone': '01-888111', 'type': 'حكومي', 'beds': '280', 'emergency': true, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى الإخلاص', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3180, 'lng': 44.1760, 'phone': '01-999222', 'type': 'خاص', 'beds': '55', 'emergency': false, 'image': '🏥', 'rating': 3.2},
    {'name': 'مستشفى الوفاء', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3730, 'lng': 44.1900, 'phone': '01-000333', 'type': 'خاص', 'beds': '108', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى الصادق', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3480, 'lng': 44.1960, 'phone': '01-111555', 'type': 'خاص', 'beds': '92', 'emergency': false, 'image': '🏥', 'rating': 3.7},
    {'name': 'مستشفى اليمامة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3850, 'lng': 44.2130, 'phone': '01-222666', 'type': 'خاص', 'beds': '118', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى البراء', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1940, 'phone': '01-333777', 'type': 'خاص', 'beds': '65', 'emergency': false, 'image': '🏥', 'rating': 3.4},
    {'name': 'مستشفى الإسراء', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3340, 'lng': 44.1840, 'phone': '01-444888', 'type': 'خاص', 'beds': '132', 'emergency': true, 'image': '🏥', 'rating': 4.3},
    {'name': 'مستشفى العباس', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3760, 'lng': 44.2030, 'phone': '01-555999', 'type': 'خاص', 'beds': '78', 'emergency': false, 'image': '🏥', 'rating': 3.6},
    {'name': 'مستشفى الزيتون', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3420, 'lng': 44.1980, 'phone': '01-666000', 'type': 'خاص', 'beds': '85', 'emergency': true, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى دار الشفاء', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3570, 'lng': 44.2060, 'phone': '01-777111', 'type': 'خاص', 'beds': '155', 'emergency': true, 'image': '🏥', 'rating': 4.5},
    {'name': 'مستشفى البشير', 'address': 'شارع الستين، جولة 48', 'lat': 15.3370, 'lng': 44.1890, 'phone': '01-888222', 'type': 'خاص', 'beds': '102', 'emergency': false, 'image': '🏥', 'rating': 3.8},
    {'name': 'مستشفى القاسمي', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-999333', 'type': 'خاص', 'beds': '175', 'emergency': true, 'image': '🏥', 'rating': 4.4},
    {'name': 'مستشفى الفردوس', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3510, 'lng': 44.1950, 'phone': '01-000444', 'type': 'خاص', 'beds': '58', 'emergency': false, 'image': '🏥', 'rating': 3.3},
    {'name': 'مستشفى 7 يوليو', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3920, 'lng': 44.2160, 'phone': '01-111666', 'type': 'حكومي', 'beds': '350', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى الوحدة', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3740, 'lng': 44.2080, 'phone': '01-222777', 'type': 'خاص', 'beds': '112', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى الأقصى الجديد', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1950, 'phone': '01-333888', 'type': 'خاص', 'beds': '95', 'emergency': false, 'image': '🏥', 'rating': 3.7},
    {'name': 'مستشفى النهضة', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3280, 'lng': 44.1800, 'phone': '01-444999', 'type': 'خاص', 'beds': '148', 'emergency': true, 'image': '🏥', 'rating': 4.3},
    {'name': 'مستشفى الإسراء التخصصي', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-555000', 'type': 'خاص', 'beds': '168', 'emergency': true, 'image': '🏥', 'rating': 4.6},
    {'name': 'مستشفى السلامة', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3500, 'lng': 44.2030, 'phone': '01-666111', 'type': 'خاص', 'beds': '62', 'emergency': false, 'image': '🏥', 'rating': 3.2},
    {'name': 'مستشفى العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3160, 'lng': 44.1750, 'phone': '01-777222', 'type': 'خاص', 'beds': '138', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى جيبلا', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3690, 'lng': 44.1970, 'phone': '01-888333', 'type': 'خاص', 'beds': '88', 'emergency': false, 'image': '🏥', 'rating': 3.5},
    {'name': 'مستشفى الأطباء', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3780, 'lng': 44.2050, 'phone': '01-000555', 'type': 'خاص', 'beds': '125', 'emergency': false, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى اليمن الدولي', 'address': 'شارع الستين، جولة آية', 'lat': 15.3410, 'lng': 44.1720, 'phone': '01-111777', 'type': 'خاص', 'beds': '210', 'emergency': true, 'image': '🏥', 'rating': 4.7},
    {'name': 'مستشفى العاصمة', 'address': 'شارع الزبيري، شارع القاهرة', 'lat': 15.3525, 'lng': 44.1995, 'phone': '01-222888', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى التقوى', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-444111', 'type': 'خاص', 'beds': '110', 'emergency': false, 'image': '🏥', 'rating': 3.6},
    {'name': 'مستشفى الهداية', 'address': 'شارع الخمسين، حي الهداية', 'lat': 15.3795, 'lng': 44.2095, 'phone': '01-555222', 'type': 'خاص', 'beds': '85', 'emergency': true, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى الشفاء', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3575, 'lng': 44.1925, 'phone': '01-666333', 'type': 'خاص', 'beds': '100', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى الأمان', 'address': 'شارع باب اليمن، حي الأمان', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-777444', 'type': 'خاص', 'beds': '75', 'emergency': false, 'image': '🏥', 'rating': 3.4},
    {'name': 'مستشفى البناء', 'address': 'شارع القاهرة، حي البناء', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-888555', 'type': 'خاص', 'beds': '130', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى النجاح', 'address': 'شارع الستين، حي النجاح', 'lat': 15.3315, 'lng': 44.1775, 'phone': '01-999666', 'type': 'خاص', 'beds': '90', 'emergency': false, 'image': '🏥', 'rating': 3.5},
    {'name': 'مستشفى التقدم', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3875, 'lng': 44.2155, 'phone': '01-000777', 'type': 'خاص', 'beds': '105', 'emergency': true, 'image': '🏥', 'rating': 3.8},
    {'name': 'مستشفى الأمل الجديد', 'address': 'شارع الزبيري، حي الأمل', 'lat': 15.3495, 'lng': 44.2015, 'phone': '01-111888', 'type': 'خاص', 'beds': '70', 'emergency': false, 'image': '🏥', 'rating': 3.3},
    {'name': 'مستشفى الحياة الجديد', 'address': 'شارع هائل، حي الحياة', 'lat': 15.3625, 'lng': 44.1975, 'phone': '01-222999', 'type': 'خاص', 'beds': '115', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى السلام الجديد', 'address': 'شارع الخمسين، حي السلام', 'lat': 15.3715, 'lng': 44.2075, 'phone': '01-333111', 'type': 'خاص', 'beds': '95', 'emergency': true, 'image': '🏥', 'rating': 3.7},
    {'name': 'مستشفى النصر', 'address': 'شارع التحرير، حي النصر', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-444222', 'type': 'خاص', 'beds': '80', 'emergency': false, 'image': '🏥', 'rating': 3.4},
    {'name': 'مستشفى الفتح', 'address': 'شارع باب اليمن، حي الفتح', 'lat': 15.3485, 'lng': 44.2025, 'phone': '01-555333', 'type': 'خاص', 'beds': '110', 'emergency': true, 'image': '🏥', 'rating': 4.1},
    {'name': 'مستشفى الأصالة', 'address': 'شارع القاهرة، حي الأصالة', 'lat': 15.3515, 'lng': 44.2045, 'phone': '01-666444', 'type': 'خاص', 'beds': '75', 'emergency': false, 'image': '🏥', 'rating': 3.2},
    {'name': 'مستشفى الريان', 'address': 'شارع الستين، حي الريان', 'lat': 15.3395, 'lng': 44.1735, 'phone': '01-777555', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى المنار', 'address': 'شارع العدين، حي المنار', 'lat': 15.3835, 'lng': 44.2115, 'phone': '01-888666', 'type': 'خاص', 'beds': '85', 'emergency': false, 'image': '🏥', 'rating': 3.5},
    {'name': 'مستشفى الوفاء الجديد', 'address': 'شارع الزبيري، حي الوفاء', 'lat': 15.3475, 'lng': 44.1975, 'phone': '01-999777', 'type': 'خاص', 'beds': '100', 'emergency': true, 'image': '🏥', 'rating': 4.0},
    {'name': 'مستشفى العطاء', 'address': 'شارع هائل، حي العطاء', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-000888', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥', 'rating': 3.6},
    {'name': 'مستشفى الشروق', 'address': 'شارع الخمسين، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-111999', 'type': 'خاص', 'beds': '105', 'emergency': false, 'image': '🏥', 'rating': 3.4},
    {'name': 'مستشفى السعادة', 'address': 'شارع التحرير، حي السعادة', 'lat': 15.3585, 'lng': 44.1905, 'phone': '01-222000', 'type': 'خاص', 'beds': '75', 'emergency': true, 'image': '🏥', 'rating': 3.8},
    {'name': 'مستشفى البشائر', 'address': 'شارع باب اليمن، حي البشائر', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-333111', 'type': 'خاص', 'beds': '85', 'emergency': false, 'image': '🏥', 'rating': 3.3},
    {'name': 'مستشفى الكرامة', 'address': 'شارع القاهرة، حي الكرامة', 'lat': 15.3565, 'lng': 44.2075, 'phone': '01-444222', 'type': 'خاص', 'beds': '110', 'emergency': true, 'image': '🏥', 'rating': 4.2},
    {'name': 'مستشفى الأمل الكبير', 'address': 'شارع الستين، حي الأمل الكبير', 'lat': 15.3335, 'lng': 44.1815, 'phone': '01-555333', 'type': 'خاص', 'beds': '95', 'emergency': true, 'image': '🏥', 'rating': 3.7},
    {'name': 'مستشفى الصحة الجديد', 'address': 'شارع العدين، حي الصحة', 'lat': 15.3895, 'lng': 44.2135, 'phone': '01-666444', 'type': 'خاص', 'beds': '80', 'emergency': false, 'image': '🏥', 'rating': 3.5},
    {'name': 'مستشفى الحياة الكبير', 'address': 'شارع الزبيري، حي الحياة الكبير', 'lat': 15.3505, 'lng': 44.2005, 'phone': '01-777555', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥', 'rating': 4.3},
    {'name': 'مستشفى التضامن', 'address': 'شارع هائل، حي التضامن', 'lat': 15.3635, 'lng': 44.1965, 'phone': '01-888666', 'type': 'خاص', 'beds': '70', 'emergency': false, 'image': '🏥', 'rating': 3.2},
    {'name': 'مستشفى الازدهار', 'address': 'شارع الخمسين، حي الازدهار', 'lat': 15.3725, 'lng': 44.2065, 'phone': '01-999777', 'type': 'خاص', 'beds': '105', 'emergency': true, 'image': '🏥', 'rating': 3.9},
    {'name': 'مستشفى الأنوار', 'address': 'شارع التحرير، حي الأنوار', 'lat': 15.3565, 'lng': 44.1945, 'phone': '01-000888', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥', 'rating': 3.6},
  ];


  // ============================================================
  // 💊 100+ صيدلية
  // ============================================================
  final List<Map<String, dynamic>> _pharmacies = [
    {'name': 'صيدلية الشفاء', 'address': 'شارع الزبيري، أمام مستشفى الثورة', 'lat': 15.3510, 'lng': 44.1990, 'phone': '01-123456', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.5},
    {'name': 'صيدلية اليمن', 'address': 'شارع التحرير، بجانب البنك المركزي', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-234567', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية الأمل', 'address': 'شارع هائل، أمام جامعة صنعاء', 'lat': 15.3650, 'lng': 44.1970, 'phone': '01-345678', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.6},
    {'name': 'صيدلية ابن حيان', 'address': 'شارع الستين، الحصبة', 'lat': 15.3820, 'lng': 44.2080, 'phone': '01-456789', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.9},
    {'name': 'صيدلية الشهيد', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-567890', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية النصر', 'address': 'شارع الأربعين، شارع الستين', 'lat': 15.3250, 'lng': 44.1830, 'phone': '01-678901', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.7},
    {'name': 'صيدلية الحياة', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3520, 'lng': 44.1980, 'phone': '01-789012', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية البرج', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3620, 'lng': 44.1960, 'phone': '01-890123', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية اليقين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-901234', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 3.8},
    {'name': 'صيدلية الوطنية', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-012345', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.5},
    {'name': 'صيدلية الصحة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-112233', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية الإيمان', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-223344', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية الرازي', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3550, 'lng': 44.2060, 'phone': '01-334455', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.9},
    {'name': 'صيدلية القدس', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-445566', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية الأقصى', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3140, 'lng': 44.1780, 'phone': '01-556677', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.5},
    {'name': 'صيدلية النور', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3490, 'lng': 44.1960, 'phone': '01-667788', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية الهدى', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3190, 'lng': 44.1790, 'phone': '01-778899', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 3.8},
    {'name': 'صيدلية الفاروق', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3670, 'lng': 44.1920, 'phone': '01-889900', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 4.0},
    {'name': 'صيدلية السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1950, 'phone': '01-990011', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true, 'rating': 4.1},
    {'name': 'صيدلية الوفاء', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-001122', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.5},
    {'name': 'صيدلية الأندلس', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3440, 'lng': 44.1990, 'phone': '01-112244', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية الحكمة', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3270, 'lng': 44.1810, 'phone': '01-223355', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية الأطباء', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2050, 'phone': '01-334466', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.7},
    {'name': 'صيدلية المستقبل', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3470, 'lng': 44.1950, 'phone': '01-445577', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية التعاون', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3630, 'lng': 44.1980, 'phone': '01-556688', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية المدينة', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3330, 'lng': 44.1820, 'phone': '01-667799', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 3.8},
    {'name': 'صيدلية اليمامة', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1920, 'phone': '01-778800', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': true, 'rating': 4.1},
    {'name': 'صيدلية الربيع', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3880, 'lng': 44.2140, 'phone': '01-889911', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية الجزيرة', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3730, 'lng': 44.2060, 'phone': '01-990022', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.5},
    {'name': 'صيدلية الأقصى الجديدة', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3410, 'lng': 44.1980, 'phone': '01-001133', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية الهلال', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3290, 'lng': 44.1780, 'phone': '01-112255', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.7},
    {'name': 'صيدلية الزهراء', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3560, 'lng': 44.2070, 'phone': '01-223366', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.5},
    {'name': 'صيدلية الأمن', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3500, 'lng': 44.1940, 'phone': '01-334477', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 3.9},
    {'name': 'صيدلية الإخلاص', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-445588', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 4.0},
    {'name': 'صيدلية طيبة', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1960, 'phone': '01-556699', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية الصفوة', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3170, 'lng': 44.1760, 'phone': '01-667700', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 3.6},
    {'name': 'صيدلية النهضة', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3760, 'lng': 44.2050, 'phone': '01-778811', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.8},
    {'name': 'صيدلية الفيحاء', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-889922', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية الرحمة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3840, 'lng': 44.2120, 'phone': '01-990033', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 3.9},
    {'name': 'صيدلية البراء', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3570, 'lng': 44.2080, 'phone': '01-001144', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 4.1},
    {'name': 'صيدلية العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3150, 'lng': 44.1740, 'phone': '01-112266', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': true, 'rating': 3.7},
    {'name': 'صيدلية الفردوس', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3540, 'lng': 44.1970, 'phone': '01-223377', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية العنقاء', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3680, 'lng': 44.1940, 'phone': '01-334488', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية البشير', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3600, 'lng': 44.1910, 'phone': '01-445599', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية النجاح', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3310, 'lng': 44.1840, 'phone': '01-556600', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 3.8},
    {'name': 'صيدلية اليمن السعيد', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3750, 'lng': 44.2090, 'phone': '01-667711', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 4.3},
    {'name': 'صيدلية دار الدواء', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3420, 'lng': 44.1990, 'phone': '01-778822', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true, 'rating': 4.1},
    {'name': 'صيدلية اليسر', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3510, 'lng': 44.2040, 'phone': '01-889933', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.5},
    {'name': 'صيدلية الريان', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3350, 'lng': 44.1860, 'phone': '01-990044', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.5},
    {'name': 'صيدلية الإحسان', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1980, 'phone': '01-001155', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية السعادة', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3720, 'lng': 44.1890, 'phone': '01-112277', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية التوفيق', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1920, 'phone': '01-223388', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 3.7},
    {'name': 'صيدلية الخير', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3910, 'lng': 44.2150, 'phone': '01-334499', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية الأنوار', 'address': 'شارع الستين، جولة 48', 'lat': 15.3360, 'lng': 44.1870, 'phone': '01-445500', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 3.9},
    {'name': 'صيدلية الجامعة', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3790, 'lng': 44.2040, 'phone': '01-556611', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية الهداية', 'address': 'شارع باب اليمن، ميدان التحرير', 'lat': 15.3480, 'lng': 44.2010, 'phone': '01-667722', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية المنار', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3540, 'lng': 44.2040, 'phone': '01-778833', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية التقوى', 'address': 'شارع الستين، شارع الستين الشمالي', 'lat': 15.3390, 'lng': 44.1710, 'phone': '01-889944', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 3.8},
    {'name': 'صيدلية الروضة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3640, 'lng': 44.1960, 'phone': '01-990055', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية البستان', 'address': 'شارع الزبيري، أمام الخطوط الجوية', 'lat': 15.3470, 'lng': 44.2000, 'phone': '01-001166', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.5},
    {'name': 'صيدلية الأزهر', 'address': 'شارع الستين، حي الأزهر', 'lat': 15.3355, 'lng': 44.1865, 'phone': '01-112277', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.1},
    {'name': 'صيدلية التقوى الجديدة', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-223388', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية الهداية الجديدة', 'address': 'شارع الخمسين، حي الهداية', 'lat': 15.3795, 'lng': 44.2095, 'phone': '01-334499', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية الشفاء الجديدة', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3575, 'lng': 44.1925, 'phone': '01-445500', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 3.9},
    {'name': 'صيدلية الأمان', 'address': 'شارع باب اليمن، حي الأمان', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-556611', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 4.0},
    {'name': 'صيدلية البناء', 'address': 'شارع القاهرة، حي البناء', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-667722', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية النجاح الجديدة', 'address': 'شارع الستين، حي النجاح', 'lat': 15.3315, 'lng': 44.1775, 'phone': '01-778833', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 3.8},
    {'name': 'صيدلية التقدم', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3875, 'lng': 44.2155, 'phone': '01-889944', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.7},
    {'name': 'صيدلية الأمل الكبير', 'address': 'شارع الزبيري، حي الأمل الكبير', 'lat': 15.3495, 'lng': 44.2015, 'phone': '01-990055', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية الحياة الكبيرة', 'address': 'شارع هائل، حي الحياة الكبير', 'lat': 15.3625, 'lng': 44.1975, 'phone': '01-001166', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.1},
    {'name': 'صيدلية السلام الكبيرة', 'address': 'شارع الخمسين، حي السلام الكبير', 'lat': 15.3715, 'lng': 44.2075, 'phone': '01-112277', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية النصر الجديدة', 'address': 'شارع التحرير، حي النصر', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-223388', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية الفتح الجديدة', 'address': 'شارع باب اليمن، حي الفتح', 'lat': 15.3485, 'lng': 44.2025, 'phone': '01-334499', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية الأصالة', 'address': 'شارع القاهرة، حي الأصالة', 'lat': 15.3515, 'lng': 44.2045, 'phone': '01-445500', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.5},
    {'name': 'صيدلية الريان الجديدة', 'address': 'شارع الستين، حي الريان', 'lat': 15.3395, 'lng': 44.1735, 'phone': '01-556611', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية المنار الجديدة', 'address': 'شارع العدين، حي المنار', 'lat': 15.3835, 'lng': 44.2115, 'phone': '01-667722', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 3.9},
    {'name': 'صيدلية الوفاء الكبيرة', 'address': 'شارع الزبيري، حي الوفاء', 'lat': 15.3475, 'lng': 44.1975, 'phone': '01-778833', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 4.1},
    {'name': 'صيدلية العطاء', 'address': 'شارع هائل، حي العطاء', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-889944', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': true, 'rating': 3.8},
    {'name': 'صيدلية الشروق', 'address': 'شارع الخمسين، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-990055', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.4},
    {'name': 'صيدلية السعادة الجديدة', 'address': 'شارع التحرير، حي السعادة', 'lat': 15.3585, 'lng': 44.1905, 'phone': '01-001166', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.6},
    {'name': 'صيدلية البشائر', 'address': 'شارع باب اليمن، حي البشائر', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-112277', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.0},
    {'name': 'صيدلية الكرامة', 'address': 'شارع القاهرة، حي الكرامة', 'lat': 15.3565, 'lng': 44.2075, 'phone': '01-223388', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true, 'rating': 4.3},
    {'name': 'صيدلية الصحة الجديدة', 'address': 'شارع الستين، حي الصحة', 'lat': 15.3335, 'lng': 44.1815, 'phone': '01-334499', 'hours': '24 ساعة', 'image': '💊', 'delivery': false, 'rating': 3.7},
    {'name': 'صيدلية التضامن', 'address': 'شارع العدين، حي التضامن', 'lat': 15.3895, 'lng': 44.2135, 'phone': '01-445500', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': true, 'rating': 3.9},
    {'name': 'صيدلية الازدهار', 'address': 'شارع الزبيري، حي الازدهار', 'lat': 15.3505, 'lng': 44.2005, 'phone': '01-556611', 'hours': '24 ساعة', 'image': '💊', 'delivery': true, 'rating': 4.2},
    {'name': 'صيدلية الأنوار الجديدة', 'address': 'شارع هائل، حي الأنوار', 'lat': 15.3635, 'lng': 44.1965, 'phone': '01-667722', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false, 'rating': 3.5},
  ];

  // ============================================================
  // 🔬 100+ مختبر
  // ============================================================
  final List<Map<String, dynamic>> _labs = [
    {'name': 'المختبر الوطني', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-012345', 'tests': '650+', 'image': '🔬', 'accredited': true, 'rating': 4.7},
    {'name': 'مختبر الثقة', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3520, 'lng': 44.1980, 'phone': '01-123456', 'tests': '520+', 'image': '🔬', 'accredited': true, 'rating': 4.5},
    {'name': 'مختبر البرج', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3620, 'lng': 44.1960, 'phone': '01-234567', 'tests': '480+', 'image': '🔬', 'accredited': true, 'rating': 4.2},
    {'name': 'مختبر اليقين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-345678', 'tests': '350+', 'image': '🔬', 'accredited': true, 'rating': 4.0},
    {'name': 'مختبرات الحياة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-456789', 'tests': '420+', 'image': '🔬', 'accredited': false, 'rating': 3.8},
    {'name': 'معمل ابن سينا', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3490, 'lng': 44.1960, 'phone': '01-567890', 'tests': '380+', 'image': '🧪', 'accredited': true, 'rating': 4.3},
    {'name': 'مختبر الأمل', 'address': 'شارع هائل، أمام جامعة صنعاء', 'lat': 15.3650, 'lng': 44.1970, 'phone': '01-678901', 'tests': '290+', 'image': '🔬', 'accredited': false, 'rating': 3.6},
    {'name': 'معامل النخبة', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3330, 'lng': 44.1820, 'phone': '01-789012', 'tests': '550+', 'image': '🧪', 'accredited': true, 'rating': 4.6},
    {'name': 'مختبر الشروق', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-890123', 'tests': '310+', 'image': '🔬', 'accredited': false, 'rating': 3.5},
    {'name': 'معمل الدقة', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-901234', 'tests': '460+', 'image': '🧪', 'accredited': true, 'rating': 4.4},
    {'name': 'مختبر الصحة', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3140, 'lng': 44.1780, 'phone': '01-112345', 'tests': '270+', 'image': '🔬', 'accredited': false, 'rating': 3.4},
    {'name': 'معامل اليمن', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1920, 'phone': '01-223456', 'tests': '500+', 'image': '🧪', 'accredited': true, 'rating': 4.5},
    {'name': 'مختبر القدس', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-334567', 'tests': '340+', 'image': '🔬', 'accredited': true, 'rating': 4.1},
    {'name': 'معمل الرازي', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-445678', 'tests': '410+', 'image': '🧪', 'accredited': false, 'rating': 3.9},
    {'name': 'مختبر الإيمان', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3550, 'lng': 44.2060, 'phone': '01-556789', 'tests': '280+', 'image': '🔬', 'accredited': true, 'rating': 4.0},
    {'name': 'معامل الصفوة', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3190, 'lng': 44.1790, 'phone': '01-667890', 'tests': '530+', 'image': '🧪', 'accredited': true, 'rating': 4.6},
    {'name': 'مختبر الجزيرة', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3470, 'lng': 44.1950, 'phone': '01-778901', 'tests': '360+', 'image': '🔬', 'accredited': false, 'rating': 3.7},
    {'name': 'معمل السلام', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3670, 'lng': 44.1920, 'phone': '01-889012', 'tests': '440+', 'image': '🧪', 'accredited': true, 'rating': 4.3},
    {'name': 'مختبر الهدى', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3270, 'lng': 44.1810, 'phone': '01-990123', 'tests': '250+', 'image': '🔬', 'accredited': false, 'rating': 3.3},
    {'name': 'معامل الفارابي', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1950, 'phone': '01-001234', 'tests': '580+', 'image': '🧪', 'accredited': true, 'rating': 4.7},
    {'name': 'مختبر الأندلس', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3880, 'lng': 44.2140, 'phone': '01-112456', 'tests': '320+', 'image': '🔬', 'accredited': true, 'rating': 3.8},
    {'name': 'معمل الحكمة', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3730, 'lng': 44.2060, 'phone': '01-223567', 'tests': '470+', 'image': '🧪', 'accredited': true, 'rating': 4.4},
    {'name': 'مختبر النور', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3440, 'lng': 44.1990, 'phone': '01-334678', 'tests': '390+', 'image': '🔬', 'accredited': false, 'rating': 3.6},
    {'name': 'معامل الأطباء', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2050, 'phone': '01-445789', 'tests': '510+', 'image': '🧪', 'accredited': true, 'rating': 4.5},
    {'name': 'مختبر اليمامة', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3290, 'lng': 44.1780, 'phone': '01-556890', 'tests': '260+', 'image': '🔬', 'accredited': false, 'rating': 3.2},
    {'name': 'معمل التعاون', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3500, 'lng': 44.1940, 'phone': '01-667901', 'tests': '430+', 'image': '🧪', 'accredited': true, 'rating': 4.2},
    {'name': 'مختبر المستقبل', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3630, 'lng': 44.1980, 'phone': '01-778012', 'tests': '370+', 'image': '🔬', 'accredited': true, 'rating': 4.1},
    {'name': 'معامل الزهراء', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1960, 'phone': '01-889123', 'tests': '490+', 'image': '🧪', 'accredited': true, 'rating': 4.3},
    {'name': 'مختبر الوفاء', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3310, 'lng': 44.1840, 'phone': '01-990234', 'tests': '300+', 'image': '🔬', 'accredited': false, 'rating': 3.5},
    {'name': 'معمل الفيحاء', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3760, 'lng': 44.2050, 'phone': '01-001345', 'tests': '540+', 'image': '🧪', 'accredited': true, 'rating': 4.6},
    {'name': 'مختبر الهلال', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-112567', 'tests': '330+', 'image': '🔬', 'accredited': true, 'rating': 3.9},
    {'name': 'معامل الإخلاص', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3560, 'lng': 44.2070, 'phone': '01-223678', 'tests': '450+', 'image': '🧪', 'accredited': true, 'rating': 4.4},
    {'name': 'مختبر طيبة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3840, 'lng': 44.2120, 'phone': '01-334789', 'tests': '280+', 'image': '🔬', 'accredited': false, 'rating': 3.5},
    {'name': 'معمل النهضة', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3540, 'lng': 44.1970, 'phone': '01-445890', 'tests': '560+', 'image': '🧪', 'accredited': true, 'rating': 4.7},
    {'name': 'مختبر الربيع', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-556901', 'tests': '240+', 'image': '🔬', 'accredited': false, 'rating': 3.2},
    {'name': 'معامل البراء', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3170, 'lng': 44.1760, 'phone': '01-667012', 'tests': '480+', 'image': '🧪', 'accredited': true, 'rating': 4.3},
    {'name': 'مختبر العروبة', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3600, 'lng': 44.1910, 'phone': '01-778123', 'tests': '310+', 'image': '🔬', 'accredited': true, 'rating': 4.0},
    {'name': 'معامل اليمن السعيد', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3350, 'lng': 44.1860, 'phone': '01-889234', 'tests': '420+', 'image': '🧪', 'accredited': true, 'rating': 4.1},
    {'name': 'مختبر الإحسان', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3750, 'lng': 44.2090, 'phone': '01-990345', 'tests': '350+', 'image': '🔬', 'accredited': false, 'rating': 3.7},
    {'name': 'معمل الروضة', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3410, 'lng': 44.1980, 'phone': '01-001456', 'tests': '500+', 'image': '🧪', 'accredited': true, 'rating': 4.5},
    {'name': 'مختبر التوفيق', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3570, 'lng': 44.2080, 'phone': '01-112678', 'tests': '270+', 'image': '🔬', 'accredited': false, 'rating': 3.4},
    {'name': 'معامل الخير', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3150, 'lng': 44.1740, 'phone': '01-223789', 'tests': '460+', 'image': '🧪', 'accredited': true, 'rating': 4.4},
    {'name': 'مختبر الأنوار', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1980, 'phone': '01-334890', 'tests': '380+', 'image': '🔬', 'accredited': true, 'rating': 4.0},
    {'name': 'معامل الهداية', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3720, 'lng': 44.1890, 'phone': '01-445901', 'tests': '520+', 'image': '🧪', 'accredited': true, 'rating': 4.6},
    {'name': 'مختبر المنار', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3910, 'lng': 44.2150, 'phone': '01-556012', 'tests': '290+', 'image': '🔬', 'accredited': false, 'rating': 3.5},
    {'name': 'معامل التقوى', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3790, 'lng': 44.2040, 'phone': '01-667123', 'tests': '440+', 'image': '🧪', 'accredited': true, 'rating': 4.3},
    {'name': 'مختبر البستان', 'address': 'شارع الستين، جولة 48', 'lat': 15.3360, 'lng': 44.1870, 'phone': '01-778234', 'tests': '360+', 'image': '🔬', 'accredited': true, 'rating': 3.8},
    {'name': 'معامل النجاح', 'address': 'شارع باب اليمن، ميدان التحرير', 'lat': 15.3480, 'lng': 44.2010, 'phone': '01-889345', 'tests': '500+', 'image': '🧪', 'accredited': true, 'rating': 4.5},
    {'name': 'مختبر اليسر', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3540, 'lng': 44.2040, 'phone': '01-990456', 'tests': '330+', 'image': '🔬', 'accredited': false, 'rating': 3.6},
    {'name': 'معامل السعادة', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1920, 'phone': '01-001567', 'tests': '470+', 'image': '🧪', 'accredited': true, 'rating': 4.4},
    {'name': 'مختبر الريان', 'address': 'شارع الستين، شارع الستين الشمالي', 'lat': 15.3390, 'lng': 44.1710, 'phone': '01-112789', 'tests': '250+', 'image': '🔬', 'accredited': false, 'rating': 3.2},
    {'name': 'معامل دار الشفاء', 'address': 'شارع الزبيري، أمام الخطوط الجوية', 'lat': 15.3470, 'lng': 44.2000, 'phone': '01-223890', 'tests': '550+', 'image': '🧪', 'accredited': true, 'rating': 4.7},
    {'name': 'مختبر الأمن', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3640, 'lng': 44.1960, 'phone': '01-334901', 'tests': '390+', 'image': '🔬', 'accredited': true, 'rating': 4.1},
    {'name': 'معامل الصادق', 'address': 'شارع الخمسين، شارع الستين', 'lat': 15.3380, 'lng': 44.1880, 'phone': '01-445012', 'tests': '410+', 'image': '🧪', 'accredited': true, 'rating': 3.9},
    {'name': 'مختبر الفاروق', 'address': 'شارع باب اليمن، شارع باب اليمن', 'lat': 15.3500, 'lng': 44.1990, 'phone': '01-556123', 'tests': '300+', 'image': '🔬', 'accredited': false, 'rating': 3.4},
    {'name': 'معامل العنقاء', 'address': 'شارع الستين، جولة آية', 'lat': 15.3400, 'lng': 44.1730, 'phone': '01-667234', 'tests': '480+', 'image': '🧪', 'accredited': true, 'rating': 4.5},
    {'name': 'مختبر القاسمي', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-778345', 'tests': '340+', 'image': '🔬', 'accredited': true, 'rating': 4.0},
    {'name': 'معامل الفتح', 'address': 'شارع الزبيري، شارع الستين', 'lat': 15.3320, 'lng': 44.1800, 'phone': '01-889456', 'tests': '420+', 'image': '🧪', 'accredited': true, 'rating': 4.2},
    {'name': 'مختبر النصر', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3690, 'lng': 44.1950, 'phone': '01-990567', 'tests': '370+', 'image': '🔬', 'accredited': false, 'rating': 3.6},
  ];

  // ============================================================
  // 🏨 50+ مرفق صحي
  // ============================================================
  final List<Map<String, dynamic>> _facilities = [
    {'name': 'مركز صحي التحرير', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3570, 'lng': 44.1950, 'phone': '01-111222', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 4.0},
    {'name': 'مركز صحي باب اليمن', 'address': 'شارع باب اليمن، السوق القديم', 'lat': 15.3460, 'lng': 44.2020, 'phone': '01-222333', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي الحصبة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3790, 'lng': 44.2080, 'phone': '01-333444', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 4.1},
    {'name': 'مركز صحي الروضة', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-444555', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 3.9},
    {'name': 'مركز صحي السبعين', 'address': 'شارع الأربعين، حي السبعين', 'lat': 15.3120, 'lng': 44.1790, 'phone': '01-555666', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.7},
    {'name': 'مركز صحي حدة', 'address': 'شارع الستين، حدة', 'lat': 15.3240, 'lng': 44.1820, 'phone': '01-666777', 'type': 'مركز صحي', 'services': 'عيادات عامة، تطعيمات', 'image': '🏨', 'rating': 3.6},
    {'name': 'مركز صحي معين', 'address': 'شارع الزبيري، حي معين', 'lat': 15.3510, 'lng': 44.1970, 'phone': '01-777888', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 4.0},
    {'name': 'مركز صحي حزيز', 'address': 'شارع القاهرة، حي حزيز', 'lat': 15.3530, 'lng': 44.2060, 'phone': '01-888999', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي ظهرة', 'address': 'شارع العدين، ظهرة', 'lat': 15.3880, 'lng': 44.2130, 'phone': '01-999000', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.5},
    {'name': 'مركز صحي نهم', 'address': 'شارع الستين، نهم', 'lat': 15.3360, 'lng': 44.1760, 'phone': '01-000111', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.7},
    {'name': 'مركز صحي جبل النصر', 'address': 'شارع الخمسين، جبل النصر', 'lat': 15.3770, 'lng': 44.2070, 'phone': '01-111333', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 4.0},
    {'name': 'مركز صحي شعب', 'address': 'شارع الزبيري، حي شعب', 'lat': 15.3490, 'lng': 44.1980, 'phone': '01-222444', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 3.6},
    {'name': 'مركز صحي حدة الجديد', 'address': 'شارع الستين، حدة الجديدة', 'lat': 15.3260, 'lng': 44.1830, 'phone': '01-333555', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.9},
    {'name': 'مركز صحي ضلاع', 'address': 'شارع العدين، ضلاع', 'lat': 15.3850, 'lng': 44.2140, 'phone': '01-444666', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي بني الحارث', 'address': 'شارع الخمسين، بني الحارث', 'lat': 15.3760, 'lng': 44.2100, 'phone': '01-555777', 'type': 'مركز صحي', 'services': 'عيادات عامة، تطعيمات', 'image': '🏨', 'rating': 3.5},
    {'name': 'مركز صحي سنحان', 'address': 'شارع الستين، سنحان', 'lat': 15.3320, 'lng': 44.1750, 'phone': '01-666888', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 3.7},
    {'name': 'مركز صحي بيت بوس', 'address': 'شارع الزبيري، بيت بوس', 'lat': 15.3500, 'lng': 44.1960, 'phone': '01-777999', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 4.1},
    {'name': 'مركز صحي ربعي', 'address': 'شارع القاهرة، حي ربعي', 'lat': 15.3540, 'lng': 44.2040, 'phone': '01-888000', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.6},
    {'name': 'مركز صحي مسجد', 'address': 'شارع العدين، حي المسجد', 'lat': 15.3860, 'lng': 44.2120, 'phone': '01-999111', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.9},
    {'name': 'مركز صحي الأزهر', 'address': 'شارع الستين، حي الأزهر', 'lat': 15.3340, 'lng': 44.1850, 'phone': '01-000222', 'type': 'مركز صحي', 'services': 'عيادات عامة، تطعيمات', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي النهضة', 'address': 'شارع الخمسين، حي النهضة', 'lat': 15.3780, 'lng': 44.2060, 'phone': '01-111444', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 4.0},
    {'name': 'مركز صحي السلام', 'address': 'شارع التحرير، حي السلام', 'lat': 15.3560, 'lng': 44.1940, 'phone': '01-222555', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 3.7},
    {'name': 'مركز صحي الفردوس', 'address': 'شارع باب اليمن، حي الفردوس', 'lat': 15.3450, 'lng': 44.2000, 'phone': '01-333666', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.5},
    {'name': 'مركز صحي الصالح', 'address': 'شارع هائل، حي الصالح', 'lat': 15.3650, 'lng': 44.1950, 'phone': '01-444777', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 4.2},
    {'name': 'مركز صحي الحديقة', 'address': 'شارع القاهرة، حي الحديقة', 'lat': 15.3520, 'lng': 44.2050, 'phone': '01-555888', 'type': 'مركز صحي', 'services': 'عيادات عامة، تطعيمات', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي المطار', 'address': 'شارع الخمسين، المطار', 'lat': 15.3740, 'lng': 44.2090, 'phone': '01-666999', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 3.9},
    {'name': 'مركز صحي الجامعة', 'address': 'شارع هائل، الجامعة', 'lat': 15.3640, 'lng': 44.1960, 'phone': '01-777000', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 4.0},
    {'name': 'مركز صحي المحطة', 'address': 'شارع الزبيري، المحطة', 'lat': 15.3480, 'lng': 44.1970, 'phone': '01-888111', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.6},
    {'name': 'مركز صحي السوق', 'address': 'شارع باب اليمن، السوق', 'lat': 15.3440, 'lng': 44.2010, 'phone': '01-999222', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.7},
    {'name': 'مركز صحي البساتين', 'address': 'شارع الستين، البساتين', 'lat': 15.3300, 'lng': 44.1810, 'phone': '01-000333', 'type': 'مركز صحي', 'services': 'عيادات عامة، تطعيمات', 'image': '🏨', 'rating': 3.5},
    {'name': 'مركز صحي الكبوس', 'address': 'شارع التحرير، الكبوس', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-111555', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 4.1},
    {'name': 'مركز صحي الحشيشي', 'address': 'شارع القاهرة، الحشيشي', 'lat': 15.3550, 'lng': 44.2070, 'phone': '01-222666', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي السياسي', 'address': 'شارع الخمسين، السياسي', 'lat': 15.3770, 'lng': 44.2050, 'phone': '01-333777', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.6},
    {'name': 'مركز صحي الأندلس', 'address': 'شارع العدين، الأندلس', 'lat': 15.3870, 'lng': 44.2120, 'phone': '01-444888', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.9},
    {'name': 'مركز صحي الروضة الجديد', 'address': 'شارع هائل، الروضة الجديدة', 'lat': 15.3670, 'lng': 44.1920, 'phone': '01-555999', 'type': 'مركز صحي', 'services': 'عيادات عامة، تطعيمات', 'image': '🏨', 'rating': 4.0},
    {'name': 'مركز صحي الشعب', 'address': 'شارع الزبيري، الشعب', 'lat': 15.3490, 'lng': 44.1990, 'phone': '01-666000', 'type': 'مركز صحي', 'services': 'عيادات عامة، نساء وولادة', 'image': '🏨', 'rating': 3.7},
    {'name': 'مركز صحي السعادة', 'address': 'شارع الستين، السعادة', 'lat': 15.3330, 'lng': 44.1780, 'phone': '01-777111', 'type': 'مركز صحي', 'services': 'عيادات عامة، أسنان', 'image': '🏨', 'rating': 3.5},
    {'name': 'مركز صحي المنصورة', 'address': 'شارع الخمسين، المنصورة', 'lat': 15.3750, 'lng': 44.2080, 'phone': '01-888222', 'type': 'مركز صحي', 'services': 'عيادات عامة، أطفال', 'image': '🏨', 'rating': 3.8},
    {'name': 'مركز صحي قرية', 'address': 'شارع العدين، قرية', 'lat': 15.3830, 'lng': 44.2140, 'phone': '01-999333', 'type': 'مركز صحي', 'services': 'عيادات عامة، طوارئ', 'image': '🏨', 'rating': 3.6},
  ];

  // ============================================================
  // ⚕️ 50+ أخرى (عيادات خاصة، مراكز تخصصية)
  // ============================================================
  final List<Map<String, dynamic>> _others = [
    {'name': 'عيادة الدكتور أحمد', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3510, 'lng': 44.1980, 'phone': '01-111222', 'type': 'عيادة خاصة', 'specialties': 'باطنية', 'image': '⚕️', 'rating': 4.5},
    {'name': 'عيادة الدكتور ياسين', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3630, 'lng': 44.1960, 'phone': '01-222333', 'type': 'عيادة خاصة', 'specialties': 'قلبية', 'image': '⚕️', 'rating': 4.7},
    {'name': 'عيادة الدكتور خالد', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-333444', 'type': 'عيادة خاصة', 'specialties': 'جلدية', 'image': '⚕️', 'rating': 4.3},
    {'name': 'عيادة الدكتور سمير', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-444555', 'type': 'عيادة خاصة', 'specialties': 'عيون', 'image': '⚕️', 'rating': 4.6},
    {'name': 'عيادة الدكتور وليد', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3340, 'lng': 44.1830, 'phone': '01-555666', 'type': 'عيادة خاصة', 'specialties': 'أنف وأذن وحنجرة', 'image': '⚕️', 'rating': 4.2},
    {'name': 'عيادة الدكتور نبيل', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-666777', 'type': 'عيادة خاصة', 'specialties': 'أسنان', 'image': '⚕️', 'rating': 4.4},
    {'name': 'عيادة الدكتورة سعاد', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1980, 'phone': '01-777888', 'type': 'عيادة خاصة', 'specialties': 'نساء وولادة', 'image': '⚕️', 'rating': 4.8},
    {'name': 'عيادة الدكتور فارس', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3660, 'lng': 44.1920, 'phone': '01-888999', 'type': 'عيادة خاصة', 'specialties': 'عظام', 'image': '⚕️', 'rating': 4.5},
    {'name': 'عيادة الدكتور هاني', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1950, 'phone': '01-999000', 'type': 'عيادة خاصة', 'specialties': 'مسالك بولية', 'image': '⚕️', 'rating': 4.1},
    {'name': 'عيادة الدكتور رياض', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-000111', 'type': 'عيادة خاصة', 'specialties': 'أطفال', 'image': '⚕️', 'rating': 4.6},
    {'name': 'عيادة الدكتور عبدالله', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-111222', 'type': 'عيادة خاصة', 'specialties': 'باطنية', 'image': '⚕️', 'rating': 4.0},
    {'name': 'عيادة الدكتور محمد', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3550, 'lng': 44.2060, 'phone': '01-222333', 'type': 'عيادة خاصة', 'specialties': 'قلبية', 'image': '⚕️', 'rating': 4.4},
    {'name': 'عيادة الدكتور علي', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-333444', 'type': 'عيادة خاصة', 'specialties': 'جلدية', 'image': '⚕️', 'rating': 3.9},
    {'name': 'عيادة الدكتور حسن', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3190, 'lng': 44.1790, 'phone': '01-444555', 'type': 'عيادة خاصة', 'specialties': 'عيون', 'image': '⚕️', 'rating': 4.2},
    {'name': 'عيادة الدكتور ناصر', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3540, 'lng': 44.1970, 'phone': '01-555666', 'type': 'عيادة خاصة', 'specialties': 'أنف وأذن وحنجرة', 'image': '⚕️', 'rating': 4.0},
    {'name': 'مركز علاج طبيعي الحياة', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-666777', 'type': 'مركز علاج طبيعي', 'specialties': 'علاج فيزيائي', 'image': '🦿', 'rating': 4.3},
    {'name': 'مركز علاج طبيعي الأمل', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3270, 'lng': 44.1810, 'phone': '01-777888', 'type': 'مركز علاج طبيعي', 'specialties': 'علاج فيزيائي', 'image': '🦿', 'rating': 4.1},
    {'name': 'مركز صحي نفسي السلام', 'address': 'شارع الخمسين، حي السلام', 'lat': 15.3760, 'lng': 44.2050, 'phone': '01-888999', 'type': 'مركز صحي نفسي', 'specialties': 'صحة نفسية', 'image': '🧠', 'rating': 4.0},
    {'name': 'مركز صحي نفسي الأمان', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3440, 'lng': 44.1990, 'phone': '01-999000', 'type': 'مركز صحي نفسي', 'specialties': 'صحة نفسية', 'image': '🧠', 'rating': 3.8},
    {'name': 'مركز تنظيم الأسرة', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3500, 'lng': 44.1960, 'phone': '01-000111', 'type': 'مركز تنظيم أسرة', 'specialties': 'صحة إنجابية', 'image': '👨‍👩‍👦', 'rating': 4.2},
    {'name': 'مركز التغذية العلاجية', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3680, 'lng': 44.1940, 'phone': '01-111222', 'type': 'مركز تغذية', 'specialties': 'تغذية', 'image': '🥗', 'rating': 4.4},
    {'name': 'مركز اللياقة الصحية', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3560, 'lng': 44.2070, 'phone': '01-222333', 'type': 'مركز لياقة', 'specialties': 'لياقة بدنية', 'image': '🏋️', 'rating': 4.5},
    {'name': 'مركز اليوغا والصحة', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3840, 'lng': 44.2120, 'phone': '01-333444', 'type': 'مركز يوغا', 'specialties': 'يوغا وتأمل', 'image': '🧘', 'rating': 4.6},
    {'name': 'مركز مكافحة التدخين', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3290, 'lng': 44.1780, 'phone': '01-444555', 'type': 'مركز إقلاع عن التدخين', 'specialties': 'صحة تنفسية', 'image': '🚭', 'rating': 4.1},
    {'name': 'مركز رعاية المسنين', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3730, 'lng': 44.2060, 'phone': '01-555666', 'type': 'دار رعاية', 'specialties': 'رعاية مسنين', 'image': '🧓', 'rating': 4.0},
    {'name': 'مركز رعاية الأطفال', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1960, 'phone': '01-666777', 'type': 'دار رعاية', 'specialties': 'رعاية أطفال', 'image': '👶', 'rating': 4.3},
  ];

  // ============================================================
  // ✅ GETTERS
  // ============================================================
  List<Map<String, dynamic>> get _currentLocations {
    switch (widget.type) {
      case 'hospitals': return _hospitals;
      case 'pharmacies': return _pharmacies;
      case 'labs': return _labs;
      case 'facilities': return _facilities;
      case 'others': return _others;
      case 'all': return [..._hospitals, ..._pharmacies, ..._labs, ..._facilities, ..._others];
      case 'tracking': return _hospitals;
      default: return _hospitals;
    }
  }

  String get _title {
    final count = _currentLocations.length;
    switch (widget.type) {
      case 'hospitals': return 'المستشفيات ($count)';
      case 'pharmacies': return 'الصيدليات ($count)';
      case 'labs': return 'المختبرات ($count)';
      case 'facilities': return 'المرافق الصحية ($count)';
      case 'others': return 'أخرى ($count)';
      case 'all': return 'جميع المنشآت ($count)';
      case 'tracking': return 'تتبع الطلب';
      default: return 'الخريطة ($count)';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case 'hospitals': return Icons.local_hospital;
      case 'pharmacies': return Icons.local_pharmacy;
      case 'labs': return Icons.science;
      case 'facilities': return Icons.health_and_safety;
      case 'others': return Icons.medical_services;
      case 'all': return Icons.map;
      case 'tracking': return Icons.local_shipping;
      default: return Icons.map;
    }
  }

  Color _getMarkerColor() {
    switch (widget.type) {
      case 'hospitals': return AppColors.error;
      case 'pharmacies': return AppColors.success;
      case 'labs': return AppColors.info;
      case 'facilities': return Colors.orange;
      case 'others': return Colors.purple;
      case 'all': return AppColors.primary;
      case 'tracking': return AppColors.primary;
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

  List<String> get _filterOptions {
    final types = <String>{'الكل'};
    for (var loc in _currentLocations) {
      if (loc['type'] != null) types.add(loc['type'].toString());
    }
    return types.toList();
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
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                          Text(
                            loc['rating'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
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
                ],
              ),
            ],
          ),
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
    final markerColor = _getMarkerColor();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: const Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.layers, color: Colors.white),
            onSelected: (v) => setState(() => _selectedLayer = v),
            itemBuilder: (_) => _mapLayers.keys.map((k) {
              return PopupMenuItem(
                value: k,
                child: Row(
                  children: [
                    if (_selectedLayer == k)
                      const Icon(Icons.check, color: AppColors.primary, size: 16),
                    const SizedBox(width: 4),
                    Text(k),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
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
                              color: Colors.black.withOpacity(0.4),
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
                          border: Border.all(color: Colors.blue, width: 2),
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
          // ✅ شريط البحث
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: '🔍 ابحث عن منشأة صحية...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                ),
              ),
            ),
          ),
          // ✅ أزرار التحكم
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
                  backgroundColor: const Color(0xFF2A2A2A),
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
                  backgroundColor: const Color(0xFF2A2A2A),
                  child: const Icon(Icons.remove, color: Colors.white),
                ),
              ],
            ),
          ),
          // ✅ زر تحديد الموقع
          Positioned(
            left: 10,
            bottom: 150,
            child: FloatingActionButton(
              heroTag: 'my_loc',
              mini: true,
              onPressed: _getCurrentLocation,
              backgroundColor: const Color(0xFF2A2A2A),
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          // ✅ قائمة المنشآت
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildLocationsList(),
          ),
          // ✅ تتبع الطلب
          if (widget.type == 'tracking')
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: _buildTrackingCard(),
            ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'تصفية النتائج',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _filterOptions.map((option) {
                final isSelected = _filterType == option;
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _filterType = selected ? option : 'الكل');
                    Navigator.pop(context);
                  },
                  selectedColor: AppColors.primary,
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }


  Widget _buildLocationsList() {
    final locations = _filteredLocations;
    final markerColor = _getMarkerColor();

    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
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
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${locations.length} منشأة',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
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
                          ? markerColor.withOpacity(0.15)
                          : Colors.grey[900],
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
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          loc['address'],
                          style: TextStyle(fontSize: 8, color: Colors.grey[400]),
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

  Widget _buildTrackingCard() {
    final steps = ["تم الطلب", "قيد التجهيز", "تم الشحن", "تم التوصيل"];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_shipping,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "طلبك في الطريق!",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "رقم الطلب: ${widget.orderId ?? "#SHK-784512"}",
                      style: TextStyle(fontSize: 9, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(steps.length, (i) {
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: i < _currentStep ? AppColors.success : Colors.grey[700],
                        shape: BoxShape.circle,
                      ),
                      child: i < _currentStep
                          ? const Icon(Icons.check, size: 7, color: Colors.white)
                          : null,
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < _currentStep - 1 ? AppColors.success : Colors.grey[700],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(steps.length, (i) {
              return Expanded(
                child: Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 7,
                    color: i < _currentStep ? AppColors.success : Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("⏱️ ", style: TextStyle(fontSize: 14)),
                Text(
                  "الوقت المتوقع: 18 دقيقة",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
