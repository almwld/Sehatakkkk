import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/cache_service.dart';

class SymptomService {
  static final SymptomService _instance = SymptomService._internal();
  factory SymptomService() => _instance;
  SymptomService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CacheService _cache = CacheService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<String> commonSymptoms = [
    'صداع',
    'حمى',
    'سعال',
    'ضيق تنفس',
    'ألم في الصدر',
    'غثيان',
    'دوخة',
    'تعب عام',
    'ألم عضلي',
    'احتقان أنف',
    'تهاب الحلق',
    'فقدان حاسة الشم',
    'فقدان حاسة التذوق',
    'إسهال',
    'قيء',
    'ألم في البطن',
    'آلام المفاصل',
    'طفح جلدي',
    'حكة',
    'تورم',
  ];

  Future<void> init() async {
    print('✅ SymptomService initialized');
  }

  Future<List<Map<String, dynamic>>> getRecentSymptoms() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final cached = await _cache.getList('symptoms_${user.uid}');
      if (cached != null && cached.isNotEmpty) {
        return cached.map((e) => e as Map<String, dynamic>).toList();
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('symptoms')
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      final symptoms = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();

      await _cache.saveList('symptoms_${user.uid}', symptoms);
      return symptoms;
    } catch (e) {
      print('⚠️ Error getting recent symptoms: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> addSymptom({
    required String symptom,
    required int severity,
    String? notes,
    DateTime? date,
    List<String>? tags,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final data = {
        'symptom': symptom,
        'severity': severity,
        'notes': notes ?? '',
        'date': date ?? FieldValue.serverTimestamp(),
        'tags': tags ?? [],
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('symptoms')
          .add(data);

      await _cache.remove('symptoms_${user.uid}');

      return {
        'id': docRef.id,
        ...data,
      };
    } catch (e) {
      print('⚠️ Error adding symptom: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> analyzeSymptoms(List<String> symptoms) async {
    // تحليل الأعراض باستخدام قاعدة معرفية بسيطة
    final analysis = <String, dynamic>{
      'symptoms': symptoms,
      'count': symptoms.length,
    };

    if (symptoms.contains('حمى') && symptoms.contains('سعال')) {
      analysis['condition'] = 'نزلة برد أو إنفلونزا';
      analysis['severity'] = 'متوسط';
      analysis['advice'] = 'خذ قسطاً من الراحة، اشرب السوائل الدافئة، تناول مسكنات الألم';
      analysis['recommendation'] = 'مراجعة الطبيب إذا استمرت الأعراض أكثر من 3 أيام';
      analysis['medications'] = ['باراسيتامول', 'أدوية السعال', 'مضادات احتقان'];
    } else if (symptoms.contains('صداع') && symptoms.contains('دوخة')) {
      analysis['condition'] = 'إجهاد أو جفاف';
      analysis['severity'] = 'خفيف';
      analysis['advice'] = 'اشرب الماء، استرح في مكان مظلم، تجنب الضوضاء';
      analysis['recommendation'] = 'إذا استمر الصداع، استشر طبيبك';
      analysis['medications'] = ['مسكنات الألم', 'شرب الماء'];
    } else if (symptoms.contains('ألم في البطن') && symptoms.contains('غثيان')) {
      analysis['condition'] = 'اضطراب في المعدة';
      analysis['severity'] = 'متوسط';
      analysis['advice'] = 'تناول وجبات خفيفة، تجنب الأطعمة الدسمة، اشرب السوائل';
      analysis['recommendation'] = 'راجع الطبيب إذا كان الألم شديداً';
      analysis['medications'] = ['مضادات الحموضة', 'السوائل'];
    } else if (symptoms.isEmpty) {
      analysis['condition'] = 'لا توجد أعراض';
      analysis['severity'] = 'لا شيء';
      analysis['advice'] = 'أنت بحالة جيدة، استمر في الحفاظ على صحتك';
      analysis['recommendation'] = 'استمر في نمط الحياة الصحي';
      analysis['medications'] = [];
    } else {
      analysis['condition'] = 'أعراض متنوعة';
      analysis['severity'] = 'خفيف إلى متوسط';
      analysis['advice'] = 'راقب الأعراض، احصل على قسط كافٍ من الراحة';
      analysis['recommendation'] = 'إذا تفاقمت الأعراض، استشر طبيبك';
      analysis['medications'] = ['الراحة', 'السوائل'];
    }

    return analysis;
  }

  Stream<List<Map<String, dynamic>>> watchRecentSymptoms() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('symptoms')
        .orderBy('date', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {
              'id': doc.id,
              ...doc.data(),
            };
          }).toList();
        });
  }
}
