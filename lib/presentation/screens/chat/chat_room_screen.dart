// ============================================================
// 📱 شاشة غرفة الدردشة - النسخة النهائية
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/bloc/message/message_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/message_model.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/voice_recorder.dart';
import 'package:sehatak/presentation/screens/chat/widgets/reply_banner.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String userName;
  final String? userImage;
  final bool isGroup;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.userName,
    this.userImage,
    this.isGroup = false,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();

  bool _isSending = false;
  bool _showVoiceRecorder = false;
  String? _replyTo;
  String? _replyToText;
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _chatService.markAsRead(widget.chatId);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _chatService.getMessages(widget.chatId).listen(
        (messages) {
          setState(() {
            _messages = messages;
            _isLoading = false;
          });
          _scrollToBottom();
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'حدث خطأ في تحميل الرسائل: $error';
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  void _sendMessage() async {
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
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
      setState(() => _isSending = false);
    }
  }

  void _sendImage() async {
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

  void _sendVoiceMessage(String path) async {
    try {
      setState(() => _isSending = true);

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
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _sendFile() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (file == null) return;

      setState(() => _isSending = true);

      final fileName = file.path.split('/').last;
      final fileUrl = await _chatService.uploadFile(
        chatId: widget.chatId,
        file: File(file.path),
        fileName: fileName,
      );

      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: '📎 $fileName',
        fileUrl: fileUrl,
      );

      ToastService.showSuccess('✅ تم إرسال الملف');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الملف: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _shareLocation() {
    ToastService.showInfo('📍 جاري مشاركة الموقع...');
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

  void _showReactionPicker(MessageModel message) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر رد فعل',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: ['👍', '❤️', '😂', '😮', '😢', '🙏', '🔥', '🎉'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _chatService.addReaction(
                      chatId: widget.chatId,
                      messageId: message.id,
                      emoji: emoji,
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(MessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الرسالة'),
        content: const Text('هل أنت متأكد من حذف هذه الرسالة للجميع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _chatService.deleteMessage(
                chatId: widget.chatId,
                messageId: message.id,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _startAudioCall() {
    ToastService.showInfo('📞 جاري الاتصال الصوتي...');
  }

  void _startVideoCall() {
    ToastService.showInfo('📹 جاري مكالمة الفيديو...');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
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
                : _errorMessage != null
                    ? _buildErrorState(isDark)
                    : _messages.isEmpty
                        ? _buildEmptyState(isDark)
                        : ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.all(12),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return MessageBubble(
                                message: message,
                                chatId: widget.chatId,
                                isMe: message.isMe,
                                isDark: isDark,
                                onReply: (msg) {
                                  setState(() {
                                    _replyTo = msg.id;
                                    _replyToText = msg.text;
                                  });
                                  _focusNode.requestFocus();
                                },
                                onReaction: (msg) {
                                  _showReactionPicker(msg);
                                },
                                onDelete: (msg) {
                                  _showDeleteConfirmation(msg);
                                },
                              );
                            },
                          ),
          ),
          if (_showVoiceRecorder)
            VoiceRecorder(
              onRecordingComplete: (path) {
                setState(() => _showVoiceRecorder = false);
                _sendVoiceMessage(path);
              },
              onCancel: () => setState(() => _showVoiceRecorder = false),
            )
          else
            ChatInputBar(
              textController: _textController,
              focusNode: _focusNode,
              onSend: _sendMessage,
              onImagePick: _sendImage,
              onVoiceRecord: () => setState(() => _showVoiceRecorder = true),
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
            child: Text(
              widget.userName.isNotEmpty ? widget.userName[0] : 'م',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.userName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.call),
          onPressed: _startAudioCall,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          onPressed: _startVideoCall,
        ),
      ],
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // ✅ إنشاء رسالة تجريبية
              _chatService.sendMessage(
                chatId: widget.chatId,
                text: 'مرحباً، هذه أول رسالة في المحادثة',
              );
              _loadMessages();
            },
            icon: const Icon(Icons.send),
            label: const Text('إرسال رسالة تجريبية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'يرجى المحاولة مرة أخرى',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
