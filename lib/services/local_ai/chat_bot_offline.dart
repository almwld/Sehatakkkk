import 'dart:math';
import 'package:sehatak/services/local_ai/medical_knowledge_local.dart';

class ChatBotOffline {
  final MedicalKnowledgeLocal _knowledge = MedicalKnowledgeLocal();
  final Random _random = Random();
  String _sessionId = '';
  List<Map<String, dynamic>> _conversationHistory = [];

  ChatBotOffline({String? sessionId}) {
    _sessionId = sessionId ?? DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ============================================================
  // 🎯 تهيئة البوت
  // ============================================================

  Future<void> initialize() async {
    await _knowledge.initializeOfflineData();
    // ✅ تحميل المحادثة السابقة
    _conversationHistory = await _knowledge.getConversation(_sessionId);
  }

  // ============================================================
  // 💬 معالجة الرسالة
  // ============================================================

  Future<Map<String, dynamic>> respond(String message) async {
    final msgLower = message.toLowerCase().trim();

    // ✅ حفظ رسالة المستخدم
    await _knowledge.saveMessage(
      sessionId: _sessionId,
      message: message,
      isUser: true,
    );
    _conversationHistory.add({
      'text': message,
      'isUser': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // ✅ معالجة الطوارئ أولاً
    if (_isEmergency(msgLower)) {
      final response = _handleEmergency(msgLower);
      await _saveBotResponse(response);
      return response;
    }

    // ✅ البحث عن دواء
    final drug = await _knowledge.searchDrug(msgLower);
    if (drug != null) {
      final response = _formatDrugResponse(drug);
      await _saveBotResponse(response);
      return response;
    }

    // ✅ البحث عن مرض
    final disease = await _knowledge.getDisease(msgLower);
    if (disease != null) {
      final response = _formatDiseaseResponse(disease);
      await _saveBotResponse(response);
      return response;
    }

    // ✅ البحث عن إسعافات أولية
    final firstAid = await _knowledge.getFirstAid(msgLower);
    if (firstAid != null) {
      final response = _formatFirstAidResponse(firstAid);
      await _saveBotResponse(response);
      return response;
    }

    // ✅ الأنماط المعروفة
    final patternResponse = _checkPatterns(msgLower);
    if (patternResponse != null) {
      await _saveBotResponse(patternResponse);
      return patternResponse;
    }

    // ✅ رد افتراضي مع نصيحة
    final tips = await _knowledge.getRandomTips(1);
    final tip = tips.isNotEmpty ? tips.first : 'حافظ على صحتك 💚';
    final response = _formatDefaultResponse(tip);
    await _saveBotResponse(response);
    return response;
  }

  // ============================================================
  // 🚨 معالجة الطوارئ
  // ============================================================

  bool _isEmergency(String message) {
    final emergencyWords = [
      'طوارئ', 'نزيف', 'اختناق', 'غيبوبة', 'ألم صدر',
      'ضيق تنفس', 'حساسية شديدة', 'ضربة شمس', 'تسمم',
      'emergency', 'urgent', 'heart attack', 'stroke'
    ];
    return emergencyWords.any((word) => message.contains(word));
  }

  Map<String, dynamic> _handleEmergency(String message) {
    // ✅ البحث عن إسعافات أولية
    final firstAid = _knowledge.getFirstAid(message);
    if (firstAid != null) {
      return {
        'response': '🚨 حالة طارئة!\n\n${_formatFirstAidResponse(firstAid)}',
        'type': 'urgent',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    }

    return {
      'response': '''
🚨 حالة طارئة!

• اتصل فوراً على 1122 📞
• اذهب لأقرب مستشفى 🏥
• استخدم زر SOS في التطبيق 🆘

⚠️ لا تنتظر! الطوارئ الطبية تحتاج استجابة فورية.
''',
      'type': 'urgent',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // ============================================================
  // 🎨 تنسيق الردود
  // ============================================================

  String _formatDrugResponse(Map<String, dynamic> drug) {
    return '''
💊 ${drug['name']} (${drug['name_en']})

📋 التصنيف: ${drug['category']}
💊 الجرعة للبالغين: ${drug['dose_adult']}
👶 الجرعة للأطفال: ${drug['dose_child']}
⚠️ الحد الأقصى اليومي: ${drug['max_daily']}
🤰 الحمل: ${drug['pregnancy']}
🤱 الرضاعة: ${drug['breastfeeding']}
⚠️ الآثار الجانبية: ${drug['side_effects']}
🔄 التداخلات الدوائية: ${drug['interactions']}
🚫 موانع الاستعمال: ${drug['contraindications']}
📝 ملاحظات: ${drug['notes']}
🚨 الجرعة الزائدة: ${drug['overdose']}

⚠️ هذه معلومات عامة - استشر طبيبك قبل تناول أي دواء
''';
  }

  String _formatDiseaseResponse(Map<String, dynamic> disease) {
    return '''
🩺 ${disease['name']}

📋 التصنيف: ${disease['category']}
🩺 الأعراض: ${disease['symptoms']}
🔬 الأسباب: ${disease['causes']}
💊 العلاج: ${disease['treatment']}
⚠️ المضاعفات: ${disease['complications']}
🛡️ الوقاية: ${disease['prevention']}
📊 النطاق الطبيعي: ${disease['normal_range']}
👨‍⚕️ متى تزور الطبيب: ${disease['when_to_see_doctor']}
🔴 علامات الطوارئ: ${disease['emergency_warning']}

⚠️ هذا تحليل أولي فقط - لا يعوض عن الاستشارة الطبية
''';
  }

  String _formatFirstAidResponse(Map<String, dynamic> firstAid) {
    return '''
🚑 ${firstAid['name']}:

${firstAid['steps']}

${firstAid['warnings'] ?? ''}
''';
  }

  String _formatDefaultResponse(String tip) {
    return '''
شكراً لتواصلك! 🙏

💡 نصيحة اليوم:
$tip

👨‍⚕️ للاستشارة الطبية الحقيقية، يرجى حجز موعد مع طبيب متخصص.
🆘 في الحالات الطارئة، اتصل على 1122 فوراً.

💬 يمكنك سؤالي عن:
• الأدوية 💊
• الأمراض 🩺
• الإسعافات الأولية 🚑
• نصائح صحية 💡
• خدمات التطبيق 📱
''';
  }

  // ============================================================
  // 📋 الأنماط المعروفة
  // ============================================================

  Map<String, dynamic>? _checkPatterns(String message) {
    final patterns = {
      r'\b(مرحب|هلا|سلام|اهلا|صباح الخير|مساء الخير)\b': {
        'response': 'وعليكم السلام ورحمة الله وبركاته! 🌸\n\nكيف يمكنني مساعدتك اليوم؟',
        'type': 'greeting',
      },
      r'\b(شكر|جزاك|thank|thanks)\b': {
        'response': 'العفو! 🌸\n\nسعيد بمساعدتك. تذكر أنا هنا دائماً.\n\n💚 هل هناك شيء آخر يمكنني مساعدتك فيه؟',
        'type': 'greeting',
      },
      r'\b(وداع|باي|مع السلام|الى اللقاء)\b': {
        'response': 'في أمان الله! 👋\n\nدمت بصحة وعافية 🤍',
        'type': 'greeting',
      },
      r'\b(احجز|موعد|حجز|appointment)\b': {
        'response': '📅 لحجز موعد:\n1. اذهب لقسم "الأطباء" 👨‍⚕️\n2. اختر التخصص والطبيب\n3. اختر التاريخ والوقت\n4. أكد الحجز',
        'type': 'help',
      },
    };

    for (var entry in patterns.entries) {
      final pattern = RegExp(entry.key, caseSensitive: false);
      if (pattern.hasMatch(message)) {
        return {
          'response': entry.value['response'],
          'type': entry.value['type'],
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };
      }
    }
    return null;
  }

  // ============================================================
  // 💾 حفظ رد البوت
  // ============================================================

  Future<void> _saveBotResponse(Map<String, dynamic> response) async {
    final text = response['response'] as String;
    await _knowledge.saveMessage(
      sessionId: _sessionId,
      message: text,
      isUser: false,
      type: response['type'] as String?,
    );
    _conversationHistory.add({
      'text': text,
      'isUser': false,
      'type': response['type'],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ============================================================
  // 📊 إحصائيات
  // ============================================================

  Future<Map<String, int>> getStats() async {
    return await _knowledge._storage.getStats();
  }

  // ============================================================
  // 🗑️ تنظيف
  // ============================================================

  Future<void> clearHistory() async {
    await _knowledge.clearConversation(_sessionId);
    _conversationHistory.clear();
  }

  void dispose() {
    _knowledge.dispose();
  }
}
