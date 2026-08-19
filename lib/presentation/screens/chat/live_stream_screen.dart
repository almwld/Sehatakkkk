import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LiveStreamScreen extends StatefulWidget {
  final String roomId;
  final String streamerName;
  final bool isViewer;

  const LiveStreamScreen({
    super.key,
    required this.roomId,
    required this.streamerName,
    this.isViewer = true,
  });

  @override
  State<LiveStreamScreen> createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  Room? _room;
  bool _isConnected = false;
  int _viewerCount = 0;
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isMicOn = false;
  bool _isCameraOn = false;

  @override
  void initState() {
    super.initState();
    _connectToStream();
  }

  Future<void> _connectToStream() async {
    try {
      _room = Room();
      // ✅ اتصال بالبث المباشر
      await _room?.connect('wss://live.sehatak.com', 'room_${widget.roomId}');
      setState(() => _isConnected = true);

      // ✅ محاكاة عدد المشاهدين
      _simulateViewers();
    } catch (e) {
      print('❌ Stream connection error: $e');
    }
  }

  void _simulateViewers() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _viewerCount = 42 + (DateTime.now().millisecondsSinceEpoch % 50);
        });
        _simulateViewers();
      }
    });
  }

  void _sendComment() {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _comments.add({
        'user': 'مستخدم',
        'text': text,
        'time': DateTime.now(),
      });
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ شاشة البث
          Center(
            child: _isConnected
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey[900],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.live_tv,
                            size: 80,
                            color: Colors.red.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'البث المباشر',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'بواسطة ${widget.streamerName}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // ✅ واجهة البث
          if (_isConnected) ...[
            // ✅ معلومات البث
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // ✅ مؤشر مباشر
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'مباشر',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ✅ اسم البث
                  Text(
                    widget.streamerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // ✅ عدد المشاهدين
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_viewerCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // ✅ زر التحكم (للناشر فقط)
            if (!widget.isViewer)
              Positioned(
                bottom: 120,
                right: 16,
                child: Column(
                  children: [
                    _controlButton(
                      icon: _isMicOn ? Icons.mic : Icons.mic_off,
                      onTap: () => setState(() => _isMicOn = !_isMicOn),
                    ),
                    const SizedBox(height: 8),
                    _controlButton(
                      icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                      onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                    ),
                  ],
                ),
              ),

            // ✅ التعليقات
            Positioned(
              bottom: 80,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ✅ التعليقات
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[_comments.length - 1 - index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${comment['user']}: ',
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: comment['text'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ حقل التعليق
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'أضف تعليقاً...',
                            hintStyle: TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          onSubmitted: (_) => _sendComment(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendComment,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
