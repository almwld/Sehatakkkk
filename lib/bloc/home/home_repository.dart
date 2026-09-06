import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HomeRepository {
  FirebaseFirestore? get _firestore {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  FirebaseAuth? get _auth {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseAuth.instance;
  }

  Future<({bool isLoggedIn, String userName})> getUserData() async {
    try {
      final auth = _auth;

      if (auth == null) {
        return (isLoggedIn: false, userName: 'مستخدم');
      }

      final user = auth.currentUser;

      if (user == null) {
        return (isLoggedIn: false, userName: 'مستخدم');
      }

      return (
        isLoggedIn: true,
        userName: user.displayName ?? 'مستخدم',
      );
    } catch (e) {
      return (isLoggedIn: false, userName: 'مستخدم');
    }
  }

  Future<({double calories, double steps, double sleep, double heartRate})>
      getHealthStats() async {
    return (
      calories: 0.0,
      steps: 0.0,
      sleep: 0.0,
      heartRate: 0.0,
    );
  }

  Future<List<Map<String, dynamic>>> getDoctors({int limit = 10}) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('doctors')
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('⚠️ Doctors error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getHospitals({int limit = 6}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getPharmacies({int limit = 6}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getLabs({int limit = 6}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getArticles({int limit = 4}) async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getTips() async {
    return [];
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts({
    int limit = 10,
  }) async {
    return [];
  }

  Future<int> getNotificationCount() async {
    return 0;
  }
}
