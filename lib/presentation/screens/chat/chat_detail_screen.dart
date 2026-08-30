// ============================================================
// 📱 شاشة تفاصيل المحادثة - النسخة النهائية
// ============================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/bloc/message/message_bloc.dart';
import 'package:sehatak/bloc/message/message_event.dart';
import 'package:sehatak/bloc/message/message_state.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/app_strings.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/models/message_model.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_input_bar.dart';
import 'package:sehatak/presentation/screens/chat/widgets/voice_recorder.dart';
import 'package:sehatak/presentation/screens/chat/widgets/reply_banner.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:image_picker/image_picker.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String userName;
  final bool isDoctor;
  final String? userImage;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.isDoctor,
    this.userImage,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ImagePicker _picker = ImagePicker();
  final ChatService _chatService = ChatService();

  bool _isSending = false;
  bool _showVoiceRecorder = false;
  String? _replyTo;
  String? _replyToText;

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(LoadMessagesEvent(chatId: widget.chatId, limit: 50));
    _chatService.markAsRead(widget.chatId);
    _chatService.connectNextcloud();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ✅ دالة إضافة خلفية الدردشة
  Widget _buildChatBackground(Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isDark 
                ? 'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png'
                : 'assets/images/sehatak_chat_wallpaper_light_1080x2160.png',
          ),
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDark),
      body: _buildChatBackground(
        Column(
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
              child: BlocBuilder<MessageBloc, MessageState>(
                builder: (context, state) {
                  if (state is MessageLoadingState || state is MessageRefreshingState) {
                    return ChatShimmer(isDark: isDark);
                  }

                  if (state is MessageErrorState) {
                    return _buildErrorState(isDark, state.message);
                  }

                  if (state is MessagesLoadedState) {
                    final messages = state.messages;
                    if (messages.isEmpty) {
                      return _buildEmptyState(isDark);
                    }
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
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
                    );
                  }

                  return const SizedBox.shrink();
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const Text(
                  'متصل',
                  style: TextStyle(fontSize: 11, color: AppColors.online),
                ),
              ],
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
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // TODO: إظهار خيارات إضافية
          },
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
            AppStrings.noMessages,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.startChat,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.read<MessageBloc>().add(RefreshMessagesEvent(chatId: widget.chatId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);

    context.read<MessageBloc>().add(
      SendMessageEvent(
        chatId: widget.chatId,
        text: text,
        replyTo: _replyTo,
        replyToText: _replyToText,
      ),
    );

    _textController.clear();
    setState(() {
      _replyTo = null;
      _replyToText = null;
    });
    _scrollToBottom();
    setState(() => _isSending = false);
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

      context.read<MessageBloc>().add(
        SendMessageEvent(
          chatId: widget.chatId,
          text: '📷 صورة',
          imageUrl: imageUrl,
        ),
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

      context.read<MessageBloc>().add(
        SendMessageEvent(
          chatId: widget.chatId,
          text: '🎤 رسالة صوتية',
          audioUrl: audioUrl,
        ),
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

      context.read<MessageBloc>().add(
        SendMessageEvent(
          chatId: widget.chatId,
          text: '📎 $fileName',
          fileUrl: fileUrl,
        ),
      );

      ToastService.showSuccess('✅ تم إرسال الملف');
      _scrollToBottom();
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الملف: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _shareLocation() async {
    ToastService.showInfo('📍 جاري مشاركة الموقع...');
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
                    context.read<MessageBloc>().add(
                      AddReactionEvent(
                        chatId: widget.chatId,
                        messageId: message.id,
                        emoji: emoji,
                      ),
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
              context.read<MessageBloc>().add(
                DeleteMessageEvent(
                  chatId: widget.chatId,
                  messageId: message.id,
                  forEveryone: true,
                ),
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
}
