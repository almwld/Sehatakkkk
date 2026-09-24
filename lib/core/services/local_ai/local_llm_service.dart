import 'dart:async';
import 'package:flutter/services.dart';

/// Optional on-device Arabic LLM. The GGUF weights live outside the APK and
/// are downloaded once to app-private storage. After installation inference
/// is fully local and requires no API key.
class LocalLlmService {
  static const _channel = MethodChannel('com.sehatak.app/local_llm');
  static final LocalLlmService instance = LocalLlmService._();
  LocalLlmService._();

  final StreamController<double> _progress = StreamController<double>.broadcast();
  bool _listening = false;

  Stream<double> get progress => _progress.stream;

  void _ensureListener() {
    if (_listening) return;
    _listening = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'progress') {
        final data = Map<String, dynamic>.from(call.arguments as Map);
        final percent = (data['percent'] as num?)?.toDouble() ?? -1;
        if (percent >= 0) _progress.add(percent / 100);
      }
    });
  }

  Future<Map<String, dynamic>> status() async {
    _ensureListener();
    final result = await _channel.invokeMethod<Map>('status');
    return Map<String, dynamic>.from(result ?? const {});
  }

  Future<bool> isReady() async => (await status())['ready'] == true;

  Future<void> download() async {
    _ensureListener();
    await _channel.invokeMethod('download');
  }

  Future<String> generate({
    required String prompt,
    required String systemPrompt,
    int maxTokens = 192,
  }) async {
    _ensureListener();
    final result = await _channel.invokeMethod<String>('generate', {
      'prompt': prompt,
      'systemPrompt': systemPrompt,
      'maxTokens': maxTokens,
    });
    return result?.trim() ?? '';
  }

  Future<void> release() => _channel.invokeMethod('release');

  void dispose() => _progress.close();
}
