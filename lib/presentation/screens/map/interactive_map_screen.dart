import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

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

  static const LatLng sanaaCenter = LatLng(15.3694, 44.1910);
  String _selectedLayer = 'خريطة الشوارع';
  Position? _currentPosition;
  LatLng? _selectedLocation;
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  List<Map<String, dynamic>> _firestorePlaces = const [];
  bool _loadingFirestorePlaces = false;

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

  // 🏥 المستشفيات (100)
    // لا توجد بيانات ثابتة: جميع المنشآت الصحية تأتي من Firestore (map_facilities).
  // هذا يمنع عرض منشآت وهمية أو إحداثيات تجريبية على الخريطة.
  final List<Map<String, dynamic>> _hospitals = const [];
  final List<Map<String, dynamic>> _pharmacies = const [];
  final List<Map<String, dynamic>> _labs = const [];
  final List<Map<String, dynamic>> _clinics = const [];
  final List<Map<String, dynamic>> _other = const [];

  // دمج جميع الأماكن
  List<Map<String, dynamic>> get _allPlaces {
    return [
      ..._firestorePlaces,
      ..._hospitals,
      ..._pharmacies,
      ..._labs,
      ..._clinics,
      ..._other,
    ];
  }

  // دالة البحث والتصفية
  List<Map<String, dynamic>> _getFilteredPlaces() {
    final places = _allPlaces;
    
    if (_selectedCategory == 'الكل' && _searchQuery.isEmpty) {
      return places;
    }
    
    return places.where((place) {
      if (_selectedCategory != 'الكل') {
        final categoryMap = {
          'مستشفيات': 'hospitals',
          'صيدليات': 'pharmacies',
          'مختبرات': 'labs',
          'عيادات': 'clinics',
          'أخرى': 'other',
        };
        final targetCategory = categoryMap[_selectedCategory];
        if (targetCategory != null &&
            _normalizeCategory(place['category']) != targetCategory) {
          return false;
        }
      }
      
      if (_searchQuery.isNotEmpty) {
        final name = (place['name'] ?? '').toString().toLowerCase();
        final address = (place['address'] ?? '').toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        if (!name.contains(query) && !address.contains(query)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  // 🎨 الحصول على مسار الأيقونة حسب الفئة
  String _getIconPath(String category) {
    switch (category) {
      case 'hospitals':
        return 'assets/icons/map_pins/hospital.svg';
      case 'pharmacies':
        return 'assets/icons/map_pins/pharmacy.svg';
      case 'labs':
        return 'assets/icons/map_pins/laboratory.svg';
      case 'clinics':
        return 'assets/icons/map_pins/clinic.svg';
      case 'other':
        return 'assets/icons/map_pins/medical.svg';
      default:
        return 'assets/icons/map_pins/medical.svg';
    }
  }

  // 🎨 أيقونة SVG لعرض التفاصيل
  Widget _getCategoryIconWidget(String category, {double size = 24}) {
    return SvgPicture.asset(
      _getIconPath(category),
      width: size,
      height: size,
      fit: BoxFit.contain,
      colorFilter: const ColorFilter.mode(
        AppColors.primary,
        BlendMode.srcIn,
      ),
      placeholderBuilder: (context) => SizedBox(
        width: size,
        height: size,
      ),
    );
  }

  Widget _buildMapLocationIcon({double size = 34}) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/icons/settings/select_location.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  // 🏷️ الحصول على اسم الفئة بالعربية
  String _normalizeCategory(dynamic raw) {
    final value = raw?.toString().trim().toLowerCase() ?? '';
    switch (value) {
      case 'hospital':
      case 'hospitals':
      case 'مستشفى':
      case 'مستشفيات':
        return 'hospitals';
      case 'pharmacy':
      case 'pharmacies':
      case 'pharmacist':
      case 'صيدلية':
      case 'صيدليات':
        return 'pharmacies';
      case 'lab':
      case 'labs':
      case 'laboratory':
      case 'laboratories':
      case 'مختبر':
      case 'مختبرات':
        return 'labs';
      case 'clinic':
      case 'clinics':
      case 'doctor':
      case 'dentist':
      case 'eye':
      case 'عيادة':
      case 'عيادات':
        return 'clinics';
      default:
        return 'other';
    }
  }

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

  // 🎨 بناء العلامات (Markers) مع Clustering
  List<Marker> _buildMarkers() {
    final filtered = _getFilteredPlaces();

    return filtered.map((place) {
      final category = place['category'] as String? ?? 'other';
      final lat = (place['lat'] as num).toDouble();
      final lng = (place['lng'] as num).toDouble();
      final isSelected = _selectedLocation != null &&
          _selectedLocation!.latitude == lat &&
          _selectedLocation!.longitude == lng;

      return Marker(
        point: LatLng(lat, lng),
        width: isSelected ? 68 : 58,
        height: isSelected ? 86 : 74,
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showPlaceDetails(place),
          child: AnimatedScale(
            scale: isSelected ? 1.10 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: SizedBox(
              width: isSelected ? 64 : 54,
              height: isSelected ? 82 : 70,
              child: (place['isFirestore'] == true)
                  ? _buildMapLocationIcon(size: isSelected ? 52 : 44)
                  : SvgPicture.asset(
                      _getIconPath(category),
                      fit: BoxFit.contain,
                      alignment: Alignment.bottomCenter,
                      placeholderBuilder: (context) => Center(
                        child: _buildMapLocationIcon(
                          size: isSelected ? 34 : 28,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      );
    }).toList(growable: false);
  }

  // 📋 عرض تفاصيل المكان
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
                  child: Image.asset('assets/icons/settings/select_location.png', width: 28, height: 28, fit: BoxFit.contain),
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
                          Image.asset(
                            AppAssets.selectLocation,
                            width: 16,
                            height: 16,
                            fit: BoxFit.contain,
                          ),
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
                      if (place['rating'] is num)
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
                  Image.asset('assets/icons/settings/select_location.png', width: 16, height: 16, fit: BoxFit.contain),
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
                  Image.asset('assets/icons/settings/select_location.png', width: 16, height: 16, fit: BoxFit.contain),
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
                      final origin = _currentPosition != null
                          ? '${_currentPosition!.latitude},${_currentPosition!.longitude}'
                          : (_selectedLocation != null
                              ? '${_selectedLocation!.latitude},${_selectedLocation!.longitude}'
                              : '');
                      final destination = '${place['lat']},${place['lng']}';
                      final url = origin.isEmpty
                          ? 'https://www.google.com/maps/search/?api=1&query=$destination'
                          : 'https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination';
                      _launchUrl(url);
                    },
                    icon: Image.asset('assets/icons/settings/select_location.png', width: 20, height: 20),
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
                    icon: Image.asset('assets/icons/settings/select_location.png', width: 20, height: 20),
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

  Future<void> _loadFirestoreMapData() async {
    if (_loadingFirestorePlaces) return;
    _loadingFirestorePlaces = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('map_facilities')
          .where('isPublished', isEqualTo: true)
          .limit(300)
          .get();

      final places = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final location = data['location'];
        final lat = data['lat'];
        final lng = data['lng'];
        double? latitude;
        double? longitude;
        if (location is GeoPoint) {
          latitude = location.latitude;
          longitude = location.longitude;
        } else if (lat is num && lng is num) {
          latitude = lat.toDouble();
          longitude = lng.toDouble();
        }
        if (latitude == null || longitude == null) continue;

        places.add({
          'id': doc.id,
          'name': (data['name'] ?? 'مرفق صحي').toString(),
          'address': (data['address'] ?? data['area'] ?? 'الموقع المحفوظ').toString(),
          'phone': (data['phone'] ?? '').toString(),
          'role': (data['role'] ?? '').toString(),
          'category': _normalizeCategory(data['category'] ?? data['role']),
          'lat': latitude,
          'lng': longitude,
          'rating': data['rating'] is num ? (data['rating'] as num).toDouble() : null,
          'isFirestore': true,
        });
      }

      if (mounted) setState(() => _firestorePlaces = places);
    } catch (e) {
      debugPrint('Map Firestore facilities load skipped: $e');
    } finally {
      _loadingFirestorePlaces = false;
    }
  }

  Future<void> _loadSavedUserLocation() async {
    LatLng? point;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('delivery_latitude');
      final lng = prefs.getDouble('delivery_longitude');
      if (lat != null && lng != null) point = LatLng(lat, lng);
    } catch (_) {}

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = snapshot.data();
        final location = data?['location'];
        if (location is GeoPoint) {
          point = LatLng(location.latitude, location.longitude);
        }
      } catch (e) {
        debugPrint('Map user location load skipped: $e');
      }
    }

    if (!mounted || point == null) return;
    setState(() => _selectedLocation = point);
    _mapController.move(point, 15);
  }

  // 🌐 فتح الرابط
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 📍 الحصول على الموقع الحالي
  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        await _loadSavedUserLocation();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        14,
      );
    } catch (e) {
      debugPrint('Map current location error: $e');
      await _loadSavedUserLocation();
    }
  }

  // 🎨 اختيار طبقة الخريطة
  void _selectLayer(String layerName) {
    setState(() {
      _selectedLayer = layerName;
    });
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _loadFirestoreMapData();
    _loadSavedUserLocation();
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
        title: const Text('الخريطة الصحية'),
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: UnifiedSearchBar(controller: _searchController, onChanged: (value) {
                setState(() => _searchQuery = value);
              }, hintText: 'ابحث عن مستشفى، صيدلية، مختبر، عيادة...'),
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
          
          // 🗺️ الخريطة الصحية — عرض كامل للمساحة المتاحة أسفل أدوات البحث
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition != null
                            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                            : sanaaCenter,
                        initialZoom: 14,
                        minZoom: 8,
                        maxZoom: 19,
                        onTap: (_, __) {
                          setState(() => _selectedLocation = null);
                        },
                      ),
                      children: [
                        // نفس طبقة الشوارع المفتوحة المستخدمة في «حدد موقعك»
                        TileLayer(
                          urlTemplate: _mapLayers[_selectedLayer]!['url']!,
                          userAgentPackageName: 'com.sehatak.app',
                          maxNativeZoom: 19,
                        ),
                        // الاحتفاظ بكل منشآت الخريطة الحالية وClustering.
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
                                width: 58,
                                height: 70,
                                point: _selectedLocation!,
                                alignment: Alignment.bottomCenter,
                                child: _buildMapLocationIcon(size: 58),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // نفس أدوات تحديد الموقع، مع الإبقاء على بيانات الخريطة الصحية.
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: isDark ? const Color(0xFF1A2540) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        elevation: 2,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'تكبير الخريطة',
                              onPressed: () {
                                final zoom = _mapController.camera.zoom;
                                _mapController.move(_mapController.camera.center, (zoom + 1).clamp(8, 19));
                              },
                              icon: const Icon(Icons.add, color: AppColors.primary),
                            ),
                            IconButton(
                              tooltip: 'تصغير الخريطة',
                              onPressed: () {
                                final zoom = _mapController.camera.zoom;
                                _mapController.move(_mapController.camera.center, (zoom - 1).clamp(8, 19));
                              },
                              icon: const Icon(Icons.remove, color: AppColors.primary),
                            ),
                            IconButton(
                              tooltip: 'موقعي الحالي',
                              onPressed: _getCurrentLocation,
                              icon: const Icon(Icons.my_location, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      left: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black87 : Colors.white.withOpacity(.94),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Text(
                            'بيانات المنشآت من صحتك • الخرائط من OpenStreetMap',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
