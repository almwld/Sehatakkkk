import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/yemeni_dialect.dart';
import 'package:sehatak/services/local_ai/neural_medical_ai.dart';
import 'package:sehatak/services/local_ai/chat_bot_offline.dart';

class AIChatbotNeuralScreen extends StatefulWidget {
  const AIChatbotNeuralScreen({super.key});

  @override
  State<AIChatbotNeuralScreen> createState() => _AIChatbotNeuralScreenState();
}

class _AIChatbotNeuralScreenState extends State<AIChatbotNeuralScreen> {
  late NeuralMedicalAI _neuralAI;
  late ChatBotOffline _chatBot;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String _userId = '';
  Map<String, dynamic> _userProfile = {};

  // ✅ أسئلة مقترحة باللهجة اليمنية
  final List<String> _suggestedQuestions = [
    'راسي يوجعني شو اسوي؟',
    'كيف اخفض الضغط ياخوي؟',
    'عندي حرارة وش احسن دوا؟',
    'كيف انظم نومي؟',
    'شو فوائد المشي للصحة؟',
    'كيف اقوي مناعتي؟',
    'عندي الم في بطني شو الحل؟',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    setState(() => _isLoading = true);

    try {
      _userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      _neuralAI = NeuralMedicalAI();
      _chatBot = ChatBotOffline(sessionId: _userId);
      await _chatBot.initialize();
      
      // ✅ تحميل المحادثة السابقة
      final history = await _chatBot._knowledge.getConversation(_userId);
      if (history.isNotEmpty) {
        setState(() {
          _messages.addAll(history.map((msg) => {
            'text': msg['message'],
            'isUser': msg['is_user'] == 1,
            'timestamp': DateTime.fromMillisecondsSinceEpoch(msg['timestamp']),
            'type': msg['type'],
          }));
        });
      } else {
        _addWelcomeMessage();
      }

      setState(() => _isInitialized = true);
    } catch (e) {
      print('❌ AI initialization error: $e');
      _addWelcomeMessage();
      setState(() => _isInitialized = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addWelcomeMessage() {
    final welcome = '''
هلا والله! 🌸

أنا المساعد الصحي الذكي، وأتكلم باللهجة اليمنية عشان تفهمني وتفهمني 😊

قدر أساعدك في:
• 💊 معلومات عن الأدوية
• 🩺 تشخيص أولي للأعراض
• 🚑 إسعافات أولية
• 💡 نصائح صحية يومية
• 📅 حجز مواعيد

تكلم معاي باللهجة اليمنية عادي، أنا فاهمك 👍

كيف أقدر أساعدك اليوم يا غالي؟
''';
    _messages.add({
      'text': welcome,
      'isUser': false,
      'timestamp': DateTime.now(),
      'type': 'greeting',
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || !_isInitialized) return;

    // ✅ تحويل اللهجة إلى نص مفهوم
    final processedText = _preprocessMessage(text);

    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'timestamp': DateTime.now(),
      });
      _messageController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // ✅ استخدام الذكاء الاصطناعي
      final aiResponse = await _neuralAI.processMessage(
        message: processedText,
        userId: _userId,
        userProfile: jsonEncode(_userProfile),
      );
      
      final reply = aiResponse['response'] as String;
      final sentiment = aiResponse['sentiment'] as String;
      final intent = aiResponse['intent'] as String;

      // ✅ حفظ الرد في قاعدة البيانات
      await _chatBot._knowledge.saveMessage(
        sessionId: _userId,
        message: reply,
        isUser: false,
        type: intent,
      );

      setState(() {
        _messages.add({
          'text': reply,
          'isUser': false,
          'timestamp': DateTime.fromMillisecondsSinceEpoch(aiResponse['timestamp'] as int),
          'type': intent,
          'sentiment': sentiment,
        });
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'عذراً يا غالي، حصل خطأ. حاول مرة ثانية 🙏',
          'isUser': false,
          'timestamp': DateTime.now(),
          'type': 'error',
        });
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  // ============================================================
  // 🛠️ معالجة النص قبل الإرسال
  // ============================================================

  String _preprocessMessage(String text) {
    // ✅ تحويل الكلمات العامية إلى مفهومة
    final Map<String, String> dialectMap = {
      'راسي يوجعني': 'صداع',
      'بطني يلعب': 'ألم بطن',
      'حرارة': 'حمى',
      'كحة': 'سعال',
      'متعب': 'تعب',
      'يخوي': '',
      'يا غالي': '',
      'يا باشا': '',
      'شو': 'ما',
      'إيش': 'ماذا',
      'ليش': 'لماذا',
      'وين': 'أين',
      'منو': 'من',
      'الحين': 'الآن',
      'بكرة': 'غداً',
      'وايد': 'كثير',
      'شوية': 'قليل',
      'زين': 'جيد',
      'كويس': 'جيد',
    };

    String result = text;
    for (var entry in dialectMap.entries) {
      if (result.contains(entry.key)) {
        result = result.replaceAll(entry.key, entry.value);
      }
    }
    return result;
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

  Future<void> _clearChat() async {
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
            onPressed: () async {
              await _chatBot.clearHistory();
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
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
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'المساعد الذكي',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
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
                    'Online',
                    style: TextStyle(fontSize: 9, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
          ),
        ],
      ),
      body: _isLoading && _messages.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ مؤشر الحالة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  color: Colors.blue.withOpacity(0.08),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 14, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '🧠 ذكاء اصطناعي يتحدث باللهجة اليمنية',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ قائمة الرسائل
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildTypingIndicator(isDark);
                      }
                      return _buildMessage(_messages[index], isDark);
                    },
                  ),
                ),

