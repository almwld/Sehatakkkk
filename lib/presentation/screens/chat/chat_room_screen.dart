// ============================================================
// 📱 شاشة غرفة الدردشة - ChatRoomScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/chat_model.dart';
import 'package:sehatak/models/message_model.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/reply_banner.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String userName;
  final String? userImage;
  final bool isDoctor;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.userName,
    this.userImage,
    this.isDoctor = false,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ChatService _chatService = ChatService();
  final ImagePicker _picker = ImagePicker();

  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  bool _showVoiceRecorder = false;
  String? _replyTo;
  String? _replyToText;
  List<String> _typingUsers = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _chatService.markAsRead(widget.chatId);
  }

  void _loadMessages() {
    setState(() => _isLoading = true);
    _chatService.getMessages(widget.chatId).listen(
      (messages) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _scrollToBottom();
      },
      onError: (error) {
        setState(() => _isLoading = false);
        ToastService.showError('❌ فشل تحميل الرسائل: $error');
      },
    );
  }

  // ✅ إرسال رسالة
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: text,
        replyTo: _replyTo,
        replyToText: _replyToText,
      );

      _textController.clear();
      setState(() {
        _replyTo = null;
        _replyToText = null;
      });
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ✅ إرسال صورة
  Future<void> _sendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image == null) return;

      setState(() => _isSending = true);

      final imageUrl = await _chatService.uploadImage(
        chatId: widget.chatId,
        image: File(image.path),
      );

      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: '📷 صورة',
        imageUrl: imageUrl,
      );

      ToastService.showSuccess('✅ تم إرسال الصورة');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الصورة: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  // ✅ تسجيل صوتي
  void _startVoiceRecording() {
    setState(() => _showVoiceRecorder = true);
  }

  void _sendVoiceMessage(String path) async {
    setState(() => _showVoiceRecorder = false);
    try {
      final audioUrl = await _chatService.uploadAudio(
        chatId: widget.chatId,
        audio: File(path),
      );

      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: '🎤 رسالة صوتية',
        audioUrl: audioUrl,
      );

      ToastService.showSuccess('✅ تم إرسال الصوت');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الصوت: $e');
    }
  }

  // ✅ مشاركة الموقع
  void _shareLocation() {
    ToastService.showInfo('📍 جاري مشاركة الموقع...');
  }

  // ✅ إرسال ملف
  void _sendFile() {
    ToastService.showInfo('📎 جاري إرسال الملف...');
  }

  // ✅ الرد على رسالة
  void _onReply(MessageModel message) {
    setState(() {
      _replyTo = message.id;
      _replyToText = message.text;
    });
    _focusNode.requestFocus();
  }

  // ✅ تفاعلات
  void _onReaction(MessageModel message) {
    ToastService.showInfo('❤️ تم إضافة التفاعل');
  }

  // ✅ حذف رسالة
  void _onDelete(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل أنت متأكد من حذف هذه الرسالة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _chatService.deleteMessage(
                chatId: widget.chatId,
                messageId: message.id,
              );
              ToastService.showSuccess('✅ تم حذف الرسالة');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          if (_typingUsers.isNotEmpty)
            TypingIndicator(name: _typingUsers.first),
          if (_replyTo != null)
            ReplyBanner(
              message: _replyToText ?? '',
              senderName: widget.userName,
              onCancel: () => setState(() {
                _replyTo = null;
                _replyToText = null;
              }),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _messages.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.isMe;
                          return MessageBubble(
                            message: message,
                            chatId: widget.chatId,
                            isMe: isMe,
                            isDark: isDark,
                            onReply: _onReply,
                            onReaction: _onReaction,
                            onDelete: _onDelete,
                          );
                        },
                      ),
          ),
          if (_showVoiceRecorder)
            _buildVoiceRecorder()
          else
            ChatInputBar(
              textController: _textController,
              focusNode: _focusNode,
              onSend: _sendMessage,
              onImagePick: _sendImage,
              onVoiceRecord: _startVoiceRecording,
              onLocationShare: _shareLocation,
              onFilePick: _sendFile,
              isSending: _isSending,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            backgroundImage: widget.userImage != null && widget.userImage!.isNotEmpty
                ? NetworkImage(widget.userImage!)
                : null,
            child: widget.userImage == null || widget.userImage!.isEmpty
                ? Text(
                    widget.userName.isNotEmpty ? widget.userName[0] : 'م',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.userName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: Icon(Icons.call, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => ToastService.showInfo('📞 جاري الاتصال...'),
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => ToastService.showInfo('📹 جاري مكالمة فيديو...'),
          ),
        ],
      ),
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد رسائل',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ المحادثة الآن',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRecorder() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record, color: Colors.red),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('جاري التسجيل...'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.red),
            onPressed: () {
              setState(() => _showVoiceRecorder = false);
              ToastService.showInfo('⏹️ تم إيقاف التسجيل');
            },
          ),
        ],
      ),
    );
  }
}
