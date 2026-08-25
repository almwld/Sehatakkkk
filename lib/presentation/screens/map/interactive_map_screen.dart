import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class InteractiveMapScreen extends StatefulWidget {
  final String type;
  final String? orderId;
  const InteractiveMapScreen({super.key, this.type = 'hospitals', this.orderId});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();

  // ============================================================
  // 📌 أيقونات SVG من مجلد map_pins
  // ============================================================
  late final PictureProvider _hospitalIcon;
  late final PictureProvider _pharmacyIcon;
  late final PictureProvider _laboratoryIcon;
  late final PictureProvider _medicalIcon;
  late final PictureProvider _clinicIcon;

  static const LatLng sanaaCenter = LatLng(15.3694, 44.1910);
  String _selectedLayer = 'خريطة داكنة';
  Position? _currentPosition;
  LatLng? _selectedLocation;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';

  final List<String> _categories = [
    'الكل',
    'مستشفيات',
    'صيدليات',
    'مختبرات',
    'عيادات',
    'أخرى',
  ];

  final Map<String, Map<String, String>> _mapLayers = {
    'خريطة داكنة': {
      'url': 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
      'desc': 'خريطة داكنة احترافية'
    },
    'خريطة الشوارع': {
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      'desc': 'خريطة شوارع مفتوحة'
    },
  };

  // ============================================================
  // 🏥 المستشفيات (100)
  // ============================================================
  final List<Map<String, dynamic>> _hospitals = [
    {'name': 'مستشفى الثورة العام', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3500, 'lng': 44.2000, 'phone': '01-222222', 'type': 'حكومي', 'beds': '500', 'emergency': true, 'rating': 4.5, 'category': 'hospitals'},
    {'name': 'المستشفى الجمهوري', 'address': 'شارع الزبيري، ميدان التحرير', 'lat': 15.3530, 'lng': 44.2010, 'phone': '01-999444', 'type': 'حكومي', 'beds': '450', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى الكويت الجامعي', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3800, 'lng': 44.2100, 'phone': '01-333333', 'type': 'جامعي', 'beds': '400', 'emergency': true, 'rating': 4.4, 'category': 'hospitals'},
    {'name': 'مستشفى السبعين للأمومة', 'address': 'السبعين، شارع الأربعين', 'lat': 15.3100, 'lng': 44.1800, 'phone': '01-444444', 'type': 'تخصصي', 'beds': '300', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'المستشفى العسكري', 'address': 'شارع القاهرة، التحرير', 'lat': 15.3550, 'lng': 44.2050, 'phone': '01-777777', 'type': 'عسكري', 'beds': '600', 'emergency': true, 'rating': 4.6, 'category': 'hospitals'},
    {'name': 'مستشفى آزال', 'address': 'شارع هائل، التحرير', 'lat': 15.3600, 'lng': 44.1950, 'phone': '01-555555', 'type': 'خاص', 'beds': '150', 'emergency': true, 'rating': 4.7, 'category': 'hospitals'},
    {'name': 'مستشفى اليمن الألماني', 'address': 'شارع الستين، أمام الخطوط الجوية', 'lat': 15.3450, 'lng': 44.1750, 'phone': '01-111222', 'type': 'خاص', 'beds': '200', 'emergency': true, 'rating': 4.8, 'category': 'hospitals'},
    {'name': 'مستشفى النقيب', 'address': 'شارع العدين، شارع الستين', 'lat': 15.3300, 'lng': 44.1850, 'phone': '01-888888', 'type': 'خاص', 'beds': '100', 'emergency': false, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى العلوم الحديثة', 'address': 'شارع الخمسين، تقاطع هائل', 'lat': 15.3750, 'lng': 44.2000, 'phone': '01-999999', 'type': 'خاص', 'beds': '120', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى الأمل', 'address': 'شارع الزبيري، بجانب البنك المركزي', 'lat': 15.3490, 'lng': 44.2020, 'phone': '01-222333', 'type': 'خاص', 'beds': '80', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى الحياة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3630, 'lng': 44.1940, 'phone': '01-333444', 'type': 'خاص', 'beds': '90', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى الصفوة', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-444555', 'type': 'خاص', 'beds': '110', 'emergency': false, 'rating': 3.8, 'category': 'hospitals'},
    {'name': 'مستشفى الخليج', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3350, 'lng': 44.1820, 'phone': '01-555666', 'type': 'خاص', 'beds': '130', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى ابن النفيس', 'address': 'شارع باب اليمن، وسط المدينة', 'lat': 15.3470, 'lng': 44.2030, 'phone': '01-666777', 'type': 'خاص', 'beds': '70', 'emergency': false, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى الرازي', 'address': 'شارع الخمسين، حي الأندلس', 'lat': 15.3720, 'lng': 44.2020, 'phone': '01-777888', 'type': 'خاص', 'beds': '160', 'emergency': true, 'rating': 4.4, 'category': 'hospitals'},
    {'name': 'مستشفى الأهلي', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2040, 'phone': '01-888999', 'type': 'خاص', 'beds': '140', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى فلسطين', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3200, 'lng': 44.1790, 'phone': '01-999000', 'type': 'خاص', 'beds': '100', 'emergency': false, 'rating': 3.6, 'category': 'hospitals'},
    {'name': 'مستشفى 22 مايو', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3150, 'lng': 44.1770, 'phone': '01-000111', 'type': 'حكومي', 'beds': '220', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى 48', 'address': 'شارع الستين، بجانب جولة 48', 'lat': 15.3380, 'lng': 44.1880, 'phone': '01-111333', 'type': 'حكومي', 'beds': '180', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى جامعة الإيمان', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3800, 'lng': 44.2150, 'phone': '01-222444', 'type': 'جامعي', 'beds': '300', 'emergency': true, 'rating': 4.4, 'category': 'hospitals'},
    {'name': 'مستشفى الفارابي', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3680, 'lng': 44.1920, 'phone': '01-333555', 'type': 'خاص', 'beds': '85', 'emergency': false, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى الحكمة', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1990, 'phone': '01-444666', 'type': 'خاص', 'beds': '95', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1960, 'phone': '01-555777', 'type': 'خاص', 'beds': '75', 'emergency': false, 'rating': 3.5, 'category': 'hospitals'},
    {'name': 'مستشفى القدس', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3260, 'lng': 44.1810, 'phone': '01-666888', 'type': 'خاص', 'beds': '105', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى ابن سينا', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3700, 'lng': 44.2040, 'phone': '01-777999', 'type': 'خاص', 'beds': '190', 'emergency': true, 'rating': 4.6, 'category': 'hospitals'},
    {'name': 'مستشفى الأقصى', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3440, 'lng': 44.2010, 'phone': '01-888000', 'type': 'خاص', 'beds': '60', 'emergency': false, 'rating': 3.4, 'category': 'hospitals'},
    {'name': 'مستشفى النور', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3530, 'lng': 44.2070, 'phone': '01-999111', 'type': 'خاص', 'beds': '115', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى الهدى', 'address': 'شارع الستين، الحديدة', 'lat': 15.3400, 'lng': 44.1740, 'phone': '01-000222', 'type': 'خاص', 'beds': '88', 'emergency': false, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى الفيحاء', 'address': 'شارع العدين، السنينة', 'lat': 15.3900, 'lng': 44.2120, 'phone': '01-111444', 'type': 'خاص', 'beds': '125', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى الرحمة', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3640, 'lng': 44.1980, 'phone': '01-222555', 'type': 'خاص', 'beds': '72', 'emergency': false, 'rating': 3.6, 'category': 'hospitals'},
    {'name': 'مستشفى طيبة', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3550, 'lng': 44.1970, 'phone': '01-333666', 'type': 'خاص', 'beds': '135', 'emergency': true, 'rating': 4.4, 'category': 'hospitals'},
    {'name': 'مستشفى الجزيرة', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1910, 'phone': '01-444777', 'type': 'خاص', 'beds': '80', 'emergency': false, 'rating': 3.8, 'category': 'hospitals'},
    {'name': 'مستشفى الهلال', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3320, 'lng': 44.1830, 'phone': '01-555888', 'type': 'خاص', 'beds': '98', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى الزهراء', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3770, 'lng': 44.2060, 'phone': '01-666999', 'type': 'خاص', 'beds': '145', 'emergency': true, 'rating': 4.5, 'category': 'hospitals'},
    {'name': 'مستشفى الأندلس', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-777000', 'type': 'خاص', 'beds': '68', 'emergency': false, 'rating': 3.5, 'category': 'hospitals'},
    {'name': 'مستشفى التعاون', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3580, 'lng': 44.2080, 'phone': '01-888111', 'type': 'حكومي', 'beds': '280', 'emergency': true, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى الإخلاص', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3180, 'lng': 44.1760, 'phone': '01-999222', 'type': 'خاص', 'beds': '55', 'emergency': false, 'rating': 3.2, 'category': 'hospitals'},
    {'name': 'مستشفى الوفاء', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3730, 'lng': 44.1900, 'phone': '01-000333', 'type': 'خاص', 'beds': '108', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى الصادق', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3480, 'lng': 44.1960, 'phone': '01-111555', 'type': 'خاص', 'beds': '92', 'emergency': false, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى اليمامة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3850, 'lng': 44.2130, 'phone': '01-222666', 'type': 'خاص', 'beds': '118', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى البراء', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1940, 'phone': '01-333777', 'type': 'خاص', 'beds': '65', 'emergency': false, 'rating': 3.4, 'category': 'hospitals'},
    {'name': 'مستشفى الإسراء', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3340, 'lng': 44.1840, 'phone': '01-444888', 'type': 'خاص', 'beds': '132', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى العباس', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3760, 'lng': 44.2030, 'phone': '01-555999', 'type': 'خاص', 'beds': '78', 'emergency': false, 'rating': 3.6, 'category': 'hospitals'},
    {'name': 'مستشفى الزيتون', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3420, 'lng': 44.1980, 'phone': '01-666000', 'type': 'خاص', 'beds': '85', 'emergency': true, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى دار الشفاء', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3570, 'lng': 44.2060, 'phone': '01-777111', 'type': 'خاص', 'beds': '155', 'emergency': true, 'rating': 4.5, 'category': 'hospitals'},
    {'name': 'مستشفى البشير', 'address': 'شارع الستين، جولة 48', 'lat': 15.3370, 'lng': 44.1890, 'phone': '01-888222', 'type': 'خاص', 'beds': '102', 'emergency': false, 'rating': 3.8, 'category': 'hospitals'},
    {'name': 'مستشفى القاسمي', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-999333', 'type': 'خاص', 'beds': '175', 'emergency': true, 'rating': 4.4, 'category': 'hospitals'},
    {'name': 'مستشفى الفردوس', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3510, 'lng': 44.1950, 'phone': '01-000444', 'type': 'خاص', 'beds': '58', 'emergency': false, 'rating': 3.3, 'category': 'hospitals'},
    {'name': 'مستشفى 7 يوليو', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3920, 'lng': 44.2160, 'phone': '01-111666', 'type': 'حكومي', 'beds': '350', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى الوحدة', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3740, 'lng': 44.2080, 'phone': '01-222777', 'type': 'خاص', 'beds': '112', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى الأقصى الجديد', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1950, 'phone': '01-333888', 'type': 'خاص', 'beds': '95', 'emergency': false, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى النهضة', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3280, 'lng': 44.1800, 'phone': '01-444999', 'type': 'خاص', 'beds': '148', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى الإسراء التخصصي', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-555000', 'type': 'خاص', 'beds': '168', 'emergency': true, 'rating': 4.6, 'category': 'hospitals'},
    {'name': 'مستشفى السلامة', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3500, 'lng': 44.2030, 'phone': '01-666111', 'type': 'خاص', 'beds': '62', 'emergency': false, 'rating': 3.2, 'category': 'hospitals'},
    {'name': 'مستشفى العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3160, 'lng': 44.1750, 'phone': '01-777222', 'type': 'خاص', 'beds': '138', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى جيبلا', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3690, 'lng': 44.1970, 'phone': '01-888333', 'type': 'خاص', 'beds': '88', 'emergency': false, 'rating': 3.5, 'category': 'hospitals'},
    {'name': 'مستشفى الأطباء', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3780, 'lng': 44.2050, 'phone': '01-000555', 'type': 'خاص', 'beds': '125', 'emergency': false, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى اليمن الدولي', 'address': 'شارع الستين، جولة آية', 'lat': 15.3410, 'lng': 44.1720, 'phone': '01-111777', 'type': 'خاص', 'beds': '210', 'emergency': true, 'rating': 4.7, 'category': 'hospitals'},
    {'name': 'مستشفى العاصمة', 'address': 'شارع الزبيري، شارع القاهرة', 'lat': 15.3525, 'lng': 44.1995, 'phone': '01-222888', 'type': 'خاص', 'beds': '120', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى التقوى', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-444111', 'type': 'خاص', 'beds': '110', 'emergency': false, 'rating': 3.6, 'category': 'hospitals'},
    {'name': 'مستشفى الهداية', 'address': 'شارع الخمسين، حي الهداية', 'lat': 15.3795, 'lng': 44.2095, 'phone': '01-555222', 'type': 'خاص', 'beds': '85', 'emergency': true, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى الشفاء', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3575, 'lng': 44.1925, 'phone': '01-666333', 'type': 'خاص', 'beds': '100', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى الأمان', 'address': 'شارع باب اليمن، حي الأمان', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-777444', 'type': 'خاص', 'beds': '75', 'emergency': false, 'rating': 3.4, 'category': 'hospitals'},
    {'name': 'مستشفى البناء', 'address': 'شارع القاهرة، حي البناء', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-888555', 'type': 'خاص', 'beds': '130', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى النجاح', 'address': 'شارع الستين، حي النجاح', 'lat': 15.3315, 'lng': 44.1775, 'phone': '01-999666', 'type': 'خاص', 'beds': '90', 'emergency': false, 'rating': 3.5, 'category': 'hospitals'},
    {'name': 'مستشفى التقدم', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3875, 'lng': 44.2155, 'phone': '01-000777', 'type': 'خاص', 'beds': '105', 'emergency': true, 'rating': 3.8, 'category': 'hospitals'},
    {'name': 'مستشفى الأمل الجديد', 'address': 'شارع الزبيري، حي الأمل', 'lat': 15.3495, 'lng': 44.2015, 'phone': '01-111888', 'type': 'خاص', 'beds': '70', 'emergency': false, 'rating': 3.3, 'category': 'hospitals'},
    {'name': 'مستشفى الحياة الجديد', 'address': 'شارع هائل، حي الحياة', 'lat': 15.3625, 'lng': 44.1975, 'phone': '01-222999', 'type': 'خاص', 'beds': '115', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى السلام الجديد', 'address': 'شارع الخمسين، حي السلام', 'lat': 15.3715, 'lng': 44.2075, 'phone': '01-333111', 'type': 'خاص', 'beds': '95', 'emergency': true, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى النصر', 'address': 'شارع التحرير، حي النصر', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-444222', 'type': 'خاص', 'beds': '80', 'emergency': false, 'rating': 3.4, 'category': 'hospitals'},
    {'name': 'مستشفى الفتح', 'address': 'شارع باب اليمن، حي الفتح', 'lat': 15.3485, 'lng': 44.2025, 'phone': '01-555333', 'type': 'خاص', 'beds': '110', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى الأصالة', 'address': 'شارع القاهرة، حي الأصالة', 'lat': 15.3515, 'lng': 44.2045, 'phone': '01-666444', 'type': 'خاص', 'beds': '75', 'emergency': false, 'rating': 3.2, 'category': 'hospitals'},
    {'name': 'مستشفى الريان', 'address': 'شارع الستين، حي الريان', 'lat': 15.3395, 'lng': 44.1735, 'phone': '01-777555', 'type': 'خاص', 'beds': '120', 'emergency': true, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى المنار', 'address': 'شارع العدين، حي المنار', 'lat': 15.3835, 'lng': 44.2115, 'phone': '01-888666', 'type': 'خاص', 'beds': '85', 'emergency': false, 'rating': 3.5, 'category': 'hospitals'},
    {'name': 'مستشفى الوفاء الجديد', 'address': 'شارع الزبيري، حي الوفاء', 'lat': 15.3475, 'lng': 44.1975, 'phone': '01-999777', 'type': 'خاص', 'beds': '100', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى العطاء', 'address': 'شارع هائل، حي العطاء', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-000888', 'type': 'خاص', 'beds': '90', 'emergency': true, 'rating': 3.6, 'category': 'hospitals'},
    {'name': 'مستشفى الشروق', 'address': 'شارع الخمسين، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-111999', 'type': 'خاص', 'beds': '105', 'emergency': false, 'rating': 3.4, 'category': 'hospitals'},
    {'name': 'مستشفى السعادة', 'address': 'شارع التحرير، حي السعادة', 'lat': 15.3585, 'lng': 44.1905, 'phone': '01-222000', 'type': 'خاص', 'beds': '75', 'emergency': true, 'rating': 3.8, 'category': 'hospitals'},
    {'name': 'مستشفى البشائر', 'address': 'شارع باب اليمن، حي البشائر', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-333111', 'type': 'خاص', 'beds': '85', 'emergency': false, 'rating': 3.3, 'category': 'hospitals'},
    {'name': 'مستشفى الكرامة', 'address': 'شارع القاهرة، حي الكرامة', 'lat': 15.3565, 'lng': 44.2075, 'phone': '01-444222', 'type': 'خاص', 'beds': '110', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى الأمل الكبير', 'address': 'شارع الستين، حي الأمل الكبير', 'lat': 15.3335, 'lng': 44.1815, 'phone': '01-555333', 'type': 'خاص', 'beds': '95', 'emergency': true, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى الصحة الجديد', 'address': 'شارع العدين، حي الصحة', 'lat': 15.3895, 'lng': 44.2135, 'phone': '01-666444', 'type': 'خاص', 'beds': '80', 'emergency': false, 'rating': 3.5, 'category': 'hospitals'},
    {'name': 'مستشفى الحياة الكبير', 'address': 'شارع الزبيري، حي الحياة الكبير', 'lat': 15.3505, 'lng': 44.2005, 'phone': '01-777555', 'type': 'خاص', 'beds': '120', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى التضامن', 'address': 'شارع هائل، حي التضامن', 'lat': 15.3635, 'lng': 44.1965, 'phone': '01-888666', 'type': 'خاص', 'beds': '70', 'emergency': false, 'rating': 3.2, 'category': 'hospitals'},
    {'name': 'مستشفى الازدهار', 'address': 'شارع الخمسين، حي الازدهار', 'lat': 15.3725, 'lng': 44.2065, 'phone': '01-999777', 'type': 'خاص', 'beds': '105', 'emergency': true, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى الأنوار', 'address': 'شارع التحرير، حي الأنوار', 'lat': 15.3565, 'lng': 44.1945, 'phone': '01-000888', 'type': 'خاص', 'beds': '90', 'emergency': true, 'rating': 3.6, 'category': 'hospitals'},
    {'name': 'مستشفى الأمانة', 'address': 'شارع الزبيري، حي الأمانة', 'lat': 15.3538, 'lng': 44.2035, 'phone': '01-112233', 'type': 'حكومي', 'beds': '250', 'emergency': true, 'rating': 4.5, 'category': 'hospitals'},
    {'name': 'مستشفى صنعاء الدولي', 'address': 'شارع التحرير، حي صنعاء', 'lat': 15.3671, 'lng': 44.1966, 'phone': '01-223344', 'type': 'خاص', 'beds': '300', 'emergency': true, 'rating': 4.7, 'category': 'hospitals'},
    {'name': 'مستشفى الجمهورية الجديد', 'address': 'شارع الستين، حي الجمهورية', 'lat': 15.3412, 'lng': 44.1878, 'phone': '01-334455', 'type': 'حكومي', 'beds': '320', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى السلام الدولي', 'address': 'شارع الخمسين، حي السلام الدولي', 'lat': 15.3743, 'lng': 44.2109, 'phone': '01-445566', 'type': 'خاص', 'beds': '180', 'emergency': true, 'rating': 4.6, 'category': 'hospitals'},
    {'name': 'مستشفى الشفاء التخصصي', 'address': 'شارع القاهرة، حي الشفاء التخصصي', 'lat': 15.3294, 'lng': 44.1741, 'phone': '01-556677', 'type': 'تخصصي', 'beds': '140', 'emergency': true, 'rating': 4.4, 'category': 'hospitals'},
    {'name': 'مستشفى الحياة الجديد', 'address': 'شارع هائل، حي الحياة الجديد', 'lat': 15.3825, 'lng': 44.2132, 'phone': '01-667788', 'type': 'خاص', 'beds': '110', 'emergency': false, 'rating': 3.9, 'category': 'hospitals'},
    {'name': 'مستشفى النصر العام', 'address': 'شارع الأربعين، حي النصر العام', 'lat': 15.3166, 'lng': 44.1803, 'phone': '01-778899', 'type': 'حكومي', 'beds': '260', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
    {'name': 'مستشفى الوفاء الجديد', 'address': 'شارع العدين، حي الوفاء الجديد', 'lat': 15.3907, 'lng': 44.2174, 'phone': '01-889900', 'type': 'خاص', 'beds': '95', 'emergency': false, 'rating': 3.7, 'category': 'hospitals'},
    {'name': 'مستشفى التعاون الجديد', 'address': 'شارع باب اليمن، حي التعاون الجديد', 'lat': 15.3438, 'lng': 44.1996, 'phone': '01-990011', 'type': 'حكومي', 'beds': '290', 'emergency': true, 'rating': 4.0, 'category': 'hospitals'},
    {'name': 'مستشفى الاتحاد', 'address': 'شارع صنعاء، حي الاتحاد', 'lat': 15.3569, 'lng': 44.1927, 'phone': '01-001122', 'type': 'خاص', 'beds': '130', 'emergency': true, 'rating': 4.3, 'category': 'hospitals'},
    {'name': 'مستشفى الأمل الشامل', 'address': 'شارع مأرب، حي الأمل الشامل', 'lat': 15.3300, 'lng': 44.1858, 'phone': '01-112200', 'type': 'خاص', 'beds': '85', 'emergency': false, 'rating': 3.8, 'category': 'hospitals'},
    {'name': 'مستشفى البشير الجديد', 'address': 'شارع تعز، حي البشير الجديد', 'lat': 15.3631, 'lng': 44.2089, 'phone': '01-223311', 'type': 'خاص', 'beds': '100', 'emergency': true, 'rating': 4.2, 'category': 'hospitals'},
    {'name': 'مستشفى الصحة الشامل', 'address': 'شارع الحديدة، حي الصحة الشامل', 'lat': 15.3472, 'lng': 44.1760, 'phone': '01-334422', 'type': 'خاص', 'beds': '120', 'emergency': true, 'rating': 4.5, 'category': 'hospitals'},
    {'name': 'مستشفى الهلال الجديد', 'address': 'شارع عمران، حي الهلال الجديد', 'lat': 15.3803, 'lng': 44.2141, 'phone': '01-445533', 'type': 'خاص', 'beds': '155', 'emergency': true, 'rating': 4.1, 'category': 'hospitals'},
  ];

  // ============================================================
  // 💊 الصيدليات (100)
  // ============================================================
  final List<Map<String, dynamic>> _pharmacies = [
    {'name': 'صيدلية الشفاء', 'address': 'شارع الزبيري، أمام مستشفى الثورة', 'lat': 15.3510, 'lng': 44.1990, 'phone': '01-123456', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية اليمن', 'address': 'شارع التحرير، بجانب البنك المركزي', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-234567', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية الأمل', 'address': 'شارع هائل، أمام جامعة صنعاء', 'lat': 15.3650, 'lng': 44.1970, 'phone': '01-345678', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.6, 'category': 'pharmacies'},
    {'name': 'صيدلية ابن حيان', 'address': 'شارع الستين، الحصبة', 'lat': 15.3820, 'lng': 44.2080, 'phone': '01-456789', 'hours': '8 ص - 11 م', 'delivery': false, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية الشهيد', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-567890', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية النصر', 'address': 'شارع الأربعين، شارع الستين', 'lat': 15.3250, 'lng': 44.1830, 'phone': '01-678901', 'hours': '9 ص - 10 م', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية الحياة', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3520, 'lng': 44.1980, 'phone': '01-789012', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية البرج', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3620, 'lng': 44.1960, 'phone': '01-890123', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية اليقين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-901234', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية الوطنية', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-012345', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الصحة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-112233', 'hours': '9 ص - 10 م', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية الإيمان', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-223344', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية الرازي', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3550, 'lng': 44.2060, 'phone': '01-334455', 'hours': '8 ص - 11 م', 'delivery': false, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية القدس', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-445566', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية الأقصى', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3140, 'lng': 44.1780, 'phone': '01-556677', 'hours': '8 ص - 10 م', 'delivery': false, 'rating': 3.5, 'category': 'pharmacies'},
    {'name': 'صيدلية النور', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3490, 'lng': 44.1960, 'phone': '01-667788', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية الهدى', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3190, 'lng': 44.1790, 'phone': '01-778899', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية الفاروق', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3670, 'lng': 44.1920, 'phone': '01-889900', 'hours': '24 ساعة', 'delivery': false, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1950, 'phone': '01-990011', 'hours': '8 ص - 11 م', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية الوفاء', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-001122', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الأندلس', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3440, 'lng': 44.1990, 'phone': '01-112244', 'hours': '8 ص - 10 م', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية الحكمة', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3270, 'lng': 44.1810, 'phone': '01-223355', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية الأطباء', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2050, 'phone': '01-334466', 'hours': '9 ص - 11 م', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية المستقبل', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3470, 'lng': 44.1950, 'phone': '01-445577', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية التعاون', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3630, 'lng': 44.1980, 'phone': '01-556688', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية المدينة', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3330, 'lng': 44.1820, 'phone': '01-667799', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية اليمامة', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1920, 'phone': '01-778800', 'hours': '9 ص - 10 م', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية الربيع', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3880, 'lng': 44.2140, 'phone': '01-889911', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية الجزيرة', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3730, 'lng': 44.2060, 'phone': '01-990022', 'hours': '8 ص - 11 م', 'delivery': false, 'rating': 3.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الأقصى الجديدة', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3410, 'lng': 44.1980, 'phone': '01-001133', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية الهلال', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3290, 'lng': 44.1780, 'phone': '01-112255', 'hours': '8 ص - 10 م', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية الزهراء', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3560, 'lng': 44.2070, 'phone': '01-223366', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الأمن', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3500, 'lng': 44.1940, 'phone': '01-334477', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية الإخلاص', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-445588', 'hours': '24 ساعة', 'delivery': false, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية طيبة', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1960, 'phone': '01-556699', 'hours': '8 ص - 11 م', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية الصفوة', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3170, 'lng': 44.1760, 'phone': '01-667700', 'hours': '24 ساعة', 'delivery': true, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية النهضة', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3760, 'lng': 44.2050, 'phone': '01-778811', 'hours': '9 ص - 10 م', 'delivery': false, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية الفيحاء', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-889922', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية الرحمة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3840, 'lng': 44.2120, 'phone': '01-990033', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية البراء', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3570, 'lng': 44.2080, 'phone': '01-001144', 'hours': '24 ساعة', 'delivery': false, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3150, 'lng': 44.1740, 'phone': '01-112266', 'hours': '9 ص - 11 م', 'delivery': true, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية الفردوس', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3540, 'lng': 44.1970, 'phone': '01-223377', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية العنقاء', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3680, 'lng': 44.1940, 'phone': '01-334488', 'hours': '8 ص - 10 م', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية البشير', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3600, 'lng': 44.1910, 'phone': '01-445599', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية النجاح', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3310, 'lng': 44.1840, 'phone': '01-556600', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية اليمن السعيد', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3750, 'lng': 44.2090, 'phone': '01-667711', 'hours': '24 ساعة', 'delivery': false, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية دار الدواء', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3420, 'lng': 44.1990, 'phone': '01-778822', 'hours': '8 ص - 11 م', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية اليسر', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3510, 'lng': 44.2040, 'phone': '01-889933', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الريان', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3350, 'lng': 44.1860, 'phone': '01-990044', 'hours': '9 ص - 10 م', 'delivery': false, 'rating': 3.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الإحسان', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1980, 'phone': '01-001155', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية السعادة', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3720, 'lng': 44.1890, 'phone': '01-112277', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية التوفيق', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1920, 'phone': '01-223388', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية الخير', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3910, 'lng': 44.2150, 'phone': '01-334499', 'hours': '9 ص - 11 م', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية الأنوار', 'address': 'شارع الستين، جولة 48', 'lat': 15.3360, 'lng': 44.1870, 'phone': '01-445500', 'hours': '24 ساعة', 'delivery': true, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية الجامعة', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3790, 'lng': 44.2040, 'phone': '01-556611', 'hours': '8 ص - 10 م', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية الهداية', 'address': 'شارع باب اليمن، ميدان التحرير', 'lat': 15.3480, 'lng': 44.2010, 'phone': '01-667722', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية المنار', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3540, 'lng': 44.2040, 'phone': '01-778833', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية التقوى', 'address': 'شارع الستين، شارع الستين الشمالي', 'lat': 15.3390, 'lng': 44.1710, 'phone': '01-889944', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية الروضة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3640, 'lng': 44.1960, 'phone': '01-990055', 'hours': '8 ص - 11 م', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية البستان', 'address': 'شارع الزبيري، أمام الخطوط الجوية', 'lat': 15.3470, 'lng': 44.2000, 'phone': '01-001166', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الأزهر', 'address': 'شارع الستين، حي الأزهر', 'lat': 15.3355, 'lng': 44.1865, 'phone': '01-112277', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية التقوى الجديدة', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-223388', 'hours': '8 ص - 11 م', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية الهداية الجديدة', 'address': 'شارع الخمسين، حي الهداية', 'lat': 15.3795, 'lng': 44.2095, 'phone': '01-334499', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية الشفاء الجديدة', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3575, 'lng': 44.1925, 'phone': '01-445500', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية الأمان', 'address': 'شارع باب اليمن، حي الأمان', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-556611', 'hours': '24 ساعة', 'delivery': false, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية البناء', 'address': 'شارع القاهرة، حي البناء', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-667722', 'hours': '8 ص - 10 م', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية النجاح الجديدة', 'address': 'شارع الستين، حي النجاح', 'lat': 15.3315, 'lng': 44.1775, 'phone': '01-778833', 'hours': '24 ساعة', 'delivery': true, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية التقدم', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3875, 'lng': 44.2155, 'phone': '01-889944', 'hours': '9 ص - 11 م', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية الأمل الكبير', 'address': 'شارع الزبيري، حي الأمل الكبير', 'lat': 15.3495, 'lng': 44.2015, 'phone': '01-990055', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية الحياة الكبيرة', 'address': 'شارع هائل، حي الحياة الكبير', 'lat': 15.3625, 'lng': 44.1975, 'phone': '01-001166', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية السلام الكبيرة', 'address': 'شارع الخمسين، حي السلام الكبير', 'lat': 15.3715, 'lng': 44.2075, 'phone': '01-112277', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية النصر الجديدة', 'address': 'شارع التحرير، حي النصر', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-223388', 'hours': '9 ص - 10 م', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية الفتح الجديدة', 'address': 'شارع باب اليمن، حي الفتح', 'lat': 15.3485, 'lng': 44.2025, 'phone': '01-334499', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية الأصالة', 'address': 'شارع القاهرة، حي الأصالة', 'lat': 15.3515, 'lng': 44.2045, 'phone': '01-445500', 'hours': '8 ص - 11 م', 'delivery': false, 'rating': 3.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الريان الجديدة', 'address': 'شارع الستين، حي الريان', 'lat': 15.3395, 'lng': 44.1735, 'phone': '01-556611', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية المنار الجديدة', 'address': 'شارع العدين، حي المنار', 'lat': 15.3835, 'lng': 44.2115, 'phone': '01-667722', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية الوفاء الكبيرة', 'address': 'شارع الزبيري، حي الوفاء', 'lat': 15.3475, 'lng': 44.1975, 'phone': '01-778833', 'hours': '24 ساعة', 'delivery': false, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية العطاء', 'address': 'شارع هائل، حي العطاء', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-889944', 'hours': '8 ص - 10 م', 'delivery': true, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية الشروق', 'address': 'شارع الخمسين، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-990055', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية السعادة الجديدة', 'address': 'شارع التحرير، حي السعادة', 'lat': 15.3585, 'lng': 44.1905, 'phone': '01-001166', 'hours': '9 ص - 11 م', 'delivery': false, 'rating': 3.6, 'category': 'pharmacies'},
    {'name': 'صيدلية البشائر', 'address': 'شارع باب اليمن، حي البشائر', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-112277', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية الكرامة', 'address': 'شارع القاهرة، حي الكرامة', 'lat': 15.3565, 'lng': 44.2075, 'phone': '01-223388', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية الصحة الجديدة', 'address': 'شارع الستين، حي الصحة', 'lat': 15.3335, 'lng': 44.1815, 'phone': '01-334499', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية التضامن', 'address': 'شارع العدين، حي التضامن', 'lat': 15.3895, 'lng': 44.2135, 'phone': '01-445500', 'hours': '9 ص - 10 م', 'delivery': true, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية الازدهار', 'address': 'شارع الزبيري، حي الازدهار', 'lat': 15.3505, 'lng': 44.2005, 'phone': '01-556611', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية الأنوار الجديدة', 'address': 'شارع هائل، حي الأنوار', 'lat': 15.3635, 'lng': 44.1965, 'phone': '01-667722', 'hours': '8 ص - 11 م', 'delivery': false, 'rating': 3.5, 'category': 'pharmacies'},
    {'name': 'صيدلية الأمانة', 'address': 'شارع الزبيري، حي الأمانة', 'lat': 15.3538, 'lng': 44.2035, 'phone': '01-112233', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية صنعاء', 'address': 'شارع التحرير، حي صنعاء', 'lat': 15.3671, 'lng': 44.1966, 'phone': '01-223344', 'hours': '8 ص - 12 م', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية التحرير الجديدة', 'address': 'شارع الستين، حي التحرير الجديدة', 'lat': 15.3412, 'lng': 44.1878, 'phone': '01-334455', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.6, 'category': 'pharmacies'},
    {'name': 'صيدلية الخمسين', 'address': 'شارع الخمسين، حي الخمسين', 'lat': 15.3743, 'lng': 44.2109, 'phone': '01-445566', 'hours': '9 ص - 10 م', 'delivery': false, 'rating': 4.0, 'category': 'pharmacies'},
    {'name': 'صيدلية القاهرة الجديدة', 'address': 'شارع القاهرة، حي القاهرة الجديدة', 'lat': 15.3294, 'lng': 44.1741, 'phone': '01-556677', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
    {'name': 'صيدلية العدين الجديدة', 'address': 'شارع هائل، حي العدين الجديدة', 'lat': 15.3825, 'lng': 44.2132, 'phone': '01-667788', 'hours': '8 ص - 11 م', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية هائل الجديدة', 'address': 'شارع الأربعين، حي هائل الجديدة', 'lat': 15.3166, 'lng': 44.1803, 'phone': '01-778899', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.8, 'category': 'pharmacies'},
    {'name': 'صيدلية الأربعين', 'address': 'شارع باب اليمن، حي الأربعين', 'lat': 15.3907, 'lng': 44.2174, 'phone': '01-889900', 'hours': '9 ص - 12 م', 'delivery': true, 'rating': 4.4, 'category': 'pharmacies'},
    {'name': 'صيدلية باب اليمن الجديدة', 'address': 'شارع صنعاء، حي باب اليمن الجديدة', 'lat': 15.3438, 'lng': 44.1996, 'phone': '01-990011', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.2, 'category': 'pharmacies'},
    {'name': 'صيدلية صنعاء الكبرى', 'address': 'شارع مأرب، حي صنعاء الكبرى', 'lat': 15.3569, 'lng': 44.1927, 'phone': '01-001122', 'hours': '8 ص - 10 م', 'delivery': false, 'rating': 3.9, 'category': 'pharmacies'},
    {'name': 'صيدلية مأرب', 'address': 'شارع تعز، حي مأرب', 'lat': 15.3300, 'lng': 44.1858, 'phone': '01-112200', 'hours': '24 ساعة', 'delivery': true, 'rating': 4.5, 'category': 'pharmacies'},
    {'name': 'صيدلية تعز الجديدة', 'address': 'شارع الحديدة، حي تعز الجديدة', 'lat': 15.3631, 'lng': 44.2089, 'phone': '01-223311', 'hours': '8 ص - 11 م', 'delivery': true, 'rating': 4.1, 'category': 'pharmacies'},
    {'name': 'صيدلية الحديدة', 'address': 'شارع عمران، حي الحديدة', 'lat': 15.3472, 'lng': 44.1760, 'phone': '01-334422', 'hours': '24 ساعة', 'delivery': false, 'rating': 3.7, 'category': 'pharmacies'},
    {'name': 'صيدلية عمران', 'address': 'شارع الجديد، حي عمران', 'lat': 15.3803, 'lng': 44.2141, 'phone': '01-445533', 'hours': '9 ص - 10 م', 'delivery': true, 'rating': 4.3, 'category': 'pharmacies'},
  ];

  // ============================================================
  // 🔬 المختبرات (100)
  // ============================================================
  final List<Map<String, dynamic>> _labs = [
    {'name': 'المختبر الوطني', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-012345', 'tests': '650+', 'accredited': true, 'rating': 4.7, 'category': 'labs'},
    {'name': 'مختبر الثقة', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3520, 'lng': 44.1980, 'phone': '01-123456', 'tests': '520+', 'accredited': true, 'rating': 4.5, 'category': 'labs'},
    {'name': 'مختبر البرج', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3620, 'lng': 44.1960, 'phone': '01-234567', 'tests': '480+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'مختبر اليقين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-345678', 'tests': '350+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'مختبرات الحياة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-456789', 'tests': '420+', 'accredited': false, 'rating': 3.8, 'category': 'labs'},
    {'name': 'معمل ابن سينا', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3490, 'lng': 44.1960, 'phone': '01-567890', 'tests': '380+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'مختبر الأمل', 'address': 'شارع هائل، أمام جامعة صنعاء', 'lat': 15.3650, 'lng': 44.1970, 'phone': '01-678901', 'tests': '290+', 'accredited': false, 'rating': 3.6, 'category': 'labs'},
    {'name': 'معامل النخبة', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3330, 'lng': 44.1820, 'phone': '01-789012', 'tests': '550+', 'accredited': true, 'rating': 4.6, 'category': 'labs'},
    {'name': 'مختبر الشروق', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-890123', 'tests': '310+', 'accredited': false, 'rating': 3.5, 'category': 'labs'},
    {'name': 'معمل الدقة', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-901234', 'tests': '460+', 'accredited': true, 'rating': 4.4, 'category': 'labs'},
    {'name': 'مختبر الصحة', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3140, 'lng': 44.1780, 'phone': '01-112345', 'tests': '270+', 'accredited': false, 'rating': 3.4, 'category': 'labs'},
    {'name': 'معامل اليمن', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1920, 'phone': '01-223456', 'tests': '500+', 'accredited': true, 'rating': 4.5, 'category': 'labs'},
    {'name': 'مختبر القدس', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-334567', 'tests': '340+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
    {'name': 'معمل الإسراء', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3260, 'lng': 44.1810, 'phone': '01-445678', 'tests': '390+', 'accredited': false, 'rating': 3.7, 'category': 'labs'},
    {'name': 'مختبر الهدى', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3440, 'lng': 44.2010, 'phone': '01-556789', 'tests': '280+', 'accredited': false, 'rating': 3.3, 'category': 'labs'},
    {'name': 'معمل الشفاء', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3530, 'lng': 44.2070, 'phone': '01-667890', 'tests': '410+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'مختبر الفيحاء', 'address': 'شارع العدين، السنينة', 'lat': 15.3900, 'lng': 44.2120, 'phone': '01-778901', 'tests': '330+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'معمل الأندلس', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3550, 'lng': 44.1970, 'phone': '01-889012', 'tests': '370+', 'accredited': false, 'rating': 3.8, 'category': 'labs'},
    {'name': 'مختبر السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1960, 'phone': '01-990123', 'tests': '260+', 'accredited': false, 'rating': 3.2, 'category': 'labs'},
    {'name': 'معمل النهضة', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3680, 'lng': 44.1920, 'phone': '01-001234', 'tests': '440+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'مختبر العباس', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3800, 'lng': 44.2100, 'phone': '01-112345', 'tests': '360+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
    {'name': 'معمل الرازي', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-223456', 'tests': '490+', 'accredited': true, 'rating': 4.6, 'category': 'labs'},
    {'name': 'مختبر الإخلاص', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-334567', 'tests': '300+', 'accredited': false, 'rating': 3.4, 'category': 'labs'},
    {'name': 'معمل الزهراء', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3800, 'lng': 44.2150, 'phone': '01-445678', 'tests': '420+', 'accredited': true, 'rating': 4.4, 'category': 'labs'},
    {'name': 'مختبر الأمانة', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1990, 'phone': '01-556789', 'tests': '290+', 'accredited': false, 'rating': 3.3, 'category': 'labs'},
    {'name': 'معمل التقوى', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-667890', 'tests': '380+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'مختبر الهداية', 'address': 'شارع الخمسين، حي الهداية', 'lat': 15.3795, 'lng': 44.2095, 'phone': '01-778901', 'tests': '320+', 'accredited': false, 'rating': 3.6, 'category': 'labs'},
    {'name': 'معمل الشروق', 'address': 'شارع التحرير، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-889012', 'tests': '400+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'مختبر النور', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3420, 'lng': 44.1980, 'phone': '01-990123', 'tests': '270+', 'accredited': false, 'rating': 3.2, 'category': 'labs'},
    {'name': 'معمل الحياة', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3570, 'lng': 44.2060, 'phone': '01-001234', 'tests': '450+', 'accredited': true, 'rating': 4.5, 'category': 'labs'},
    {'name': 'مختبر الكرامة', 'address': 'شارع الستين، جولة 48', 'lat': 15.3370, 'lng': 44.1890, 'phone': '01-112345', 'tests': '310+', 'accredited': false, 'rating': 3.5, 'category': 'labs'},
    {'name': 'معمل القاسمي', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-223456', 'tests': '470+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'مختبر الفردوس', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3510, 'lng': 44.1950, 'phone': '01-334567', 'tests': '280+', 'accredited': false, 'rating': 3.3, 'category': 'labs'},
    {'name': 'معمل الوحدة', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3740, 'lng': 44.2080, 'phone': '01-445678', 'tests': '390+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
    {'name': 'مختبر الأقصى', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1950, 'phone': '01-556789', 'tests': '260+', 'accredited': false, 'rating': 3.1, 'category': 'labs'},
    {'name': 'معمل النهضة', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3280, 'lng': 44.1800, 'phone': '01-667890', 'tests': '430+', 'accredited': true, 'rating': 4.4, 'category': 'labs'},
    {'name': 'مختبر الإسراء التخصصي', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-778901', 'tests': '500+', 'accredited': true, 'rating': 4.6, 'category': 'labs'},
    {'name': 'معمل السلامة', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3500, 'lng': 44.2030, 'phone': '01-889012', 'tests': '250+', 'accredited': false, 'rating': 3.0, 'category': 'labs'},
    {'name': 'مختبر العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3160, 'lng': 44.1750, 'phone': '01-990123', 'tests': '340+', 'accredited': true, 'rating': 3.9, 'category': 'labs'},
    {'name': 'معمل جيبلا', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3690, 'lng': 44.1970, 'phone': '01-001234', 'tests': '370+', 'accredited': false, 'rating': 3.7, 'category': 'labs'},
    {'name': 'مختبر الأطباء', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3780, 'lng': 44.2050, 'phone': '01-112345', 'tests': '410+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'معمل اليمن الدولي', 'address': 'شارع الستين، جولة آية', 'lat': 15.3410, 'lng': 44.1720, 'phone': '01-223456', 'tests': '520+', 'accredited': true, 'rating': 4.7, 'category': 'labs'},
    {'name': 'مختبر العاصمة', 'address': 'شارع الزبيري، شارع القاهرة', 'lat': 15.3525, 'lng': 44.1995, 'phone': '01-334567', 'tests': '360+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'معمل التقوى الجديد', 'address': 'شارع هائل، جولة التقوى', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-445678', 'tests': '380+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'مختبر الهداية الجديد', 'address': 'شارع الخمسين، حي الهداية', 'lat': 15.3795, 'lng': 44.2095, 'phone': '01-556789', 'tests': '320+', 'accredited': false, 'rating': 3.6, 'category': 'labs'},
    {'name': 'معمل الشفاء الجديد', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3575, 'lng': 44.1925, 'phone': '01-667890', 'tests': '400+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'مختبر الأمان', 'address': 'شارع باب اليمن، حي الأمان', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-778901', 'tests': '290+', 'accredited': false, 'rating': 3.4, 'category': 'labs'},
    {'name': 'معمل البناء', 'address': 'شارع القاهرة، حي البناء', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-889012', 'tests': '430+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'مختبر النجاح', 'address': 'شارع الستين، حي النجاح', 'lat': 15.3315, 'lng': 44.1775, 'phone': '01-990123', 'tests': '310+', 'accredited': false, 'rating': 3.5, 'category': 'labs'},
    {'name': 'معمل التقدم', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3875, 'lng': 44.2155, 'phone': '01-001234', 'tests': '390+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
    {'name': 'مختبر الأمل الجديد', 'address': 'شارع الزبيري، حي الأمل', 'lat': 15.3495, 'lng': 44.2015, 'phone': '01-112345', 'tests': '270+', 'accredited': false, 'rating': 3.3, 'category': 'labs'},
    {'name': 'معمل الحياة الجديد', 'address': 'شارع هائل، حي الحياة', 'lat': 15.3625, 'lng': 44.1975, 'phone': '01-223456', 'tests': '450+', 'accredited': true, 'rating': 4.5, 'category': 'labs'},
    {'name': 'مختبر السلام الجديد', 'address': 'شارع الخمسين، حي السلام', 'lat': 15.3715, 'lng': 44.2075, 'phone': '01-334567', 'tests': '340+', 'accredited': true, 'rating': 3.9, 'category': 'labs'},
    {'name': 'معمل النصر', 'address': 'شارع التحرير، حي النصر', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-445678', 'tests': '280+', 'accredited': false, 'rating': 3.2, 'category': 'labs'},
    {'name': 'مختبر الفتح', 'address': 'شارع باب اليمن، حي الفتح', 'lat': 15.3485, 'lng': 44.2025, 'phone': '01-556789', 'tests': '360+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'معمل الأصالة', 'address': 'شارع القاهرة، حي الأصالة', 'lat': 15.3515, 'lng': 44.2045, 'phone': '01-667890', 'tests': '300+', 'accredited': false, 'rating': 3.4, 'category': 'labs'},
    {'name': 'مختبر الريان', 'address': 'شارع الستين، حي الريان', 'lat': 15.3395, 'lng': 44.1735, 'phone': '01-778901', 'tests': '420+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'معمل المنار', 'address': 'شارع العدين، حي المنار', 'lat': 15.3835, 'lng': 44.2115, 'phone': '01-889012', 'tests': '330+', 'accredited': false, 'rating': 3.7, 'category': 'labs'},
    {'name': 'مختبر الوفاء الجديد', 'address': 'شارع الزبيري، حي الوفاء', 'lat': 15.3475, 'lng': 44.1975, 'phone': '01-990123', 'tests': '380+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
    {'name': 'معمل العطاء', 'address': 'شارع هائل، حي العطاء', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-001234', 'tests': '310+', 'accredited': false, 'rating': 3.5, 'category': 'labs'},
    {'name': 'مختبر الشروق الجديد', 'address': 'شارع الخمسين، حي الشروق', 'lat': 15.3755, 'lng': 44.2045, 'phone': '01-112345', 'tests': '400+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'معمل السعادة', 'address': 'شارع التحرير، حي السعادة', 'lat': 15.3585, 'lng': 44.1905, 'phone': '01-223456', 'tests': '290+', 'accredited': false, 'rating': 3.3, 'category': 'labs'},
    {'name': 'مختبر البشائر', 'address': 'شارع باب اليمن، حي البشائر', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-334567', 'tests': '340+', 'accredited': true, 'rating': 3.8, 'category': 'labs'},
    {'name': 'معمل الكرامة الجديد', 'address': 'شارع القاهرة، حي الكرامة', 'lat': 15.3565, 'lng': 44.2075, 'phone': '01-445678', 'tests': '460+', 'accredited': true, 'rating': 4.5, 'category': 'labs'},
    {'name': 'مختبر الأمل الكبير', 'address': 'شارع الستين، حي الأمل الكبير', 'lat': 15.3335, 'lng': 44.1815, 'phone': '01-556789', 'tests': '350+', 'accredited': true, 'rating': 4.0, 'category': 'labs'},
    {'name': 'معمل الصحة الجديد', 'address': 'شارع العدين، حي الصحة', 'lat': 15.3895, 'lng': 44.2135, 'phone': '01-667890', 'tests': '310+', 'accredited': false, 'rating': 3.6, 'category': 'labs'},
    {'name': 'مختبر الحياة الكبير', 'address': 'شارع الزبيري، حي الحياة الكبير', 'lat': 15.3505, 'lng': 44.2005, 'phone': '01-778901', 'tests': '480+', 'accredited': true, 'rating': 4.6, 'category': 'labs'},
    {'name': 'معمل التضامن', 'address': 'شارع هائل، حي التضامن', 'lat': 15.3635, 'lng': 44.1965, 'phone': '01-889012', 'tests': '270+', 'accredited': false, 'rating': 3.1, 'category': 'labs'},
    {'name': 'مختبر الازدهار', 'address': 'شارع الخمسين، حي الازدهار', 'lat': 15.3725, 'lng': 44.2065, 'phone': '01-990123', 'tests': '410+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'معمل الأنوار', 'address': 'شارع التحرير، حي الأنوار', 'lat': 15.3565, 'lng': 44.1945, 'phone': '01-001234', 'tests': '320+', 'accredited': false, 'rating': 3.5, 'category': 'labs'},
    {'name': 'مختبر الأمانة الجديد', 'address': 'شارع الزبيري، حي الأمانة', 'lat': 15.3538, 'lng': 44.2035, 'phone': '01-112345', 'tests': '440+', 'accredited': true, 'rating': 4.4, 'category': 'labs'},
    {'name': 'معمل صنعاء الدولي', 'address': 'شارع التحرير، حي صنعاء الدولي', 'lat': 15.3671, 'lng': 44.1966, 'phone': '01-223456', 'tests': '500+', 'accredited': true, 'rating': 4.8, 'category': 'labs'},
    {'name': 'مختبر الجمهورية الجديد', 'address': 'شارع الستين، حي الجمهورية الجديد', 'lat': 15.3412, 'lng': 44.1878, 'phone': '01-334567', 'tests': '380+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'معمل السلام الدولي', 'address': 'شارع الخمسين، حي السلام الدولي', 'lat': 15.3743, 'lng': 44.2109, 'phone': '01-445678', 'tests': '460+', 'accredited': true, 'rating': 4.6, 'category': 'labs'},
    {'name': 'مختبر الشفاء التخصصي', 'address': 'شارع القاهرة، حي الشفاء التخصصي', 'lat': 15.3294, 'lng': 44.1741, 'phone': '01-556789', 'tests': '390+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'معمل الحياة الجديد', 'address': 'شارع هائل، حي الحياة الجديد', 'lat': 15.3825, 'lng': 44.2132, 'phone': '01-667890', 'tests': '340+', 'accredited': true, 'rating': 3.9, 'category': 'labs'},
    {'name': 'مختبر النصر العام', 'address': 'شارع الأربعين، حي النصر العام', 'lat': 15.3166, 'lng': 44.1803, 'phone': '01-778901', 'tests': '420+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
    {'name': 'معمل الوفاء الجديد', 'address': 'شارع العدين، حي الوفاء الجديد', 'lat': 15.3907, 'lng': 44.2174, 'phone': '01-889012', 'tests': '300+', 'accredited': false, 'rating': 3.5, 'category': 'labs'},
    {'name': 'مختبر التعاون الجديد', 'address': 'شارع باب اليمن، حي التعاون الجديد', 'lat': 15.3438, 'lng': 44.1996, 'phone': '01-990123', 'tests': '450+', 'accredited': true, 'rating': 4.4, 'category': 'labs'},
    {'name': 'معمل الاتحاد', 'address': 'شارع صنعاء، حي الاتحاد', 'lat': 15.3569, 'lng': 44.1927, 'phone': '01-001234', 'tests': '370+', 'accredited': true, 'rating': 4.2, 'category': 'labs'},
    {'name': 'مختبر الأمل الشامل', 'address': 'شارع مأرب، حي الأمل الشامل', 'lat': 15.3300, 'lng': 44.1858, 'phone': '01-112345', 'tests': '310+', 'accredited': false, 'rating': 3.6, 'category': 'labs'},
    {'name': 'معمل البشير الجديد', 'address': 'شارع تعز، حي البشير الجديد', 'lat': 15.3631, 'lng': 44.2089, 'phone': '01-223456', 'tests': '400+', 'accredited': true, 'rating': 4.3, 'category': 'labs'},
    {'name': 'مختبر الصحة الشامل', 'address': 'شارع الحديدة، حي الصحة الشامل', 'lat': 15.3472, 'lng': 44.1760, 'phone': '01-334567', 'tests': '430+', 'accredited': true, 'rating': 4.5, 'category': 'labs'},
    {'name': 'معمل الهلال الجديد', 'address': 'شارع عمران، حي الهلال الجديد', 'lat': 15.3803, 'lng': 44.2141, 'phone': '01-445678', 'tests': '360+', 'accredited': true, 'rating': 4.1, 'category': 'labs'},
  ];

  // ============================================================
  // 🏥 عيادات ومستوصفات خاصة (60)
  // ============================================================
  final List<Map<String, dynamic>> _clinics = [
    {'name': 'عيادة الدكتور أحمد', 'address': 'شارع الزبيري، أمام البنك', 'lat': 15.3495, 'lng': 44.1995, 'phone': '01-111222', 'specialty': 'باطنية', 'rating': 4.5, 'category': 'clinics'},
    {'name': 'عيادة الدكتور خالد', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3585, 'lng': 44.1945, 'phone': '01-222333', 'specialty': 'قلبية', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة سارة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3645, 'lng': 44.1975, 'phone': '01-333444', 'specialty': 'أطفال', 'rating': 4.6, 'category': 'clinics'},
    {'name': 'عيادة الدكتور علي', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3345, 'lng': 44.1835, 'phone': '01-444555', 'specialty': 'جلدية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة فاطمة', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3475, 'lng': 44.2015, 'phone': '01-555666', 'specialty': 'نساء وولادة', 'rating': 4.7, 'category': 'clinics'},
    {'name': 'عيادة الدكتور عمر', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3795, 'lng': 44.2085, 'phone': '01-666777', 'specialty': 'عظام', 'rating': 4.4, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة نادية', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3445, 'lng': 44.2005, 'phone': '01-777888', 'specialty': 'نفسية', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتور يوسف', 'address': 'شارع العدين، السنينة', 'lat': 15.3875, 'lng': 44.2125, 'phone': '01-888999', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة حنان', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3135, 'lng': 44.1795, 'phone': '01-999000', 'specialty': 'أسنان', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتور محمد', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3565, 'lng': 44.1985, 'phone': '01-000111', 'specialty': 'باطنية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتور يامي', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3625, 'lng': 44.1925, 'phone': '01-111333', 'specialty': 'قلبية', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة ليلى', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3695, 'lng': 44.1935, 'phone': '01-222444', 'specialty': 'أطفال', 'rating': 4.8, 'category': 'clinics'},
    {'name': 'عيادة الدكتور حسن', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3275, 'lng': 44.1825, 'phone': '01-333555', 'specialty': 'جلدية', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة مها', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3545, 'lng': 44.2055, 'phone': '01-444666', 'specialty': 'نساء وولادة', 'rating': 4.6, 'category': 'clinics'},
    {'name': 'عيادة الدكتور رامي', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3725, 'lng': 44.2055, 'phone': '01-555777', 'specialty': 'عظام', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة سلمى', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3455, 'lng': 44.1995, 'phone': '01-666888', 'specialty': 'نفسية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتور زيد', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3815, 'lng': 44.2145, 'phone': '01-777999', 'specialty': 'أنف وأذن وحنجرة', 'rating': 3.9, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة رنا', 'address': 'شارع الأربعين، شارع الستين', 'lat': 15.3245, 'lng': 44.1845, 'phone': '01-888000', 'specialty': 'أسنان', 'rating': 4.4, 'category': 'clinics'},
    {'name': 'عيادة الدكتور ماجد', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3475, 'lng': 44.2005, 'phone': '01-999111', 'specialty': 'باطنية', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة أمل', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3555, 'lng': 44.1935, 'phone': '01-000222', 'specialty': 'قلبية', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتور بدر', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3665, 'lng': 44.1965, 'phone': '01-111444', 'specialty': 'أطفال', 'rating': 4.5, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة نوال', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3335, 'lng': 44.1845, 'phone': '01-222555', 'specialty': 'جلدية', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتور خليل', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3595, 'lng': 44.2075, 'phone': '01-333666', 'specialty': 'نساء وولادة', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة هدى', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3795, 'lng': 44.2065, 'phone': '01-444777', 'specialty': 'عظام', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتور يعود', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3435, 'lng': 44.1995, 'phone': '01-555888', 'specialty': 'نفسية', 'rating': 3.8, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة منى', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3915, 'lng': 44.2155, 'phone': '01-666999', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتور هشام', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3155, 'lng': 44.1785, 'phone': '01-777000', 'specialty': 'أسنان', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة ريم', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3505, 'lng': 44.1975, 'phone': '01-888111', 'specialty': 'باطنية', 'rating': 4.4, 'category': 'clinics'},
    {'name': 'عيادة الدكتور حامد', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3605, 'lng': 44.1955, 'phone': '01-999222', 'specialty': 'قلبية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة عبير', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3705, 'lng': 44.1955, 'phone': '01-000333', 'specialty': 'أطفال', 'rating': 4.7, 'category': 'clinics'},
    {'name': 'عيادة الدكتور عادل', 'address': 'شارع الستين، جولة 48', 'lat': 15.3385, 'lng': 44.1885, 'phone': '01-111555', 'specialty': 'جلدية', 'rating': 3.9, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة غادة', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3585, 'lng': 44.2075, 'phone': '01-222666', 'specialty': 'نساء وولادة', 'rating': 4.5, 'category': 'clinics'},
    {'name': 'عيادة الدكتور راشد', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3785, 'lng': 44.2075, 'phone': '01-333777', 'specialty': 'عظام', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة شيماء', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3465, 'lng': 44.1985, 'phone': '01-444888', 'specialty': 'نفسية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتور فهد', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3865, 'lng': 44.2125, 'phone': '01-555999', 'specialty': 'أنف وأذن وحنجرة', 'rating': 3.9, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة إيمان', 'address': 'شارع الأربعين، شارع الستين', 'lat': 15.3215, 'lng': 44.1815, 'phone': '01-666000', 'specialty': 'أسنان', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتور جمال', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3525, 'lng': 44.1965, 'phone': '01-777111', 'specialty': 'باطنية', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة رابعة', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3595, 'lng': 44.1925, 'phone': '01-888222', 'specialty': 'قلبية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتور ناصر', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3675, 'lng': 44.1945, 'phone': '01-999333', 'specialty': 'أطفال', 'rating': 4.4, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة سميرة', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3175, 'lng': 44.1775, 'phone': '01-000444', 'specialty': 'جلدية', 'rating': 3.8, 'category': 'clinics'},
    {'name': 'عيادة الدكتور وليد', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3535, 'lng': 44.2055, 'phone': '01-111666', 'specialty': 'نساء وولادة', 'rating': 4.6, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة نجلاء', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3765, 'lng': 44.2095, 'phone': '01-222777', 'specialty': 'عظام', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتور مراد', 'address': 'شارع باب اليمن، ميدان التحرير', 'lat': 15.3495, 'lng': 44.2025, 'phone': '01-333888', 'specialty': 'نفسية', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة هناء', 'address': 'شارع العدين، حي السنينة', 'lat': 15.3895, 'lng': 44.2145, 'phone': '01-444999', 'specialty': 'أنف وأذن وحنجرة', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتور زياد', 'address': 'شارع الأربعين، حي الصخر', 'lat': 15.3185, 'lng': 44.1795, 'phone': '01-555000', 'specialty': 'أسنان', 'rating': 4.5, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة منال', 'address': 'شارع الزبيري، حي الأندلس', 'lat': 15.3515, 'lng': 44.1985, 'phone': '01-666111', 'specialty': 'باطنية', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتور أكرم', 'address': 'شارع التحرير، حي البلد', 'lat': 15.3615, 'lng': 44.1935, 'phone': '01-777222', 'specialty': 'قلبية', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة بسمة', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3715, 'lng': 44.1945, 'phone': '01-888333', 'specialty': 'أطفال', 'rating': 4.7, 'category': 'clinics'},
    {'name': 'عيادة الدكتور أسامة', 'address': 'شارع الستين، حي النخبة', 'lat': 15.3355, 'lng': 44.1855, 'phone': '01-999444', 'specialty': 'جلدية', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة فائزة', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3555, 'lng': 44.2065, 'phone': '01-000555', 'specialty': 'نساء وولادة', 'rating': 4.4, 'category': 'clinics'},
    {'name': 'عيادة الدكتور نبيل', 'address': 'شارع الخمسين، حي النور', 'lat': 15.3775, 'lng': 44.2085, 'phone': '01-111777', 'specialty': 'عظام', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة سهى', 'address': 'شارع باب اليمن، حي السلام', 'lat': 15.3475, 'lng': 44.2015, 'phone': '01-222888', 'specialty': 'نفسية', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتور رياض', 'address': 'شارع العدين، حي التقدم', 'lat': 15.3885, 'lng': 44.2165, 'phone': '01-333999', 'specialty': 'أنف وأذن وحنجرة', 'rating': 3.9, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة وفاء', 'address': 'شارع الأربعين، حي النصر', 'lat': 15.3175, 'lng': 44.1805, 'phone': '01-444000', 'specialty': 'أسنان', 'rating': 4.3, 'category': 'clinics'},
    {'name': 'عيادة الدكتور يليم', 'address': 'شارع الزبيري، حي العاصمة', 'lat': 15.3535, 'lng': 44.1995, 'phone': '01-555111', 'specialty': 'باطنية', 'rating': 4.0, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة حليمة', 'address': 'شارع التحرير، حي الشفاء', 'lat': 15.3635, 'lng': 44.1945, 'phone': '01-666222', 'specialty': 'قلبية', 'rating': 4.2, 'category': 'clinics'},
    {'name': 'عيادة الدكتور معاذ', 'address': 'شارع هائل، حي الوفاء', 'lat': 15.3735, 'lng': 44.1955, 'phone': '01-777333', 'specialty': 'أطفال', 'rating': 4.6, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة خديجة', 'address': 'شارع الستين، حي الصمد', 'lat': 15.3375, 'lng': 44.1865, 'phone': '01-888444', 'specialty': 'جلدية', 'rating': 4.1, 'category': 'clinics'},
    {'name': 'عيادة الدكتور بهاء', 'address': 'شارع القاهرة، حي الأمانة', 'lat': 15.3575, 'lng': 44.2085, 'phone': '01-999555', 'specialty': 'نساء وولادة', 'rating': 4.5, 'category': 'clinics'},
    {'name': 'عيادة الدكتورة سناء', 'address': 'شارع الخمسين، حي الازدهار', 'lat': 15.3805, 'lng': 44.2105, 'phone': '01-000666', 'specialty': 'عظام', 'rating': 4.3, 'category': 'clinics'},
  ];

  // ============================================================
  // 📌 أخرى (مراكز صحية، تأمين، إسعاف، خيرية) - 60
  // ============================================================
  final List<Map<String, dynamic>> _other = [
    {'name': 'مركز صحي الزبيري', 'address': 'شارع الزبيري، وسط البلد', 'lat': 15.3515, 'lng': 44.1985, 'phone': '01-111222', 'type': 'مركز صحي', 'rating': 4.3, 'category': 'other'},
    {'name': 'مركز صحي التحرير', 'address': 'شارع التحرير، ميدان التحرير', 'lat': 15.3595, 'lng': 44.1925, 'phone': '01-222333', 'type': 'مركز صحي', 'rating': 4.1, 'category': 'other'},
    {'name': 'مركز صحي هائل', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3655, 'lng': 44.1955, 'phone': '01-333444', 'type': 'مركز صحي', 'rating': 4.4, 'category': 'other'},
    {'name': 'مركز صحي الحصبة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3815, 'lng': 44.2095, 'phone': '01-444555', 'type': 'مركز صحي', 'rating': 3.9, 'category': 'other'},
    {'name': 'مركز صحي باب اليمن', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3455, 'lng': 44.1995, 'phone': '01-555666', 'type': 'مركز صحي', 'rating': 4.2, 'category': 'other'},
    {'name': 'مركز صحي العدين', 'address': 'شارع العدين، السنينة', 'lat': 15.3885, 'lng': 44.2135, 'phone': '01-666777', 'type': 'مركز صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'هيئة التأمين الصحي', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3505, 'lng': 44.1975, 'phone': '01-777888', 'type': 'تأمين صحي', 'rating': 4.5, 'category': 'other'},
    {'name': 'شركة التأمين الوطنية', 'address': 'شارع التحرير، بجانب البنك', 'lat': 15.3585, 'lng': 44.1935, 'phone': '01-888999', 'type': 'تأمين صحي', 'rating': 4.2, 'category': 'other'},
    {'name': 'شركة اليمن للتأمين', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3365, 'lng': 44.1835, 'phone': '01-999000', 'type': 'تأمين صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'هلال أحمر يمني', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3485, 'lng': 44.2015, 'phone': '199', 'type': 'إسعاف', 'rating': 4.8, 'category': 'other'},
    {'name': 'جمعية الهلال الأحمر', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3735, 'lng': 44.2055, 'phone': '199', 'type': 'إسعاف', 'rating': 4.7, 'category': 'other'},
    {'name': 'مركز الإسعاف الوطني', 'address': 'شارع الستين، جولة 48', 'lat': 15.3395, 'lng': 44.1895, 'phone': '199', 'type': 'إسعاف', 'rating': 4.6, 'category': 'other'},
    {'name': 'جمعية الأمل الخيرية', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3575, 'lng': 44.1965, 'phone': '01-111000', 'type': 'خيرية', 'rating': 4.4, 'category': 'other'},
    {'name': 'مؤسسة الصحة الخيرية', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3625, 'lng': 44.1915, 'phone': '01-222111', 'type': 'خيرية', 'rating': 4.3, 'category': 'other'},
    {'name': 'جمعية الشفاء الخيرية', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3705, 'lng': 44.1945, 'phone': '01-333222', 'type': 'خيرية', 'rating': 4.2, 'category': 'other'},
    {'name': 'مركز صحي السبعين', 'address': 'السبعين، شارع الأربعين', 'lat': 15.3125, 'lng': 44.1815, 'phone': '01-444333', 'type': 'مركز صحي', 'rating': 3.8, 'category': 'other'},
    {'name': 'مركز صحي النهضة', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3165, 'lng': 44.1765, 'phone': '01-555444', 'type': 'مركز صحي', 'rating': 4.1, 'category': 'other'},
    {'name': 'مركز صحي السلام', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3185, 'lng': 44.1735, 'phone': '01-666555', 'type': 'مركز صحي', 'rating': 3.9, 'category': 'other'},
    {'name': 'مركز صحي الفتح', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3565, 'lng': 44.2045, 'phone': '01-777666', 'type': 'مركز صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'مركز صحي النصر', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3935, 'lng': 44.2165, 'phone': '01-888777', 'type': 'مركز صحي', 'rating': 3.7, 'category': 'other'},
    {'name': 'مركز صحي الأمل', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3425, 'lng': 44.1985, 'phone': '01-999888', 'type': 'مركز صحي', 'rating': 4.3, 'category': 'other'},
    {'name': 'شركة الرعاية للتأمين', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3535, 'lng': 44.1965, 'phone': '01-111999', 'type': 'تأمين صحي', 'rating': 4.1, 'category': 'other'},
    {'name': 'شركة الصحة للتأمين', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3605, 'lng': 44.1945, 'phone': '01-222888', 'type': 'تأمين صحي', 'rating': 3.9, 'category': 'other'},
    {'name': 'شركة العناية للتأمين', 'address': 'شارع هائل، فرع الجامعة', 'lat': 15.3715, 'lng': 44.1965, 'phone': '01-333777', 'type': 'تأمين صحي', 'rating': 4.2, 'category': 'other'},
    {'name': 'مركز الإسعاف المتقدم', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3805, 'lng': 44.2075, 'phone': '199', 'type': 'إسعاف', 'rating': 4.5, 'category': 'other'},
    {'name': 'مركز الإسعاف السريع', 'address': 'شارع الستين، جولة آية', 'lat': 15.3425, 'lng': 44.1735, 'phone': '199', 'type': 'إسعاف', 'rating': 4.4, 'category': 'other'},
    {'name': 'مركز الإسعاف الميداني', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3595, 'lng': 44.2085, 'phone': '199', 'type': 'إسعاف', 'rating': 4.3, 'category': 'other'},
    {'name': 'جمعية البر الخيرية', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3465, 'lng': 44.2025, 'phone': '01-444111', 'type': 'خيرية', 'rating': 4.6, 'category': 'other'},
    {'name': 'مؤسسة السلام الخيرية', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3635, 'lng': 44.1915, 'phone': '01-555222', 'type': 'خيرية', 'rating': 4.3, 'category': 'other'},
    {'name': 'جمعية الوفاء الخيرية', 'address': 'شارع هائل، حي الأندلس', 'lat': 15.3725, 'lng': 44.1935, 'phone': '01-666333', 'type': 'خيرية', 'rating': 4.1, 'category': 'other'},
    {'name': 'مركز صحي العاصمة', 'address': 'شارع الزبيري، شارع القاهرة', 'lat': 15.3525, 'lng': 44.2005, 'phone': '01-777444', 'type': 'مركز صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'مركز صحي صنعاء', 'address': 'شارع التحرير، حي صنعاء', 'lat': 15.3685, 'lng': 44.1955, 'phone': '01-888555', 'type': 'مركز صحي', 'rating': 4.2, 'category': 'other'},
    {'name': 'مركز صحي اليمن', 'address': 'شارع الستين، حي اليمن', 'lat': 15.3405, 'lng': 44.1755, 'phone': '01-999666', 'type': 'مركز صحي', 'rating': 3.8, 'category': 'other'},
    {'name': 'مركز صحي الوحدة', 'address': 'شارع الخمسين، حي الوحدة', 'lat': 15.3755, 'lng': 44.2065, 'phone': '01-000777', 'type': 'مركز صحي', 'rating': 4.1, 'category': 'other'},
    {'name': 'مركز صحي الاتحاد', 'address': 'شارع القاهرة، حي الاتحاد', 'lat': 15.3575, 'lng': 44.2055, 'phone': '01-111888', 'type': 'مركز صحي', 'rating': 3.9, 'category': 'other'},
    {'name': 'مركز صحي الإخلاص', 'address': 'شارع العدين، حي الإخلاص', 'lat': 15.3905, 'lng': 44.2145, 'phone': '01-222999', 'type': 'مركز صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'شركة الأمان للتأمين', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3485, 'lng': 44.2005, 'phone': '01-333111', 'type': 'تأمين صحي', 'rating': 4.3, 'category': 'other'},
    {'name': 'شركة الثقة للتأمين', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3615, 'lng': 44.1935, 'phone': '01-444222', 'type': 'تأمين صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'شركة السلام للتأمين', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3665, 'lng': 44.1965, 'phone': '01-555333', 'type': 'تأمين صحي', 'rating': 4.2, 'category': 'other'},
    {'name': 'مركز الإسعاف الجوي', 'address': 'شارع الخمسين، المطار', 'lat': 15.3775, 'lng': 44.2115, 'phone': '199', 'type': 'إسعاف', 'rating': 4.7, 'category': 'other'},
    {'name': 'مركز الإسعاف البحري', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3285, 'lng': 44.1825, 'phone': '199', 'type': 'إسعاف', 'rating': 4.5, 'category': 'other'},
    {'name': 'مركز الإسعاف البري', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3495, 'lng': 44.2035, 'phone': '199', 'type': 'إسعاف', 'rating': 4.4, 'category': 'other'},
    {'name': 'جمعية العطاء الخيرية', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3585, 'lng': 44.1975, 'phone': '01-666444', 'type': 'خيرية', 'rating': 4.5, 'category': 'other'},
    {'name': 'مؤسسة الوفاق الخيرية', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3645, 'lng': 44.1925, 'phone': '01-777555', 'type': 'خيرية', 'rating': 4.2, 'category': 'other'},
    {'name': 'جمعية الإحسان الخيرية', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3735, 'lng': 44.1955, 'phone': '01-888666', 'type': 'خيرية', 'rating': 4.0, 'category': 'other'},
    {'name': 'مركز صحي الفردوس', 'address': 'شارع الزبيري، حي الفردوس', 'lat': 15.3545, 'lng': 44.1995, 'phone': '01-999777', 'type': 'مركز صحي', 'rating': 3.9, 'category': 'other'},
    {'name': 'مركز صحي النجاح', 'address': 'شارع التحرير، حي النجاح', 'lat': 15.3625, 'lng': 44.1965, 'phone': '01-000888', 'type': 'مركز صحي', 'rating': 4.3, 'category': 'other'},
    {'name': 'مركز صحي التقدم', 'address': 'شارع الستين، حي التقدم', 'lat': 15.3375, 'lng': 44.1875, 'phone': '01-111999', 'type': 'مركز صحي', 'rating': 4.1, 'category': 'other'},
    {'name': 'مركز صحي الكرامة', 'address': 'شارع الخمسين، حي الكرامة', 'lat': 15.3765, 'lng': 44.2075, 'phone': '01-222000', 'type': 'مركز صحي', 'rating': 4.0, 'category': 'other'},
    {'name': 'مركز صحي الأمان', 'address': 'شارع القاهرة، حي الأمان', 'lat': 15.3565, 'lng': 44.2065, 'phone': '01-333111', 'type': 'مركز صحي', 'rating': 3.8, 'category': 'other'},
    {'name': 'مركز صحي الوفاء', 'address': 'شارع العدين، حي الوفاء', 'lat': 15.3895, 'lng': 44.2155, 'phone': '01-444222', 'type': 'مركز صحي', 'rating': 4.2, 'category': 'other'},
    {'name': 'شركة الإخلاص للتأمين', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3525, 'lng': 44.1985, 'phone': '01-555333', 'type': 'تأمين صحي', 'rating': 4.1, 'category': 'other'},
    {'name': 'شركة الصفوة للتأمين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3595, 'lng': 44.1955, 'phone': '01-666444', 'type': 'تأمين صحي', 'rating': 3.9, 'category': 'other'},
    {'name': 'شركة الريان للتأمين', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3685, 'lng': 44.1945, 'phone': '01-777555', 'type': 'تأمين صحي', 'rating': 4.3, 'category': 'other'},
    {'name': 'مركز الإسعاف الشامل', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3325, 'lng': 44.1855, 'phone': '199', 'type': 'إسعاف', 'rating': 4.6, 'category': 'other'},
    {'name': 'مركز الإسعاف المتكامل', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3785, 'lng': 44.2085, 'phone': '199', 'type': 'إسعاف', 'rating': 4.5, 'category': 'other'},
    {'name': 'مركز الإسعاف الوطني الجديد', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3535, 'lng': 44.2055, 'phone': '199', 'type': 'إسعاف', 'rating': 4.4, 'category': 'other'},
    {'name': 'جمعية النهضة الخيرية', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3475, 'lng': 44.2015, 'phone': '01-888777', 'type': 'خيرية', 'rating': 4.6, 'category': 'other'},
    {'name': 'مؤسسة الأمل الخيرية', 'address': 'شارع التحرير، بجانب البنك', 'lat': 15.3605, 'lng': 44.1945, 'phone': '01-999888', 'type': 'خيرية', 'rating': 4.3, 'category': 'other'},
    {'name': 'جمعية الخير الدائمة', 'address': 'شارع هائل، حي الأندلس', 'lat': 15.3715, 'lng': 44.1955, 'phone': '01-000999', 'type': 'خيرية', 'rating': 4.1, 'category': 'other'},
  ];

  // ============================================================
  // 🏥 دمج جميع الأماكن معاً
  // ============================================================
  List<Map<String, dynamic>> get _allPlaces {
    return [
      ..._hospitals,
      ..._pharmacies,
      ..._labs,
      ..._clinics,
      ..._other,
    ];
  }

  // ============================================================
  // 🔍 دالة البحث والتصفية
  // ============================================================
  List<Map<String, dynamic>> _getFilteredPlaces() {
    final places = _allPlaces;
    
    if (_selectedCategory == 'الكل' && _searchQuery.isEmpty) {
      return places;
    }
    
    return places.where((place) {
      // تصفية حسب الفئة
      if (_selectedCategory != 'الكل') {
        final categoryMap = {
          'مستشفيات': 'hospitals',
          'صيدليات': 'pharmacies',
          'مختبرات': 'labs',
          'عيادات': 'clinics',
          'أخرى': 'other',
        };
        final targetCategory = categoryMap[_selectedCategory];
        if (targetCategory != null && place['category'] != targetCategory) {
          return false;
        }
      }
      
      // تصفية حسب البحث
      if (_searchQuery.isNotEmpty) {
        final name = (place['name'] as String).toLowerCase();
        final address = (place['address'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !address.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  // ============================================================
  // 🎨 بناء العلامات (Markers) مع Clustering
  // ============================================================
  List<Marker> _buildMarkers() {
    final filtered = _getFilteredPlaces();
    
    return filtered.map((place) {
      final isSelected = _selectedLocation != null &&
          _selectedLocation!.latitude == place['lat'] &&
          _selectedLocation!.longitude == place['lng'];
      
      return Marker(
        width: 40,
        height: 40,
        point: LatLng(place['lat'] as double, place['lng'] as double),
        child: GestureDetector(
          onTap: () => _showPlaceDetails(place),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: isSelected ? 48 : 36,
            height: isSelected ? 48 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Icon(
                      _getIconForCategory(place['category'] as String),
                      color: AppColors.primary,
                      size: 18,
                    ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // ============================================================
  // 🎨 الحصول على الأيقونة حسب الفئة
  // ============================================================
  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'hospitals':
        return Icons.local_hospital;
      case 'pharmacies':
        return Icons.local_pharmacy;
      case 'labs':
        return Icons.science;
      case 'clinics':
        return Icons.healing;
      case 'other':
        return Icons.place;
      default:
        return Icons.place;
    }
  }

  // ============================================================
  // 🏷️ الحصول على اسم الفئة بالعربية
  // ============================================================
  String _getCategoryLabel(String category) {
    switch (category) {
      case 'hospitals':
        return 'مستشفى';
      case 'pharmacies':
        return 'صيدلية';
      case 'labs':
        return 'مختبر';
      case 'clinics':
        return 'عيادة';
      case 'other':
        return 'أخرى';
      default:
        return 'أخرى';
    }
  }

  // ============================================================
  // 📋 عرض تفاصيل المكان
  // ============================================================
  void _showPlaceDetails(Map<String, dynamic> place) {
    setState(() {
      _selectedLocation = LatLng(place['lat'] as double, place['lng'] as double);
    });
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIconForCategory(place['category'] as String),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place['address'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (place.containsKey('rating'))
                        Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '${place['rating']}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getCategoryLabel(place['category'] as String),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            if (place.containsKey('phone'))
              Row(
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    place['phone'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            if (place.containsKey('hours'))
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    place['hours'] as String,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final url = 'https://www.google.com/maps/dir/${_currentPosition?.latitude},${_currentPosition?.longitude}/${place['lat']},${place['lng']}';
                      _launchUrl(url);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('الاتجاهات'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (place.containsKey('phone')) {
                        _launchUrl('tel:${place['phone']}');
                      }
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('اتصال'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  // ============================================================
  // 🌐 فتح الرابط
  // ============================================================
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ============================================================
  // 📍 الحصول على الموقع الحالي
  // ============================================================
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14,
      );
    } catch (e) {
      print('❌ Error getting location: $e');
    }
  }

  // ============================================================
  // 🎨 اختيار طبقة الخريطة
  // ============================================================
  void _selectLayer(String layerName) {
    setState(() {
      _selectedLayer = layerName;
    });
  }

  // ============================================================
  // 🏗️ بناء الواجهة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الخريطة التفاعلية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 شريط البحث
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن مستشفى، صيدلية، مختبر، عيادة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          
          // 🏷️ فلتر الفئات
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          
          // 🗺️ الخريطة مع Clustering
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition != null
                    ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                    : sanaaCenter,
                initialZoom: 14,
                minZoom: 8,
                maxZoom: 18,
                onTap: (_, __) {
                  setState(() => _selectedLocation = null);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _mapLayers[_selectedLayer]!['url']!,
                  userAgentPackageName: 'com.example.sehatak',
                ),
                // ✅ استخدام MarkerClusterLayer لتجميع الدبابيس
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    markers: _buildMarkers(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 60,
                        height: 60,
                        point: _selectedLocation!,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _mapLayers.keys.map((layerName) {
            final isSelected = _selectedLayer == layerName;
            return GestureDetector(
              onTap: () => _selectLayer(layerName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  layerName,
                  style: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
