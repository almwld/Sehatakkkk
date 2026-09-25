import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  static const _areaKey = 'delivery_area';
  static const _addressKey = 'delivery_address';
  static const _latKey = 'delivery_latitude';
  static const _lngKey = 'delivery_longitude';

  static const _areas = <String>[
    'صنعاء', 'عدن', 'تعز', 'الحديدة', 'إب', 'حضرموت', 'ذمار', 'عمران',
    'حجة', 'المحويت', 'ريمة', 'البيضاء', 'مأرب', 'شبوة', 'أبين', 'لحج',
    'الضالع', 'صعدة', 'الجوف', 'المهرة', 'سقطرى',
  ];

  static const _sanaaCenter = LatLng(15.3694, 44.1910);

  final TextEditingController _addressController = TextEditingController();
  final MapController _mapController = MapController();

  String? _selectedArea;
  LatLng? _selectedLocation;
  bool _loading = true;
  bool _locating = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_latKey);
      final lng = prefs.getDouble(_lngKey);
      if (!mounted) return;
      setState(() {
        _selectedArea = prefs.getString(_areaKey);
        _addressController.text = prefs.getString(_addressKey) ?? '';
        if (lat != null && lng != null) _selectedLocation = LatLng(lat, lng);
        _loading = false;
      });
      if (_selectedLocation != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _mapController.move(_selectedLocation!, 16);
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _useGps() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        ToastService.showError('فعّل خدمة الموقع (GPS) في الهاتف ثم حاول مرة أخرى');
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        ToastService.showError('تم رفض إذن الموقع');
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        ToastService.showError('إذن الموقع مرفوض نهائياً. فعّله من إعدادات الهاتف');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _selectedLocation = point);
      _mapController.move(point, 17);

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[
            if ((p.street ?? '').trim().isNotEmpty) p.street!.trim(),
            if ((p.subLocality ?? '').trim().isNotEmpty) p.subLocality!.trim(),
            if ((p.locality ?? '').trim().isNotEmpty) p.locality!.trim(),
          ];
          if (parts.isNotEmpty) _addressController.text = parts.join('، ');
        }
      } catch (_) {}

      ToastService.showSuccess('تم تحديد موقعك الحالي بدقة');
    } catch (e) {
      ToastService.showError('تعذر تحديد موقعك. تأكد من تشغيل GPS والمحاولة مرة أخرى');
      debugPrint('LocationSelection GPS error: ${e}');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onMapTap(TapPosition _, LatLng point) {
    setState(() => _selectedLocation = point);
    _mapController.move(point, 17);
  }

  Future<void> _saveLocation() async {
    final area = _selectedArea;
    final address = _addressController.text.trim();
    if (area == null || area.isEmpty) {
      ToastService.showError('اختر المحافظة أولاً');
      return;
    }
    if (address.isEmpty) {
      ToastService.showError('أدخل موقعك بالتفصيل لتسهيل التوصيل');
      return;
    }
    if (_selectedLocation == null) {
      ToastService.showError('حدد موقعك على الخريطة أو استخدم GPS الهاتف');
      return;
    }

    setState(() => _saving = true);
    try {
      final point = _selectedLocation!;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_areaKey, area);
      await prefs.setString(_addressKey, address);
      await prefs.setDouble(_latKey, point.latitude);
      await prefs.setDouble(_lngKey, point.longitude);

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final firestore = FirebaseFirestore.instance;
          final userRef = firestore.collection('users').doc(user.uid);
          final userSnapshot = await userRef.get();
          final userData = userSnapshot.data() ?? <String, dynamic>{};
          final role = (userData['role'] ?? 'user').toString();
          final pointData = GeoPoint(point.latitude, point.longitude);

          await userRef.update({
            'deliveryArea': area,
            'deliveryAddress': address,
            'location': pointData,
            'locationUpdatedAt': FieldValue.serverTimestamp(),
          });

          final facilityCategory = _facilityCategoryForRole(role);
          if (facilityCategory != null) {
            await FirebaseFunctions.instanceFor(region: 'us-central1')
                .httpsCallable('syncMapFacility')
                .call({
              'lat': point.latitude,
              'lng': point.longitude,
              'address': address,
              'area': area,
            });
          } else {
            await firestore.collection('map_facilities').doc(user.uid).delete();
          }
        } catch (e) {
          debugPrint('Location profile/facility sync skipped: $e');
        }
      }

      if (!mounted) return;
      ToastService.showSuccess('تم حفظ موقعك لاستخدامه في خدمات التوصيل');
      Navigator.pop(context, {
        'area': area,
        'address': address,
        'latitude': point.latitude,
        'longitude': point.longitude,
      });
    } catch (e) {
      ToastService.showError('تعذر حفظ الموقع، حاول مرة أخرى');
      debugPrint('Location save error: ${e}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _facilityCategoryForRole(String role) {
    switch (role.trim().toLowerCase()) {
      case 'hospital':
      case 'hospital_owner':
      case 'hospitaladmin':
        return 'hospitals';
      case 'doctor':
      case 'nurse':
      case 'midwife':
      case 'physiotherapist':
      case 'paramedic':
      case 'dentist':
      case 'ophthalmologist':
      case 'eye_doctor':
        return 'clinics';
      case 'pharmacist':
      case 'pharmacy':
      case 'pharmacy_owner':
        return 'pharmacies';
      case 'lab':
      case 'laboratory':
      case 'laboratory_owner':
        return 'labs';
      case 'service':
      case 'health_facility':
        return 'other';
      default:
        return null;
    }
  }

  Future<void> _clearLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_areaKey);
    await prefs.remove(_addressKey);
    await prefs.remove(_latKey);
    await prefs.remove(_lngKey);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(user.uid).update({
          'deliveryArea': FieldValue.delete(),
          'deliveryAddress': FieldValue.delete(),
          'location': FieldValue.delete(),
          'locationUpdatedAt': FieldValue.delete(),
        });
        await firestore.collection('map_facilities').doc(user.uid).delete();
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _selectedArea = null;
      _selectedLocation = null;
      _addressController.clear();
    });
    ToastService.showSuccess('تم حذف الموقع المحفوظ');
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد موقعك'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: [
                      _buildIntro(dark),
                      const SizedBox(height: 12),
                      _buildAreaSelector(dark),
                      const SizedBox(height: 12),
                      _buildAddressField(dark),
                      const SizedBox(height: 12),
                      _buildGpsButton(),
                      const SizedBox(height: 12),
                      _buildMap(dark),
                      const SizedBox(height: 10),
                      if (_selectedLocation != null) _buildCoordinates(dark),
                    ],
                  ),
                ),
                _buildBottomActions(dark),
              ],
            ),
    );
  }

  Widget _buildIntro(bool dark) => Card(
        elevation: 0,
        color: dark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 32),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'حدد موقعك بدقة ليتم استخدامه في التوصيل والخدمات القريبة منك. يمكنك إدخال العنوان أو تحديده مباشرة عبر GPS والخريطة.',
                  style: TextStyle(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildAreaSelector(bool dark) => Card(
        elevation: 0,
        color: dark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _selectedArea,
            decoration: const InputDecoration(
              labelText: 'المحافظة',
              prefixIcon: Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(),
            ),
            dropdownColor: dark ? const Color(0xFF1A2540) : Colors.white,
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF263238),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            items: _areas.map((area) => DropdownMenuItem<String>(
              value: area,
              child: Text(
                area,
                style: TextStyle(
                  color: dark ? Colors.white : const Color(0xFF263238),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
            onChanged: (value) => setState(() => _selectedArea = value),
          ),
        ),
      );

  Widget _buildAddressField(bool dark) => Card(
        elevation: 0,
        color: dark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'موقعك بالتفصيل',
              hintText: 'مثال: شارع حدة، جوار ...، الحي ...، أقرب معلم ...',
              helperText: 'اكتب الوصف الذي يساعد مندوب التوصيل على الوصول إليك',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 42),
                child: Icon(Icons.edit_location_alt_outlined),
              ),
              border: OutlineInputBorder(),
            ),
          ),
        ),
      );

  Widget _buildGpsButton() => SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _locating ? null : _useGps,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: _locating
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.my_location),
          label: Text(_locating ? 'جارٍ تحديد موقعك...' : 'تحديد موقعي بدقة عبر GPS'),
        ),
      );

  Widget _buildMap(bool dark) => Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        color: dark ? const Color(0xFF1A2540) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 330,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation ?? _sanaaCenter,
                  initialZoom: _selectedLocation != null ? 16 : 12,
                  minZoom: 8,
                  maxZoom: 19,
                  onTap: _onMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sehatak.app',
                  ),
                  if (_selectedLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation!,
                          width: 58,
                          height: 70,
                          alignment: Alignment.bottomCenter,
                          child: Image.asset(
                            'assets/icons/settings/select_location.webp',
                            width: 58,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: dark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  elevation: 2,
                  child: IconButton(
                    tooltip: 'تحديد موقعي عبر GPS',
                    onPressed: _locating ? null : _useGps,
                    icon: const Icon(Icons.my_location, color: AppColors.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                left: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: dark ? Colors.black87 : Colors.white.withOpacity(.94),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'اضغط على الخريطة لوضع الدبوس في الموقع الدقيق',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCoordinates(bool dark) {
    final point = _selectedLocation!;
    return Text(
      'الإحداثيات المحفوظة: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: dark ? Colors.grey[400] : Colors.grey[600]),
    );
  }

  Widget _buildBottomActions(bool dark) => SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0B1121) : Colors.white,
            boxShadow: const [BoxShadow(blurRadius: 10, offset: Offset(0, -2), color: Colors.black12)],
          ),
          child: Row(
            children: [
              if (_selectedArea != null || _selectedLocation != null || _addressController.text.isNotEmpty)
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : _clearLocation,
                    child: const Text('حذف الموقع'),
                  ),
                ),
              if (_selectedArea != null || _selectedLocation != null || _addressController.text.isNotEmpty)
                const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _saveLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'جارٍ الحفظ...' : 'حفظ الموقع'),
                ),
              ),
            ],
          ),
        ),
      );
}
