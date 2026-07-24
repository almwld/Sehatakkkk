import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderId;
  const OrderTrackingScreen({super.key, this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  int _currentStep = 2;
  bool _isLiveTracking = true;
  late final MapController _mapController;

  LatLng _driverLocation = const LatLng(15.3694, 44.1910);
  LatLng _destination = const LatLng(15.3550, 44.2000);

  final List<LatLng> _routePoints = [
    const LatLng(15.3694, 44.1910),
    const LatLng(15.3680, 44.1930),
    const LatLng(15.3660, 44.1950),
    const LatLng(15.3630, 44.1960),
    const LatLng(15.3600, 44.1980),
    const LatLng(15.3570, 44.1990),
    const LatLng(15.3550, 44.2000),
  ];

  final List<Map<String, dynamic>> _steps = [
    {'label': 'تم تأكيد الطلب', 'icon': Icons.check_circle, 'time': '10:30 ص', 'completed': true},
    {'label': 'تم التجهيز', 'icon': Icons.pending, 'time': '10:45 ص', 'completed': true},
    {'label': 'في الطريق إليك', 'icon': Icons.local_shipping, 'time': '11:00 ص', 'completed': false},
    {'label': 'تم التوصيل', 'icon': Icons.home, 'time': 'جاري...', 'completed': false},
  ];

  final Map<String, dynamic> _driver = {
    'name': 'أحمد علي',
    'phone': '777888999',
    'rating': 4.9,
    'reviews': 328,
    'vehicle': 'سيارة - صنعاء 1234',
    'status': 'في الطريق',
    'image': 'https://ui-avatars.com/api/?name=أحمد+علي&background=0D5257&color=fff',
    'eta': '8 دقائق',
  };

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _startLiveTracking();
  }

  void _startLiveTracking() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _driverLocation = const LatLng(15.3650, 44.1940);
          _currentStep = 2;
        });
      }
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _driverLocation = const LatLng(15.3600, 44.1970);
        });
      }
    });
    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _driverLocation = const LatLng(15.3560, 44.1990);
        });
      }
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ✅ AppBar مخصص
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تتبع الطلب',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'رقم الطلب: ${widget.orderId ?? "#SHK-${DateTime.now().millisecondsSinceEpoch}"}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'مباشر',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ✅ الخريطة
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _driverLocation,
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sehatak.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _driverLocation,
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        Marker(
                          point: _destination,
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.4),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          color: primaryColor.withOpacity(0.6),
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                  ],
                ),
                // ✅ الوقت المتبقي
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'الوقت المتوقع للتوصيل',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.grey : Colors.grey,
                                ),
                              ),
                              Text(
                                '${_driver['eta']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('تحديث'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ✅ معلومات السائق والمراحل
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // ✅ معلومات السائق
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        backgroundImage: NetworkImage(_driver['image']),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _driver['name'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _driver['status'],
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 12),
                                const SizedBox(width: 2),
                                Text(
                                  _driver['rating'].toString(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${_driver['reviews']} تقييم)',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.grey : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.directions_car, size: 12, color: isDark ? Colors.grey : Colors.grey),
                                const SizedBox(width: 2),
                                Text(
                                  _driver['vehicle'],
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: isDark ? Colors.grey : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.call, color: Colors.green),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(Icons.message, color: primaryColor),
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // ✅ مراحل التتبع
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _steps.length,
                      itemBuilder: (context, index) {
                        final step = _steps[index];
                        final isCompleted = step['completed'] as bool;
                        final isActive = index == _currentStep;
                        final isLast = index == _steps.length - 1;

                        return Row(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green
                                        : (isActive ? primaryColor : Colors.grey.withOpacity(0.2)),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCompleted ? Icons.check : step['icon'] as IconData,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  step['label'] as String,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: isCompleted || isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isCompleted || isActive
                                        ? (isDark ? Colors.white : Colors.black87)
                                        : (isDark ? Colors.grey : Colors.grey),
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            if (!isLast)
                              Container(
                                width: 30,
                                height: 2,
                                color: isCompleted
                                    ? Colors.green
                                    : (isActive ? primaryColor : Colors.grey.withOpacity(0.2)),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
