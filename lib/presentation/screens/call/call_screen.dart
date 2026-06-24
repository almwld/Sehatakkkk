import 'package:flutter/material.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  final LiveKitService _liveKit = LiveKitService();
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  int _callDuration = 0;
  bool _isConnecting = true;
  String _errorMessage = '';
  
  // ✅ إضافة WebView للوصول إلى Agent Console
  bool _showConsole = false;
  final String _consoleUrl = 'https://cloud.livekit.io/projects/platformsehatak/agents/console';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCall();
  }

  @override
  void dispose() {
    _liveKit.endCall();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startCall() async {
    try {
      await _liveKit.startCall(
        roomName: widget.chatId,
        callerName: widget.doctorName,
        isVideo: widget.isVideo,
      );
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'فشل الاتصال: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${_errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _callDuration++);
        if (_callDuration < 60) {
          Future.delayed(const Duration(seconds: 1), _startTimer);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showConsole) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Agent Console'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _showConsole = false),
            ),
          ],
        ),
        body: WebView(
          initialUrl: _consoleUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (url) {
            print('✅ Agent Console loaded: $url');
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_errorMessage.isNotEmpty)
                    Icon(Icons.error_outline, color: AppColors.error, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage.isNotEmpty ? _errorMessage : 'جاري الاتصال...',
                    style: TextStyle(
                      color: _errorMessage.isNotEmpty ? AppColors.error : Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_isConnecting)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  // ✅ زر فتح Agent Console
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _showConsole = true),
                        icon: const Icon(Icons.videocam),
                        label: const Text('فتح Agent Console للتصحيح'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.isVideo && _errorMessage.isEmpty)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white54, size: 40),
                ),
              ),
            ),
          if (_errorMessage.isEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _callButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        color: _isMuted ? AppColors.error : Colors.white,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      if (widget.isVideo)
                        _callButton(
                          icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          color: _isCameraOn ? Colors.white : AppColors.error,
                          onTap: () => setState(() => _isCameraOn = !_isCameraOn),
                        ),
                      _callButton(
                        icon: Icons.call_end,
                        color: AppColors.error,
                        size: 60,
                        onTap: () => Navigator.pop(context),
                      ),
                      _callButton(
                        icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        color: _isSpeakerOn ? AppColors.info : Colors.white,
                        onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                      if (widget.isVideo)
                        _callButton(
                          icon: Icons.switch_camera,
                          color: Colors.white,
                          onTap: () {},
                        ),
                      // ✅ زر Agent Console
                      _callButton(
                        icon: Icons.developer_mode,
                        color: AppColors.info,
                        onTap: () => setState(() => _showConsole = true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_errorMessage.isEmpty)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'جاري الاتصال...',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required Color color,
    double size = 50,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(
          icon,
          color: color,
          size: size * 0.5,
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
