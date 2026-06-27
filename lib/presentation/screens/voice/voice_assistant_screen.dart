import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:sehatak/core/constants/app_colors.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = 'اضغط على الميكروفون للتحدث';
  String _response = '';

  final List<Map<String, String>> _commands = [
    {'command': 'أعراض', 'response': 'يمكنك استخدام خدمة فحص الأعراض في قسم الصحة'},
    {'command': 'طبيب', 'response': 'يمكنك حجز موعد مع طبيب من قسم الأطباء'},
    {'command': 'موعد', 'response': 'يمكنك إدارة مواعيدك من قسم المواعيد'},
    {'command': 'دواء', 'response': 'يمكنك طلب الأدوية من قسم الصيدلية'},
    {'command': 'تحليل', 'response': 'يمكنك طلب تحاليل من قسم التحاليل'},
    {'command': 'مساعدة', 'response': 'أنا هنا لمساعدتك! اختر الخدمة التي تريدها'},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        setState(() {
          _isListening = status == 'listening';
        });
      },
      onError: (error) {
        setState(() {
          _text = 'حدث خطأ: $error';
          _isListening = false;
        });
      },
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              _processCommand(_text);
            });
          },
          listenMode: stt.ListenMode.dictation,
          localeId: 'ar_SA',
        );
        setState(() => _isListening = true);
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  void _processCommand(String text) {
    final lower = text.toLowerCase();
    String foundResponse = 'لم أفهم طلبك. يمكنك قول: أعراض، طبيب، موعد، دواء، تحليل، أو مساعدة';
    
    for (final cmd in _commands) {
      if (lower.contains(cmd['command']!.toLowerCase())) {
        foundResponse = cmd['response']!;
        break;
      }
    }
    
    setState(() => _response = foundResponse);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعد الصوتي', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _listen,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isListening ? AppColors.error : AppColors.purple,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purple.withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isListening ? 'جاري الاستماع...' : 'اضغط للتحدث',
              style: TextStyle(
                color: _isListening ? AppColors.error : AppColors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _text,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            if (_response.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      _response,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: _commands.map((cmd) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Text(
                    cmd['command']!,
                    style: const TextStyle(fontSize: 11, color: AppColors.primary),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
