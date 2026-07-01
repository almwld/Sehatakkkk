import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class InteractiveMapScreen extends StatefulWidget {
  final String? type;
  const InteractiveMapScreen({super.key, this.type});

  @override
  State<InteractiveMapScreen> createState() => _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends State<InteractiveMapScreen> {
  String _selectedType = 'الكل';
  LatLng _center = const LatLng(15.3694, 44.1910); // صنعاء

  // ✅ 10 مستشفيات وعيادات في صنعاء
  final List<Map<String, dynamic>> _locations = [
    {
      'id': 'hospital_thawra',
      'name': 'مستشفى الثورة العام',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-201111',
      'lat': 15.3694,
      'lng': 44.1910,
      'rating': 4.7,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_motahidun',
      'name': 'مستشفى المتحدون التخصصي',
      'type': 'مستشفى',
      'address': 'شارع تعز، صنعاء',
      'phone': '01-444444',
      'lat': 15.3594,
      'lng': 44.2010,
      'rating': 4.9,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_children',
      'name': 'مستشفى الأطفال التخصصي',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-333333',
      'lat': 15.3794,
      'lng': 44.1810,
      'rating': 4.8,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_heart',
      'name': 'مستشفى القلب التخصصي',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-555555',
      'lat': 15.3594,
      'lng': 44.2110,
      'rating': 4.8,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_maternity',
      'name': 'مستشفى الولادة والأمومة',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-666666',
      'lat': 15.3894,
      'lng': 44.1910,
      'rating': 4.7,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_neurology',
      'name': 'مستشفى الأعصاب التخصصي',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-777777',
      'lat': 15.3494,
      'lng': 44.2010,
      'rating': 4.6,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_ent',
      'name': 'مستشفى الأنف والأذن والحنجرة',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-888888',
      'lat': 15.3694,
      'lng': 44.1710,
      'rating': 4.5,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
    {
      'id': 'hospital_zad',
      'name': 'مركز زاد الطبي',
      'type': 'مركز طبي',
      'address': 'صنعاء',
      'phone': '01-999999',
      'lat': 15.3794,
      'lng': 44.2010,
      'rating': 4.6,
      'icon': Icons.medical_services,
      'color': AppColors.teal,
    },
    {
      'id': 'hospital_barashi',
      'name': 'مركز البراشي للجلدية والتجميل',
      'type': 'مركز طبي',
      'address': 'صنعاء',
      'phone': '01-111222',
      'lat': 15.3594,
      'lng': 44.1810,
      'rating': 4.8,
      'icon': Icons.medical_services,
      'color': AppColors.teal,
    },
    {
      'id': 'hospital_alaghbari',
      'name': 'مستشفى الاغبري التخصصي',
      'type': 'مستشفى',
      'address': 'صنعاء',
      'phone': '01-222333',
      'lat': 15.3894,
      'lng': 44.2010,
      'rating': 4.7,
      'icon': Icons.local_hospital,
      'color': AppColors.primary,
    },
  ];

  List<Map<String, dynamic>> get _filteredLocations {
    if (_selectedType == 'الكل') return _locations;
    return _locations.where((loc) => loc['type'] == _selectedType).toList();
  }

  final List<String> _types = ['الكل', 'مستشفى', 'مركز طبي'];

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLocations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text('المرافق الصحية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () {
              // ✅ تحديد الموقع الحالي
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ..._types.map((type) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedType = type),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _selectedType == type
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedType == type
                              ? AppColors.primary
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ✅ الخريطة
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _center,
                initialZoom: 13.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.sehatak.app',
                ),
                MarkerLayer(
                  markers: filtered.map((location) {
                    return Marker(
                      width: 40,
                      height: 40,
                      point: LatLng(location['lat'], location['lng']),
                      child: GestureDetector(
                        onTap: () {
                          _showLocationDetails(context, location);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            location['icon'],
                            color: location['color'],
                            size: 24,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // ✅ قائمة المواقع
          Expanded(
            flex: 1,
            child: Container(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final location = filtered[index];
                  return _buildLocationCard(context, location);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Map<String, dynamic> location) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = location['color'] as Color;

    return GestureDetector(
      onTap: () {
        _showLocationDetails(context, location);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF2D3A54) : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                location['icon'],
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location['address'],
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    location['type'],
                    style: TextStyle(
                      fontSize: 9,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppColors.amber,
                    ),
                    Text(
                      ' ${location['rating']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDetails(BuildContext context, Map<String, dynamic> location) {
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
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: location['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    location['icon'],
                    color: location['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        location['type'],
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _detailRow(Icons.location_on_rounded, location['address']),
            _detailRow(Icons.phone_rounded, location['phone']),
            _detailRow(Icons.star_rounded, '${location['rating']} / 5.0'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.directions_rounded),
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
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
