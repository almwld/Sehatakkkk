import 'package:sehatak/core/services/sound_manager.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        
        setState(() {
          _currentChatId = newChatId;
        });
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
    if (_currentChatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جاري إنشاء المحادثة...')),
      );
      return;
    }

    final messageId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final newMessage = {
      'id': messageId,
      'senderId': FirebaseAuth.instance.currentUser?.uid ?? 'me',
      'senderName': 'أنا',
      'text': text.isNotEmpty ? text : (_selectedImage != null ? 'صورة' : ''),
      'imageUrl': _selectedImage?.path,
      'audioUrl': _recordingPath,
      'timestamp': DateTime.now(),
      'status': 'sending',
      'isLocal': true,
      'isTemp': true,
    };

    setState(() {
      _messages.add(newMessage);
      _selectedImage = null;
      _showMediaPreview = false;
      _messageController.clear();
      _recordingPath = null;
    });
    _scrollToBottom();
    setState(() => _isSending = true);

    try {
      String? imageUrl;
      String? audioUrl;

      if (_selectedImage != null) {
        imageUrl = await _chatService.uploadMedia(_selectedImage!, 'image');
      }

      if (_recordingPath != null && _recordingPath!.isNotEmpty) {
        audioUrl = await _chatService.uploadMedia(File(_recordingPath!), 'audio');
      }

      await _chatService.sendMessage(
        chatId: _currentChatId!,
        text: text.isNotEmpty ? text : (imageUrl != null ? 'صورة' : ''),
        imageUrl: imageUrl,
        audioUrl: audioUrl,
      );

      setState(() {
        final index = _messages.indexWhere((msg) => msg['id'] == messageId);
        if (index != -1) {
          _messages[index]['status'] = 'sent';
          _messages[index]['isTemp'] = false;
          _messages[index]['imageUrl'] = imageUrl ?? _messages[index]['imageUrl'];
          _messages[index]['audioUrl'] = audioUrl ?? _messages[index]['audioUrl'];
        }
      });

      context.read<ChatBloc>().add(LoadChatMessages(_currentChatId!));
    } catch (e) {
      setState(() {
        final index = _messages.indexWhere((msg) => msg['id'] == messageId);
        if (index != -1) {
          _messages[index]['status'] = 'failed';
        }
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
      });
      if (path != null && path.isNotEmpty) {
        setState(() {
          _recordingPath = path;
          _showMediaPreview = true;
        });
        _sendMessage();
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
      _recordingPath = null;
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

  Widget _buildStatusIcon(String status) {
    switch (status) {
      case 'sending':
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        );
      case 'sent':
        return const Icon(
          Icons.done_all_rounded,
          size: 14,
          color: Colors.white70,
        );
      case 'failed':
        return const Icon(
          Icons.error_outline_rounded,
          size: 14,
          color: Colors.red,
        );
      default:
        return const Icon(
          Icons.done_rounded,
          size: 14,
          color: Colors.white70,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLow,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (_showMediaPreview && (_selectedImage != null || _recordingPath != null))
            _buildMediaPreview(),
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state is ChatErrorState) {
                  print('⚠️ Chat error: ${state.message}');
                }
                if (state is ChatLoadedState) {
                  _mergeMessages(state.messages);
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is ChatLoadingState && _messages.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatErrorState && _messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _initializeChat,
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
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
                  padding: const EdgeInsets.all(16),
                  itemCount: allMessages.length,
                  reverse: false,
                  itemBuilder: (context, index) {
                    final message = allMessages[index];
                    final isMe = message['senderId'] == FirebaseAuth.instance.currentUser?.uid ||
                        message['senderId'] == 'me';
                    final isTemp = message['isTemp'] == true;
                    final status = message['status'] ?? 'sent';

                    return _buildMessageBubble(
                      text: message['text'] ?? '',
                      isMe: isMe,
                      time: message['timestamp'] is DateTime
                          ? _formatTime(message['timestamp'])
                          : '',
                      imageUrl: message['imageUrl'],
                      audioUrl: message['audioUrl'],
                      isTemp: isTemp,
                      status: status,
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

  void _mergeMessages(List<Map<String, dynamic>> firestoreMessages) {
    _messages.removeWhere((msg) => 
      msg['isLocal'] == true && 
      msg['status'] == 'sent' &&
      firestoreMessages.any((fm) => 
        fm['text'] == msg['text'] && 
        fm['timestamp'] is Timestamp &&
        fm['timestamp'].toDate().difference(msg['timestamp']).inSeconds.abs() < 5
      )
    );

    for (final msg in firestoreMessages) {
      final exists = _messages.any((m) => 
        m['id'] == msg['id'] || 
        (m['text'] == msg['text'] && 
         m['isLocal'] == true && 
         m['status'] == 'sending')
      );
      if (!exists) {
        _messages.add({
          ...msg,
          'status': 'sent',
          'isLocal': false,
        });
      }
    }
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
              color: AppColors.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
          ),
          onPressed: _startAudioCall,
          tooltip: 'مكالمة صوتية',
        ),
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
          if (_selectedImage != null)
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
          if (_recordingPath != null && _selectedImage == null)
            const Expanded(
              child: Row(
                children: [
                  Icon(Icons.audio_file_rounded, color: Colors.white, size: 30),
                  SizedBox(width: 8),
                  Text(
                    '🎵 رسالة صوتية',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
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
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: _isRecording ? AppColors.error : AppColors.grey,
            ),
            onPressed: _isRecording ? _stopRecording : _startRecording,
          ),
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: (_selectedImage != null || 
                         _recordingPath != null || 
                         _messageController.text.trim().isNotEmpty)
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
    String status = 'sent',
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
                const SizedBox(width: 4),
                if (isMe) _buildStatusIcon(status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
