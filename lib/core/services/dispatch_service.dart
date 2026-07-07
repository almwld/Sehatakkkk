import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class DispatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ✅ البحث عن أقرب مقدمي خدمة
  Future<List<Map<String, dynamic>>> findNearbyProviders({
    required double lat,
    required double lng,
    required String role, // 'pharmacy', 'lab', 'home_service'
    int radius = 5, // كيلومتر
    int limit = 5,
  }) async {
    try {
      // ✅ جلب جميع مقدمي الخدمة في المنطقة
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .where('isAvailable', isEqualTo: true)
          .get();

      final providers = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data.containsKey('location')) {
          final geoPoint = data['location'] as GeoPoint;
          final distance = await Geolocator.distanceBetween(
            lat, lng,
            geoPoint.latitude, geoPoint.longitude,
          ) / 1000; // تحويل إلى كيلومتر

          if (distance <= radius) {
            providers.add({
              ...data,
              'uid': doc.id,
              'distance': distance,
            });
          }
        }
      }

      // ✅ ترتيب حسب الأقرب
      providers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      
      return providers.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ إرسال إشعار صامت لأقرب مقدمي خدمة
  Future<void> silentDispatch({
    required String orderId,
    required String patientId,
    required String serviceType,
    required String description,
    required double lat,
    required double lng,
  }) async {
    final providers = await findNearbyProviders(
      lat: lat,
      lng: lng,
      role: serviceType,
    );

    for (final provider in providers) {
      final bidId = _uuid.v4();
      
      await _firestore.collection('bids').doc(bidId).set({
        'id': bidId,
        'orderId': orderId,
        'patientId': patientId,
        'providerId': provider['uid'],
        'providerName': provider['name'] ?? 'مقدم خدمة',
        'serviceType': serviceType,
        'description': description,
        'status': 'pending', // pending, accepted, rejected
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(minutes: 2)),
        ),
      });

      // ✅ إشعار صامت للمقدم
      // سيتم تفعيله مع FCM لاحقاً
      print('📤 Silent dispatch to: ${provider['name']}');
    }
  }

  // ✅ قبول الطلب (First-to-Respond)
  Future<void> acceptBid(String bidId, String providerId) async {
    final bidDoc = await _firestore.collection('bids').doc(bidId).get();
    if (!bidDoc.exists) return;

    final data = bidDoc.data()!;
    if (data['status'] != 'pending') return;

    // ✅ تحديث حالة العرض
    await _firestore.collection('bids').doc(bidId).update({
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // ✅ رفض العروض الأخرى لنفس الطلب
    final otherBids = await _firestore
        .collection('bids')
        .where('orderId', isEqualTo: data['orderId'])
        .where('status', isEqualTo: 'pending')
        .get();

    for (final doc in otherBids.docs) {
      await doc.reference.update({
        'status': 'rejected',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    // ✅ تحديث الطلب
    await _firestore.collection('orders').doc(data['orderId']).update({
      'providerId': providerId,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Bid accepted: $bidId by $providerId');
  }
}
