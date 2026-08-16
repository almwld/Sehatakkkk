import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AiChatbotScreen extends StatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  State<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends State<AiChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'text': 'مرحباً! أنا المساعد الصحي الذكي. كيف يمكنني مساعدتك اليوم؟',
      'isUser': false,
      'time': DateTime.now(),
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': DateTime.now(),
      });
      _messageController.clear();
      _isTyping = true;
    });

    // محاكاة الرد
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isTyping = false;
        _messages.add({
          'text': 'شكراً على سؤالك. سأقوم بتحليل استفسارك وتقديم الإجابة المناسبة. هل لديك أي استفسار آخر؟',
          'isUser': false,
          'time': DateTime.now(),
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المساعد الصحي الذكي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add({
                  'text': 'مرحباً! أنا المساعد الصحي الذكي. كيف يمكنني مساعدتك اليوم؟',
                  'isUser': false,
                  'time': DateTime.now(),
                });
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator(isDark);
                }
                final message = _messages[index];
                return _buildMessage(message, isDark);
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, bool isDark) {
    final isUser = message['isUser'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.smart_toy, color: AppColors.primary, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser
                  ? AppColors.primary
                  : (isDark ? const Color(0xFF1A2540) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['text'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message['time'] as DateTime),
                  style: TextStyle(
                    fontSize: 9,
                    color: isUser ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[400]),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.primary, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(Icons.smart_toy, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildDot(Colors.grey, 0),
                const SizedBox(width: 4),
                _buildDot(Colors.grey, 300),
                const SizedBox(width: 4),
                _buildDot(Colors.grey, 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () {
              ToastService.showSuccess(context, '📎 جاري إرفاق ملف...');
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
