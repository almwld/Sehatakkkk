import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/medical_ai_local.dart';
import 'package:sehatak/core/localization/app_strings.dart';

class SmartClinicScreen extends StatefulWidget {
  const SmartClinicScreen({super.key});
  @override
  State<SmartClinicScreen> createState() => _SmartClinicScreenState();
}

class _SmartClinicScreenState extends State<SmartClinicScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  final _ai = LocalMedicalAI();
  final _controller = TextEditingController();
  final List<Map<String, String>> _chat = [];
  bool _isTyping = false;

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _chat.add({'role': 'user', 'text': text});
      _isTyping = true;
    });
    _controller.clear();

    Future.delayed(const Duration(milliseconds: 800), () {
      final reply = _ai.chatbotRespond(text);
      String fullReply = reply;
      setState(() {
        _chat.add({'role': 'bot', 'text': fullReply});
        _isTyping = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: _t('المساعد الذكي 🤖'), backgroundColor: AppColors.primary),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(8),
          color: AppColors.warning.withOpacity(0.08),
          child: Row(children: [
            const Icon(Icons.info, size: 14, color: AppColors.warning),
            const SizedBox(width: 4),
            Expanded(child: Text(_t('يعمل محلياً بدون إنترنت'), style: const TextStyle(fontSize: 10))),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _chat.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, i) {
              if (_isTyping && i == _chat.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(_t('...يكتب'), style: const TextStyle(color: AppColors.grey)),
                  ),
                );
              }
              final msg = _chat[i];
              final isUser = msg['role'] == 'user';
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.primary : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(isUser ? msg['text']! : _t(msg['text']!), style: TextStyle(color: isUser ? Colors.white : null, fontSize: 13)),
                ),
              );
            },
          ),
        ),
        SizedBox(
          height: 42,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 8), children: [
            _quickChip('🤒 أعراض', 'عندي صداع وحرارة'),
            _quickChip('💊 باراسيتامول', 'باراسيتامول'),
            _quickChip('💎 الباقات', 'كم سعر الباقة'),
            _quickChip('📅 حجز', 'كيف احجز موعد'),
            _quickChip('💡 نصيحة', 'نصيحة'),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)]),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: _t('اسألني...'),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            )),
            const SizedBox(width: 4),
            CircleAvatar(
              backgroundColor: AppColors.primary,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: () => _send(_controller.text),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _quickChip(String label, String query) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(label: Text(_t(label), style: const TextStyle(fontSize: 11)), onPressed: () => _send(query)),
    );
  }
}
