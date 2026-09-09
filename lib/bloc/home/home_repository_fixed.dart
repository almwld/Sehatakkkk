import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class HomeRepositoryFixed {
  FirebaseFirestore? get firestore => Firebase.apps.isEmpty ? null : FirebaseFirestore.instance;
  FirebaseAuth? get auth => Firebase.apps.isEmpty ? null : FirebaseAuth.instance;

  Future<({bool isLoggedIn, String userName})> getUserData() async {
    try {
      final user = auth?.currentUser;
      if (user == null) return (isLoggedIn: false, userName: 'مستخدم');
      var name = user.displayName ?? '';
      if (name.trim().isEmpty) name = (await firestore?.collection('users').doc(user.uid).get())?.data()?['name']?.toString() ?? '';
      return (isLoggedIn: true, userName: name.trim().isEmpty ? 'مستخدم' : name.trim());
    } catch (_) { return (isLoggedIn: false, userName: 'مستخدم'); }
  }

  Future<({double calories, double steps, double sleep, double heartRate})> getHealthStats() async {
    try {
      final f = firestore; final u = auth?.currentUser;
      if (f == null || u == null) return (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0);
      final d = (await f.collection('health_metrics').doc(u.uid).get()).data();
      double n(dynamic x) => x is num ? x.toDouble() : double.tryParse('$x') ?? 0.0;
      return (calories: n(d?['calories']), steps: n(d?['steps']), sleep: n(d?['sleep']), heartRate: n(d?['heartRate']));
    } catch (_) { return (calories: 0.0, steps: 0.0, sleep: 0.0, heartRate: 0.0); }
  }

  Future<List<Map<String,dynamic>>> getDoctors({int limit=10}) async => _query('doctors', limit, verified: true);
  Future<List<Map<String,dynamic>>> getHospitals({int limit=6}) => _city('hospitals', limit);
  Future<List<Map<String,dynamic>>> getLabs({int limit=6}) => _city('labs', limit);
  Future<List<Map<String,dynamic>>> getPharmacies({int limit=6}) => _city('pharmacies', limit);
  Future<List<Map<String,dynamic>>> _city(String c,int limit) async { try { final f=firestore; if(f==null)return []; final s=await f.collection(c).where('cityNormalized',isEqualTo:'صنعاء').limit(limit).get(); return s.docs.map((d)=>{'id':d.id,...d.data()}).toList(); } catch(_){return [];} }
  Future<List<Map<String,dynamic>>> _query(String c,int limit,{bool verified=false}) async { try { final f=firestore; if(f==null)return []; Query<Map<String,dynamic>> q=f.collection(c); if(verified)q=q.where('isVerified',isEqualTo:true); final s=await q.limit(limit).get(); return s.docs.map((d)=>{'id':d.id,...d.data()}).toList(); } catch(_){return [];} }
  Future<List<Map<String,dynamic>>> getArticles({int limit=4}) async { try { final f=firestore;if(f==null)return [];final s=await f.collection('articles').where('isPublished',isEqualTo:true).limit(limit).get();return s.docs.map((d)=>{'id':d.id,...d.data()}).toList(); }catch(_){return [];} }
  Future<List<Map<String,dynamic>>> getTips() async => [];
  Future<List<Map<String,dynamic>>> getCommunityPosts({int limit=10}) async => [];
  Future<int> getNotificationCount() async => 0;
}
