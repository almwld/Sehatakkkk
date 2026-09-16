import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/local_ai/local_medical_ai.dart';
import 'package:sehatak/core/services/local_ai/smart_health_knowledge.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatBot _chatBot = ChatBot();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  static const _quick = <Map<String, String>>[
    {'title': 'أعراضي', 'prompt': 'أريد المساعدة في فهم أعراضي'},
    {'title': 'دواء', 'prompt': 'أريد معلومات عن دواء'},
    {'title': 'طبيب', 'prompt': 'أريد معرفة كيف أجد طبيباً مناسباً'},
    {'title': 'تحاليل', 'prompt': 'أين أجد التحاليل ونتائج الفحوصات؟'},
    {'title': 'طوارئ', 'prompt': 'ماذا أفعل إذا كانت حالتي طارئة؟'},
    {'title': 'خدمات التطبيق', 'prompt': 'ما الخدمات التي يمكن أن توجهني إليها؟'},
  ];

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': 'مرحباً 👋\nأنا المساعد الصحي الذكي في صحتك.\n\nأستطيع شرح المعلومات الصحية العامة، مساعدتك في فهم الأعراض، إعطائك إرشادات أولية، والأهم: توجيهك إلى خدمة التطبيق المناسبة بدل أن تبحث عنها بنفسك.\n\nقل مثلاً: «أريد طبيب قلب» أو «أين نتائج تحاليلي؟» وسأخبرك بما يمكنك فعله داخل التطبيق.',
      'user': false,
      'time': DateTime.now(),
    });
  }

  Future<void> _send(String value) async {
    final text = value.trim();
    if (text.isEmpty || _loading) return;
    setState(() {
      _messages.add({'text': text, 'user': true, 'time': DateTime.now()});
      _controller.clear();
      _loading = true;
    });
    _scroll();

    await Future<void>.delayed(const Duration(milliseconds: 250));
    final service = SmartHealthKnowledge.findService(text);
    Map<String, dynamic> result;
    try {
      result = _chatBot.respond(text);
    } catch (_) {
      result = {'response': 'لم أتمكن من تحليل السؤال حالياً. جرّب صياغته بطريقة أخرى.', 'type': 'fallback'};
    }

    var reply = (result['response'] ?? 'لم أجد إجابة مناسبة.').toString();
    if (service != null) {
      reply = '$reply\n\n📍 داخل صحتك\n${service['help']}\n\nاضغط «فتح الخدمة» للانتقال إليها مباشرة.';
    } else if (_contains(text, ['كيف استخدم', 'كيف أستخدم', 'كيف اصل', 'كيف اوصل', 'كيف أجد', 'خدمات التطبيق'])) {
      reply = 'أستطيع توجيهك داخل التطبيق حسب طلبك. مثال:\n• «أريد طبيباً» ← الأطباء\n• «أريد دواء» ← الصيدلية\n• «أريد تحليل» ← المختبرات\n• «أريد متابعة صحتي» ← صحتي\n• «أريد استشارة» ← الاستشارات\n• «أحتاج طوارئ» ← الطوارئ\n• «أريد أقرب منشأة» ← الخريطة\n\nاكتب ما تحتاجه بلغتك الطبيعية وسأحدد لك المسار المناسب.';
    }

    setState(() {
      _messages.add({
        'text': reply,
        'user': false,
        'time': DateTime.now(),
        'service': service,
        'type': result['type'],
      });
      _loading = false;
    });
    _scroll();
  }

  bool _contains(String text, List<String> values) {
    final normalized = text.toLowerCase();
    return values.any(normalized.contains);
  }

  void _scroll() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _openService(Map<String, dynamic> service) async {
    final route = service['route']?.toString();
    if (route == null || route.isEmpty) return;
    try {
      await Navigator.of(context).pushNamed(route);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الخدمة «${service['title']}» موجودة في التطبيق، لكن مسارها غير متاح من هذه الشاشة حالياً.')),
      );
    }
  }

  void _clear() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('مسح المحادثة'),
        content: const Text('هل تريد مسح المحادثة الحالية؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              setState(() {
                _messages.clear();
                _messages.add({'text': 'تم بدء محادثة جديدة. كيف أساعدك؟', 'user': false, 'time': DateTime.now()});
              });
            },
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF7FAFA),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(children: [
          Image.asset('assets/images/services/ai_assistant.png', width: 34, height: 34, fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_outlined)),
          const SizedBox(width: 8),
          const Expanded(child: Text('المساعد الصحي الذكي', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: const Text('صحتك', style: TextStyle(fontSize: 9)),
          ),
        ]),
        actions: [IconButton(onPressed: _clear, icon: const Icon(Icons.delete_outline))],
      ),
      body: Column(children: [
        _buildServiceHub(dark),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            itemCount: _messages.length + (_loading ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == _messages.length) return _typing(dark);
              return _message(_messages[index], dark);
            },
          ),
        ),
        _input(dark),
      ]),
    );
  }

  Widget _buildServiceHub(bool dark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(color: dark ? const Color(0xFF111A2D) : Colors.white, boxShadow: const [BoxShadow(blurRadius: 5, color: Color(0x11000000))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('كيف أساعدك اليوم؟', style: TextStyle(fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _quick.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) => ActionChip(
              avatar: const Icon(Icons.auto_awesome, size: 15),
              label: Text(_quick[i]['title']!),
              onPressed: () => _send(_quick[i]['prompt']!),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: SmartHealthKnowledge.services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final s = SmartHealthKnowledge.services[i];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openService(s),
                child: Container(
                  width: 92,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : const Color(0xFFF3F8F7), borderRadius: BorderRadius.circular(12)),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(s['icon'] as IconData, color: AppColors.primary, size: 23),
                    const SizedBox(height: 3),
                    Text(s['title'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _message(Map<String, dynamic> message, bool dark) {
    final user = message['user'] == true;
    final service = message['service'] as Map<String, dynamic>?;
    return Align(
      alignment: user ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 355),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: user ? AppColors.primary : (dark ? const Color(0xFF1A2540) : Colors.white),
          borderRadius: BorderRadius.circular(17).copyWith(bottomRight: user ? const Radius.circular(4) : null, bottomLeft: user ? null : const Radius.circular(4)),
          boxShadow: user ? null : const [BoxShadow(blurRadius: 3, color: Color(0x10000000))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(message['text']?.toString() ?? '', style: TextStyle(color: user ? Colors.white : (dark ? Colors.white : Colors.black87), height: 1.5, fontSize: 14)),
          if (!user && service != null) ...[
            const SizedBox(height: 9),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _openService(service),
                icon: const Icon(Icons.open_in_new, size: 17),
                label: Text('فتح ${service['title']}'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, minimumSize: const Size(0, 40)),
              ),
            ),
          ],
          const SizedBox(height: 3),
          Text(_time(message['time'] as DateTime), style: TextStyle(fontSize: 9, color: user ? Colors.white70 : Colors.grey)),
        ]),
      ),
    );
  }

  Widget _typing(bool dark) => Align(alignment: AlignmentDirectional.centerStart, child: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: const Text('المساعد يكتب…')));

  Widget _input(bool dark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        decoration: BoxDecoration(color: dark ? const Color(0xFF111A2D) : Colors.white, boxShadow: const [BoxShadow(blurRadius: 6, color: Color(0x12000000))]),
        child: Row(children: [
          Expanded(child: TextField(
            controller: _controller,
            textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.send,
            onSubmitted: _send,
            decoration: InputDecoration(hintText: 'اكتب سؤالك أو الخدمة التي تريدها…', filled: true, fillColor: dark ? const Color(0xFF1A2540) : const Color(0xFFF3F5F6), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11)),
          )),
          const SizedBox(width: 7),
          IconButton.filled(onPressed: _loading ? null : () => _send(_controller.text), icon: const Icon(Icons.send_rounded)),
        ]),
      ),
    );
  }

  String _time(DateTime time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}
