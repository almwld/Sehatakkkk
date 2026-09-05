import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<({bool isLoggedIn, String userName})> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return (isLoggedIn: false, userName: "مستخدم");
      }
      return (isLoggedIn: true, userName: user.displayName ?? "مستخدم");
    } catch (e) {
      return (isLoggedIn: false, userName: "مستخدم");
    }
  }

  Future<({double calories, double steps, double sleep, double heartRate})> getHealthStats() async {
    return (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0);
  }

  Future<List<Map<String, dynamic>>> getDoctors({int limit = 10}) async {
    try {
      final snapshot = await _firestore.collection('doctors').limit(limit).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) => doc.data()).toList();
      }
    } catch (e) {
      print('⚠️ Doctors error: $e');
    }
    return [
      {'id': 'd1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'photoUrl': ImageKit.doctor1, 'rating': 4.9, 'reviewsCount': 328, 'isAvailable': true},
      {'id': 'd2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'photoUrl': ImageKit.doctor2, 'rating': 4.8, 'reviewsCount': 256, 'isAvailable': true},
      {'id': 'd3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'photoUrl': ImageKit.doctor3, 'rating': 4.7, 'reviewsCount': 189, 'isAvailable': true},
      {'id': 'd4', 'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'photoUrl': ImageKit.doctor4, 'rating': 4.6, 'reviewsCount': 89, 'isAvailable': true},
      {'id': 'd5', 'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'photoUrl': ImageKit.doctor5, 'rating': 4.8, 'reviewsCount': 210, 'isAvailable': true},
    ];
  }

  Future<List<Map<String, dynamic>>> getHospitals({int limit = 6}) async {
    return [
      {'id': 'h1', 'name': 'مستشفى 22 مايو', 'address': 'صنعاء - حدة', 'imageUrl': ImageKit.hospital1, 'rating': 4.9},
      {'id': 'h2', 'name': 'مستشفى آزال', 'address': 'صنعاء', 'imageUrl': ImageKit.hospital2, 'rating': 4.8},
      {'id': 'h3', 'name': 'مستشفى السبعين', 'address': 'صنعاء', 'imageUrl': ImageKit.hospital3, 'rating': 4.7},
      {'id': 'h4', 'name': 'مستشفى الكويت', 'address': 'صنعاء', 'imageUrl': ImageKit.hospital4, 'rating': 4.8},
      {'id': 'h5', 'name': 'المستشفى الجمهوري', 'address': 'صنعاء', 'imageUrl': ImageKit.hospital5, 'rating': 4.6},
      {'id': 'h6', 'name': 'مستشفى الثورة العام', 'address': 'صنعاء', 'imageUrl': ImageKit.hospital6, 'rating': 4.5},
    ];
  }

  Future<List<Map<String, dynamic>>> getPharmacies({int limit = 6}) async {
    return [
      {'id': 'p1', 'name': 'صيدلية ابن حيان', 'address': 'صنعاء', 'imageUrl': ImageKit.pharmacy1, 'rating': 4.9},
      {'id': 'p2', 'name': 'صيدلية عالم الصيدلة', 'address': 'صنعاء', 'imageUrl': ImageKit.pharmacy2, 'rating': 4.8},
      {'id': 'p3', 'name': 'صيدلية النهضة', 'address': 'صنعاء', 'imageUrl': ImageKit.pharmacy3, 'rating': 4.7},
      {'id': 'p4', 'name': 'صيدلية اليمن الحديثة', 'address': 'صنعاء', 'imageUrl': ImageKit.pharmacy1, 'rating': 4.6},
      {'id': 'p5', 'name': 'صيدلية الشفاء', 'address': 'صنعاء', 'imageUrl': ImageKit.pharmacy2, 'rating': 4.5},
      {'id': 'p6', 'name': 'صيدلية الأمانة', 'address': 'صنعاء', 'imageUrl': ImageKit.pharmacy3, 'rating': 4.4},
    ];
  }

  Future<List<Map<String, dynamic>>> getLabs({int limit = 6}) async {
    return [
      {'id': 'l1', 'name': 'مختبرات الرازي', 'address': 'صنعاء', 'imageUrl': ImageKit.lab1, 'rating': 4.9},
      {'id': 'l2', 'name': 'مختبرات العولقي', 'address': 'صنعاء', 'imageUrl': ImageKit.lab2, 'rating': 4.8},
      {'id': 'l3', 'name': 'مختبرات المأمون', 'address': 'صنعاء', 'imageUrl': ImageKit.lab3, 'rating': 4.7},
      {'id': 'l4', 'name': 'مختبرات الذبحاني', 'address': 'صنعاء', 'imageUrl': ImageKit.lab1, 'rating': 4.6},
      {'id': 'l5', 'name': 'مختبرات النخبة', 'address': 'صنعاء', 'imageUrl': ImageKit.lab2, 'rating': 4.5},
      {'id': 'l6', 'name': 'مختبرات اليمن الحديثة', 'address': 'صنعاء', 'imageUrl': ImageKit.lab3, 'rating': 4.4},
    ];
  }

  Future<List<Map<String, dynamic>>> getArticles({int limit = 4}) async {
    return [
      {'id': 'a1', 'title': 'فوائد المشي اليومي', 'category': 'صحة عامة', 'imageUrl': ImageKit.morningWalk, 'timeAgo': 'منذ ساعة'},
      {'id': 'a2', 'title': 'نصائح لتقوية المناعة', 'category': 'تغذية', 'imageUrl': ImageKit.immuneBoost, 'timeAgo': 'منذ 3 ساعات'},
      {'id': 'a3', 'title': 'أهمية النوم الصحي', 'category': 'صحة نفسية', 'imageUrl': ImageKit.sleepTips, 'timeAgo': 'منذ 5 ساعات'},
      {'id': 'a4', 'title': 'العناية بالبشرة في الصيف', 'category': 'جلدية', 'imageUrl': ImageKit.skinCare, 'timeAgo': 'منذ يوم'},
    ];
  }

  Future<List<Map<String, dynamic>>> getTips() async {
    return [
      {'id': 't1', 'title': 'شرب الماء', 'subtitle': '8 أكواب يومياً', 'icon': 'assets/images/tracking/water_drinking.png', 'content': 'شرب 8 أكواب من الماء يومياً يحسن الصحة'},
      {'id': 't2', 'title': 'المشي', 'subtitle': '30 دقيقة يومياً', 'icon': 'assets/images/tracking/walking.png', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب'},
      {'id': 't3', 'title': 'النوم', 'subtitle': '7-8 ساعات ليلاً', 'icon': 'assets/images/tracking/sleep_tracking.png', 'content': 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية'},
      {'id': 't4', 'title': 'الفواكه', 'subtitle': '5 حصص يومياً', 'icon': 'assets/images/tracking/fruits.png', 'content': 'تناول 5 حصص من الفواكه والخضار يومياً'},
    ];
  }

  Future<List<Map<String, dynamic>>> getCommunityPosts({int limit = 10}) async {
    return [
      {'id': '1', 'userId': 'u1', 'userName': 'د. سارة العمري', 'userAvatar': 'س', 'imageUrl': ImageKit.skinCare, 'title': 'نصائح للعناية بالبشرة', 'content': 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك', 'likes': 120, 'comments': 15, 'shares': 8, 'views': 450, 'timeAgo': 'منذ ساعة'},
      {'id': '2', 'userId': 'u2', 'userName': 'د. خالد النخلاني', 'userAvatar': 'خ', 'imageUrl': ImageKit.morningWalk, 'title': 'فوائد المشي الصباحي', 'content': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب', 'likes': 95, 'comments': 8, 'shares': 5, 'views': 320, 'timeAgo': 'منذ 3 ساعات'},
      {'id': '3', 'userId': 'u3', 'userName': 'د. أحمد المؤيد', 'userAvatar': 'أ', 'imageUrl': ImageKit.nutritionTips, 'title': 'تغذيتك سر صحتك', 'content': 'الطعام الصحي هو أساس المناعة القوية', 'likes': 210, 'comments': 22, 'shares': 12, 'views': 680, 'timeAgo': 'منذ 5 ساعات'},
    ];
  }

  Future<int> getNotificationCount() async {
    return 0;
  }
}
