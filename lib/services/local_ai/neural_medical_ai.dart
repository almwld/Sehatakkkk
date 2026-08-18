import 'dart:math';
import 'package:sehatak/core/constants/yemeni_dialect.dart';
import 'package:sehatak/services/local_ai/medical_knowledge_local.dart';
import 'package:sehatak/services/local_ai/chat_bot_offline.dart';

// ============================================================
//   🧠 NeuralMedicalAI - محاكاة الذكاء الاصطناعي
//   يحاكي نماذج مثل ChatGPT و Gemini ولكن على الجهاز
// ============================================================

class NeuralMedicalAI {
  static final NeuralMedicalAI _instance = NeuralMedicalAI._internal();
  factory NeuralMedicalAI() => _instance;
  NeuralMedicalAI._internal();

  final Random _random = Random();
  final MedicalKnowledgeLocal _knowledge = MedicalKnowledgeLocal();
  final ChatBotOffline _chatBot = ChatBotOffline();
  
  // ✅ حفظ السياق والمستخدم
  final Map<String, Map<String, dynamic>> _userProfiles = {};
  final Map<String, List<Map<String, dynamic>>> _conversationContext = {};
  
  // ✅ الأنماط العصبية (محاكاة التعلم)
  final Map<String, List<String>> _neuralPatterns = {};
  
  // ✅ درجة الثقة في الردود
  double _confidenceThreshold = 0.7;

  // ============================================================
  // 🎯 معالجة الرسالة مع الذكاء الاصطناعي
  // ============================================================

