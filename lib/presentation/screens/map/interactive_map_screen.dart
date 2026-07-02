
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:latlong2/latlong.dart";
import "package:geolocator/geolocator.dart";
import "package:url_launcher/url_launcher.dart";
import "../../../core/constants/app_colors.dart";

class InteractiveMapScreen extends StatefulWidget {
  final String type;
  final String? orderId;
  const InteractiveMapScreen({super.key, this.type = "hospitals", this.orderId});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  late final MapController _mapController;
  static const LatLng sanaaCenter = LatLng(15.3694, 44.1910);
  String _selectedLayer = "خريطة ملونة";
  Position? _currentPosition;
  LatLng? _selectedLocation;
  int _currentStep = 2;
  String _searchQuery = "";
  String _filterType = "الكل";

  final Map<String, Map<String, String>> _mapLayers = {
    "خريطة ملونة": {"url": "https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png", "desc": "خرائط ملونة مع أسماء"},
    "خريطة فاتحة": {"url": "https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png", "desc": "خرائط فاتحة للتفاصيل"},
    "خريطة داكنة": {"url": "https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png", "desc": "خرائط داكنة للمساء"},
  };

  final List<Map<String, dynamic>> _hospitals = [
    {"name": "مستشفى الثورة العام", "address": "شارع الزبيري، باب اليمن", "lat": 15.3500, "lng": 44.2000, "phone": "01-222222", "type": "حكومي", "beds": "500", "emergency": true, "image": "🏥"},
    {"name": "المستشفى الجمهوري", "address": "شارع الزبيري، ميدان التحرير", "lat": 15.3530, "lng": 44.2010, "phone": "01-999444", "type": "حكومي", "beds": "450", "emergency": true, "image": "🏥"},
    {"name": "مستشفى الكويت الجامعي", "address": "شارع الخمسين، الحصبة", "lat": 15.3800, "lng": 44.2100, "phone": "01-333333", "type": "جامعي", "beds": "400", "emergency": true, "image": "🏥"},
    {"name": "مستشفى السبعين", "address": "السبعين، شارع الأربعين", "lat": 15.3100, "lng": 44.1800, "phone": "01-444444", "type": "تخصصي", "beds": "300", "emergency": true, "image": "🏥"},
  ];

  final List<Map<String, dynamic>> _pharmacies = [
    {"name": "صيدلية الشفاء", "address": "شارع الزبيري، أمام مستشفى الثورة", "lat": 15.3510, "lng": 44.1990, "phone": "01-123456", "hours": "24 ساعة", "image": "💊", "delivery": true},
    {"name": "صيدلية اليمن", "address": "شارع التحرير، بجانب البنك المركزي", "lat": 15.3580, "lng": 44.1930, "phone": "01-234567", "hours": "8 ص - 12 م", "image": "💊", "delivery": true},
  ];

  final List<Map<String, dynamic>> _labs = [
    {"name": "المختبر الوطني", "address": "شارع الستين، أمام المستشفى العسكري", "lat": 15.3540, "lng": 44.2030, "phone": "01-012345", "tests": "650+", "image": "🔬", "accredited": true},
    {"name": "مختبر الثقة", "address": "شارع الزبيري، عمارة النعمان", "lat": 15.3520, "lng": 44.1980, "phone": "01-123456", "tests": "520+", "image": "🔬", "accredited": true},
  ];

  List<Map<String, dynamic>> get _currentLocations {
    switch (widget.type) {
      case "hospitals": return _hospitals;
      case "pharmacies": return _pharmacies;
      case "labs": return _labs;
      case "tracking": return _hospitals;
      default: return _hospitals;
    }
  }

  String get _title {
    final count = _currentLocations.length;
    switch (widget.type) {
      case "hospitals": return "المستشفيات ($count)";
      case "pharmacies": return "الصيدليات ($count)";
      case "labs": return "المختبرات ($count)";
      case "tracking": return "تتبع الطلب";
      default: return "الخريطة ($count)";
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case "hospitals": return Icons.local_hospital;
      case "pharmacies": return Icons.local_pharmacy;
      case "labs": return Icons.science;
      case "tracking": return Icons.local_shipping;
      default: return Icons.map;
    }
  }

