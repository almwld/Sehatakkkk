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

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        return doc.data() ?? {};
      }
      return {};
    } catch (e) {
      print('⚠️ Error getting user health data: $e');
      return {};
    }
  }

  Map<String, dynamic> _generateRecommendation(Map<String, dynamic> userData) {
    // تحليل بسيط لتوليد توصيات (يمكن استخدام AI حقيقي هنا)
    final recommendations = [
      {
        'title': 'تحسين جودة النوم',
        'description': 'بناءً على نمط نومك، نوصي بالنوم 7-8 ساعات يومياً والابتعاد عن الشاشات قبل النوم بساعة.',
        'category': 'النوم',
        'priority': 'عالية',
        'actions': [
          'حدد موعد نوم ثابت',
          'تجنب الكافيين بعد الساعة 4 م',
          'مارس تمارين الاسترخاء',
        ],
      },
      {
        'title': 'نظام غذائي صحي',
        'description': 'نوصي بتناول 5 حصص من الفواكه والخضار يومياً، وشرب 8 أكواب من الماء، وتقليل السكريات.',
        'category': 'التغذية',
        'priority': 'عالية',
        'actions': [
          'تناول وجبات متوازنة',
          'اشرب الماء بانتظام',
          'قلل من الوجبات السريعة',
        ],
      },
      {
        'title': 'تمارين يومية',
        'description': 'المشي 30 دقيقة يومياً يقلل خطر أمراض القلب والسكري. جرب صعود الدرج بدلاً من المصعد.',
        'category': 'اللياقة',
        'priority': 'متوسطة',
        'actions': [
          'امشِ 30 دقيقة يومياً',
          'استخدم الدرج بدلاً من المصعد',
          'مارس تمارين التمدد',
        ],
      },
      {
        'title': 'إدارة التوتر',
        'description': 'ممارسة التأمل والتنفس العميق 10 دقائق يومياً يساعد في تقليل التوتر وتحسين الصحة النفسية.',
        'category': 'الصحة النفسية',
        'priority': 'متوسطة',
        'actions': [
          'مارس التأمل يومياً',
          'خذ فترات راحة من العمل',
          'تواصل مع الأصدقاء والعائلة',
        ],
      },
    ];

    // اختيار توصية عشوائية
    final index = DateTime.now().second % recommendations.length;
    return recommendations[index];
  }

  Map<String, dynamic> _getDefaultRecommendation() {
    return {
      'title': 'حافظ على صحتك',
      'description': 'نوصي بممارسة الرياضة بانتظام وتناول الطعام الصحي وشرب الماء بكثرة.',
      'category': 'عام',
      'priority': 'متوسطة',
      'actions': [
        'مارس الرياضة 3 مرات أسبوعياً',
        'تناول وجبات صحية متوازنة',
        'اشرب 8 أكواب ماء يومياً',
      ],
    };
  }

  Future<List<Map<String, dynamic>>> getRecommendationsByCategory(String category) async {
    try {
      // محاكاة جلب توصيات حسب الفئة
      final allRecommendations = [
        {
          'title': 'تحسين النوم',
          'description': 'نمط نوم صحي يحسن الصحة العامة',
          'category': 'النوم',
        },
        {
          'title': 'التغذية المتوازنة',
          'description': 'نظام غذائي صحي يحسن المناعة',
          'category': 'التغذية',
        },
        {
          'title': 'التمارين اليومية',
          'description': 'الرياضة تحسن الصحة النفسية والجسدية',
          'category': 'اللياقة',
        },
        {
          'title': 'التأمل والاسترخاء',
          'description': 'التأمل يقلل التوتر والقلق',
          'category': 'الصحة النفسية',
        },
      ];

      if (category == 'الكل') {
        return allRecommendations;
      }

      return allRecommendations
          .where((r) => r['category'] == category)
          .toList();
    } catch (e) {
      print('⚠️ Error getting recommendations by category: $e');
      return [];
    }
  }
}
