import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/services/local_ai/chat_bot_offline.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class AIChatbotNeuralScreen extends StatefulWidget {
  const AIChatbotNeuralScreen({super.key});

  @override
  State<AIChatbotNeuralScreen> createState() => _AIChatbotNeuralScreenState();
}

class _AIChatbotNeuralScreenState extends State<AIChatbotNeuralScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  late final ChatBotOffline _chatBot;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  late final String _userId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _userId = uid == null ? 'neural_guest_v1' : 'neural_user_$uid';
    _chatBot = ChatBotOffline(sessionId: _userId);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _chatBot.initialize();
      final history = await _chatBot.getConversation();
      if (!mounted) return;
      setState(() {
        _messages.addAll(history.map((m) => {
          'text': m['message']?.toString() ?? '',
          'isUser': m['is_user'] == 1,
          'timestamp': DateTime.fromMillisecondsSinceEpoch((m['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
        }));
        if (_messages.isEmpty) _messages.add({'text': _t('مرحباً! أنا المساعد الطبي العصبي. اكتب استفسارك وسأحلله محلياً.'), 'isUser': false, 'timestamp': DateTime.now()});
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();
    setState(() { _messages.add({'text': text, 'isUser': true, 'timestamp': DateTime.now()}); _loading = true; });
    try {
      final result = _chatBot.respond(text, languageCode: AppStrings.of(context).locale.languageCode);
      if (!mounted) return;
      setState(() { _messages.add({'text': result['response']?.toString() ?? '', 'isUser': false, 'timestamp': DateTime.now()}); _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _messages.add({'text': _t('تعذر تحليل الرسالة حالياً.'), 'isUser': false, 'timestamp': DateTime.now()}); _loading = false; });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_scrollController.hasClients) _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  });

  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: Text(_t('المساعد الطبي العصبي')), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Column(children: [
        Expanded(child: ListView.builder(controller: _scrollController, padding: const EdgeInsets.all(16), itemCount: _messages.length + (_loading ? 1 : 0), itemBuilder: (_, i) => i == _messages.length ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()) : _bubble(_messages[i], dark))),
        SafeArea(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _send(), decoration: InputDecoration(hintText: _t('اكتب استفسارك الطبي...'), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))))),), const SizedBox(width: 8), CircleAvatar(backgroundColor: AppColors.primary, child: IconButton(onPressed: _loading ? null : _send, icon: const Icon(Icons.send, color: Colors.white)))]))),
      ]),
    );
  }

  Widget _bubble(Map<String, dynamic> m, bool dark) {
    final user = m['isUser'] == true;
    return Align(alignment: user ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82), decoration: BoxDecoration(color: user ? AppColors.primary : (dark ? const Color(0xFF1A2540) : Colors.white), borderRadius: BorderRadius.circular(16)), child: Text(m['text']?.toString() ?? '', style: TextStyle(color: user ? Colors.white : (dark ? Colors.white : Colors.black87), height: 1.45))));
  }
}
