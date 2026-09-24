import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Small bounded local conversation memory. No server and no API key.
class LocalDialogueState {
  static const _key = 'local_ai_dialogue_state_v1';
  static const _maxTurns = 12;

  String? topic;
  String? lastIntent;
  final Map<String, String> slots = <String, String>{};
  final List<String> recentUserMessages = <String>[];

  Future<void> update({
    String? topic,
    String? intent,
    Map<String, String> newSlots = const {},
    String? userMessage,
  }) async {
    if (topic != null && topic.isNotEmpty) this.topic = topic;
    if (intent != null && intent.isNotEmpty) lastIntent = intent;
    slots.addAll(newSlots);
    if (userMessage != null && userMessage.trim().isNotEmpty) {
      recentUserMessages.add(userMessage.trim());
      if (recentUserMessages.length > _maxTurns) {
        recentUserMessages.removeAt(0);
      }
    }
    await save();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode({
      'topic': topic,
      'lastIntent': lastIntent,
      'slots': slots,
      'recentUserMessages': recentUserMessages,
    }));
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      topic = data['topic']?.toString();
      lastIntent = data['lastIntent']?.toString();
      slots
        ..clear()
        ..addAll((data['slots'] as Map? ?? const {}).map(
          (key, value) => MapEntry('$key', '$value'),
        ));
      recentUserMessages
        ..clear()
        ..addAll((data['recentUserMessages'] as List? ?? const [])
            .map((e) => '$e'));
    } catch (_) {
      // Corrupt local memory is non-critical; start a clean session.
      await clear();
    }
  }

  Future<void> clear() async {
    topic = null;
    lastIntent = null;
    slots.clear();
    recentUserMessages.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