                // ✅ الأسئلة المقترحة باللهجة اليمنية
                if (_messages.length <= 3)
                  Container(
                    height: 110,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 أسئلة شائعة باليمني:',
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
                              hintText: 'اكتب باليمني... كيفك انت؟',
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: _sendMessage,
                          iconSize: 20,
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

  Widget _buildMessage(Map<String, dynamic> message, bool isDark) {
    final isUser = message['isUser'] as bool;
    final type = message['type'] as String?;
    final sentiment = message['sentiment'] as String?;

    Color sentimentColor = Colors.grey;
    if (sentiment == 'positive') sentimentColor = Colors.green;
    if (sentiment == 'negative') sentimentColor = Colors.orange;
    if (sentiment == 'urgent') sentimentColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
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
                  if (!isUser)
                    Row(
                      children: [
                        Container(
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
                        const SizedBox(width: 8),
                        if (sentiment != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: sentimentColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _getSentimentLabel(sentiment),
                              style: TextStyle(
                                fontSize: 8,
                                color: sentimentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    message['text'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUser ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message['timestamp'] as DateTime),
                    style: TextStyle(
                      fontSize: 9,
                      color: isUser ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 18,
              ),
            ),
        ],
      ),
    );
  }

  String _getTypeLabel(String? type) {
    final labels = {
      'greeting': '👋 ترحيب',
      'drug_info': '💊 دواء',
      'disease_info': '🩺 مرض',
      'first_aid': '🚑 إسعافات',
      'emergency': '🚨 طوارئ',
      'health_tip': '💡 نصيحة',
      'appointment': '📅 موعد',
      'gratitude': '🙏 شكر',
      'general': '💬 عام',
      'error': '⚠️ خطأ',
    };
    return labels[type ?? 'general'] ?? '💬';
  }

  String _getSentimentLabel(String sentiment) {
    final labels = {
      'positive': '😊 إيجابي',
      'negative': '😟 سلبي',
      'urgent': '🚨 طوارئ',
      'neutral': '😐 محايد',
    };
    return labels[sentiment] ?? '😐';
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.auto_awesome,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(isDark, 0),
                const SizedBox(width: 4),
                _buildDot(isDark, 300),
                const SizedBox(width: 4),
                _buildDot(isDark, 600),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isDark, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
