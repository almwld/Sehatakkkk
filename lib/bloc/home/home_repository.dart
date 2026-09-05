// ============================================================
// 📁 lib/bloc/home/home_repository.dart
// 📦 جلب البيانات من Firestore
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/doctor/doctor_model.dart';
import 'package:sehatak/core/models/hospital/hospital_model.dart';
import 'package:sehatak/core/models/pharmacy/pharmacy_model.dart';
import 'package:sehatak/core/models/lab/lab_model.dart';
import 'package:sehatak/core/models/article/article_model.dart';
import 'package:sehatak/core/models/tip/tip_model.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';

class HomeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<({bool isLoggedIn, String userName})> getUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return (isLoggedIn: false, userName: 'مستخدم');
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        return (
          isLoggedIn: true,
          userName: data?['name'] ?? user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم',
        );
      }
      return (isLoggedIn: true, userName: user.displayName ?? user.email?.split('@')[0] ?? 'مستخدم');
    } catch (e) {
      return (isLoggedIn: false, userName: 'مستخدم');
    }
  }

  Future<({double calories, double steps, double sleep, double heartRate})> getHealthStats() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return (calories: 0, steps: 0, sleep: 0, heartRate: 0);
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('health_stats')
          .doc('today')
          .get();
      if (doc.exists) {
        final data = doc.data();
        return (
          calories: (data?['calories'] as num?)?.toDouble() ?? 0,
          steps: (data?['steps'] as num?)?.toDouble() ?? 0,
          sleep: (data?['sleep'] as num?)?.toDouble() ?? 0,
          heartRate: (data?['heartRate'] as num?)?.toDouble() ?? 0,
        );
      }
      return (calories: 0, steps: 0, sleep: 0, heartRate: 0);
    } catch (e) {
      return (calories: 0, steps: 0, sleep: 0, heartRate: 0);
    }
  }

  Future<List<DoctorModel>> getDoctors({int limit = 10}) async {
    try {
      final snapshot = await _firestore.collection('doctors').limit(limit).get();
      if (snapshot.docs.isEmpty) return _defaultDoctors();
      return snapshot.docs.map((doc) => DoctorModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultDoctors();
    }
  }

  List<DoctorModel> _defaultDoctors() {
    return [
      DoctorModel(id: 'd1', name: 'د. أحمد المولد', specialty: 'باطنية', photoUrl: ImageKit.doctor1, rating: 4.9, reviewsCount: 328, isAvailable: true),
      DoctorModel(id: 'd2', name: 'د. خالد النخلاني', specialty: 'قلبية', photoUrl: ImageKit.doctor2, rating: 4.8, reviewsCount: 256, isAvailable: true),
      DoctorModel(id: 'd3', name: 'د. أسماء الهندي', specialty: 'أطفال', photoUrl: ImageKit.doctor3, rating: 4.7, reviewsCount: 189, isAvailable: true),
      DoctorModel(id: 'd4', name: 'د. محمد العلاي', specialty: 'أنف وأذن وحنجرة', photoUrl: ImageKit.doctor4, rating: 4.6, reviewsCount: 89, isAvailable: true),
      DoctorModel(id: 'd5', name: 'د. فاطمة صديقي', specialty: 'نساء وولادة', photoUrl: ImageKit.doctor5, rating: 4.8, reviewsCount: 210, isAvailable: true),
    ];
  }

  Future<List<HospitalModel>> getHospitals({int limit = 6}) async {
    try {
      final snapshot = await _firestore.collection('hospitals').limit(limit).get();
      if (snapshot.docs.isEmpty) return _defaultHospitals();
      return snapshot.docs.map((doc) => HospitalModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultHospitals();
    }
  }

  List<HospitalModel> _defaultHospitals() {
    return [
      HospitalModel(id: 'h1', name: 'مستشفى 22 مايو', address: 'صنعاء - حدة', imageUrl: ImageKit.hospital1, rating: 4.9, emergency: true, isVerified: true),
      HospitalModel(id: 'h2', name: 'مستشفى آزال', address: 'صنعاء', imageUrl: ImageKit.hospital2, rating: 4.8, emergency: true, isVerified: true),
      HospitalModel(id: 'h3', name: 'مستشفى السبعين', address: 'صنعاء', imageUrl: ImageKit.hospital3, rating: 4.7, emergency: true, isVerified: true),
      HospitalModel(id: 'h4', name: 'مستشفى الكويت', address: 'صنعاء', imageUrl: ImageKit.hospital4, rating: 4.8, emergency: true, isVerified: true),
      HospitalModel(id: 'h5', name: 'المستشفى الجمهوري', address: 'صنعاء', imageUrl: ImageKit.hospital5, rating: 4.6, emergency: true, isVerified: true),
      HospitalModel(id: 'h6', name: 'مستشفى الثورة العام', address: 'صنعاء', imageUrl: ImageKit.hospital6, rating: 4.5, emergency: true, isVerified: true),
    ];
  }

  Future<List<PharmacyModel>> getPharmacies({int limit = 6}) async {
    try {
      final snapshot = await _firestore.collection('pharmacies').limit(limit).get();
      if (snapshot.docs.isEmpty) return _defaultPharmacies();
      return snapshot.docs.map((doc) => PharmacyModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultPharmacies();
    }
  }

  List<PharmacyModel> _defaultPharmacies() {
    return [
      PharmacyModel(id: 'p1', name: 'صيدلية ابن حيان', address: 'صنعاء', imageUrl: ImageKit.pharmacy1, rating: 4.9, delivery: true, isVerified: true),
      PharmacyModel(id: 'p2', name: 'صيدلية عالم الصيدلة', address: 'صنعاء', imageUrl: ImageKit.pharmacy2, rating: 4.8, delivery: true, isVerified: true),
      PharmacyModel(id: 'p3', name: 'صيدلية النهضة', address: 'صنعاء', imageUrl: ImageKit.pharmacy3, rating: 4.7, delivery: true, isVerified: true),
      PharmacyModel(id: 'p4', name: 'صيدلية اليمن الحديثة', address: 'صنعاء', imageUrl: ImageKit.pharmacy1, rating: 4.6, delivery: true, isVerified: true),
      PharmacyModel(id: 'p5', name: 'صيدلية الشفاء', address: 'صنعاء', imageUrl: ImageKit.pharmacy2, rating: 4.5, delivery: false, isVerified: true),
      PharmacyModel(id: 'p6', name: 'صيدلية الأمانة', address: 'صنعاء', imageUrl: ImageKit.pharmacy3, rating: 4.4, delivery: true, isVerified: true),
    ];
  }

  Future<List<LabModel>> getLabs({int limit = 6}) async {
    try {
      final snapshot = await _firestore.collection('labs').limit(limit).get();
      if (snapshot.docs.isEmpty) return _defaultLabs();
      return snapshot.docs.map((doc) => LabModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultLabs();
    }
  }

  List<LabModel> _defaultLabs() {
    return [
      LabModel(id: 'l1', name: 'مختبرات الرازي', address: 'صنعاء', imageUrl: ImageKit.lab1, rating: 4.9, accredited: true, isVerified: true),
      LabModel(id: 'l2', name: 'مختبرات العولقي', address: 'صنعاء', imageUrl: ImageKit.lab2, rating: 4.8, accredited: true, isVerified: true),
      LabModel(id: 'l3', name: 'مختبرات المأمون', address: 'صنعاء', imageUrl: ImageKit.lab3, rating: 4.7, accredited: true, isVerified: true),
      LabModel(id: 'l4', name: 'مختبرات الذبحاني', address: 'صنعاء', imageUrl: ImageKit.lab1, rating: 4.6, accredited: true, isVerified: true),
      LabModel(id: 'l5', name: 'مختبرات النخبة', address: 'صنعاء', imageUrl: ImageKit.lab2, rating: 4.5, accredited: true, isVerified: true),
      LabModel(id: 'l6', name: 'مختبرات اليمن الحديثة', address: 'صنعاء', imageUrl: ImageKit.lab3, rating: 4.4, accredited: true, isVerified: true),
    ];
  }

  Future<List<ArticleModel>> getArticles({int limit = 4}) async {
    try {
      final snapshot = await _firestore
          .collection('articles')
          .where('isPublished', isEqualTo: true)
          .orderBy('publishedAt', descending: true)
          .limit(limit)
          .get();
      if (snapshot.docs.isEmpty) return _defaultArticles();
      return snapshot.docs.map((doc) => ArticleModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultArticles();
    }
  }

  List<ArticleModel> _defaultArticles() {
    return [
      ArticleModel(id: 'a1', title: 'فوائد المشي اليومي', category: 'صحة عامة', imageUrl: ImageKit.morningWalk, isPublished: true, publishedAt: DateTime.now().subtract(const Duration(hours: 1))),
      ArticleModel(id: 'a2', title: 'نصائح لتقوية المناعة', category: 'تغذية', imageUrl: ImageKit.immuneBoost, isPublished: true, publishedAt: DateTime.now().subtract(const Duration(hours: 3))),
      ArticleModel(id: 'a3', title: 'أهمية النوم الصحي', category: 'صحة نفسية', imageUrl: ImageKit.sleepTips, isPublished: true, publishedAt: DateTime.now().subtract(const Duration(hours: 5))),
      ArticleModel(id: 'a4', title: 'العناية بالبشرة في الصيف', category: 'جلدية', imageUrl: ImageKit.skinCare, isPublished: true, publishedAt: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }

  Future<List<TipModel>> getTips() async {
    try {
      final snapshot = await _firestore.collection('tips').limit(4).get();
      if (snapshot.docs.isEmpty) return _defaultTips();
      return snapshot.docs.map((doc) => TipModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultTips();
    }
  }

  List<TipModel> _defaultTips() {
    return [
      TipModel(id: 't1', title: 'شرب الماء', subtitle: '8 أكواب يومياً', icon: 'assets/images/tracking/water_drinking.png', content: 'شرب 8 أكواب من الماء يومياً يحسن الصحة', isPublished: true),
      TipModel(id: 't2', title: 'المشي', subtitle: '30 دقيقة يومياً', icon: 'assets/images/tracking/walking.png', content: 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب', isPublished: true),
      TipModel(id: 't3', title: 'النوم', subtitle: '7-8 ساعات ليلاً', icon: 'assets/images/tracking/sleep_tracking.png', content: 'النوم 7-8 ساعات يومياً يحسن الصحة النفسية', isPublished: true),
      TipModel(id: 't4', title: 'الفواكه', subtitle: '5 حصص يومياً', icon: 'assets/images/tracking/fruits.png', content: 'تناول 5 حصص من الفواكه والخضار يومياً', isPublished: true),
    ];
  }

  Future<List<CommunityPostModel>> getCommunityPosts({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('community_posts')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      if (snapshot.docs.isEmpty) return _defaultCommunityPosts();
      return snapshot.docs.map((doc) => CommunityPostModel.fromFirestore(doc)).toList();
    } catch (e) {
      return _defaultCommunityPosts();
    }
  }

  List<CommunityPostModel> _defaultCommunityPosts() {
    return [
      CommunityPostModel(id: '1', userId: 'u1', userName: 'د. سارة العمري', userAvatar: 'س', imageUrl: ImageKit.skinCare, title: 'نصائح للعناية بالبشرة', content: 'مع حلول فصل الصيف، احرصي على ترطيب بشرتك', likes: 120, comments: 15, shares: 8, views: 450, createdAt: DateTime.now().subtract(const Duration(hours: 1))),
      CommunityPostModel(id: '2', userId: 'u2', userName: 'د. خالد النخلاني', userAvatar: 'خ', imageUrl: ImageKit.morningWalk, title: 'فوائد المشي الصباحي', content: 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب', likes: 95, comments: 8, shares: 5, views: 320, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      CommunityPostModel(id: '3', userId: 'u3', userName: 'د. أحمد المؤيد', userAvatar: 'أ', imageUrl: ImageKit.nutritionTips, title: 'تغذيتك سر صحتك', content: 'الطعام الصحي هو أساس المناعة القوية', likes: 210, comments: 22, shares: 12, views: 680, createdAt: DateTime.now().subtract(const Duration(hours: 5))),
    ];
  }

  Future<int> getNotificationCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 0;
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .count()
          .get();
      return snapshot.count;
    } catch (e) {
      return 0;
    }
  }
}
