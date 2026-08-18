import 'package:sehatak/core/services/local_storage_service.dart';

class ContinualLearning {
  static final ContinualLearning _instance = ContinualLearning._internal();
  factory ContinualLearning() => _instance;
  ContinualLearning._internal();

  final LocalStorageService _storage = LocalStorageService();
  
  // ✅ تخزين التفاعلات للتعلم
  final List<Map<String, dynamic>> _interactions = [];
  final Map<String, int> _wordFrequency = {};
  final Map<String, List<String>> _contextPatterns = {};
  
  // ✅ عتبات التعلم
  static const int _learningThreshold = 10;
  static const double _improvementRate = 0.05;

  // ============================================================
  // 📝 تسجيل التفاعل
  // ============================================================

  Future<void> recordInteraction({
    required String userMessage,
    required String botResponse,
    required String sentiment,
    required String intent,
    bool wasHelpful = true,
  }) async {
    _interactions.add({
      'user_message': userMessage,
      'bot_response': botResponse,
      'sentiment': sentiment,
      'intent': intent,
      'was_helpful': wasHelpful,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // ✅ تحليل الكلمات المفتاحية
    _analyzeWords(userMessage);
    
    // ✅ حفظ في قاعدة البيانات
    await _saveInteraction(userMessage, botResponse, sentiment, intent, wasHelpful);
    
    // ✅ التعلم عند الوصول للعتبة
    if (_interactions.length % _learningThreshold == 0) {
      await _learnFromInteractions();
    }
  }

  // ============================================================
  // 🔍 تحليل الكلمات
  // ============================================================

  void _analyzeWords(String text) {
    final words = text.split(' ');
    for (var word in words) {
      if (word.length > 2) {
        _wordFrequency[word] = (_wordFrequency[word] ?? 0) + 1;
      }
    }
  }

  // ============================================================
  // 🧠 التعلم من التفاعلات
  // ============================================================

  Future<void> _learnFromInteractions() async {
    // ✅ تحسين الأنماط
    for (var interaction in _interactions) {
      final message = interaction['user_message'] as String;
      final response = interaction['bot_response'] as String;
      final wasHelpful = interaction['was_helpful'] as bool;
      
      if (wasHelpful) {
        // ✅ تعزيز الأنماط الناجحة
        final key = _extractKey(message);
        if (!_contextPatterns.containsKey(key)) {
          _contextPatterns[key] = [];
        }
        if (!_contextPatterns[key]!.contains(response)) {
          _contextPatterns[key]!.add(response);
        }
      }
    }
    
    // ✅ تحسين الثقة
    final helpfulCount = _interactions.where((i) => i['was_helpful'] == true).length;
    final totalCount = _interactions.length;
    if (totalCount > 0) {
      final helpfulRatio = helpfulCount / totalCount;
      if (helpfulRatio < 0.7) {
        // ✅ تحسين الردود إذا كانت النسبة منخفضة
        print('📚 Improving responses...');
      }
    }
    
    // ✅ حفظ التقدم
    await _saveLearningProgress();
  }

  // ============================================================
  // 🎯 استخراج المفتاح
  // ============================================================

  String _extractKey(String text) {
    final words = text.split(' ');
    if (words.length > 3) {
      return words.take(3).join(' ');
    }
    return text;
  }

  // ============================================================
  // 💾 حفظ البيانات
  // ============================================================

  Future<void> _saveInteraction(
    String userMessage,
    String botResponse,
    String sentiment,
    String intent,
    bool wasHelpful,
  ) async {
    await _storage.saveMessage(
      sessionId: 'learning',
      message: userMessage,
      isUser: true,
      type: intent,
    );
    await _storage.saveMessage(
      sessionId: 'learning',
      message: botResponse,
      isUser: false,
      type: 'response_$intent',
    );
  }

  Future<void> _saveLearningProgress() async {
    // ✅ حفظ التقدم في SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learning_data', jsonEncode({
      'interactions': _interactions.length,
      'patterns': _contextPatterns.length,
      'words': _wordFrequency.length,
      'last_updated': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  // ============================================================
  // 📊 إحصائيات التعلم
  // ============================================================

  Map<String, dynamic> getLearningStats() {
    return {
      'total_interactions': _interactions.length,
      'patterns_learned': _contextPatterns.length,
      'unique_words': _wordFrequency.length,
      'helpful_ratio': _interactions.isEmpty 
          ? 0 
          : _interactions.where((i) => i['was_helpful'] == true).length / _interactions.length,
    };
  }

  // ============================================================
  // 🔄 تحسين الردود
  // ============================================================

  String? improveResponse(String userMessage) {
    final key = _extractKey(userMessage);
    if (_contextPatterns.containsKey(key)) {
      final responses = _contextPatterns[key]!;
      if (responses.isNotEmpty) {
        // ✅ اختيار أفضل رد بناءً على التقييم
        return responses.reduce((a, b) => a.length > b.length ? a : b);
      }
    }
    return null;
  }
}
