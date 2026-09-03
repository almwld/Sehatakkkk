import 'package:sehatak/core/services/toast_service.dart';
// ============================================================
// 📱 ChatDetailScreen - شاشة الدردشة المتكاملة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/entities/message_entity.dart';
import '../../../core/constants/app_colors.dart';
import '../../../bloc/messages/messages_bloc.dart';
import '../../../bloc/messages/messages_event.dart';
import '../../../bloc/messages/messages_state.dart';
import 'widgets/message_bubble.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/reply_banner.dart';
import 'widgets/typing_indicator.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  bool _isSending = false;
  String? _replyTo;
  String? _replyToText;
  List<String> _typingUsers = [];

  @override
  void initState() {
    super.initState();
    context.read<MessagesBloc>().add(LoadMessages(chatId: widget.chatId));
    context.read<MessagesBloc>().add(StreamMessages(chatId: widget.chatId));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    context.read<MessagesBloc>().add(StopStreamingMessages());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: _buildAppBar(isDark),
      body: Column(
        children: [
          // ✅ مؤشر الكتابة
          if (_typingUsers.isNotEmpty)
            TypingIndicator(
              name: _typingUsers.length == 1 ? _typingUsers.first : '${_typingUsers.length} أشخاص',
            ),
          // ✅ شريط الرد
          if (_replyTo != null)
            ReplyBanner(
              message: _replyToText ?? '',
              senderName: 'مستخدم',
              onCancel: () => setState(() {
                _replyTo = null;
                _replyToText = null;
              }),
            ),
          // ✅ قائمة الرسائل
          Expanded(
            child: BlocBuilder<MessagesBloc, MessagesState>(
              builder: (context, state) {
                if (state is MessagesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MessagesError) {
                  return _buildErrorState(isDark, state.message);
                }

                if (state is MessagesLoaded) {
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
                      final isMe = message.senderId ==
                          FirebaseAuth.instance.currentUser?.uid;
                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        onReply: () {
                          setState(() {
                            _replyTo = message.id;
                            _replyToText = message.text;
                          });
                        },
                        onDelete: () {
                          context.read<MessagesBloc>().add(
                            DeleteMessage(
                              chatId: widget.chatId,
                              messageId: message.id,
                            ),
                          );
                        },
                        onReaction: (emoji) {
                          context.read<MessagesBloc>().add(
                            AddReaction(
                              chatId: widget.chatId,
                              messageId: message.id,
                              emoji: emoji,
                            ),
                          );
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          // ✅ شريط الإدخال
          ChatInputBar(
            textController: _textController,
            onSend: _sendMessage,
            onImagePick: _sendImage,
            onVoiceRecord: _startVoiceRecording,
            onFilePick: _sendFile,
            onLocationShare: _shareLocation,
            isSending: _isSending,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏗️ AppBar
  // ============================================================

  AppBar _buildAppBar(bool isDark) {
    return AppBar(
      title: const Text('الدردشة'),
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

  // ============================================================
  // 💬 إدارة الرسائل
  // ============================================================

  Future<void> _sendMessage(String text) async {
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      context.read<MessagesBloc>().add(
        SendMessage(
          chatId: widget.chatId,
          text: text,
          replyTo: _replyTo,
        ),
      );
      _textController.clear();
      setState(() {
        _replyTo = null;
        _replyToText = null;
      });
      _scrollToBottom();
    } catch (e) {
      // Error handled by BLoC
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;

      setState(() => _isSending = true);
      // TODO: رفع الصورة وإرسالها
      ToastService.showInfo('📷 جاري رفع الصورة...');
    } catch (e) {
      // Error handled
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _startVoiceRecording() {
    ToastService.showInfo('🎤 جاري التسجيل...');
  }

  void _sendFile() {
    ToastService.showInfo('📎 جاري اختيار الملف...');
  }

  void _shareLocation() {
    ToastService.showInfo('📍 جاري مشاركة الموقع...');
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

  // ============================================================
  // 🎨 حالات فارغة وخطأ
  // ============================================================

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
              context.read<MessagesBloc>().add(
                LoadMessages(chatId: widget.chatId),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
