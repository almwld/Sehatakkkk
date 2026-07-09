import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_event.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_state.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String userId;
  final bool isDoctor;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.userName,
    required this.userId,
    required this.isDoctor,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isSending = false;
  late ChatBloc _chatBloc;

  @override
  void initState() {
    super.initState();
    _chatBloc = context.read<ChatBloc>();
    _chatBloc.add(ListenToMessages(widget.chatId));
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    _chatBloc.add(SendChatMessage(
      chatId: widget.chatId,
      text: text,
    ));
    
    _textController.clear();
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  void _startRecording() {
    setState(() => _isRecording = true);
    // ✅ بدء التسجيل الصوتي (سيتم ربطه لاحقاً)
  }

  void _stopRecording() {
    setState(() => _isRecording = false);
    // ✅ إيقاف التسجيل وإرسال الملف الصوتي (سيتم ربطه لاحقاً)
  }

  void _showImagePicker() {
    // ✅ اختيار صورة من المعرض (سيتم ربطه لاحقاً)
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        if (date.day == now.day && date.month == now.month && date.year == now.year) {
          return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        } else if (date.day == now.day - 1) {
          return 'أمس';
        } else {
          return '${date.day}/${date.month}';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0] : 'م',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5257),
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam, color: Color(0xFF0D5257)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Color(0xFF0D5257)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ عرض الرسائل الحقيقية
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatLoadedState) {
                  final messages = state.messages;
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 80,
                            color: isDark ? Colors.grey[600] : Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ابدأ المحادثة الآن',
                            style: TextStyle(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أرسل رسالة لبدء التواصل',
                            style: TextStyle(
                              color: isDark ? Colors.grey[500] : Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['senderId'] == currentUserId;
                      return _buildMessageBubble(msg, isMe, isDark);
                    },
                  );
                }
                if (state is ChatErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _chatBloc.add(ListenToMessages(widget.chatId));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          // ✅ حقل الإدخال الذكي مع التسجيل الصوتي
          _buildSmartInputField(isDark),
        ],
      ),
    );
  }

  // ============================================================
  // 💬 فقاعة الرسالة المتطورة
  // ============================================================
  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, bool isDark) {
    final text = msg['text'] ?? '';
    final imageUrl = msg['imageUrl'];
    final time = _formatTime(msg['timestamp']);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0] : 'م',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe 
                    ? AppColors.primary 
                    : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ✅ عرض الصورة إذا وجدت
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    _buildImageMessage(imageUrl, isDark),
                  
                  // ✅ عرض النص
                  if (text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: imageUrl != null ? 8 : 0),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  
                  // ✅ الوقت
                  if (time.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[600]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼️ عرض الصورة مع Caching
  // ============================================================
  Widget _buildImageMessage(String imageUrl, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 200,
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          height: 200,
          color: isDark ? Colors.grey[800] : Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.broken_image, color: Colors.grey, size: 40),
              const SizedBox(height: 8),
              Text(
                'فشل تحميل الصورة',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎙️ حقل الإدخال الذكي مع التسجيل الصوتي
  // ============================================================
  Widget _buildSmartInputField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: _isRecording
          ? _buildRecordingWave()
          : Row(
              children: [
                // ✅ زر المرفقات
                IconButton(
                  icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: _showImagePicker,
                ),
                
                // ✅ حقل الإدخال
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        onChanged: (text) {
                          setState(() => _isTyping = text.trim().isNotEmpty);
                        },
                        onSubmitted: (_) => _sendMessage(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // ✅ زر الرموز التعبيرية
                IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: () {},
                ),
                
                // ✅ زر الإرسال / الميكروفون
                GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) => _stopRecording(),
                  onTap: _isTyping ? _sendMessage : null,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _isTyping ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isTyping ? AppColors.primary : (isDark ? Colors.grey[600] : Colors.grey[300]),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isTyping ? Icons.send : Icons.mic,
                      color: _isTyping ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // 🎵 موجة التسجيل الصوتي
  // ============================================================
  Widget _buildRecordingWave() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _stopRecording,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // ✅ أيقونة التسجيل النابضة
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ✅ موجة الصوت المتحركة
                  Expanded(
                    child: SizedBox(
                      height: 24,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 30,
                        itemBuilder: (context, index) {
                          final height = 4 + (index % 8) * 3;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 3,
                            height: height.toDouble(),
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.6 + (index % 5) * 0.08),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'جاري التسجيل...',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
