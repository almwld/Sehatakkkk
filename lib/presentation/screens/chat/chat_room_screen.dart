import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/theme/app_theme.dart';

enum AudioRecordingState { idle, recording, locked }

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.contactName, required this.contactType});

  final String contactName;
  final String contactType;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  AudioRecordingState _recordingState = AudioRecordingState.idle;

  // بيانات وهمية للرسائل
  final List<Map<String, dynamic>> _messages = [
    {'text': 'مرحباً دكتور، كيف حالك؟', 'isMe': true, 'time': '10:30 ص', 'type': 'text'},
    {'text': 'أهلاً بك، أنا بخير. كيف يمكنني مساعدتك؟', 'isMe': false, 'time': '10:31 ص', 'type': 'text'},
    {
      'text': 'أعاني من صداع منذ يومين.',
      'isMe': true,
      'time': '10:32 ص',
      'type': 'text',
    },
    {
      'text': 'هل تعاني من أي أعراض أخرى؟',
      'isMe': false,
      'time': '10:33 ص',
      'type': 'text',
    },
    {
      'text': 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=300',
      'isMe': true,
      'time': '10:35 ص',
      'type': 'image',
    },
    {
      'text': 'شكراً على الصورة، سأفحصها وأعطيك النتيجة.',
      'isMe': false,
      'time': '10:36 ص',
      'type': 'text',
    },
  ];

  @override
  void initState() {
    super.initState();
    // تهيئة الـ Recorder (محاكاة)
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // إغلاق الـ Recorder
    super.dispose();
  }

  // ============================================================
  // 🎤 محاكاة بدء التسجيل الآمن
  // ============================================================
  Future<void> _startRecording() async {
    try {
      setState(() {
        _recordingState = AudioRecordingState.recording;
      });
      // محاكاة التسجيل
    } catch (e) {
      _stopRecording(cancel: true);
    }
  }

  Future<void> _stopRecording({required bool cancel}) async {
    setState(() {
      _recordingState = AudioRecordingState.idle;
    });
    if (!cancel) {
      // إرسال الصوت
    }
  }

  // ============================================================
  // 🧩 بناء حقل الإدخال الذكي
  // ============================================================
  Widget _buildSmartInputField() {
    final primaryColor = AppTheme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.white,
      child: Row(
        children: [
          // حقل الكتابة
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _recordingState == AudioRecordingState.recording
                        ? _buildRecordingWave()
                        : TextField(
                            controller: _textController,
                            onChanged: (text) {
                              setState(() => _isTyping = text.trim().isNotEmpty);
                            },
                            decoration: const InputDecoration(
                              hintText: 'اكتب رسالتك...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontFamily: 'Tajawal'),
                            ),
                          ),
                  ),
                  Icon(Icons.attach_file, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // زر التفاعل الذكي
          GestureDetector(
            onLongPressStart: (_) async {
              if (!_isTyping) await _startRecording();
            },
            onLongPressEnd: (_) async {
              if (!_isTyping) await _stopRecording(cancel: false);
            },
            child: CircleAvatar(
              radius: 24,
              backgroundColor: _recordingState == AudioRecordingState.recording
                  ? Colors.red
                  : primaryColor,
              child: Icon(
                _isTyping
                    ? Icons.send
                    : (_recordingState == AudioRecordingState.recording
                        ? Icons.stop
                        : Icons.mic),
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 واجهة موجة التسجيل
  // ============================================================
  Widget _buildRecordingWave() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(Icons.fiber_manual_record, color: Colors.red, size: 14),
          SizedBox(width: 8),
          Text(
            'جاري تسجيل الصوت...',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 بناء فقاعة الرسالة
  // ============================================================
  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark) {
    final isMe = message['isMe'] as bool;
    final type = message['type'] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 16),
            ),
          const SizedBox(width: 6),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe
                  ? AppTheme.primaryColor
                  : (isDark ? const Color(0xFF1A2540) : Colors.white),
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
              ),
              border: isDark && !isMe
                  ? Border.all(color: Colors.grey[800]!, width: 0.5)
                  : null,
            ),
            child: type == 'image'
                ? _buildImageMessage(message['text'] as String)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['text'] as String,
                        style: TextStyle(
                          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message['time'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          fontFamily: 'Tajawal',
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
  // 🧩 بناء رسالة الصورة المحسّنة
  // ============================================================
  Widget _buildImageMessage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // فتح معاينة الصورة
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
          maxHeight: 300,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.grey[100],
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.broken_image_outlined, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('فشل تحميل الصورة', style: TextStyle(fontFamily: 'Tajawal')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1121) : AppTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 18),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contactName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontFamily: 'Tajawal',
                  ),
                ),
                Text(
                  widget.contactType,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: AppTheme.primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // قائمة الرسائل
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message, isDark);
              },
            ),
          ),
          // حقل الإدخال
          _buildSmartInputField(),
        ],
      ),
    );
  }
}
