import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/group_service.dart';
import 'package:sehatak/core/services/typing_service.dart';
import 'package:sehatak/presentation/screens/chat/widgets/message_bubble.dart';
import 'package:sehatak/presentation/screens/chat/widgets/typing_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GroupService _groupService = GroupService();
  final TypingService _typingService = TypingService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isTyping = false;
  Timer? _typingDebounce;

  @override
  void initState() {
    super.initState();
    _groupService.markGroupMessagesAsRead(widget.groupId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingDebounce?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final isTyping = text.isNotEmpty;
    setState(() => _isTyping = isTyping);

    _typingDebounce?.cancel();
    if (isTyping) {
      _typingDebounce = Timer(const Duration(milliseconds: 500), () {
        _typingService.startTyping(chatId: widget.groupId);
      });
    } else {
      _typingService.stopTyping(chatId: widget.groupId);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      await _groupService.sendGroupMessage(
        groupId: widget.groupId,
        text: text,
      );
      _messageController.clear();
      setState(() => _isTyping = false);
      _scrollToBottom();
    } catch (e) {
      print('❌ Error sending group message: $e');
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;

      final ref = FirebaseStorage.instance
          .ref()
          .child('groups/${widget.groupId}/images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(image.path));
      final imageUrl = await ref.getDownloadURL();

      await _groupService.sendGroupMessage(
        groupId: widget.groupId,
        text: '📷 صورة',
        imageUrl: imageUrl,
      );
      _scrollToBottom();
    } catch (e) {
      print('❌ Error sending image: $e');
    }
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

  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0b141a) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(widget.groupName),
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0b141a) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: isDark ? Colors.white : Colors.black87),
            onPressed: _showGroupInfo,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _groupService.getGroupMessages(widget.groupId),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!;
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
                          final isMe = message['senderId'] == _auth.currentUser?.uid;

                          return MessageBubble(
                            chatId: widget.groupId,
                            messageId: message['id'],
                            text: message['text'] ?? '',
                            type: message['type'] ?? 'text',
                            mediaUrl: message['imageUrl'] ?? message['audioUrl'],
                            isMe: isMe,
                            time: _formatTime(message['timestamp'] as Timestamp?),
                            isRead: true,
                            senderName: message['senderName'] as String?,
                            reactions: List<String>.from(message['reactions'] ?? []),
                            reactionCounts: Map<String, int>.from(message['reactionCounts'] ?? {}),
                            onDelete: isMe ? () {
                              // حذف الرسالة
                            } : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _typingService.getTypingStatus(widget.groupId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    final typingUsers = snapshot.data!
                        .where((user) => user['userId'] != _auth.currentUser?.uid)
                        .toList();
                    if (typingUsers.isEmpty) return const SizedBox.shrink();

                    final names = typingUsers.map((user) => user['userName'] as String).toList();
                    final displayName = names.length == 1
                        ? names.first
                        : '${names.first} و ${names.length - 1} آخرين';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const TypingIndicator(),
                                const SizedBox(width: 8),
                                Text(
                                  '$displayName يكتب...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // ✅ حقل الإدخال
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0b141a) : Colors.white,
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
                IconButton(
                  icon: Icon(Icons.photo_library, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  onPressed: _sendImage,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF202c33) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _messageController,
                      onChanged: _onTextChanged,
                      onSubmitted: (_) => _sendMessage(),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      color: _isTyping ? AppColors.primary : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isTyping ? AppColors.primary : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isTyping ? Icons.send : Icons.mic,
                      color: _isTyping ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      size: 20,
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
            Icons.group_work_rounded,
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

  void _showGroupInfo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FutureBuilder<Map<String, dynamic>?>(
        future: _groupService.getGroupDetails(widget.groupId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final group = snapshot.data!;
          final members = List<String>.from(group['members'] ?? []);
          final admins = List<String>.from(group['admins'] ?? []);
          final isAdmin = admins.contains(_auth.currentUser?.uid);

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  group['name'] ?? 'المجموعة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${members.length} أعضاء',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                if (isAdmin) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.person_add, color: AppColors.primary),
                    title: const Text('إضافة عضو'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: إضافة عضو
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppColors.primary),
                    title: const Text('تعديل اسم المجموعة'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: تعديل الاسم
                    },
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text('مغادرة المجموعة', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showLeaveDialog();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLeaveDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مغادرة المجموعة'),
        content: const Text('هل أنت متأكد من رغبتك في مغادرة المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _groupService.leaveGroup(widget.groupId);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ تم مغادرة المجموعة'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ فشل مغادرة المجموعة: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
  }
}
