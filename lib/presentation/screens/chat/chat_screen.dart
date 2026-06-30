import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String? receiverId;
  final String? receiverName;
  final String? receiverPhoto;
  final bool isVideoCall;

  const ChatScreen({
    super.key,
    this.conversationId,
    this.receiverId,
    this.receiverName,
    this.receiverPhoto,
    this.isVideoCall = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ChatService _chatService = ChatService();
  final AudioRecorder _audioRecorder = AudioRecorder();

  String? _conversationId;
  String? _receiverId;
  String? _receiverName;
  String? _receiverPhoto;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isRecording = false;
  String? _recordingPath;
  bool _isTyping = false;
  Timer? _typingTimer;

  File? _selectedImage;
  File? _selectedFile;
  bool _showMediaPreview = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnackBar('يرجى تسجيل الدخول أولاً', isError: true);
        return;
      }

      if (widget.conversationId != null) {
        _conversationId = widget.conversationId;
        _receiverId = widget.receiverId;
        _receiverName = widget.receiverName;
        _receiverPhoto = widget.receiverPhoto;
      } else if (widget.receiverId != null) {
        final conv = await _chatService.getOrCreateConversation(widget.receiverId!);
        _conversationId = conv.id;
        _receiverId = widget.receiverId;
        _receiverName = widget.receiverName ?? conv.otherParticipantName;
        _receiverPhoto = widget.receiverPhoto ?? conv.otherParticipantPhoto;
      }

      if (_conversationId != null) {
        await _chatService.markAsRead(_conversationId!);
      }

      setState(() => _isLoading = false);
    } catch (e) {
      _showSnackBar('فشل تحميل المحادثة: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handleTyping(String text) {
    if (_conversationId == null || _receiverId == null) return;

    _typingTimer?.cancel();
    final isTyping = text.isNotEmpty;

    _chatService.setTyping(_conversationId!, isTyping);

    if (isTyping) {
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _chatService.setTyping(_conversationId!, false);
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if ((text.isEmpty && _selectedImage == null && _selectedFile == null) || _isSending) return;
    if (_conversationId == null || _receiverId == null) {
      _showSnackBar('المحادثة غير جاهزة', isError: true);
      return;
    }

    setState(() => _isSending = true);

    try {
      if (_selectedImage != null) {
        await _chatService.sendImageMessage(
          conversationId: _conversationId!,
          imageFile: _selectedImage!,
          caption: text.isNotEmpty ? text : null,
        );
        _selectedImage = null;
        _showMediaPreview = false;
        _messageController.clear();
        _scrollToBottom();
        setState(() => _isSending = false);
        return;
      }

      if (_selectedFile != null) {
        await _chatService.sendFileMessage(
          conversationId: _conversationId!,
          file: _selectedFile!,
          caption: text.isNotEmpty ? text : null,
        );
        _selectedFile = null;
        _showMediaPreview = false;
        _messageController.clear();
        _scrollToBottom();
        setState(() => _isSending = false);
        return;
      }

      await _chatService.sendMessage(
        conversationId: _conversationId!,
        content: text,
      );

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      _showSnackBar('فشل إرسال الرسالة: $e', isError: true);
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _startRecording() async {
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
      } else {
        _showSnackBar('يرجى منح إذن الميكروفون', isError: true);
      }
    } catch (e) {
      _showSnackBar('فشل بدء التسجيل: $e', isError: true);
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });

      if (path != null && _conversationId != null) {
        final file = File(path);
        await _chatService.sendAudioMessage(
          conversationId: _conversationId!,
          audioFile: file,
        );
        _scrollToBottom();
      }
    } catch (e) {
      _showSnackBar('فشل إيقاف التسجيل: $e', isError: true);
      setState(() {
        _isRecording = false;
        _recordingPath = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showMediaPreview = true;
        _selectedFile = null;
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _showMediaPreview = true;
        _selectedFile = null;
      });
    }
  }

  void _clearMedia() {
    setState(() {
      _selectedImage = null;
      _selectedFile = null;
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
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return '${diff.inMinutes} د';
    if (diff.inDays < 1) return '${diff.inHours} س';
    if (diff.inDays < 7) return '${diff.inDays} ي';
    return DateFormat('dd/MM').format(time);
  }

  void _navigateToCall({bool isVideo = true}) {
    if (_conversationId == null || _receiverId == null || _receiverName == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          roomName: _conversationId!,
          callerName: _receiverName!,
          callerPhoto: _receiverPhoto,
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: _buildAppBar(isDark),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_isTyping) _buildTypingIndicator(),
                Expanded(
                  child: _conversationId != null
                      ? _buildMessagesStream()
                      : _buildEmptyState(),
                ),
                if (_showMediaPreview && (_selectedImage != null || _selectedFile != null))
                  _buildMediaPreview(),
                _buildInputBar(isDark),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
      foregroundColor: isDark ? Colors.white : AppColors.primary,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.pop(context),
        splashRadius: 24,
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: _receiverPhoto != null
                  ? DecorationImage(
                      image: NetworkImage(_receiverPhoto!),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: _receiverPhoto == null
                ? Center(
                    child: Text(
                      _receiverName?.isNotEmpty == true ? _receiverName![0] : 'م',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _receiverName ?? 'مستخدم',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call, color: AppColors.success, size: 20),
          ),
          onPressed: () => _navigateToCall(isVideo: false),
          tooltip: 'مكالمة صوتية',
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.videocam, color: AppColors.info, size: 20),
          ),
          onPressed: () => _navigateToCall(isVideo: true),
          tooltip: 'مكالمة فيديو',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.warning.withOpacity(0.08),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$_receiverName يكتب...',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesStream() {
    return StreamBuilder<List<ChatMessage>>(
      stream: _chatService.getMessages(_conversationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 60, color: AppColors.error),
                const SizedBox(height: 16),
                Text('حدث خطأ: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeChat,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final messages = snapshot.data ?? [];
        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMe = message.senderId == FirebaseAuth.instance.currentUser?.uid;
            return _buildMessageBubble(message, isMe);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final isDeleted = message.isDeleted;
    final isImage = message.type == MessageType.image;
    final isAudio = message.type == MessageType.audio;
    final isFile = message.type == MessageType.file;
    final isText = message.type == MessageType.text;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && !isDeleted)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: _receiverPhoto != null
                    ? DecorationImage(
                        image: NetworkImage(_receiverPhoto!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: _receiverPhoto == null
                  ? Center(
                      child: Text(
                        _receiverName?.isNotEmpty == true ? _receiverName![0] : 'م',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primary
                    : (isDeleted
                        ? Colors.grey[300]
                        : Theme.of(context).colorScheme.surfaceVariant),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                ),
                border: isDeleted ? Border.all(color: Colors.grey[400]!) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isImage && message.fileUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.fileUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 150,
                          width: 200,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 40),
                        ),
                      ),
                    ),
                  if (isAudio && message.fileUrl != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('0:30', style: TextStyle(fontSize: 10, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  if (isFile && message.fileUrl != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, color: AppColors.info),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.fileName ?? 'ملف',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (message.fileSize != null)
                                  Text(
                                    '${(message.fileSize! / 1024).toStringAsFixed(1)} KB',
                                    style: const TextStyle(fontSize: 9, color: AppColors.grey),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (isText && !isDeleted)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        message.content,
                        style: TextStyle(
                          color: isMe ? Colors.white : null,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  if (isDeleted)
                    Text(
                      '🗑️ تم حذف هذه الرسالة',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : AppColors.grey,
                          fontSize: 9,
                        ),
                      ),
                      if (isMe && !isDeleted) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all_rounded
                              : message.status == MessageStatus.delivered
                                  ? Icons.done_all_rounded
                                  : Icons.done_rounded,
                          size: 14,
                          color: message.status == MessageStatus.read
                              ? AppColors.info
                              : Colors.white54,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chat_bubble_outline, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد رسائل بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابدأ المحادثة الآن',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_selectedImage != null)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (_selectedFile != null)
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      path.basename(_selectedFile!.path),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _clearMedia,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              icon: Icon(
                Icons.attach_file_rounded,
                color: isDark ? Colors.white70 : AppColors.grey,
                size: 24,
              ),
              onSelected: (value) {
                switch (value) {
                  case 'gallery':
                    _pickImage();
                    break;
                  case 'camera':
                    _takePhoto();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'gallery',
                  child: Row(
                    children: [
                      Icon(Icons.photo_library, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('المعرض'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'camera',
                  child: Row(
                    children: [
                      Icon(Icons.camera_alt, color: AppColors.primary),
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
                color: _isRecording ? AppColors.error : (isDark ? Colors.white70 : AppColors.grey),
                size: 24,
              ),
              onPressed: _isRecording ? _stopRecording : _startRecording,
              splashRadius: 20,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0B1121)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  textAlign: TextAlign.right,
                  maxLines: 5,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  onChanged: _handleTyping,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (_messageController.text.trim().isNotEmpty ||
                          _selectedImage != null ||
                          _selectedFile != null)
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
                onPressed: (_messageController.text.trim().isNotEmpty ||
                        _selectedImage != null ||
                        _selectedFile != null)
                    ? _sendMessage
                    : null,
                splashRadius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
