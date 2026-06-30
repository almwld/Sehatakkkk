import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_event.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_state.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
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
  String? _recordingPath;
  bool _isTyping = false;
  bool _isSending = false;
  File? _selectedImage;
  bool _showMediaPreview = false;

  List<Map<String, dynamic>> _localMessages = [];

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChatMessages(widget.chatId));
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
          chatId: widget.chatId,
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
          chatId: widget.chatId,
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

    setState(() => _isSending = true);

    final tempMessage = {
      'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
      'senderId': FirebaseAuth.instance.currentUser?.uid ?? 'me',
      'senderName': 'أنا',
      'text': text.isNotEmpty ? text : (_selectedImage != null ? 'صورة' : ''),
      'imageUrl': _selectedImage?.path,
      'timestamp': DateTime.now(),
      'isTemp': true,
    };

    setState(() {
      _localMessages.add(tempMessage);
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
        chatId: widget.chatId,
        text: text.isNotEmpty ? text : (imageUrl != null ? 'صورة' : ''),
        imageUrl: imageUrl,
      );

      setState(() {
        _localMessages.removeWhere((msg) => msg['id'] == tempMessage['id']);
        _selectedImage = null;
        _showMediaPreview = false;
        _messageController.clear();
      });

      context.read<ChatBloc>().add(LoadChatMessages(widget.chatId));
    } catch (e) {
      setState(() {
        _localMessages.removeWhere((msg) => msg['id'] == tempMessage['id']);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الإرسال: $e')),
      );
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
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
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
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });
      if (path != null && path.isNotEmpty) {
        setState(() => _isSending = true);
        try {
          final audioUrl = await _chatService.uploadMedia(File(path), 'audio');
          await _chatService.sendMessage(
            chatId: widget.chatId,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل إيقاف التسجيل: $e')),
      );
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _selectedImage = null;
      _showMediaPreview = false;
    });
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
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_showMediaPreview && _selectedImage != null) _buildMediaPreview(),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatErrorState) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is ChatLoadedState) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ChatBloc>().add(LoadChatMessages(widget.chatId));
                          },
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                List<Map<String, dynamic>> allMessages = [];
                if (state is ChatLoadedState) {
                  allMessages = [...state.messages];
                }
                allMessages.addAll(_localMessages);
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
                  padding: const EdgeInsets.all(16),
                  itemCount: allMessages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    final isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid ||
                        message['senderId'] == 'me';
                    final isTemp = message['isTemp'] == true;

                    return _buildMessageBubble(
                      text: message['text'] ?? '',
                      isMe: isMe,
                      time: message['timestamp'] is DateTime
                          ? _formatTime(message['timestamp'])
                          : '',
                      imageUrl: message['imageUrl'],
                      audioUrl: message['audioUrl'],
                      isTemp: isTemp,
                    );
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
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
              color: Colors.white24,
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
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'متصل',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
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
                      '🟢',
                      style: TextStyle(
                        fontSize: 10,
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
        // ✅ زر المكالمة الصوتية
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
          ),
          onPressed: _startAudioCall,
          tooltip: 'مكالمة صوتية',
        ),
        // ✅ زر مكالمة الفيديو
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.videocam_rounded, color: AppColors.info, size: 20),
          ),
          onPressed: _startVideoCall,
          tooltip: 'مكالمة فيديو',
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
            onPressed: _clearMedia,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ زر المرفقات
          PopupMenuButton<String>(
            icon: const Icon(Icons.attach_file_rounded, color: AppColors.grey),
            onSelected: (value) {
              if (value == 'gallery') {
                _pickImage();
              } else if (value == 'camera') {
                _takePhoto();
              }
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
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: _isRecording ? AppColors.error : AppColors.grey,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
          // ✅ حقل النص
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onChanged: (text) {
                setState(() {
                  _isTyping = text.isNotEmpty;
                });
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required String time,
    String? imageUrl,
    String? audioUrl,
    bool isTemp = false,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 5),
            bottomRight: Radius.circular(isMe ? 5 : 20),
          ),
          border: isTemp ? Border.all(color: AppColors.warning, width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ✅ عرض الصورة
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_rounded),
                        ),
                      )
                    : Image.file(
                        File(imageUrl),
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image_rounded),
                        ),
                      ),
              ),
            // ✅ عرض الصوت
            if (audioUrl != null && audioUrl.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: isMe ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.white24
                              : AppColors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '0:30',
                      style: TextStyle(
                        color: isMe ? Colors.white70 : AppColors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            // ✅ عرض النص
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  text,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.grey,
                  ),
                ),
                if (isTemp) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.timer_rounded,
                    size: 10,
                    color: AppColors.warning,
                  ),
                ],
                if (isMe && !isTemp) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: AppColors.success,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
