import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AIRecommendationService {
  static final AIRecommendationService _instance = AIRecommendationService._internal();
  factory AIRecommendationService() => _instance;
  AIRecommendationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    print('✅ AIRecommendationService initialized');
  }

  Future<Map<String, dynamic>> getRecommendation() async {
    try {
      final user = _auth.currentUser;
      
      // جلب بيانات المستخدم الصحية
      final userData = await _getUserHealthData();
      
      // تحليل البيانات وإنتاج توصية
      return _generateRecommendation(userData);
    } catch (e) {
      print('⚠️ Error getting recommendation: $e');
      return _getDefaultRecommendation();
    }
  }

  Future<Map<String, dynamic>> _getUserHealthData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return {};

      final results = await Future.wait([
        _firestore.collection('users').doc(user.uid).get(),
        _firestore.collection('health_metrics').doc(user.uid).get(),
      ]);
      final userData = results[0].data() ?? <String, dynamic>{};
      final metrics = results[1].data() ?? <String, dynamic>{};
      return {...userData, 'health_metrics': metrics};
    } catch (e) {
      print('⚠️ Error getting user health data: $e');
      return {};
    }
  }

  Map<String, dynamic> _generateRecommendation(Map<String, dynamic> userData) {
    final metrics = Map<String, dynamic>.from(
      userData['health_metrics'] is Map ? userData['health_metrics'] as Map : const {},
    );
    final sleep = (metrics['sleep'] as num?)?.toDouble();
    final steps = (metrics['steps'] as num?)?.toDouble();
    final oxygen = (metrics['bloodOxygen'] as num?)?.toDouble();
    if (oxygen != null && oxygen < 95) {
      return {'title':'مراجعة قراءة الأكسجين','description':'القراءة المسجلة أقل من 95%. أعد القياس بجهاز موثوق، وإذا استمرت القراءة المنخفضة فاطلب تقييماً طبياً.','category':'الأكسجين','priority':'عالية','source':'health_metrics'};
    }
    if (sleep != null && sleep < 7) {
      return {'title':'تحسين النوم','description':'آخر مدة نوم مسجلة أقل من 7 ساعات. حاول تثبيت موعد النوم وتقليل المنبهات والشاشات قبل النوم.','category':'النوم','priority':'متوسطة','source':'health_metrics'};
    }
    if (steps != null && steps < 5000) {
      return {'title':'زيادة النشاط اليومي','description':'عدد الخطوات المسجل منخفض نسبياً. زد الحركة تدريجياً بما يناسب حالتك الصحية.','category':'النشاط','priority':'متوسطة','source':'health_metrics'};
    }
    return {'title':'استمر في متابعة مؤشراتك','description':'لا توجد إشارة واضحة من القياسات الحالية تستدعي تنبيهاً. استمر في تسجيل القياسات ومراجعتها مع مختص عند الحاجة.','category':'عام','priority':'منخفضة','source':'health_metrics'};
  }

  Map<String, dynamic> _getDefaultRecommendation() {
    return {'title':'ابدأ بتسجيل مؤشراتك','description':'سجّل قياساتك الصحية الفعلية ليتم عرض إرشادات مبنية على البيانات المتاحة.','category':'عام','priority':'منخفضة','source':'health_metrics'};
  }

  Future<List<Map<String, dynamic>>> getRecommendationsByCategory(String category) async {
    try {
      final data = await _getUserHealthData();
      final metrics = Map<String, dynamic>.from(
        data['health_metrics'] is Map ? data['health_metrics'] as Map : const {},
      );
      final all = <Map<String, dynamic>>[
        _generateRecommendation({'health_metrics': metrics}),
      ];
      if (category == 'الكل') return all;
      return all.where((item) => item['category'] == category).toList();
    } catch (_) {
      return [];
    }
  }
}
