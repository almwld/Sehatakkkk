import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/cache_service.dart';

class SymptomService {
  static final SymptomService _instance = SymptomService._internal();
  factory SymptomService() => _instance;
  SymptomService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> commonSymptoms = const ['صداع','حمى','سعال','ضيق تنفس','ألم في الصدر','غثيان','دوخة','تعب عام','ألم عضلي','احتقان أنف','التهاب الحلق','فقدان حاسة الشم','فقدان حاسة التذوق','إسهال','قيء','ألم في البطن','آلام المفاصل','طفح جلدي','حكة','تورم'];
  Future<void> init() async {}

  Future<List<Map<String, dynamic>>> getRecentSymptoms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      final cached = await CacheService.getList('symptoms_${user.uid}');
      if (cached != null && cached.isNotEmpty) return cached;
      final snapshot = await _firestore.collection('users').doc(user.uid).collection('symptoms').orderBy('date', descending: true).limit(10).get();
      final symptoms = snapshot.docs.map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()}).toList();
      await CacheService.saveList('symptoms_${user.uid}', symptoms);
      return symptoms;
    } catch (_) { return []; }
  }

  Future<Map<String, dynamic>> addSymptom({required String symptom, required int severity, String? notes, DateTime? date, List<String>? tags}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    final data = <String, dynamic>{'symptom': symptom, 'severity': severity, 'notes': notes ?? '', 'date': date ?? FieldValue.serverTimestamp(), 'tags': tags ?? [], 'userId': user.uid, 'createdAt': FieldValue.serverTimestamp()};
    final docRef = await _firestore.collection('users').doc(user.uid).collection('symptoms').add(data);
    await CacheService.remove('symptoms_${user.uid}');
    return {'id': docRef.id, ...data};
  }

  Future<Map<String, dynamic>> analyzeSymptoms(List<String> symptoms) async {
    final analysis = <String, dynamic>{'symptoms': symptoms, 'count': symptoms.length};
    if (symptoms.contains('حمى') && symptoms.contains('سعال')) {
      analysis.addAll({'condition':'نزلة برد أو إنفلونزا','severity':'متوسط','advice':'خذ قسطاً من الراحة واشرب السوائل','recommendation':'مراجعة الطبيب إذا استمرت الأعراض أكثر من 3 أيام'});
    } else if (symptoms.contains('صداع') && symptoms.contains('دوخة')) {
      analysis.addAll({'condition':'إجهاد أو جفاف','severity':'خفيف','advice':'اشرب الماء واسترح','recommendation':'إذا استمر الصداع استشر طبيبك'});
    } else if (symptoms.isEmpty) {
      analysis.addAll({'condition':'لا توجد أعراض','severity':'لا شيء','advice':'استمر في نمط حياة صحي','recommendation':'استمر في المتابعة الصحية'});
    } else {
      analysis.addAll({'condition':'أعراض متنوعة','severity':'خفيف إلى متوسط','advice':'راقب الأعراض واحصل على الراحة','recommendation':'إذا تفاقمت الأعراض استشر طبيباً'});
    }
    return analysis;
  }

  Stream<List<Map<String, dynamic>>> watchRecentSymptoms() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);
    return _firestore.collection('users').doc(user.uid).collection('symptoms').orderBy('date', descending: true).limit(10).snapshots().map((s) => s.docs.map((d) => <String, dynamic>{'id': d.id, ...d.data()}).toList());
  }
}
