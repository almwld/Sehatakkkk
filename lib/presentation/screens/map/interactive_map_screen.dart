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
  // 🏥 100+ مستشفى
  // ============================================================
  final List<Map<String, dynamic>> _hospitals = List.generate(105, (index) {
    final names = [
      'مستشفى الثورة العام', 'المستشفى الجمهوري', 'مستشفى الكويت الجامعي',
      'المستشفى العسكري', 'مستشفى آزال', 'مستشفى اليمن الألماني',
      'مستشفى النقيب', 'مستشفى العلوم الحديثة', 'مستشفى الأمل',
      'مستشفى الحياة', 'مستشفى الصفوة', 'مستشفى الخليج',
      'مستشفى ابن النفيس', 'مستشفى الرازي', 'مستشفى الأهلي',
      'مستشفى فلسطين', 'مستشفى الفارابي', 'مستشفى الحكمة',
      'مستشفى السلام', 'مستشفى القدس', 'مستشفى ابن سينا',
      'مستشفى الأقصى', 'مستشفى النور', 'مستشفى الهدى',
      'مستشفى الفيحاء', 'مستشفى الرحمة', 'مستشفى طيبة',
      'مستشفى الجزيرة', 'مستشفى الهلال', 'مستشفى الزهراء',
      'مستشفى الأندلس', 'مستشفى الإخلاص', 'مستشفى الوفاء',
      'مستشفى الصادق', 'مستشفى اليمامة', 'مستشفى البراء',
      'مستشفى الإسراء', 'مستشفى العباس', 'مستشفى الزيتون',
      'مستشفى دار الشفاء', 'مستشفى البشير', 'مستشفى القاسمي',
      'مستشفى الفردوس', 'مستشفى الوحدة', 'مستشفى الأقصى الجديد',
      'مستشفى النهضة', 'مستشفى الإسراء التخصصي', 'مستشفى السلامة',
      'مستشفى العروبة', 'مستشفى جيبلا', 'مستشفى الأطباء',
      'مستشفى اليمن الدولي', 'مستشفى العاصمة', 'مستشفى التقوى',
      'مستشفى الشفاء', 'مستشفى الأمان', 'مستشفى البناء',
      'مستشفى النجاح', 'مستشفى التقدم', 'مستشفى الأمل الجديد',
      'مستشفى الحياة الجديد', 'مستشفى السلام الجديد', 'مستشفى النصر',
      'مستشفى الفتح', 'مستشفى الأصالة', 'مستشفى الريان',
      'مستشفى المنار', 'مستشفى الوفاء الجديد', 'مستشفى العطاء',
      'مستشفى الشروق', 'مستشفى السعادة', 'مستشفى البشائر',
      'مستشفى الكرامة', 'مستشفى الأمل الكبير', 'مستشفى الصحة الجديد',
      'مستشفى الحياة الكبير', 'مستشفى التضامن', 'مستشفى الازدهار',
      'مستشفى الأنوار', 'مستشفى النهضة الجديد', 'مستشفى العافية',
      'مستشفى البركة', 'مستشفى النجاح الجديد', 'مستشفى الإخلاص الجديد',
      'مستشفى الوفاء الكبير', 'مستشفى العطاء الجديد', 'مستشفى الشروق الجديد',
      'مستشفى السعادة الجديد', 'مستشفى البشائر الجديد', 'مستشفى الكرامة الجديد',
      'مستشفى الأمل الكبير الجديد', 'مستشفى الصحة المتقدم', 'مستشفى الحياة المتقدم',
      'مستشفى التضامن الجديد', 'مستشفى الازدهار الجديد', 'مستشفى الأنوار الجديد',
      'مستشفى النهضة المتقدم', 'مستشفى العافية الجديد', 'مستشفى البركة الجديد',
      'مستشفى النجاح المتقدم', 'مستشفى الإخلاص المتقدم', 'مستشفى الوفاء المتقدم',
      'مستشفى العطاء المتقدم', 'مستشفى الشروق المتقدم', 'مستشفى السعادة المتقدم',
    ];
    final addresses = [
      'شارع الزبيري، باب اليمن', 'شارع الزبيري، ميدان التحرير', 'شارع الخمسين، الحصبة',
      'شارع القاهرة، التحرير', 'شارع هائل، التحرير', 'شارع الستين، أمام الخطوط الجوية',
      'شارع العدين، شارع الستين', 'شارع الخمسين، تقاطع هائل', 'شارع الزبيري، بجانب البنك المركزي',
      'شارع هائل، جولة كنتاكي', 'شارع التحرير، عمارة الكبوس', 'شارع الستين، مجمع النخبة',
      'شارع باب اليمن، وسط المدينة', 'شارع الخمسين، حي الأندلس', 'شارع القاهرة، بجانب السفارة',
    ];
    final phones = ['01-222222', '01-999444', '01-333333', '01-777777', '01-555555', '01-111222'];
    final types = ['حكومي', 'خاص', 'جامعي', 'عسكري', 'تخصصي'];

    return {
      'name': names[index % names.length],
      'address': addresses[index % addresses.length],
      'lat': 15.3100 + (index % 10) * 0.008,
      'lng': 44.1700 + (index % 8) * 0.008,
      'phone': phones[index % phones.length],
      'type': types[index % types.length],
      'beds': '${200 + (index % 5) * 50}',
      'emergency': index % 3 != 0,
      'image': '🏥',
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // ============================================================
  // 💊 100+ صيدلية
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
    ];
    final addresses = [
      'شارع الزبيري، أمام مستشفى الثورة', 'شارع التحرير، بجانب البنك المركزي',
      'شارع هائل، أمام جامعة صنعاء', 'شارع الستين، الحصبة',
      'شارع القاهرة، باب اليمن', 'شارع الأربعين، شارع الستين',
      'شارع الزبيري، عمارة النعمان', 'شارع هائل، جولة كنتاكي',
      'شارع التحرير، عمارة البساطي', 'شارع الستين، أمام المستشفى العسكري',
    ];

    return {
      'name': names[index % names.length],
      'address': addresses[index % addresses.length],
      'lat': 15.3200 + (index % 10) * 0.008,
      'lng': 44.1750 + (index % 8) * 0.008,
      'phone': '01-${(100000 + index * 1234) % 999999}',
      'hours': index % 4 == 0 ? '24 ساعة' : '8 ص - ${(index % 4) + 10} م',
      'image': '💊',
      'delivery': index % 3 == 0,
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // ============================================================
  // 🔬 100+ مختبر
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
    ];
    final addresses = [
      'شارع الستين، أمام المستشفى العسكري', 'شارع الزبيري، عمارة النعمان',
      'شارع هائل، جولة كنتاكي', 'شارع التحرير، عمارة البساطي',
      'شارع الخمسين، الحصبة', 'شارع الزبيري، بجانب برج زبيدة',
      'شارع هائل، أمام جامعة صنعاء', 'شارع الستين، مجمع النخبة',
    ];

    return {
      'name': names[index % names.length],
      'address': addresses[index % addresses.length],
      'lat': 15.3300 + (index % 10) * 0.008,
      'lng': 44.1800 + (index % 8) * 0.008,
      'phone': '01-${(200000 + index * 1234) % 999999}',
      'tests': ['650+', '520+', '480+', '350+', '420+', '380+'][index % 6],
      'image': index % 2 == 0 ? '🔬' : '🧪',
      'accredited': index % 3 != 0,
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // ============================================================
  // 🏨 100+ مرفق صحي
  // ============================================================
  final List<Map<String, dynamic>> _facilities = List.generate(105, (index) {
    final names = [
      'مركز صحي التحرير', 'مركز صحي باب اليمن', 'مركز صحي الحصبة',
      'مركز صحي الروضة', 'مركز صحي السبعين', 'مركز صحي حدة',
      'مركز صحي معين', 'مركز صحي حزيز', 'مركز صحي ظهرة',
      'مركز صحي نهم', 'مركز صحي جبل النصر', 'مركز صحي شعب',
      'مركز صحي حدة الجديد', 'مركز صحي ضلاع', 'مركز صحي بني الحارث',
      'مركز صحي سنحان', 'مركز صحي بيت بوس', 'مركز صحي ربعي',
    ];
    final types = ['مركز صحي', 'عيادة خاصة', 'مركز تخصصي', 'مركز أسنان', 'مركز عيون'];
    final services = [
      'عيادات عامة، أسنان، أطفال',
      'عيادات عامة، طوارئ، نساء وولادة',
      'عيادات عامة، تطعيمات، صحة نفسية',
    ];

    return {
      'name': names[index % names.length],
      'address': 'صنعاء، حي ${['التحرير', 'باب اليمن', 'الحصبة', 'الروضة', 'السبعين'][index % 5]}',
      'lat': 15.3100 + (index % 10) * 0.008,
      'lng': 44.1700 + (index % 8) * 0.008,
      'phone': '01-${(300000 + index * 1234) % 999999}',
      'type': types[index % types.length],
      'services': services[index % services.length],
      'image': '🏨',
      'rating': (4.0 + (index % 10) * 0.1).toStringAsFixed(1),
    };
  });

  // ✅ ============================================================
  // ✅ GETTERS (المفقودة التي تسبب الخطأ)
  // ✅ ============================================================
  List<Map<String, dynamic>> get _currentLocations {
    switch (widget.type) {
      case 'hospitals':
        return _hospitals;
      case 'pharmacies':
        return _pharmacies;
      case 'labs':
        return _labs;
      case 'facilities':
        return _facilities;
      case 'all':
        return [..._hospitals, ..._pharmacies, ..._labs, ..._facilities];
      default:
        return _hospitals;
    }
  }

  String get _title {
    final count = _currentLocations.length;
    switch (widget.type) {
      case 'hospitals':
        return 'المستشفيات ($count)';
      case 'pharmacies':
        return 'الصيدليات ($count)';
      case 'labs':
        return 'المختبرات ($count)';
      case 'facilities':
        return 'المرافق الصحية ($count)';
      case 'all':
        return 'جميع المنشآت ($count)';
      default:
        return 'الخريطة ($count)';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case 'hospitals':
        return Icons.local_hospital;
      case 'pharmacies':
        return Icons.local_pharmacy;
      case 'labs':
        return Icons.science;
      case 'facilities':
        return Icons.health_and_safety;
      case 'all':
        return Icons.map;
      default:
        return Icons.map;
    }
  }

  Color _getMarkerColor() {
    switch (widget.type) {
      case 'hospitals':
        return AppColors.error;
      case 'pharmacies':
        return AppColors.success;
      case 'labs':
        return AppColors.info;
      case 'facilities':
        return Colors.orange;
      case 'all':
        return AppColors.primary;
      default:
        return AppColors.primary;
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
                        Text(loc['rating'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                    const Expanded(
                        child: Text('طوارئ 24 ساعة',
                            style: TextStyle(fontSize: 12, color: Colors.red))),
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
                    const Expanded(
                        child: Text('توصيل متاح',
                            style: TextStyle(fontSize: 12, color: AppColors.success))),
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
                    const Expanded(
                        child: Text('معتمد', style: TextStyle(fontSize: 12, color: AppColors.info))),
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
                    Expanded(
                        child: Text('${loc['tests']} فحص متاح',
                            style: const TextStyle(fontSize: 12))),
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
                    if (_selectedLayer == k)
                      const Icon(Icons.check, color: AppColors.primary, size: 16),
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
