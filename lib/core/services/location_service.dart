import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _currentPosition;

  Future<void> init() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('✅ LocationService initialized');
    } catch (e) {
      print('⚠️ Failed to get location: $e');
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      print('⚠️ Failed to get location: $e');
      return null;
    }
  }

  Future<String> getAddressFromLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];
        
        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          parts.add(place.country!);
        }
        
        return parts.join('، ');
      }
      
      return 'موقع غير معروف';
    } catch (e) {
      print('⚠️ Error getting address: $e');
      return 'موقع غير معروف';
    }
  }

  Future<List<Map<String, dynamic>>> getNearbyServices() async {
    return [
      {
        'id': '1',
        'name': 'مستشفى الثورة العام',
        'type': 'مستشفى',
        'distance': '0.8 كم',
        'lat': 15.3500,
        'lng': 44.2000,
        'rating': 4.5,
        'open': true,
      },
      {
        'id': '2',
        'name': 'صيدلية الشفاء',
        'type': 'صيدلية',
        'distance': '1.2 كم',
        'lat': 15.3580,
        'lng': 44.1930,
        'rating': 4.8,
        'open': true,
      },
      {
        'id': '3',
        'name': 'مختبر الرازي',
        'type': 'مختبر',
        'distance': '2.0 كم',
        'lat': 15.3540,
        'lng': 44.2030,
        'rating': 4.7,
        'open': true,
      },
    ];
  }

  Future<double> getDistance(double lat1, double lng1, double lat2, double lng2) async {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }
}
