// ============================================================
// 📱 شاشة تفاصيل المحادثة - النسخة النهائية
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/models/message_model.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'dart:async';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String userId;
  final String userName;
  final bool isDoctor;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.userName,
    this.isDoctor = false,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
StreamSubscription<List<MessageModel>>? _messagesSubscription;
  
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('📱 ChatDetailScreen opened with chatId: ${widget.chatId}');
    _loadMessages();
    _chatService.markAsRead(widget.chatId);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _chatService.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ استخدام ChatService مباشرة (بدون MessageBloc)
      _messagesSubscription = _chatService.getMessages(widget.chatId).listen(
        (messages) {
          if (!mounted) return;

          print('📩 Received ${messages.length} messages');
          setState(() {
            _messages = messages;
            _isLoading = false;
          });
          _scrollToBottom();
        },
        onError: (error) {
          if (!mounted) return;

          print('❌ Error loading messages: $error');
          setState(() {
            _isLoading = false;
            _errorMessage = 'حدث خطأ في تحميل الرسائل: $error';
          });
        },
      );
    } catch (e) {
      print('❌ Exception loading messages: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'حدث خطأ: $e';
      });
    }
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (!mounted) return;

    setState(() => _isSending = true);

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        text: text,
      );
      _textController.clear();
      _scrollToBottom();
      ToastService.showSuccess('✅ تم إرسال الرسالة');
    } catch (e) {
      ToastService.showError('❌ فشل إرسال الرسالة: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;

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
      appBar: AppBar(
        title: Text(widget.userName),
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'مكالمة صوتية',
            icon: const Icon(Icons.call),
            onPressed: () {
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
            },
          ),
          IconButton(
            tooltip: 'مكالمة فيديو',
            icon: const Icon(Icons.videocam),
            onPressed: () {
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
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                              final user = FirebaseAuth.instance.currentUser;
                              final isMe = message.senderId == user?.uid;
                              
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(12).copyWith(
                                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                                    bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    if (!isMe)
                                      Text(
                                        message.senderName,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(message.timestamp),
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isMe ? Colors.white70 : (isDark ? Colors.grey[400] : Colors.grey[500]),
                                          ),
                                        ),
                                        if (isMe) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            message.isRead ? Icons.done_all : Icons.done,
                                            size: 12,
                                            color: message.isRead ? Colors.blue : Colors.white70,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
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
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _textController,
                      onChanged: (text) => setState(() {}),
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _textController.text.trim().isNotEmpty ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _textController.text.trim().isNotEmpty ? AppColors.primary : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                        width: 1.5,
                      ),
                    ),
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Icon(
                            _textController.text.trim().isNotEmpty ? Icons.send : Icons.mic,
                            color: _textController.text.trim().isNotEmpty ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              _sendMessage();
            },
            icon: const Icon(Icons.send),
            label: const Text('إرسال رسالة تجريبية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
    return '${time.day}/${time.month}';
  }
}
