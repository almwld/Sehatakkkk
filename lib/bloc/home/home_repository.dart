import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HomeRepository {
  FirebaseFirestore? get _firestore => Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;
  FirebaseAuth? get _auth => Firebase.apps.isEmpty ? null : FirebaseAuth.instance;

  Future<({bool isLoggedIn, String userName})> getUserData() async {
    try {
      final auth = _auth;
      final user = auth?.currentUser;
      if (user == null) return (isLoggedIn: false, userName: 'مستخدم');
      var name = user.displayName ?? '';
      if (name.trim().isEmpty) {
        final data = (await _firestore?.collection('users').doc(user.uid).get())?.data();
        name = data?['name']?.toString() ?? '';
      }
      return (isLoggedIn: true, userName: name.trim().isEmpty ? 'مستخدم' : name.trim());
    } catch (_) {
      return (isLoggedIn: false, userName: 'مستخدم');
    }
  }

  Future<({double calories, double steps, double sleep, double heartRate})> getHealthStats() async {
    try {
      final firestore = _firestore;
      final user = _auth?.currentUser;
      if (firestore == null || user == null) return (calories: 0, steps: 0, sleep: 0, heartRate: 0);
      final data = (await firestore.collection('health_metrics').doc(user.uid).get()).data();
      double number(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;
      return (calories: number(data?['calories']), steps: number(data?['steps']), sleep: number(data?['sleep']), heartRate: number(data?['heartRate']));
    } catch (_) {
      return (calories: 0, steps: 0, sleep: 0, heartRate: 0);
    }
  }

  Future<List<Map<String, dynamic>>> getDoctors({int limit = 10}) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return [];
      final snapshot = await firestore.collection('doctors').where('isVerified', isEqualTo: true).limit(limit).get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHospitals({int limit = 6}) async {
    return _getCityFacilities('hospitals', limit);
  }

  Future<List<Map<String, dynamic>>> getLabs({int limit = 6}) async {
    return _getCityFacilities('labs', limit);
  }

  Future<List<Map<String, dynamic>>> getPharmacies({int limit = 6}) async {
    return _getCityFacilities('pharmacies', limit);
  }

  Future<List<Map<String, dynamic>>> _getCityFacilities(String collection, int limit) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return [];
      final snapshot = await firestore.collection(collection).where('cityNormalized', isEqualTo: 'صنعاء').limit(limit).get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getArticles({int limit = 4}) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return [];
      final snapshot = await firestore.collection('articles').where('isPublished', isEqualTo: true).limit(limit).get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (_) {
      try {
        final firestore = _firestore;
        if (firestore == null) return [];
        final snapshot = await firestore.collection('articles').limit(limit).get();
        return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> getTips() async => [];

  Future<List<Map<String, dynamic>>> getCommunityPosts({int limit = 10}) async {
    try {
      final firestore = _firestore;
      if (firestore == null) return [];
      final snapshot = await firestore.collection('community_posts').where('isPublished', isEqualTo: true).limit(limit).get();
      final posts = snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
      posts.sort((a, b) {
        final at = a['createdAt'];
        final bt = b['createdAt'];
        return at is Timestamp && bt is Timestamp ? bt.compareTo(at) : 0;
      });
      return posts;
    } catch (_) {
      return [];
    }
  }

  Future<int> getNotificationCount() async {
    try {
      final firestore = _firestore;
      final user = _auth?.currentUser;
      if (firestore == null || user == null) return 0;
      final value = (await firestore.collection('users').doc(user.uid).get()).data()?['unreadNotificationsCount'];
      return value is num ? value.toInt() : 0;
    } catch (_) {
      return 0;
    }
  }
}
