import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/constants/text_styles.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
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
    required this.isDoctor,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  bool _isTyping = false;
  bool _showVoiceRecorder = false;
  bool _isRecording = false;
  String? _recordingPath;
  String? _replyToMessageId;
  Map<String, dynamic>? _replyToMessage;
  Timer? _typingDebounce;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  String? _selectedReactionMessageId;

  @override
  void initState() {
    super.initState();
    _markAsRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    _recordingTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _markAsRead() async {
    // ... الكود
  }

  void _onTextChanged(String text) {
    // ... الكود
  }

  void _sendTypingStatus(bool isTyping) {
    // ... الكود
  }

  Future<void> _sendMessage() async {
    // ... الكود
  }

  void _addReaction(String messageId, String emoji) async {
    // ... الكود
  }

  Future<void> _sendImage() async {
    // ... الكود
  }

  Future<void> _startRecording() async {
    // ... الكود
  }

  Future<void> _stopRecording() async {
    // ... الكود
  }

  void _scrollToBottom() {
    // ... الكود
  }

  void _showAttachmentOptions() {
    // ... الكود
  }

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return "";
    if (timestamp == null) return "";
    if (timestamp == null) return "";
    // ... الكود
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: _showDoctorInfo,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(ImageKit.doctor1),
                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(widget.userName),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          // ✅ زر الاتصال - بدون IconButton
          GestureDetector(
            onTap: () => ToastService.showInfo('📞 جاري الاتصال...'),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.call),
            ),
          ),
          // ✅ زر مكالمة فيديو - بدون IconButton
          GestureDetector(
            onTap: () => ToastService.showInfo('📹 جاري مكالمة فيديو...'),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.videocam),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/images/chat_background.svg'),
                  fit: BoxFit.cover,
                  opacity: isDark ? 0.1 : 0.3,
                ),
              ),
              child: Column(
                children: [
                  if (_replyToMessage != null)
                    _buildReplyBanner(isDark),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('chats')
                          .doc(widget.chatId)
                          .collection('messages')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('❌ ${snapshot.error}'));
                        }
                        if (!snapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final messages = snapshot.data!.docs;
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
                            final data = message.data() as Map<String, dynamic>;
                            final isMe = data['senderId'] == _auth.currentUser?.uid;

                            return _buildMessageBubble(data, message.id, isMe, isDark);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ✅ حقل الإدخال
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1121) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: _showVoiceRecorder
                ? _buildVoiceRecorder(isDark)
                : _buildInputField(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyBanner(bool isDark) {
    // ... الكود
    return Container();
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, String messageId, bool isMe, bool isDark) {
    // ... الكود
    return Container();
  }

  Widget _buildInputField(bool isDark) {
    // ... الكود
    return Container();
  }

  Widget _buildVoiceRecorder(bool isDark) {
    // ... الكود
    return Container();
  }

  void _showFullScreenImage(String imageUrl) {
    // ... الكود
  }

  void _showDoctorInfo() {
    // ... الكود
  }

  Widget _buildEmptyState(bool isDark) {
    // ... الكود
    return Container();
  }
}
