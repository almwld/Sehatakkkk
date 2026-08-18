import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/services/local_ai/local_medical_ai.dart';

class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatBot _chatBot = ChatBot();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isFirstMessage = true;

  // ✅ الأسئلة المقترحة
  final List<String> _suggestedQuestions = [
    'ما هي أعراض الأنفلونزا؟',
    'كيف أحسب مؤشر كتلة الجسم؟',
    'نصائح لتقوية المناعة',
    'ما هي فوائد المشي؟',
    'كيف أنظم نومي؟',
    'أفضل أطعمة للقلب',
    'ما هي أعراض كورونا؟',
    'كيف أعتني بطفلي الرضيع؟',
    'ما هو دواء الباراسيتامول؟',
    'ماذا أفعل في حالة الحروق؟',
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add({
      'text': 'مرحباً! 👋\nأنا المساعد الصحي الذكي.\n\nيمكنني مساعدتك في:\n• 💊 معلومات عن الأدوية\n• 🩺 تحليل الأعراض\n• 🚑 الإسعافات الأولية\n• 💡 نصائح صحية\n• 📱 خدمات التطبيق\n\nكيف يمكنني مساعدتك اليوم؟',
      'isUser': false,
      'timestamp': DateTime.now(),
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
      _isLoading = true;
      _isFirstMessage = false;
    });
    _scrollToBottom();

    // ✅ معالجة الرد
    await Future.delayed(const Duration(milliseconds: 400));

    final response = _chatBot.respond(text);
    final reply = response['response'] as String;
    final type = response['type'] as String;

    setState(() {
      _messages.add({
        'text': reply,
        'isUser': false,
        'timestamp': DateTime.now(),
        'type': type,
      });
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المحادثة'),
        content: const Text('هل أنت متأكد من مسح جميع الرسائل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
                _isFirstMessage = true;
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'المساعد الصحي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'متصل',
                    style: TextStyle(fontSize: 10, color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: isDark ? Colors.white : Colors.black87),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط المعلومات
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.primary.withOpacity(0.08),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اسألني عن صحتك، الأدوية، الأعراض، أو خدمات التطبيق',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // ✅ قائمة الرسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator(isDark);
                }
                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),

          // ✅ الأسئلة المقترحة
          if (_isFirstMessage)
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 أسئلة مقترحة:',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestedQuestions.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _messageController.text = _suggestedQuestions[index];
                            _sendMessage();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1A2540) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _suggestedQuestions[index],
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // ✅ حقل الإدخال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: _showAttachOptions,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'اكتب استفسارك الطبي...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 دوال العرض
  // ============================================================

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark) {
    final isUser = message['isUser'] as bool;
    final type = message['type'] as String?;

    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isUser ? 48 : 8,
        right: isUser ? 8 : 48,
      ),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.medical_services, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                  bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                ),
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
                  // ✅ نوع الرد
                  if (!isUser && type != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getTypeLabel(type),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Text(
                    message['text'] as String,
                    style: TextStyle(
                      color: isUser
                          ? Colors.white
                          : (isDark ? Colors.white : Colors.black87),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['timestamp'] as DateTime),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white70
                          : (isDark ? Colors.grey[500] : Colors.grey[500]),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, color: AppColors.primary, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    final labels = {
      'greeting': '👋 ترحيب',
      'drug_info': '💊 دواء',
      'disease_info': '🩺 مرض',
      'first_aid': '🚑 إسعافات',
      'faq': '❓ سؤال شائع',
      'triage': '🩺 تحليل أعراض',
      'urgent': '🚨 طوارئ',
      'info': 'ℹ️ معلومات',
      'help': '📋 مساعدة',
      'emotional': '🧠 دعم نفسي',
      'escalate': '📤 تحويل',
    };
    return labels[type] ?? '💬 رسالة';
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: 8,
        right: 48,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medical_services, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: 4),
                _buildDot(1, isDark),
                const SizedBox(width: 4),
                _buildDot(2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 400 + (index * 150)),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[400] : AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  void _showAttachOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'إرفاق وسائط',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachOption(Icons.image, 'صورة', Colors.purple),
                _attachOption(Icons.description, 'ملف', Colors.blue),
                _attachOption(Icons.mic, 'تسجيل', Colors.red),
                _attachOption(Icons.camera_alt, 'كاميرا', Colors.green),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _attachOption(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