  Future<Map<String, dynamic>> processMessage({
    required String message,
    required String userId,
    String? userProfile,
  }) async {
    // ✅ تحليل المشاعر
    final sentiment = _analyzeSentiment(message);
    
    // ✅ تحليل النية
    final intent = _analyzeIntent(message);
    
    // ✅ الحصول على السياق
    final context = _getContext(userId);
    
    // ✅ توليد الرد الذكي
    final response = await _generateSmartResponse(
      message: message,
      userId: userId,
      sentiment: sentiment,
      intent: intent,
      context: context,
    );
    
    // ✅ حفظ السياق
    _saveContext(userId, message, response);
    
    // ✅ التعلم من التفاعل
    _learnFromInteraction(message, response);
    
    return {
      'response': response,
      'sentiment': sentiment,
      'intent': intent,
      'confidence': _confidenceThreshold,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ============================================================
  // 🎭 تحليل المشاعر
  // ============================================================

  String _analyzeSentiment(String message) {
    final positive = ['الحمد لله', 'بخير', 'تحسن', 'شكراً', 'راحة', 'طيب', 'زين', 'كويس'];
    final negative = ['تعبان', 'يوجع', 'ألم', 'حمى', 'كحة', 'تعب', 'متعب', 'صداع', 'غثيان'];
    final urgent = ['طوارئ', 'نزيف', 'اختناق', 'غيبوبة', 'ألم صدر', 'ضيق تنفس'];
    
    final msgLower = message.toLowerCase();
    
    if (urgent.any((word) => msgLower.contains(word))) return 'urgent';
    if (negative.any((word) => msgLower.contains(word))) return 'negative';
    if (positive.any((word) => msgLower.contains(word))) return 'positive';
    return 'neutral';
  }

  // ============================================================
  // 🎯 تحليل النية
  // ============================================================

  String _analyzeIntent(String message) {
    final msgLower = message.toLowerCase();
    
    if (msgLower.contains('دوا') || msgLower.contains('علاج') || msgLower.contains('حبوب')) {
      return 'drug_info';
    }
    if (msgLower.contains('مرض') || msgLower.contains('أعراض') || msgLower.contains('حالة')) {
      return 'disease_info';
    }
    if (msgLower.contains('طوارئ') || msgLower.contains('إسعاف') || msgLower.contains('نزيف')) {
      return 'emergency';
    }
    if (msgLower.contains('نوم') || msgLower.contains('أرق') || msgLower.contains('تعب')) {
      return 'health_tip';
    }
    if (msgLower.contains('موعد') || msgLower.contains('حجز') || msgLower.contains('طبيب')) {
      return 'appointment';
    }
    if (msgLower.contains('شكر') || msgLower.contains('مشكور')) {
      return 'gratitude';
    }
    if (msgLower.contains('سلام') || msgLower.contains('مرحب') || msgLower.contains('هلا')) {
      return 'greeting';
    }
    return 'general';
  }

  // ============================================================
  // 📝 توليد الرد الذكي
  // ============================================================

  Future<String> _generateSmartResponse({
    required String message,
    required String userId,
    required String sentiment,
    required String intent,
    required List<Map<String, dynamic>> context,
  }) async {
    String baseResponse = '';
    
    // ✅ تخصيص الرد حسب النية
    switch (intent) {
      case 'drug_info':
        baseResponse = await _handleDrugQuery(message);
        break;
      case 'disease_info':
        baseResponse = await _handleDiseaseQuery(message);
        break;
      case 'emergency':
        baseResponse = _handleEmergency(message);
        break;
      case 'health_tip':
        baseResponse = await _handleHealthTip(message);
        break;
      case 'appointment':
        baseResponse = _handleAppointment(message);
        break;
      case 'gratitude':
        baseResponse = _handleGratitude(message);
        break;
      case 'greeting':
        baseResponse = _handleGreeting(message);
        break;
      default:
        baseResponse = await _handleGeneralQuery(message);
    }
    
    // ✅ تخصيص حسب المشاعر
    if (sentiment == 'negative') {
      baseResponse = _addEmpathy(baseResponse);
    }
    if (sentiment == 'urgent') {
      baseResponse = _addUrgency(baseResponse);
    }
    
    // ✅ تخصيص حسب السياق
    baseResponse = _personalizeWithContext(baseResponse, context);
    
    // ✅ تخصيص حسب المستخدم
    baseResponse = _personalizeForUser(baseResponse, userId);
    
    // ✅ إضافة لهجة يمنية
    baseResponse = _addYemeniDialect(baseResponse);
    
    // ✅ إضافة لمسة إنسانية
    baseResponse = _addHumanTouch(baseResponse);
    
    return baseResponse;
  }

  // ============================================================
  // 💊 معالجة استفسارات الأدوية
  // ============================================================

  Future<String> _handleDrugQuery(String message) async {
    final drug = await _knowledge.searchDrug(message);
    if (drug != null) {
      return '''
💊 ${drug['name']} (${drug['name_en']})

📋 التصنيف: ${drug['category']}
💊 الجرعة: ${drug['dose_adult']}
👶 جرعة الأطفال: ${drug['dose_child']}
⚠️ الآثار الجانبية: ${drug['side_effects']}
🔄 التفاعلات: ${drug['interactions']}
🚫 موانع الاستعمال: ${drug['contraindications']}
📝 ملاحظات: ${drug['notes']}

⚠️ هذا مجرد معلومات عامة، استشر طبيبك قبل الاستخدام
''';
    }
    return 'ما عندي معلومات عن هذا الدوا ياخوي، لكن أقدر أسأل لك الدكتور 👨‍⚕️';
  }

  // ============================================================
  // 🩺 معالجة استفسارات الأمراض
  // ============================================================

  Future<String> _handleDiseaseQuery(String message) async {
    final disease = await _knowledge.getDisease(message);
    if (disease != null) {
      return '''
🩺 ${disease['name']}

🩺 الأعراض: ${disease['symptoms']}
🔬 الأسباب: ${disease['causes']}
💊 العلاج: ${disease['treatment']}
⚠️ المضاعفات: ${disease['complications']}
🛡️ الوقاية: ${disease['prevention']}
👨‍⚕️ متى تزور الطبيب: ${disease['when_to_see_doctor']}

⚠️ هذا تحليل أولي، لا يعوض عن استشارة الطبيب
''';
    }
    return 'ما عندي معلومات عن هذا المرض، لكن أقدر أحولك لدكتور متخصص 👨‍⚕️';
  }

  // ============================================================
  // 🚨 معالجة الطوارئ
  // ============================================================

  String _handleEmergency(String message) {
    return '''
🚨 حالة طارئة!

• اتصل فوراً على 1122 📞
• اذهب لأقرب مستشفى 🏥
• استخدم زر SOS في التطبيق 🆘
• لا تنتظر! كل ثانية مهمة ⏱️

${_getEmergencyAdvice(message)}

الله يشفيك ويعافيك 🤲
''';
  }

  String _getEmergencyAdvice(String message) {
    if (message.contains('نزيف')) {
      return '🩹 اضغط على الجرح بقطعة قماش نظيفة وارفع الجزء المصاب';
    }
    if (message.contains('اختناق')) {
      return '🫁 استخدم مناورة هيمليخ (دفع البطن)';
    }
    if (message.contains('ألم صدر')) {
      return '❤️ اجلس في وضعية مريحة، لا تتحرك كثيراً، اتصل بالطوارئ فوراً';
    }
    return '⚠️ ابقَ هادئاً، اتصل بالطوارئ، اتبع تعليماتهم';
  }

  // ============================================================
  // 💡 معالجة النصائح الصحية
  // ============================================================

  Future<String> _handleHealthTip(String message) async {
    final tips = await _knowledge.getRandomTips(2);
    if (tips.isNotEmpty) {
      return '''
💡 نصيحة صحية:

${tips.join('\n\n')}

✨ تذكر: صحتك تاج على رؤوس الأصحاء
''';
    }
    return '💡 خذ قسطاً من الراحة، اشرب مي، وتوكل على الله';
  }

  // ============================================================
  // 📅 معالجة حجز المواعيد
  // ============================================================

  String _handleAppointment(String message) {
    return '''
📅 لحجز موعد:

1️⃣ اذهب لقسم "الأطباء" 👨‍⚕️
2️⃣ اختر التخصص المناسب
3️⃣ اختر الطبيب والوقت
4️⃣ أكد الحجز

💡 تقدر تحجز موعد مع دكتور متخصص في أي وقت
''';
  }

  // ============================================================
  // 👋 معالجة التحيات
  // ============================================================

  String _handleGreeting(String message) {
    final greetings = [
      'هلا والله! كيف الحال يا غالي؟ 🌸\nكيف أقدر أساعدك اليوم؟',
      'السلام عليكم! كيف صحتك اليوم؟ 💚\nأنا هنا لخدمتك',
      'أهلاً وسهلاً! شو أخبارك؟ 😊\nكيف أقدر أكون معين لك؟',
      'مرحباً بك! الحمد لله على السلامة 🙏\nتحدث عن أي مشكلة صحية',
    ];
    return greetings[_random.nextInt(greetings.length)];
  }

  // ============================================================
  // 🙏 معالجة الشكر
  // ============================================================

  String _handleGratitude(String message) {
    final responses = [
      'العفو يا غالي! هذا واجبنا 🤍\nهل في شيء ثاني؟',
      'الله يخليك! أنا هنا لخدمتك دائماً 🌸\nكيف أقدر أساعدك زيادة؟',
      'مشكور على كلامك الطيب 🙏\nتذكر: صحتك تهمنا',
      'الله يبارك فيك! 💚\nأتمنى لك دوام الصحة والعافية',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  // ============================================================
  // 📝 معالجة الاستفسارات العامة
  // ============================================================

  Future<String> _handleGeneralQuery(String message) async {
    // ✅ البحث في قاعدة المعرفة
    final drug = await _knowledge.searchDrug(message);
    if (drug != null) return _formatDrugResponse(drug);
    
    final disease = await _knowledge.getDisease(message);
    if (disease != null) return _formatDiseaseResponse(disease);
    
    // ✅ نصيحة عامة
    final tips = await _knowledge.getRandomTips(1);
    final tip = tips.isNotEmpty ? tips.first : 'حافظ على صحتك 💚';
    
    return '''
شكراً على سؤالك 🙏

💡 نصيحة اليوم:
$tip

🩺 إذا كان عندك أعراض معينة، وصفها لي بالتفصيل عشان أقدر أساعدك أكثر

👨‍⚕️ أو تقدر تحجز موعد مع دكتور متخصص
''';
  }

  // ============================================================
  // 🎨 تخصيص الردود
  // ============================================================

  String _addEmpathy(String response) {
    final empathy = [
      'الله يكون في عونك يا غالي 🤲',
      'أتفهم شعورك، الله يشفيك ويعافيك 💚',
      'لا تخاف، الأمور طيبة بإذن الله 🙏',
      'الله يكتب لك الشفاء العاجل 🤲',
    ];
    return '$response\n\n${empathy[_random.nextInt(empathy.length)]}';
  }

  String _addUrgency(String response) {
    return '''
🚨 تنبيه عاجل!

$response

⏱️ لا تتأخر في طلب المساعدة الطبية
''';
  }

  String _personalizeWithContext(String response, List<Map<String, dynamic>> context) {
    if (context.length > 3) {
      // ✅ تذكير بالسياق السابق
      final lastTopic = context.lastWhere(
        (msg) => !msg['isUser'],
        orElse: () => {'text': ''},
      );
      if (lastTopic['text'] != null && lastTopic['text'].toString().isNotEmpty) {
        // لا نضيف تذكير إذا كان الرد قصيراً
        if (response.length > 50) {
          return '$response\n\n💭 بناءً على كلامك السابق...';
        }
      }
    }
    return response;
  }

  String _personalizeForUser(String response, String userId) {
    // ✅ تخصيص حسب معلومات المستخدم
    if (_userProfiles.containsKey(userId)) {
      final profile = _userProfiles[userId]!;
      if (profile.containsKey('name')) {
        final name = profile['name'] as String;
        if (!response.contains(name) && response.length > 30) {
          return '$response\n\n$name، أنا معك خطوة بخطوة 💪';
        }
      }
    }
    return response;
  }

  String _addYemeniDialect(String response) {
    // ✅ تحويل إلى لهجة يمنية
    String result = YemeniDialect.toSanaaniDialect(response);
    
    // ✅ إضافة كلمات يمنية عشوائية
    if (_random.nextDouble() > 0.7) {
      result = YemeniDialect.addYemeniFlavor(result);
    }
    
    return result;
  }

  String _addHumanTouch(String response) {
    final touches = [
      '💚',
      '🌸',
      '🙏',
      '🤲',
      '😊',
      '✨',
      '💪',
      '🌹',
    ];
    if (!response.contains('💚') && !response.contains('🌸')) {
      return '$response ${touches[_random.nextInt(touches.length)]}';
    }
    return response;
  }

  // ============================================================
  // 📝 تنسيق الردود
  // ============================================================

  String _formatDrugResponse(Map<String, dynamic> drug) {
    return '''
💊 ${drug['name']} (${drug['name_en']})

📋 التصنيف: ${drug['category']}
💊 الجرعة: ${drug['dose_adult']}
⚠️ الآثار: ${drug['side_effects']}
🔄 التفاعلات: ${drug['interactions']}
🚫 موانع: ${drug['contraindications']}
📝 ملاحظات: ${drug['notes']}

⚠️ استشر طبيبك قبل الاستخدام
''';
  }

  String _formatDiseaseResponse(Map<String, dynamic> disease) {
    return '''
🩺 ${disease['name']}

🩺 الأعراض: ${disease['symptoms']}
🔬 الأسباب: ${disease['causes']}
💊 العلاج: ${disease['treatment']}
⚠️ المضاعفات: ${disease['complications']}
🛡️ الوقاية: ${disease['prevention']}
👨‍⚕️ متى تزور الطبيب: ${disease['when_to_see_doctor']}

⚠️ هذا تحليل أولي
''';
  }

  // ============================================================
  // 🧠 إدارة السياق والمستخدمين
  // ============================================================

  void _saveContext(String userId, String message, String response) {
    if (!_conversationContext.containsKey(userId)) {
      _conversationContext[userId] = [];
    }
    _conversationContext[userId]!.add({
      'user_message': message,
      'bot_response': response,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // ✅ الاحتفاظ بآخر 50 رسالة فقط
    if (_conversationContext[userId]!.length > 50) {
      _conversationContext[userId]!.removeAt(0);
    }
  }

  List<Map<String, dynamic>> _getContext(String userId) {
    return _conversationContext[userId] ?? [];
  }

  void updateUserProfile(String userId, Map<String, dynamic> profile) {
    _userProfiles[userId] = profile;
  }

  Map<String, dynamic>? getUserProfile(String userId) {
    return _userProfiles[userId];
  }

  // ============================================================
  // 📚 التعلم من التفاعلات
  // ============================================================

  void _learnFromInteraction(String message, String response) {
    // ✅ تحليل الكلمات المفتاحية
    final words = message.split(' ');
    for (var word in words) {
      if (word.length > 3) {
        if (!_neuralPatterns.containsKey(word)) {
          _neuralPatterns[word] = [];
        }
        if (!_neuralPatterns[word]!.contains(response.substring(0, 20))) {
          _neuralPatterns[word]!.add(response.substring(0, 20));
        }
      }
    }
    
    // ✅ تحسين الثقة مع كل تفاعل
    _confidenceThreshold = min(0.95, _confidenceThreshold + 0.001);
  }

  // ============================================================
  // 📊 إحصائيات
  // ============================================================

  Map<String, dynamic> getStats() {
    return {
      'users': _userProfiles.length,
      'conversations': _conversationContext.length,
      'total_messages': _conversationContext.values.fold(0, (sum, list) => sum + list.length),
      'patterns': _neuralPatterns.length,
      'confidence': _confidenceThreshold,
    };
  }
}