  Color _getMarkerColor() {
    switch (widget.type) {
      case "hospitals": return AppColors.error;
      case "pharmacies": return AppColors.success;
      case "labs": return AppColors.info;
      case "tracking": return AppColors.primary;
      default: return AppColors.primary;
    }
  }

  List<Map<String, dynamic>> get _filteredLocations {
    if (_searchQuery.isEmpty && _filterType == "الكل") return _currentLocations;
    return _currentLocations.where((loc) {
      final nameMatch = loc["name"].toString().contains(_searchQuery) ||
                         loc["address"].toString().contains(_searchQuery);
      final typeMatch = _filterType == "الكل" ||
                        loc["type"] == _filterType;
      return nameMatch && typeMatch;
    }).toList();
  }

  List<String> get _filterOptions {
    final types = <String>{"الكل"};
    for (var loc in _currentLocations) {
      if (loc["type"] != null) types.add(loc["type"].toString());
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
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
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
                Text(loc["image"] ?? "🏥", style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    loc["name"],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (loc["address"] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(loc["address"], style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            if (loc["phone"] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: AppColors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(loc["phone"], style: const TextStyle(fontSize: 12))),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse("tel:${loc["phone"]}");
                      if (await canLaunchUrl(url)) launchUrl(url);
                    },
                    icon: const Icon(Icons.call, size: 16),
                    label: const Text("اتصال"),
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
                      final lat = loc["lat"] as double;
                      final lng = loc["lng"] as double;
                      final url = Uri.parse(
                        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
                      );
                      launchUrl(url);
                    },
                    icon: const Icon(Icons.navigation, size: 16),
                    label: const Text("توجيه"),
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
    final layerKey = isDark ? "خريطة داكنة" : _selectedLayer;
    final layerUrl = _mapLayers[layerKey]!["url"]!;
    final locations = _filteredLocations;
    final color = _getMarkerColor();

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (widget.type != "tracking")
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
                userAgentPackageName: "com.sehatak.app",
              ),
              MarkerLayer(
                markers: locations.map((loc) {
                  final lat = loc["lat"] as double;
                  final lng = loc["lng"] as double;
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
                          color: color,
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
          if (widget.type != "tracking")
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
                    hintText: "🔍 ابحث عن منشأة صحية...",
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ""),
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
                  heroTag: "z_in",
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
                  heroTag: "z_out",
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
              heroTag: "my_loc",
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
          if (widget.type == "tracking")
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

  Widget _buildLocationsList() {
    final locations = _filteredLocations;
    final color = _getMarkerColor();

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
                  "${locations.length} منشأة",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const Spacer(),
                if (locations.length > 5)
                  Text(
                    "اسحب للمزيد →",
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
                final isSelected = _selectedLocation?.latitude == loc["lat"] &&
                                   _selectedLocation?.longitude == loc["lng"];
                return GestureDetector(
                  onTap: () {
                    _goToLocation(loc["lat"], loc["lng"]);
                    _showLocationDetails(loc);
                  },
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 6, bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc["image"] ?? "🏥",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc["name"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          loc["address"],
                          style: const TextStyle(fontSize: 8, color: AppColors.grey),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (loc["phone"] != null)
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 9, color: AppColors.success),
                              const SizedBox(width: 2),
                              Text(
                                loc["phone"],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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
                  color: AppColors.primary.withOpacity(0.1),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      "رقم الطلب: ${widget.orderId ?? "#SHK-784512"}",
                      style: const TextStyle(fontSize: 9, color: AppColors.grey),
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
                        color: i < _currentStep ? AppColors.success : AppColors.grey,
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
                          color: i < _currentStep - 1 ? AppColors.success : AppColors.grey,
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
                    color: i < _currentStep ? AppColors.success : AppColors.grey,
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
              color: AppColors.success.withOpacity(0.06),
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

