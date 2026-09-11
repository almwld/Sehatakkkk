import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/services/local_ai/chat_bot_offline.dart';

class AIChatbotOfflineScreen extends StatefulWidget {
  const AIChatbotOfflineScreen({super.key});

  @override
  State<AIChatbotOfflineScreen> createState() => _AIChatbotOfflineScreenState();
}

class _AIChatbotOfflineScreenState extends State<AIChatbotOfflineScreen> {
  late final ChatBotOffline _chatBot;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  static const _suggestions = <String>[
    'ما هي أعراض الأنفلونزا؟',
    'ما هو دواء الباراسيتامول؟',
    'نصائح لتقوية المناعة',
    'ماذا أفعل في حالة الحروق؟',
  ];

  @override
  void initState() {
    super.initState();
    _chatBot = ChatBotOffline(sessionId: 'offline_${DateTime.now().millisecondsSinceEpoch}');
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _chatBot.initialize();
      final history = await _chatBot.getConversation();
      if (mounted) {
        setState(() {
          _messages.addAll(history.map((m) => {
            'text': m['message']?.toString() ?? '',
            'isUser': m['is_user'] == 1,
            'timestamp': DateTime.fromMillisecondsSinceEpoch((m['timestamp'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch),
            'type': m['type']?.toString(),
          }));
          if (_messages.isEmpty) _addWelcome();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _addWelcome(); _loading = false; });
    }
  }

  void _addWelcome() => _messages.add(const {
    'text': 'مرحباً! 👋\nأنا المساعد الصحي الذكي. اسألني عن الأدوية، الأمراض، الإسعافات الأولية أو النصائح الصحية.',
    'isUser': false,
    'type': 'greeting',
  });

  Future<void> _send([String? value]) async {
    final text = (value ?? _controller.text).trim();
    if (text.isEmpty || _loading) return;
    _controller.clear();
    setState(() { _messages.add({'text': text, 'isUser': true, 'timestamp': DateTime.now()}); _loading = true; });
    try {
      final result = await _chatBot.respond(text);
      if (!mounted) return;
      setState(() {
        _messages.add({'text': result['response']?.toString() ?? '', 'isUser': false, 'type': result['type']?.toString(), 'timestamp': DateTime.now()});
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _messages.add({'text': 'تعذر إنشاء الرد حالياً. حاول مرة أخرى.', 'isUser': false, 'timestamp': DateTime.now()}); _loading = false; });
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
      appBar: AppBar(
        title: const Text('المساعد الصحي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(onPressed: () async { await _chatBot.clearHistory(); if (mounted) setState(() { _messages.clear(); _addWelcome(); }); }, icon: const Icon(Icons.delete_outline))],
      ),
      body: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), color: Colors.green.withOpacity(.1), child: const Text('يعمل دون اتصال بالإنترنت ويحفظ المحادثة محلياً', style: TextStyle(fontSize: 11, color: Colors.green))),
        Expanded(child: _loading && _messages.isEmpty ? const Center(child: CircularProgressIndicator()) : ListView.builder(controller: _scrollController, padding: const EdgeInsets.all(16), itemCount: _messages.length + (_loading ? 1 : 0), itemBuilder: (_, i) => i == _messages.length ? const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()) : _bubble(_messages[i], dark))),
        if (_messages.length <= 2) SizedBox(height: 55, child: ListView.separated(padding: const EdgeInsets.symmetric(horizontal: 12), scrollDirection: Axis.horizontal, itemCount: _suggestions.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ActionChip(label: Text(_suggestions[i]), onPressed: () => _send(_suggestions[i])))),
        SafeArea(child: Padding(padding: const EdgeInsets.all(10), child: Row(children: [Expanded(child: TextField(controller: _controller, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'اكتب استفسارك الطبي...', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))))),), const SizedBox(width: 8), CircleAvatar(backgroundColor: AppColors.primary, child: IconButton(onPressed: _loading ? null : _send, icon: const Icon(Icons.send, color: Colors.white)))]))),
      ]),
    );
  }

  Widget _bubble(Map<String, dynamic> m, bool dark) {
    final user = m['isUser'] == true;
    return Align(alignment: user ? Alignment.centerRight : Alignment.centerLeft, child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .82), decoration: BoxDecoration(color: user ? AppColors.primary : (dark ? const Color(0xFF1A2540) : Colors.white), borderRadius: BorderRadius.circular(16)), child: Text(m['text']?.toString() ?? '', style: TextStyle(color: user ? Colors.white : (dark ? Colors.white : Colors.black87), height: 1.45))));
  }
}
