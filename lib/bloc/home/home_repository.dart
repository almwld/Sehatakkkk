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
        return (
          isLoggedIn: false,
          userName: 'مستخدم',
        );
      }

      final user = auth.currentUser;

      if (user == null) {
        return (
          isLoggedIn: false,
          userName: 'مستخدم',
        );
      }

      String name = user.displayName ?? '';

      if (name.trim().isEmpty) {
        try {
          final firestore = _firestore;

          if (firestore != null) {
            final userDoc = await firestore
                .collection('users')
                .doc(user.uid)
                .get();

            final data = userDoc.data();

            final firestoreName =
                data?['name']?.toString().trim();

            if (firestoreName != null &&
                firestoreName.isNotEmpty) {
              name = firestoreName;
            }
          }
        } catch (_) {}
      }

      return (
        isLoggedIn: true,
        userName: name.trim().isEmpty
            ? 'مستخدم'
            : name.trim(),
      );
    } catch (_) {
      return (
        isLoggedIn: false,
        userName: 'مستخدم',
      );
    }
  }

  Future<({
    double calories,
    double steps,
    double sleep,
    double heartRate,
  })> getHealthStats() async {
    try {
      final firestore = _firestore;
      final auth = _auth;

      if (firestore == null || auth == null) {
        return (
          calories: 0.0,
          steps: 0.0,
          sleep: 0.0,
          heartRate: 0.0,
        );
      }

      final user = auth.currentUser;

      if (user == null) {
        return (
          calories: 0.0,
          steps: 0.0,
          sleep: 0.0,
          heartRate: 0.0,
        );
      }

      final doc = await firestore
          .collection('health_metrics')
          .doc(user.uid)
          .get();

      final data = doc.data();

      if (data == null) {
        return (
          calories: 0.0,
          steps: 0.0,
          sleep: 0.0,
          heartRate: 0.0,
        );
      }

      double number(dynamic value) {
        if (value is num) {
          return value.toDouble();
        }

        return double.tryParse(
              value?.toString() ?? '',
            ) ??
            0.0;
      }

      return (
        calories: number(data['calories']),
        steps: number(data['steps']),
        sleep: number(data['sleep']),
        heartRate: number(data['heartRate']),
      );
    } catch (e) {
      return (
        calories: 0.0,
        steps: 0.0,
        sleep: 0.0,
        heartRate: 0.0,
      );
    }
  }

  Future<List<Map<String, dynamic>>> getDoctors({
    int limit = 10,
  }) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('doctors')
          .where(
            'isVerified',
            isEqualTo: true,
          )
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();
    } catch (e) {
      try {
        final firestore = _firestore;

        if (firestore == null) return [];

        final snapshot = await firestore
            .collection('doctors')
            .limit(limit)
            .get();

        return snapshot.docs
            .map(
              (doc) => {
                'id': doc.id,
                ...doc.data(),
              },
            )
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> getHospitals({
    int limit = 6,
  }) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('hospitals')
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPharmacies({
    int limit = 6,
  }) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('pharmacies')
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLabs({
    int limit = 6,
  }) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('labs')
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getArticles({
    int limit = 4,
  }) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('articles')
          .where(
            'isPublished',
            isEqualTo: true,
          )
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();
    } catch (_) {
      /*
       * إذا لم يكن isPublished موجودًا في بعض البيانات
       * القديمة، لا نسقط Home كلها.
       */
      try {
        final firestore = _firestore;

        if (firestore == null) return [];

        final snapshot = await firestore
            .collection('articles')
            .limit(limit)
            .get();

        return snapshot.docs
            .map(
              (doc) => {
                'id': doc.id,
                ...doc.data(),
              },
            )
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<Map<String, dynamic>>> getTips() async {
    /*
     * لا توجد Collection مؤكدة للنصائح ضمن الاستخراج
     * الذي أرسلته.
     *
     * لذلك لا ننشئ Collection وهمية ولا Mock Data.
     */
    return [];
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts({
    int limit = 10,
  }) async {
    try {
      final firestore = _firestore;

      if (firestore == null) return [];

      final snapshot = await firestore
          .collection('community_posts')
          .where(
            'isPublished',
            isEqualTo: true,
          )
          .limit(limit)
          .get();

      final posts = snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              ...doc.data(),
            },
          )
          .toList();

      posts.sort(
        (a, b) {
          final aDate = a['createdAt'];
          final bDate = b['createdAt'];

          if (aDate is Timestamp &&
              bDate is Timestamp) {
            return bDate.compareTo(aDate);
          }

          return 0;
        },
      );

      return posts;
    } catch (_) {
      try {
        final firestore = _firestore;

        if (firestore == null) return [];

        final snapshot = await firestore
            .collection('community_posts')
            .limit(limit)
            .get();

        return snapshot.docs
            .map(
              (doc) => {
                'id': doc.id,
                ...doc.data(),
              },
            )
            .toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<int> getNotificationCount() async {
    try {
      final firestore = _firestore;
      final auth = _auth;

      if (firestore == null || auth == null) {
        return 0;
      }

      final user = auth.currentUser;

      if (user == null) {
        return 0;
      }

      /*
       * نبحث في users أولاً عن unreadNotificationsCount.
       * لا ننشئ Collection notifications غير مؤكدة.
       */
      final userDoc = await firestore
          .collection('users')
          .doc(user.uid)
          .get();

      final data = userDoc.data();

      final value = data?['unreadNotificationsCount'];

      if (value is num) {
        return value.toInt();
      }

      return 0;
    } catch (_) {
      return 0;
    }
  }
}
