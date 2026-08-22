import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';

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
  final Connectivity _connectivity = Connectivity();

  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  int _callDuration = 0;
  bool _isConnecting = true;
  String _errorMessage = '';
  bool _hasCameraPermission = false;
  bool _isConnected = false;

  VideoTrack? _remoteVideoTrack;
  VideoTrack? _localVideoTrack;
  bool _isRemoteVideoReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkConnectivity();
    _checkPermissions();
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      setState(() {
        _isConnecting = false;
        _errorMessage = '⚠️ لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.';
      });
      _showNoInternetDialog();
    } else {
      _isConnected = true;
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ لا يوجد إنترنت'),
        content: const Text('يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            child: const Text('رجوع'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkConnectivity();
              _checkPermissions();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    SoundManager().stopAll();
    _liveKit.endCall();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    if (widget.isVideo) {
      final status = await Permission.camera.request();
      setState(() => _hasCameraPermission = status.isGranted);
      if (!_hasCameraPermission) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'يرجى منح إذن الكاميرا';
        });
        return;
      }
    }
    await Permission.microphone.request();
    _startCall();
  }

  void _startCall() async {
    try {
      if (!_isConnected) {
        setState(() {
          _isConnecting = false;
          _errorMessage = '⚠️ لا يوجد اتصال بالإنترنت';
        });
        return;
      }

      SoundManager().playCallRingtone();

      await _liveKit.startCall(
        roomName: widget.chatId,
        callerName: widget.doctorName,
        isVideo: widget.isVideo && _hasCameraPermission,
      );

      SoundManager().stopAll();

      final room = _liveKit.room;
      if (room != null) {
        final localParticipant = room.localParticipant;
        if (localParticipant != null) {
          _handleParticipant(localParticipant);
        }

        for (final participant in room.participants.values) {
          if (participant is! LocalParticipant) {
            _handleParticipant(participant);
          }
        }

        room.events.on<ParticipantConnectedEvent>((event) {
          _handleParticipant(event.participant);
          print('✅ Participant connected: ${event.participant.identity}');
        });
      }

      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
        _startTimer();
      }
    } catch (e) {
      SoundManager().stopAll();
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'فشل الاتصال: $e';
        });
        ToastService.showError('❌ ${_errorMessage}');
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) Navigator.pop(context);
        });
      }
    }
  }

  void _handleParticipant(Participant participant) {
    try {
      for (final track in participant.videoTracks) {
        if (track.track != null && track.track is VideoTrack) {
          final videoTrack = track.track as VideoTrack;
          setState(() {
            if (participant is LocalParticipant) {
              _localVideoTrack = videoTrack;
              print('✅ Local video track found');
            } else {
              _remoteVideoTrack = videoTrack;
              _isRemoteVideoReady = true;
              print('✅ Remote video track found');
            }
          });
        }
      }
    } catch (e) {
      print('❌ Error handling video tracks: $e');
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

  void _toggleCamera() async {
    final newState = await _liveKit.toggleCamera();
    setState(() => _isCameraOn = newState);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _liveKit.room?.localParticipant?.setMicrophoneEnabled(!_isMuted);
    });
  }

  void _endCall() {
    SoundManager().stopAll();
    SoundManager().playCallEnd();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📹 فيديو الطرف الآخر
          Container(
            color: Colors.black87,
            child: _isRemoteVideoReady && _remoteVideoTrack != null
                ? VideoTrackRenderer(_remoteVideoTrack!)
                : _buildConnectingScreen(),
          ),
          // 🖼️ فيديو المستخدم (Picture-in-Picture)
          if (widget.isVideo && _hasCameraPermission && _localVideoTrack != null && _errorMessage.isEmpty)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: VideoTrackRenderer(_localVideoTrack!),
                ),
              ),
            ),
          if (widget.isVideo && _hasCameraPermission && _localVideoTrack == null && _errorMessage.isEmpty)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                width: 120,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.videocam_off_rounded, color: Colors.white54, size: 40),
                ),
              ),
            ),
          // 📞 واجهة التحكم
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
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMuted ? AppColors.error : Colors.white,
                        onTap: _toggleMute,
                      ),
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                          color: _isCameraOn ? Colors.white : AppColors.error,
                          onTap: _toggleCamera,
                        ),
                      _callButton(
                        icon: Icons.call_end_rounded,
                        color: AppColors.error,
                        size: 60,
                        onTap: _endCall,
                      ),
                      _callButton(
                        icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: _isSpeakerOn ? AppColors.info : Colors.white,
                        onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: Icons.switch_camera_rounded,
                          color: Colors.white,
                          onTap: () {},
                        ),
                    ],
                  ),
                ],
              ),
            ),
          // 🏷️ اسم الطبيب
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
                  Text(
                    _callDuration == 0 ? 'جاري الاتصال...' : 'متصل',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_errorMessage.isNotEmpty)
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 60),
          const SizedBox(height: 16),
          Text(
            _errorMessage.isNotEmpty ? _errorMessage : 'جاري الاتصال...',
            style: TextStyle(
              color: _errorMessage.isNotEmpty ? AppColors.error : Colors.white,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          if (_isConnecting && _errorMessage.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
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
