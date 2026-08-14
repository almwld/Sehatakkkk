import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class ChatRoomScreen extends StatefulWidget {
  final String? roomId;
  final String? roomName;
  final bool isGroup;

  const ChatRoomScreen({
    super.key,
    this.roomId,
    this.roomName,
    this.isGroup = false,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadMembers();
  }

  Future<void> _loadMessages() async {
    if (widget.roomId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        _messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'text': data['text'] ?? '',
            'senderId': data['senderId'] ?? '',
            'senderName': data['senderName'] ?? 'مستخدم',
            'timestamp': data['timestamp'],
            'type': data['type'] ?? 'text',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMembers() async {
    if (widget.roomId == null) return;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .collection('members')
          .get();

      setState(() {
        _members = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'مستخدم',
            'image': data['image'] ?? '',
            'isOnline': data['isOnline'] ?? false,
          };
        }).toList();
      });
    } catch (e) {
      // تجاهل الأخطاء
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId ?? 'temp')
        .collection('messages')
        .add({
      'text': text,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });

    _textController.clear();
    setState(() => _isTyping = false);
    _scrollToBottom();
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

  void _showCreateGroupDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: 'إنشاء مجموعة جديدة',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة',
                hintText: 'أدخل اسم المجموعة',
                prefixIcon: Icon(Icons.group),
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 16),
            const Text(
              'سيتم إضافتك كعضو أول في المجموعة',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                _createGroup(name);
                Navigator.pop(_);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _createGroup(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .add({
        'name': name,
        'isGroup': true,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'image': ImageKit.doctor1,
      });

      await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(docRef.id)
          .collection('members')
          .doc(user.uid)
          .set({
        'name': user.displayName ?? 'مستخدم',
        'image': user.photoURL ?? '',
        'isOnline': true,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إنشاء المجموعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل إنشاء المجموعة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _addMember() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: 'إضافة عضو',
        content: TextField(
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
            hintText: 'أدخل بريد العضو',
            prefixIcon: Icon(Icons.person_add),
          ),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(_),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: Text(widget.roomName ?? 'غرفة الدردشة'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          if (widget.isGroup) ...[
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: _addMember,
              tooltip: 'إضافة عضو',
            ),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => _buildMembersSheet(isDark),
                );
              },
              tooltip: 'الأعضاء',
            ),
          ],
        ],
      ),
      floatingActionButton: widget.roomId == null
          ? FloatingActionButton(
              onPressed: _showCreateGroupDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.group_add, color: Colors.white),
            )
          : null,
      body: widget.roomId == null
          ? _buildEmptyState(isDark)
          : Column(
              children: [
                if (_isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_messages.isEmpty)
                  Expanded(
                    child: _buildEmptyChatState(isDark),
                  )
                else
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const AssetImage('assets/images/chat_background.svg'),
                          fit: BoxFit.cover,
                          opacity: isDark ? 0.1 : 0.3,
                        ),
                      ),
                      child: ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg['senderId'] == user?.uid;
                          return _buildMessageBubble(msg, isMe, isDark);
                        },
                      ),
                    ),
                  ),
                _buildInputField(isDark),
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
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد غرف دردشة',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أنشئ مجموعة جديدة للتواصل مع الآخرين',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateGroupDialog,
            icon: const Icon(Icons.group_add),
            label: const Text('إنشاء مجموعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
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
            'كن أول من يرسل رسالة',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isMe, bool isDark) {
    final text = msg['text'] ?? '';
    final time = _formatTime(msg['timestamp']);
    final senderName = msg['senderName'] ?? 'مستخدم';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                senderName,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            textDirection: TextDirection.rtl,
            children: [
              if (!isMe) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    ImageKit.doctor1,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        senderName.isNotEmpty ? senderName[0] : 'م',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.white),
                  borderRadius: BorderRadius.circular(12).copyWith(
                    bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(4),
                    bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                        fontSize: 14,
                      ),
                      textAlign: isMe ? TextAlign.end : TextAlign.start,
                    ),
                    if (time.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 9,
                            color: isMe ? Colors.white70 : (isDark ? Colors.grey[500] : Colors.grey[600]),
                          ),
                          textAlign: isMe ? TextAlign.end : TextAlign.start,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
        textDirection: TextDirection.rtl,
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _textController,
                  focusNode: _focusNode,
                  onChanged: (text) {
                    setState(() => _isTyping = text.trim().isNotEmpty);
                  },
                  onSubmitted: (_) => _sendMessage(),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: () {},
          ),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 40,
              height: 40,
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
    );
  }

  Widget _buildMembersSheet(bool isDark) {
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
          const Text(
            'أعضاء المجموعة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._members.map((member) {
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  member['image'] ?? ImageKit.doctor1,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      (member['name'] ?? 'م')[0],
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                member['name'] ?? 'مستخدم',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              trailing: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: member['isOnline'] == true ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      if (timestamp is Timestamp) {
        final date = timestamp.toDate();
        final now = DateTime.now();
        if (date.day == now.day && date.month == now.month && date.year == now.year) {
          return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        } else if (date.day == now.day - 1) {
          return 'أمس';
        } else {
          return '${date.day}/${date.month}';
        }
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}
