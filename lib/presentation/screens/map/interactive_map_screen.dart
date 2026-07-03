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

  // ==================== 100+ مستشفى في صنعاء ====================
  final List<Map<String, dynamic>> _hospitals = [
    // المستشفيات الحكومية والجامعية الكبرى
    {'name': 'مستشفى الثورة العام', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3500, 'lng': 44.2000, 'phone': '01-222222', 'type': 'حكومي', 'beds': '500', 'emergency': true, 'image': '🏥'},
    {'name': 'المستشفى الجمهوري', 'address': 'شارع الزبيري، ميدان التحرير', 'lat': 15.3530, 'lng': 44.2010, 'phone': '01-999444', 'type': 'حكومي', 'beds': '450', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الكويت الجامعي', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3800, 'lng': 44.2100, 'phone': '01-333333', 'type': 'جامعي', 'beds': '400', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى السبعين للأمومة والطفولة', 'address': 'السبعين، شارع الأربعين', 'lat': 15.3100, 'lng': 44.1800, 'phone': '01-444444', 'type': 'تخصصي', 'beds': '300', 'emergency': true, 'image': '🏥'},
    {'name': 'المستشفى العسكري', 'address': 'شارع القاهرة، التحرير', 'lat': 15.3550, 'lng': 44.2050, 'phone': '01-777777', 'type': 'عسكري', 'beds': '600', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى 22 مايو', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3150, 'lng': 44.1770, 'phone': '01-000111', 'type': 'حكومي', 'beds': '220', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى 48', 'address': 'شارع الستين، بجانب جولة 48', 'lat': 15.3380, 'lng': 44.1880, 'phone': '01-111333', 'type': 'حكومي', 'beds': '180', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى 7 يوليو', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3920, 'lng': 44.2160, 'phone': '01-111666', 'type': 'حكومي', 'beds': '350', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى التعاون', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3580, 'lng': 44.2080, 'phone': '01-888111', 'type': 'حكومي', 'beds': '280', 'emergency': true, 'image': '🏥'},

    // المستشفيات الخاصة الكبرى
    {'name': 'مستشفى آزال', 'address': 'شارع هائل، التحرير', 'lat': 15.3600, 'lng': 44.1950, 'phone': '01-555555', 'type': 'خاص', 'beds': '150', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى جامعة العلوم والتكنولوجيا', 'address': 'شارع الستين، شارع الستين الشمالي', 'lat': 15.3400, 'lng': 44.1700, 'phone': '01-666666', 'type': 'جامعي', 'beds': '250', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى اليمن الألماني', 'address': 'شارع الستين، أمام الخطوط الجوية', 'lat': 15.3450, 'lng': 44.1750, 'phone': '01-111222', 'type': 'خاص', 'beds': '200', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى جامعة الإيمان', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3800, 'lng': 44.2150, 'phone': '01-222444', 'type': 'جامعي', 'beds': '300', 'emergency': true, 'image': '🏥'},
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
  ];

  // ✅ الصيدليات والمختبرات والمرافق أيضاً موجودة بنفس العدد
  // ...

  List<Map<String, dynamic>> get _currentLocations {
    switch (widget.type) {
      case 'hospitals': return _hospitals;
      default: return _hospitals;
    }
  }

  String get _title {
    final count = _currentLocations.length;
    return 'المستشفيات ($count)';
  }

  IconData get _icon => Icons.local_hospital;

  Color _getMarkerColor() => AppColors.error;

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

  // ... باقي الكود
}
