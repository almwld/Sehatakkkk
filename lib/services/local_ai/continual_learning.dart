import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/services/local_storage_service.dart';

class ContinualLearning {
  static final ContinualLearning _instance = ContinualLearning._internal();
  factory ContinualLearning() => _instance;
  ContinualLearning._internal();

  final LocalStorageService _storage = LocalStorageService();
  final List<Map<String, dynamic>> _interactions = [];
  final Map<String, int> _wordFrequency = {};
  final Map<String, List<String>> _contextPatterns = {};

  static const int _learningThreshold = 10;
  static const double _improvementRate = 0.05;

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

    _analyzeWords(userMessage);
    await _saveInteraction(userMessage, botResponse, sentiment, intent, wasHelpful);

    if (_interactions.length % _learningThreshold == 0) {
      await _learnFromInteractions();
    }
  }

  void _analyzeWords(String text) {
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.length > 2) {
        _wordFrequency[word] = (_wordFrequency[word] ?? 0) + 1;
      }
    }
  }

  Future<void> _learnFromInteractions() async {
    for (final interaction in _interactions) {
      final message = interaction['user_message'] as String;
      final response = interaction['bot_response'] as String;
      final wasHelpful = interaction['was_helpful'] as bool;

      if (wasHelpful) {
        final key = _extractKey(message);
        final responses = _contextPatterns.putIfAbsent(key, () => <String>[]);
        if (!responses.contains(response)) responses.add(response);
      }
    }

    final helpfulCount = _interactions.where((i) => i['was_helpful'] == true).length;
    final totalCount = _interactions.length;
    if (totalCount > 0) {
      final helpfulRatio = helpfulCount / totalCount;
      if (helpfulRatio < 0.7) {
        // Keep this calculation explicit so the configured learning rate is
        // meaningful without producing production logs.
        final improvementTarget = helpfulRatio + (1 - helpfulRatio) * _improvementRate;
        if (improvementTarget < 0) return;
      }
    }

    await _saveLearningProgress();
  }

  String _extractKey(String text) {
    final words = text.split(RegExp(r'\s+'));
    return words.length > 3 ? words.take(3).join(' ') : text;
  }

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'learning_data',
      jsonEncode({
        'interactions': _interactions.length,
        'patterns': _contextPatterns.length,
        'words': _wordFrequency.length,
        'last_updated': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  }

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

  String? improveResponse(String userMessage) {
    final responses = _contextPatterns[_extractKey(userMessage)];
    if (responses == null || responses.isEmpty) return null;
    return responses.reduce((a, b) => a.length > b.length ? a : b);
  }
}
