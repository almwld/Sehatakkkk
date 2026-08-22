import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> checkPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('❌ Error getting location: $e');
      return null;
    }
  }

  Future<String> getAddressFromLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''} ${place.subLocality ?? ''} ${place.locality ?? ''} ${place.country ?? ''}';
      }
      return 'موقع غير معروف';
    } catch (e) {
      print('❌ Error getting address: $e');
      return 'موقع غير معروف';
    }
  }

  Future<void> sendLocation({
    required String chatId,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final locationAddress = address ?? await getAddressFromLocation(
      latitude: latitude,
      longitude: longitude,
    );

    final messageData = {
      'text': '📍 $locationAddress',
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'location',
      'latitude': latitude,
      'longitude': longitude,
      'address': locationAddress,
      'isRead': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': '📍 تم مشاركة موقع',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> shareCurrentLocation({
    required String chatId,
    required VoidCallback onSuccess,
    required VoidCallback onError,
  }) async {
    try {
      final position = await getCurrentLocation();
      if (position == null) {
        onError();
        return;
      }

      await sendLocation(
        chatId: chatId,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      onSuccess();
    } catch (e) {
      print('❌ Error sharing location: $e');
      onError();
    }
  }

  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} م';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} كم';
    }
  }
}
