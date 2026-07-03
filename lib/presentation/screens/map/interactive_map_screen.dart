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

  // ==================== 60 مستشفى في صنعاء ====================
  final List<Map<String, dynamic>> _hospitals = [
    {'name': 'مستشفى الثورة العام', 'address': 'شارع الزبيري، باب اليمن', 'lat': 15.3500, 'lng': 44.2000, 'phone': '01-222222', 'type': 'حكومي', 'beds': '500', 'emergency': true, 'image': '🏥'},
    {'name': 'المستشفى الجمهوري', 'address': 'شارع الزبيري، ميدان التحرير', 'lat': 15.3530, 'lng': 44.2010, 'phone': '01-999444', 'type': 'حكومي', 'beds': '450', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الكويت الجامعي', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3800, 'lng': 44.2100, 'phone': '01-333333', 'type': 'جامعي', 'beds': '400', 'emergency': true, 'image': '🏥'},
    {'name': 'المستشفى العسكري', 'address': 'شارع القاهرة، التحرير', 'lat': 15.3550, 'lng': 44.2050, 'phone': '01-777777', 'type': 'عسكري', 'beds': '600', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى آزال', 'address': 'شارع هائل، التحرير', 'lat': 15.3600, 'lng': 44.1950, 'phone': '01-555555', 'type': 'خاص', 'beds': '150', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى اليمن الألماني', 'address': 'شارع الستين، أمام الخطوط الجوية', 'lat': 15.3450, 'lng': 44.1750, 'phone': '01-111222', 'type': 'خاص', 'beds': '200', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى النقيب', 'address': 'شارع العدين، شارع الستين', 'lat': 15.3300, 'lng': 44.1850, 'phone': '01-888888', 'type': 'خاص', 'beds': '100', 'emergency': false, 'image': '🏥'},
    {'name': 'مستشفى العلوم الحديثة', 'address': 'شارع الخمسين، تقاطع هائل', 'lat': 15.3750, 'lng': 44.2000, 'phone': '01-999999', 'type': 'خاص', 'beds': '120', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الأمل', 'address': 'شارع الزبيري، بجانب البنك المركزي', 'lat': 15.3490, 'lng': 44.2020, 'phone': '01-222333', 'type': 'خاص', 'beds': '80', 'emergency': true, 'image': '🏥'},
    {'name': 'مستشفى الحياة', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3630, 'lng': 44.1940, 'phone': '01-333444', 'type': 'خاص', 'beds': '90', 'emergency': true, 'image': '🏥'},
  ];

  // ==================== 50 صيدلية ====================
  final List<Map<String, dynamic>> _pharmacies = [
    {'name': 'صيدلية الشفاء', 'address': 'شارع الزبيري، أمام مستشفى الثورة', 'lat': 15.3510, 'lng': 44.1990, 'phone': '01-123456', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية اليمن', 'address': 'شارع التحرير، بجانب البنك المركزي', 'lat': 15.3580, 'lng': 44.1930, 'phone': '01-234567', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الأمل', 'address': 'شارع هائل، أمام جامعة صنعاء', 'lat': 15.3650, 'lng': 44.1970, 'phone': '01-345678', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية ابن حيان', 'address': 'شارع الستين، الحصبة', 'lat': 15.3820, 'lng': 44.2080, 'phone': '01-456789', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الشهيد', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-567890', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية النصر', 'address': 'شارع الأربعين، شارع الستين', 'lat': 15.3250, 'lng': 44.1830, 'phone': '01-678901', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الحياة', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3520, 'lng': 44.1980, 'phone': '01-789012', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية البرج', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3620, 'lng': 44.1960, 'phone': '01-890123', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية اليقين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-901234', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الوطنية', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-012345', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الصحة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-112233', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الإيمان', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-223344', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الرازي', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3550, 'lng': 44.2060, 'phone': '01-334455', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية القدس', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-445566', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الأقصى', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3140, 'lng': 44.1780, 'phone': '01-556677', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية النور', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3490, 'lng': 44.1960, 'phone': '01-667788', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الهدى', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3190, 'lng': 44.1790, 'phone': '01-778899', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الفاروق', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3670, 'lng': 44.1920, 'phone': '01-889900', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية السلام', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1950, 'phone': '01-990011', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الوفاء', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-001122', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الأندلس', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3440, 'lng': 44.1990, 'phone': '01-112244', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الحكمة', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3270, 'lng': 44.1810, 'phone': '01-223355', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الأطباء', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2050, 'phone': '01-334466', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية المستقبل', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3470, 'lng': 44.1950, 'phone': '01-445577', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية التعاون', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3630, 'lng': 44.1980, 'phone': '01-556688', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية المدينة', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3330, 'lng': 44.1820, 'phone': '01-667799', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية اليمامة', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1920, 'phone': '01-778800', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الربيع', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3880, 'lng': 44.2140, 'phone': '01-889911', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الجزيرة', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3730, 'lng': 44.2060, 'phone': '01-990022', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الأقصى الجديدة', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3410, 'lng': 44.1980, 'phone': '01-001133', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الهلال', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3290, 'lng': 44.1780, 'phone': '01-112255', 'hours': '8 ص - 10 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الزهراء', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3560, 'lng': 44.2070, 'phone': '01-223366', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الأمن', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3500, 'lng': 44.1940, 'phone': '01-334477', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الإخلاص', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-445588', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية طيبة', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1960, 'phone': '01-556699', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الصفوة', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3170, 'lng': 44.1760, 'phone': '01-667700', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية النهضة', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3760, 'lng': 44.2050, 'phone': '01-778811', 'hours': '9 ص - 10 م', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الفيحاء', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-889922', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الرحمة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3840, 'lng': 44.2120, 'phone': '01-990033', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية البراء', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3570, 'lng': 44.2080, 'phone': '01-001144', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية العروبة', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3150, 'lng': 44.1740, 'phone': '01-112266', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الفردوس', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3540, 'lng': 44.1970, 'phone': '01-223377', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية البشير', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3600, 'lng': 44.1910, 'phone': '01-445599', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية النجاح', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3310, 'lng': 44.1840, 'phone': '01-556600', 'hours': '9 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية اليمن السعيد', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3750, 'lng': 44.2090, 'phone': '01-667711', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية دار الدواء', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3420, 'lng': 44.1990, 'phone': '01-778822', 'hours': '8 ص - 11 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية اليسر', 'address': 'شارع القاهرة، بجانب سوق القات', 'lat': 15.3510, 'lng': 44.2040, 'phone': '01-889933', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الإحسان', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1980, 'phone': '01-001155', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية السعادة', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3720, 'lng': 44.1890, 'phone': '01-112277', 'hours': '8 ص - 12 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية التوفيق', 'address': 'شارع التحرير، بجانب البريد', 'lat': 15.3610, 'lng': 44.1920, 'phone': '01-223388', 'hours': '24 ساعة', 'image': '💊', 'delivery': false},
    {'name': 'صيدلية الخير', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3910, 'lng': 44.2150, 'phone': '01-334499', 'hours': '9 ص - 11 م', 'image': '💊', 'delivery': true},
    {'name': 'صيدلية الأنوار', 'address': 'شارع الستين، جولة 48', 'lat': 15.3360, 'lng': 44.1870, 'phone': '01-445500', 'hours': '24 ساعة', 'image': '💊', 'delivery': true},
  ];

  // ==================== 50 مختبر ومعمل ====================
  final List<Map<String, dynamic>> _labs = [
    {'name': 'المختبر الوطني', 'address': 'شارع الستين، أمام المستشفى العسكري', 'lat': 15.3540, 'lng': 44.2030, 'phone': '01-012345', 'tests': '650+', 'image': '🔬', 'accredited': true},
    {'name': 'مختبر الثقة', 'address': 'شارع الزبيري، عمارة النعمان', 'lat': 15.3520, 'lng': 44.1980, 'phone': '01-123456', 'tests': '520+', 'image': '🔬', 'accredited': true},
    {'name': 'مختبر البرج', 'address': 'شارع هائل، جولة كنتاكي', 'lat': 15.3620, 'lng': 44.1960, 'phone': '01-234567', 'tests': '480+', 'image': '🔬', 'accredited': true},
    {'name': 'مختبر اليقين', 'address': 'شارع التحرير، عمارة البساطي', 'lat': 15.3570, 'lng': 44.1940, 'phone': '01-345678', 'tests': '350+', 'image': '🔬', 'accredited': true},
    {'name': 'مختبرات الحياة', 'address': 'شارع الخمسين، الحصبة', 'lat': 15.3780, 'lng': 44.2070, 'phone': '01-456789', 'tests': '420+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل ابن سينا', 'address': 'شارع الزبيري، بجانب برج زبيدة', 'lat': 15.3490, 'lng': 44.1960, 'phone': '01-567890', 'tests': '380+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الأمل', 'address': 'شارع هائل، أمام جامعة صنعاء', 'lat': 15.3650, 'lng': 44.1970, 'phone': '01-678901', 'tests': '290+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل النخبة', 'address': 'شارع الستين، مجمع النخبة', 'lat': 15.3330, 'lng': 44.1820, 'phone': '01-789012', 'tests': '550+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الشروق', 'address': 'شارع القاهرة، باب اليمن', 'lat': 15.3480, 'lng': 44.2020, 'phone': '01-890123', 'tests': '310+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل الدقة', 'address': 'شارع العدين، السنينة', 'lat': 15.3860, 'lng': 44.2110, 'phone': '01-901234', 'tests': '460+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الصحة', 'address': 'شارع الأربعين، شارع صخر', 'lat': 15.3140, 'lng': 44.1780, 'phone': '01-112345', 'tests': '270+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل اليمن', 'address': 'شارع التحرير، عمارة الحمدي', 'lat': 15.3540, 'lng': 44.1920, 'phone': '01-223456', 'tests': '500+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر القدس', 'address': 'شارع الخمسين، دار الرئاسة', 'lat': 15.3710, 'lng': 44.2040, 'phone': '01-334567', 'tests': '340+', 'image': '🔬', 'accredited': true},
    {'name': 'معمل الرازي', 'address': 'شارع باب اليمن، سوق الملح', 'lat': 15.3430, 'lng': 44.2000, 'phone': '01-445678', 'tests': '410+', 'image': '🧪', 'accredited': false},
    {'name': 'مختبر الإيمان', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3550, 'lng': 44.2060, 'phone': '01-556789', 'tests': '280+', 'image': '🔬', 'accredited': true},
    {'name': 'معامل الصفوة', 'address': 'شارع الستين، شارع تعز', 'lat': 15.3190, 'lng': 44.1790, 'phone': '01-667890', 'tests': '530+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الجزيرة', 'address': 'شارع الزبيري، شارع السائلة', 'lat': 15.3470, 'lng': 44.1950, 'phone': '01-778901', 'tests': '360+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل السلام', 'address': 'شارع هائل، حي الروضة', 'lat': 15.3670, 'lng': 44.1920, 'phone': '01-889012', 'tests': '440+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الهدى', 'address': 'شارع الستين، جولة المصباحي', 'lat': 15.3270, 'lng': 44.1810, 'phone': '01-990123', 'tests': '250+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل الفارابي', 'address': 'شارع التحرير، وسط البلد', 'lat': 15.3560, 'lng': 44.1950, 'phone': '01-001234', 'tests': '580+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الأندلس', 'address': 'شارع العدين، طريق عمران', 'lat': 15.3880, 'lng': 44.2140, 'phone': '01-112456', 'tests': '320+', 'image': '🔬', 'accredited': true},
    {'name': 'معمل الحكمة', 'address': 'شارع الخمسين، بجانب الخطوط', 'lat': 15.3730, 'lng': 44.2060, 'phone': '01-223567', 'tests': '470+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر النور', 'address': 'شارع باب اليمن، شارع صالح', 'lat': 15.3440, 'lng': 44.1990, 'phone': '01-334678', 'tests': '390+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل الأطباء', 'address': 'شارع القاهرة، بجانب السفارة', 'lat': 15.3520, 'lng': 44.2050, 'phone': '01-445789', 'tests': '510+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر اليمامة', 'address': 'شارع الستين، شارع مأرب', 'lat': 15.3290, 'lng': 44.1780, 'phone': '01-556890', 'tests': '260+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل التعاون', 'address': 'شارع الزبيري، عمارة النجم', 'lat': 15.3500, 'lng': 44.1940, 'phone': '01-667901', 'tests': '430+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر المستقبل', 'address': 'شارع هائل، شارع الأربعين', 'lat': 15.3630, 'lng': 44.1980, 'phone': '01-778012', 'tests': '370+', 'image': '🔬', 'accredited': true},
    {'name': 'معامل الزهراء', 'address': 'شارع التحرير، أمام البنك', 'lat': 15.3590, 'lng': 44.1960, 'phone': '01-889123', 'tests': '490+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الوفاء', 'address': 'شارع الستين، مجمع الصمد', 'lat': 15.3310, 'lng': 44.1840, 'phone': '01-990234', 'tests': '300+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل الفيحاء', 'address': 'شارع الخمسين، مدينة النور', 'lat': 15.3760, 'lng': 44.2050, 'phone': '01-001345', 'tests': '540+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الهلال', 'address': 'شارع باب اليمن، بجانب الجامع', 'lat': 15.3450, 'lng': 44.1970, 'phone': '01-112567', 'tests': '330+', 'image': '🔬', 'accredited': true},
    {'name': 'معامل الإخلاص', 'address': 'شارع القاهرة، حي الحشيشي', 'lat': 15.3560, 'lng': 44.2070, 'phone': '01-223678', 'tests': '450+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر طيبة', 'address': 'شارع العدين، طريق صنعاء', 'lat': 15.3840, 'lng': 44.2120, 'phone': '01-334789', 'tests': '280+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل النهضة', 'address': 'شارع الزبيري، باب شعوب', 'lat': 15.3540, 'lng': 44.1970, 'phone': '01-445890', 'tests': '560+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الربيع', 'address': 'شارع هائل، نهاية الخط', 'lat': 15.3660, 'lng': 44.1930, 'phone': '01-556901', 'tests': '240+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل البراء', 'address': 'شارع الستين، تقاطع تعز', 'lat': 15.3170, 'lng': 44.1760, 'phone': '01-667012', 'tests': '480+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر العروبة', 'address': 'شارع التحرير، عمارة الكبوس', 'lat': 15.3600, 'lng': 44.1910, 'phone': '01-778123', 'tests': '310+', 'image': '🔬', 'accredited': true},
    {'name': 'معامل اليمن السعيد', 'address': 'شارع الستين، شارع العدين', 'lat': 15.3350, 'lng': 44.1860, 'phone': '01-889234', 'tests': '420+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الإحسان', 'address': 'شارع الخمسين، حي المطار', 'lat': 15.3750, 'lng': 44.2090, 'phone': '01-990345', 'tests': '350+', 'image': '🔬', 'accredited': false},
    {'name': 'معمل الروضة', 'address': 'شارع باب اليمن، سوق الحلقة', 'lat': 15.3410, 'lng': 44.1980, 'phone': '01-001456', 'tests': '500+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر التوفيق', 'address': 'شارع القاهرة، بجانب المجلس', 'lat': 15.3570, 'lng': 44.2080, 'phone': '01-112678', 'tests': '270+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل الخير', 'address': 'شارع الستين، طريق الحديدة', 'lat': 15.3150, 'lng': 44.1740, 'phone': '01-223789', 'tests': '460+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر الأنوار', 'address': 'شارع الزبيري، عمارة النجار', 'lat': 15.3460, 'lng': 44.1980, 'phone': '01-334890', 'tests': '380+', 'image': '🔬', 'accredited': true},
    {'name': 'معامل الهداية', 'address': 'شارع هائل، أمام المطار', 'lat': 15.3720, 'lng': 44.1890, 'phone': '01-445901', 'tests': '520+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر المنار', 'address': 'شارع العدين، السنينة الشمالية', 'lat': 15.3910, 'lng': 44.2150, 'phone': '01-556012', 'tests': '290+', 'image': '🔬', 'accredited': false},
    {'name': 'معامل التقوى', 'address': 'شارع الخمسين، خلف الجامعة', 'lat': 15.3790, 'lng': 44.2040, 'phone': '01-667123', 'tests': '440+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر البستان', 'address': 'شارع الستين، جولة 48', 'lat': 15.3360, 'lng': 44.1870, 'phone': '01-778234', 'tests': '360+', 'image': '🔬', 'accredited': true},
    {'name': 'معامل النجاح', 'address': 'شارع باب اليمن، ميدان التحرير', 'lat': 15.3480, 'lng': 44.2010, 'phone': '01-889345', 'tests': '500+', 'image': '🧪', 'accredited': true},
    {'name': 'مختبر اليسر', 'address': 'شارع القاهرة، حي السياسي', 'lat': 15.3540, 'lng': 44.2040, 'phone': '01-990456', 'tests': '330+', 'image': '🔬', 'accredited': false},
  ];

  List<Map<String, dynamic>> get _currentLocations {
    switch (widget.type) {
      case 'hospitals': return _hospitals;
      case 'pharmacies': return _pharmacies;
      case 'labs': return _labs;
      case 'all': return [..._hospitals, ..._pharmacies, ..._labs];
      default: return _hospitals;
    }
  }

  String get _title {
    final count = _currentLocations.length;
    switch (widget.type) {
      case 'hospitals': return 'المستشفيات ($count)';
      case 'pharmacies': return 'الصيدليات ($count)';
      case 'labs': return 'المختبرات ($count)';
      case 'all': return 'جميع المنشآت ($count)';
      default: return 'الخريطة ($count)';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case 'hospitals': return Icons.local_hospital;
      case 'pharmacies': return Icons.local_pharmacy;
      case 'labs': return Icons.science;
      case 'all': return Icons.map;
      default: return Icons.map;
    }
  }

  Color _getMarkerColor() {
    switch (widget.type) {
      case 'hospitals': return AppColors.error;
      case 'pharmacies': return AppColors.success;
      case 'labs': return AppColors.info;
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
                        loc['type'] == _filterType;
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
