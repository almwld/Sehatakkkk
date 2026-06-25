import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_bloc.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_event.dart';
import 'package:sehatak/presentation/bloc/chat_bloc/chat_state.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;

  const ChatScreen({
    super.key,
    this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FocusNode _focusNode = FocusNode();
  
  bool _isRecording = false;
  String? _recordingPath;
  bool _isTyping = false;
  bool _isSending = false;
  String? _chatId;
  bool _isInitialized = false;

  File? _selectedImage;
  File? _selectedAudio;
  bool _showMediaPreview = false;

  @override
  void initState() {
    super.initState();
    _chatService.enableOffline(); // ✅ تفعيل التخزين المؤقت
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
    _focusNode.requestFocus(); // ✅ تركيز تلقائي
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMsg('يجب تسجيل الدخول أولاً', true);
      return;
    }

    try {
      if (widget.chatId != null && widget.chatId!.isNotEmpty) {
        setState(() {
          _chatId = widget.chatId;
          _isInitialized = true;
        });
        context.read<ChatBloc>().add(LoadChatMessages(_chatId!));
        return;
      }

      final chatId = await _chatService.createChat(
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        patientId: user.uid,
        patientName: user.displayName ?? 'مريض',
      );
      
      setState(() {
        _chatId = chatId;
        _isInitialized = true;
      });
      context.read<ChatBloc>().add(LoadChatMessages(chatId));
      
    } catch (e) {
      _showMsg('فشل إنشاء المحادثة: $e', true);
    }
  }

  // ✅ Optimistic UI: إرسال فوري مع مؤقت
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _selectedImage == null && _selectedAudio == null) || _isSending) return;
    if (_chatId == null || !_isInitialized) {
      _showMsg('جاري إنشاء المحادثة...', false);
      return;
    }

    setState(() => _isSending = true);
    
    // ✅ إضافة الرسالة محلياً فوراً (Optimistic)
    final currentUser = FirebaseAuth.instance.currentUser;
    final tempMessage = {
      'senderId': currentUser?.uid ?? 'me',
      'senderName': currentUser?.displayName ?? 'أنت',
      'text': text.isNotEmpty ? text : (_selectedImage != null ? '📷 صورة' : '🎵 رسالة صوتية'),
      'imageUrl': null,
      'audioUrl': null,
      'timestamp': DateTime.now(),
      'isSending': true,
    };
    
    context.read<ChatBloc>().add(AddLocalMessage(tempMessage));
    _messageController.clear();
    setState(() {
      _selectedImage = null;
      _selectedAudio = null;
      _showMediaPreview = false;
    });
    _scrollToBottom();

    try {
      String? imageUrl;
      String? audioUrl;

      if (_selectedImage != null) {
        imageUrl = await _chatService.uploadMedia(_selectedImage!, 'image');
      }

      if (_selectedAudio != null) {
        audioUrl = await _chatService.uploadMedia(_selectedAudio!, 'audio');
      }

      // ✅ إرسال الرسالة فعلياً
      context.read<ChatBloc>().add(
        SendChatMessage(
          chatId: _chatId!,
          text: text.isNotEmpty ? text : (imageUrl != null ? '📷 صورة' : '🎵 رسالة صوتية'),
          imageUrl: imageUrl,
          audioUrl: audioUrl,
        ),
      );
    } catch (e) {
      _showMsg('فشل الإرسال: $e', true);
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showMsg(String msg, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
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
      _showMsg('فشل بدء التسجيل: $e', true);
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
        setState(() {
          _selectedAudio = File(path);
          _showMediaPreview = true;
        });
      }
    } catch (e) {
      _showMsg('فشل إيقاف التسجيل: $e', true);
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _selectedImage = null;
      _selectedAudio = null;
      _showMediaPreview = false;
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'doctor_${widget.doctorId}',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.doctorName.isNotEmpty ? widget.doctorName[0] : 'ط',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
                    widget.doctorName.isNotEmpty ? widget.doctorName : 'الطبيب',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _isTyping ? 'يكتب...' : 'متصل 🟢',
                    style: TextStyle(
                      fontSize: 11,
                      color: _isTyping ? AppColors.warning : AppColors.success,
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
              child: const Icon(Icons.call, color: AppColors.success, size: 20),
            ),
            onPressed: () {
              if (_chatId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      chatId: _chatId!,
                      doctorName: widget.doctorName,
                      doctorId: widget.doctorId,
                      isVideo: false,
                    ),
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.videocam, color: AppColors.info, size: 20),
            ),
            onPressed: () {
              if (_chatId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CallScreen(
                      chatId: _chatId!,
                      doctorName: widget.doctorName,
                      doctorId: widget.doctorId,
                      isVideo: true,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showMediaPreview && (_selectedImage != null || _selectedAudio != null))
            _buildMediaPreview(),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (!_isInitialized) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('جاري إنشاء المحادثة...'),
                      ],
                    ),
                  );
                }
                if (state is ChatLoadingState) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatErrorState) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: AppColors.error),
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
                if (state is ChatLoadedState) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final currentUser = FirebaseAuth.instance.currentUser;
                      final isMe = message['senderId'] == currentUser?.uid ||
                                  message['senderId'] == 'me';
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        onTap: () {
                          if (message['imageUrl'] != null) {
                            _showImagePreview(message['imageUrl']);
                          }
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
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
          if (_selectedAudio != null)
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.audio_file, color: Colors.white, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '🎵 رسالة صوتية',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _clearMedia,
          ),
        ],
      ),
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.attach_file, color: AppColors.grey),
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
                      Icon(Icons.photo_library),
                      SizedBox(width: 8),
                      Text('المعرض'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'camera',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(width: 8),
                      Text('الكاميرا'),
                    ],
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? AppColors.error : AppColors.grey,
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  hintStyle: const TextStyle(fontSize: 13),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0B1121)
                      : AppColors.surfaceContainerLow,
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
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (_selectedImage != null || 
                           _selectedAudio != null || 
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
      ),
    );
  }
}
