import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// مصدر بيانات الشاشة الرئيسية. لا يتم إنشاء سجلات وهمية؛ كل قسم يقرأ من
/// مجموعات Firestore المستخدمة فعلياً في المشروع.
class HomeRepositoryFixed {
  FirebaseFirestore? get firestore =>
      Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;
  FirebaseAuth? get auth =>
      Firebase.apps.isEmpty ? null : FirebaseAuth.instance;

  Future<({bool isLoggedIn, String userName})> getUserData() async {
    try {
      final user = auth?.currentUser;
      if (user == null) return (isLoggedIn: false, userName: 'مستخدم');
      var name = user.displayName ?? '';
      if (name.trim().isEmpty) {
        final data = (await firestore?.collection('users').doc(user.uid).get())?.data();
        name = data?['name']?.toString() ?? data?['displayName']?.toString() ?? '';
      }
      return (
        isLoggedIn: true,
        userName: name.trim().isEmpty ? 'مستخدم' : name.trim(),
      );
    } catch (_) {
      return (isLoggedIn: false, userName: 'مستخدم');
    }
  }

  Future<({double calories, double steps, double sleep, double heartRate})>
      getHealthStats() async {
    try {
      final f = firestore;
      final user = auth?.currentUser;
      if (f == null || user == null) {
        return (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0);
      }
      // عقد البيانات الفعلي المستخدم في المشروع: health_metrics/{uid}.
      final data = (await f.collection('health_metrics').doc(user.uid).get()).data();
      double number(dynamic value) => value is num
          ? value.toDouble()
          : double.tryParse(value?.toString() ?? '') ?? 0.0;
      return (
        calories: number(data?['calories']),
        steps: number(data?['steps']),
        sleep: number(data?['sleep']),
        heartRate: number(data?['heartRate']),
      );
    } catch (_) {
      return (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0);
    }
  }

  Future<List<Map<String, dynamic>>> getDoctors({int limit = 10}) =>
      _query('doctors', limit, activeField: 'isAvailable');

  Future<List<Map<String, dynamic>>> getHospitals({int limit = 6}) =>
      _query('hospitals', limit, activeField: 'isActive');

  Future<List<Map<String, dynamic>>> getLabs({int limit = 6}) =>
      _query('labs', limit, activeField: 'isAvailable');

  Future<List<Map<String, dynamic>>> getPharmacies({int limit = 6}) =>
      _query('pharmacies', limit, activeField: 'isOpen');

  Future<List<Map<String, dynamic>>> _query(
    String collection,
    int limit, {
    required String activeField,
  }) async {
    try {
      final f = firestore;
      if (f == null) return [];
      final snapshot = await f
          .collection(collection)
          .where(activeField, isEqualTo: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getArticles({int limit = 4}) async {
    try {
      final f = firestore;
      if (f == null) return [];
      final snapshot = await f
          .collection('articles')
          .where('isPublished', isEqualTo: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getTips() async => [];

  Future<List<Map<String, dynamic>>> getCommunityPosts({int limit = 10}) async {
    try {
      final f = firestore;
      if (f == null) return [];
      final snapshot = await f
          .collection('community_posts')
          .where('isPublished', isEqualTo: true)
          .limit(limit)
          .get();
      final posts = snapshot.docs.map((d) => {'id': d.id, ...d.data()}).toList();
      posts.sort((a, b) {
        final at = a['createdAt'];
        final bt = b['createdAt'];
        if (at is Timestamp && bt is Timestamp) return bt.compareTo(at);
        return 0;
      });
      return posts;
    } catch (_) {
      return [];
    }
  }

  Future<int> getNotificationCount() async {
    try {
      final f = firestore;
      final user = auth?.currentUser;
      if (f == null || user == null) return 0;
      final value = (await f.collection('users').doc(user.uid).get())
          .data()?['unreadNotificationsCount'];
      return value is num ? value.toInt() : 0;
    } catch (_) {
      return 0;
    }
  }
}
