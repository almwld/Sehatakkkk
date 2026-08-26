import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
import 'package:sehatak/core/constants/app_images.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  final NextcloudService _nextcloud = NextcloudService();
  final Connectivity _connectivity = Connectivity();

  bool _isTyping = false;
  bool _isLoading = true;
  bool _useNextcloud = false;
  bool _isOnline = true;
  bool _isOfflineMode = false;
  String _chatUrl = '';
  String _otherUserId = '';

  // ✅ خلفيات الدردشة
  final List<String> _wallpapers = [
    'assets/images/sehatak_chat_wallpaper_light.svg',
    'assets/images/sehatak_chat_wallpaper_dark.svg',
    'assets/images/sehatak_chat_wallpaper_light_1080x2160.png',
    'assets/images/sehatak_chat_wallpaper_dark_1080x2160.png',
    'assets/images/sehatak_chat_wallpaper_auto.svg',
  ];

  int _selectedWallpaperIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _initializeChat();
    _getOtherUser();
    _loadWallpaperPreference();
    
    _connectivity.onConnectivityChanged.listen((result) {
      setState(() {
        _isOnline = result != ConnectivityResult.none;
        _isOfflineMode = !_isOnline;
        if (_isOnline) {
          _initializeChat();
        }
      });
    });
  }

  Future<void> _loadWallpaperPreference() async {
    // ✅ تحميل خلفية محفوظة
    final prefs = await SharedPreferences.getInstance();
    final savedIndex = prefs.getInt('chat_wallpaper_index');
    if (savedIndex != null && savedIndex < _wallpapers.length) {
      setState(() {
        _selectedWallpaperIndex = savedIndex;
      });
    }
  }

  Future<void> _saveWallpaperPreference(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('chat_wallpaper_index', index);
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
    _isOfflineMode = !_isOnline;
  }

  Future<void> _getOtherUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || widget.roomId == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(widget.roomId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        final participants = List<String>.from(data?['participants'] ?? []);
        _otherUserId = participants.firstWhere((id) => id != user.uid, orElse: () => '');
      }
    } catch (e) {
      print('❌ Error getting other user: $e');
    }
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    
    try {
      if (_isOnline) {
        final isAvailable = await _nextcloud.checkServerStatus();
        if (isAvailable && widget.roomId != null) {
          _useNextcloud = true;
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null && _otherUserId.isNotEmpty) {
            _chatUrl = await _nextcloud.getChatUrl(
              widget.roomId!,
              _otherUserId,
            );
          }
        }
      }
    } catch (e) {
      print('❌ Nextcloud error: $e');
      _useNextcloud = false;
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showWallpaperPicker() {
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
              'اختر خلفية الدردشة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _wallpapers.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedWallpaperIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWallpaperIndex = index;
                        _saveWallpaperPreference(index);
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          _wallpapers[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: Icon(
                              Icons.image_rounded,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallpaper = _wallpapers[_selectedWallpaperIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.roomName ?? 'الدردشة',
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (_isOfflineMode) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'غير متصل',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          // ✅ زر تغيير الخلفية
          IconButton(
            icon: Icon(Icons.wallpaper_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: _showWallpaperPicker,
          ),
          if (_useNextcloud && _isOnline)
            IconButton(
              icon: Icon(Icons.cloud_rounded, color: AppColors.primary),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('☁️ متصل بـ Nextcloud Talk'),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          if (_isOfflineMode)
            IconButton(
              icon: Icon(Icons.wifi_off_rounded, color: Colors.orange),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📶 غير متصل - يتم عرض الرسائل المخزنة محلياً'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(wallpaper),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _useNextcloud && _chatUrl.isNotEmpty && _isOnline
                ? _buildNextcloudChat()
                : _buildFirestoreChat(isDark),
      ),
    );
  }

  Widget _buildNextcloudChat() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF8FAFC))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            print('📱 Loading: $progress%');
          },
          onPageFinished: (url) {
            print('✅ Nextcloud chat loaded: $url');
          },
        ),
      )
      ..loadRequest(Uri.parse(_chatUrl));

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: WebViewWidget(controller: controller),
    );
  }

  Widget _buildFirestoreChat(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('يرجى تسجيل الدخول'));
    }

    return Column(
      children: [
        if (_isOfflineMode)
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.orange.withOpacity(0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  '📶 غير متصل - يتم عرض الرسائل المخزنة محلياً',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: widget.roomId == null
              ? _buildEmptyState(isDark)
              : StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chat_rooms')
                      .doc(widget.roomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('❌ ${snapshot.error}'));
                    }

                    final messages = snapshot.data?.docs ?? [];
                    if (messages.isEmpty) {
                      return _buildEmptyChatState(isDark);
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final data = message.data() as Map<String, dynamic>;
                        final isMe = data['senderId'] == user.uid;
                        return _buildMessageBubble(data, isMe, isDark);
                      },
                    );
                  },
                ),
        ),
        _buildInputField(isDark),
      ],
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe, bool isDark) {
    final text = message['text'] ?? '';
    final time = _formatTime(message['timestamp']);
    final isPending = message['pending'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.white.withOpacity(0.9)),
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                  bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isMe ? Colors.white70 : Colors.grey[500],
                        ),
                      ),
                      if (isMe && isPending) ...[
                        const SizedBox(width: 4),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white70,
                          ),
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

  Widget _buildInputField(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white.withOpacity(0.95),
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
            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            onPressed: _showAttachmentOptions,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B1121) : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
              ),
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
                  hintText: _isOnline ? 'اكتب رسالتك...' : '📶 غير متصل - سيتم الإرسال عند الاتصال',
                  hintStyle: TextStyle(
                    color: _isOnline 
                        ? (isDark ? Colors.grey[500] : Colors.grey[400])
                        : Colors.orange,
                    fontSize: 14,
                  ),
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final messageData = {
      'text': text,
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
      'pending': !_isOnline,
    };

    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(widget.roomId ?? 'temp')
        .collection('messages')
        .add(messageData);

    if (widget.roomId != null) {
      FirebaseFirestore.instance.collection('chat_rooms').doc(widget.roomId).update({
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    if (_isOnline && _useNextcloud && _chatUrl.isNotEmpty) {
      _nextcloud.sendMessage(widget.roomId ?? '', text);
    }

    _textController.clear();
    setState(() => _isTyping = false);
    _scrollToBottom();
  }

  void _showAttachmentOptions() {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📶 لا يمكن مشاركة الملفات في وضع Offline'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('صورة من المعرض'),
              onTap: () {
                Navigator.pop(context);
                _sendMedia('image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                _sendMedia('camera');
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              title: const Text('إرسال ملف'),
              onTap: () {
                Navigator.pop(context);
                _sendMedia('file');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: AppColors.primary),
              title: const Text('مشاركة الموقع'),
              onTap: () {
                Navigator.pop(context);
                _sendMedia('location');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMedia(String type) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📎 جاري إرسال $type...'),
        backgroundColor: AppColors.primary,
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
            onPressed: () {},
            icon: const Icon(Icons.group_add),
            label: const Text('إنشاء مجموعة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
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
