import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_event.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_state.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

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
    this.isDoctor = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _isTyping = false;
  bool _isSending = false;
  File? _selectedImage;
  bool _showMediaPreview = false;
  String? _currentChatId;

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _currentChatId = widget.chatId;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      final chatDoc = await _chatService.getChat(_currentChatId!);
      if (chatDoc == null || !chatDoc.exists) {
        final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
        final userName = FirebaseAuth.instance.currentUser?.displayName ?? 'مستخدم';
        
        final newChatId = await _chatService.createChat(
          doctorId: widget.isDoctor ? userId : widget.userId,
          doctorName: widget.isDoctor ? userName : widget.userName,
          patientId: widget.isDoctor ? widget.userId : userId,
          patientName: widget.isDoctor ? widget.userName : userName,
        );
        setState(() => _currentChatId = newChatId);
      }
      context.read<ChatBloc>().add(LoadChatMessages(_currentChatId!));
    } catch (e) {
      print('❌ Error initializing chat: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAudioCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: _currentChatId ?? widget.chatId,
          doctorName: widget.userName,
          doctorId: widget.userId,
          isVideo: false,
        ),
      ),
    );
  }

  void _startVideoCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: _currentChatId ?? widget.chatId,
          doctorName: widget.userName,
          doctorId: widget.userId,
          isVideo: true,
        ),
      ),
    );
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _selectedImage == null) || _isSending) return;
    if (_currentChatId == null) return;

    setState(() => _isSending = true);

    final messageId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final newMessage = {
      'id': messageId,
      'senderId': FirebaseAuth.instance.currentUser?.uid ?? 'me',
      'senderName': FirebaseAuth.instance.currentUser?.displayName ?? 'أنا',
      'text': text.isNotEmpty ? text : (_selectedImage != null ? 'صورة' : ''),
      'type': _selectedImage != null ? 'image' : 'text',
      'imageUrl': _selectedImage?.path,
      'timestamp': DateTime.now(),
      'status': 'sending',
      'isLocal': true,
    };

    setState(() {
      _messages.add(newMessage);
      _selectedImage = null;
      _showMediaPreview = false;
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _chatService.uploadMedia(_selectedImage!, 'image');
      }

      await _chatService.sendMessage(
        chatId: _currentChatId!,
        text: text.isNotEmpty ? text : (imageUrl != null ? 'صورة' : ''),
        imageUrl: imageUrl,
      );

      setState(() {
        _messages.removeWhere((msg) => msg['id'] == messageId);
        _selectedImage = null;
        _showMediaPreview = false;
        _messageController.clear();
      });
      context.read<ChatBloc>().add(LoadChatMessages(_currentChatId!));
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg['id'] == messageId);
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showMediaPreview = true;
      });
    }
  }

  void _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showMediaPreview = true;
      });
    }
  }

  void _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final path = '${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 48000,
          ),
          path: path,
        );
        setState(() => _isRecording = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل بدء التسجيل: $e')),
      );
    }
  }

  void _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null && path.isNotEmpty) {
        setState(() => _isSending = true);
        try {
          final audioUrl = await _chatService.uploadMedia(File(path), 'audio');
          await _chatService.sendMessage(
            chatId: _currentChatId!,
            text: 'رسالة صوتية',
            audioUrl: audioUrl,
          );
          _scrollToBottom();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل رفع الصوت: $e')),
          );
        } finally {
          setState(() => _isSending = false);
        }
      }
    } catch (e) {
      setState(() => _isRecording = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else if (time.day == now.day - 1) {
      return 'أمس';
    } else {
      return '${time.day}/${time.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ خلفية أورسومية صحية (مثل واتساب)
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFE8F0E8),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/chat_background.png'),
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Column(
          children: [
            _buildAppBar(isDark),
            if (_showMediaPreview && _selectedImage != null) _buildMediaPreview(),
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoadedState) {
                    _mergeMessages(state.messages);
                    _scrollToBottom();
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoadingState && _messages.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allMessages = [..._messages];
                  allMessages.sort((a, b) {
                    final aTime = a['timestamp'] is DateTime
                        ? (a['timestamp'] as DateTime).millisecondsSinceEpoch
                        : 0;
                    final bTime = b['timestamp'] is DateTime
                        ? (b['timestamp'] as DateTime).millisecondsSinceEpoch
                        : 0;
                    return aTime.compareTo(bTime);
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: allMessages.length,
                    reverse: false,
                    itemBuilder: (context, index) {
                      final message = allMessages[index];
                      final isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid ||
                          message['senderId'] == 'me';
                      final isTemp = message['isTemp'] == true;
                      final type = message['type'] ?? 'text';

                      return MessageBubble(
                        text: message['text'] ?? '',
                        type: type,
                        mediaUrl: message['imageUrl'] ?? message['audioUrl'],
                        isMe: isMe,
                        time: message['timestamp'] is DateTime
                            ? _formatTime(message['timestamp'])
                            : '',
                        isRead: message['status'] == 'sent' || !isTemp,
                        senderName: isMe ? null : (message['senderName'] ?? widget.userName),
                      );
                    },
                  );
                },
              ),
            ),
            _buildInputBar(isDark),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
      foregroundColor: isDark ? Colors.white : AppColors.primary,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                widget.userName.isNotEmpty ? widget.userName[0] : 'ط',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'متصل',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
          ),
          onPressed: _startAudioCall,
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.videocam_rounded, color: AppColors.info, size: 20),
          ),
          onPressed: _startVideoCall,
        ),
      ],
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => setState(() {
              _selectedImage = null;
              _showMediaPreview = false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // ✅ زر المرفقات
            PopupMenuButton<String>(
              icon: const Icon(Icons.attach_file_rounded, color: AppColors.grey),
              onSelected: (value) {
                if (value == 'gallery') _pickImage();
                else if (value == 'camera') _takePhoto();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'gallery',
                  child: Row(
                    children: [
                      Icon(Icons.photo_library_rounded),
                      SizedBox(width: 8),
                      Text('المعرض'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'camera',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt_rounded),
                      SizedBox(width: 8),
                      Text('الكاميرا'),
                    ],
                  ),
                ),
              ],
            ),
            // ✅ زر التسجيل الصوتي
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressEnd: (_) => _stopRecording(),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isRecording ? AppColors.error.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _isRecording ? Icons.circle_rounded : Icons.mic_rounded,
                  color: _isRecording ? AppColors.error : AppColors.grey,
                  size: 24,
                ),
              ),
            ),
            // ✅ حقل النص
            Expanded(
              child: TextField(
                controller: _messageController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                onChanged: (text) => setState(() => _isTyping = text.isNotEmpty),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            // ✅ زر الإرسال
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (_selectedImage != null || _messageController.text.trim().isNotEmpty)
                      ? [AppColors.primary, AppColors.primaryDark]
                      : [AppColors.grey, AppColors.grey],
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mergeMessages(List<Map<String, dynamic>> firestoreMessages) {
    for (final msg in firestoreMessages) {
      final exists = _messages.any((m) => m['id'] == msg['id']);
      if (!exists) {
        _messages.add({
          ...msg,
          'status': 'sent',
          'isLocal': false,
        });
      }
    }
  }
}
