import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? conversationId;
  final String? receiverId;
  final String? receiverName;
  final String? receiverPhoto;
  final bool isVideo;  // ✅ إضافة isVideo

  const ChatScreen({
    super.key,
    this.conversationId,
    this.receiverId,
    this.receiverName,
    this.receiverPhoto,
    this.isVideo = false,
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
  StreamSubscription? _messageSubscription;  // ✅ لإغلاق الـ Stream

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
    _messageSubscription?.cancel();  // ✅ إغلاق الـ Stream
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

  // ... (باقي الدوال كما هي)
}
