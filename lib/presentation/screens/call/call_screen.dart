import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:audioplayers/audioplayers.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;

  /// Firestore call document ID.
  /// Optional for backward compatibility with existing callers.
  final String? callId;

  /// True when this screen belongs to the caller.
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.chatId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
    this.callId,
    this.isOutgoing = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  final LiveKitService _liveKit = LiveKitService();
  final CallService _callService = CallService();
  final Connectivity _connectivity = Connectivity();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _callTimer;
  bool _callLifecycleEnded = false;

  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  bool _isVideoEnabled = true;
  int _callDuration = 0;
  bool _isConnecting = true;
  String _errorMessage = '';
  bool _hasCameraPermission = false;
  bool _hasMicrophonePermission = false;
  bool _isConnected = false;
  bool _isOnHold = false;

  VideoTrack? _remoteVideoTrack;
  VideoTrack? _localVideoTrack;
  bool _isRemoteVideoReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkConnectivity();
    _checkPermissions();
    _playRingtone();
  }

  Future<void> _playRingtone() async {
    try {
      await _audioPlayer.play(AssetSource('audio/call_ringtone.mp3'));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    } catch (e) {
      print('⚠️ Ringtone error: $e');
    }
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
              Navigator.pop(context);
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
    _callTimer?.cancel();
    _callTimer = null;

    _audioPlayer.stop();
    _audioPlayer.dispose();
    SoundManager().stopAll();
    _liveKit.endCall();

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    // ✅ طلب إذن الكاميرا
    if (widget.isVideo) {
      final cameraStatus = await Permission.camera.request();
      setState(() => _hasCameraPermission = cameraStatus.isGranted);
      if (!_hasCameraPermission) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'يرجى منح إذن الكاميرا';
          _isVideoEnabled = false;
        });
        ToastService.showError('❌ يرجى منح إذن الكاميرا');
        return;
      }
    }

    // ✅ طلب إذن الميكروفون
    final micStatus = await Permission.microphone.request();
    setState(() => _hasMicrophonePermission = micStatus.isGranted);
    if (!_hasMicrophonePermission) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'يرجى منح إذن الميكروفون';
      });
      ToastService.showError('❌ يرجى منح إذن الميكروفون');
      return;
    }

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

      // ✅ إيقاف نغمة الرنين
      await _audioPlayer.stop();

      // ✅ بدء المكالمة
      await _liveKit.connectRoom(
        roomName: widget.chatId,
        participantName: FirebaseAuth.instance.currentUser?.displayName ?? 'مستخدم',
      );
      if (widget.isVideo && _hasCameraPermission) {
        await _liveKit.enableCamera();
      }

      final room = _liveKit.room;
      if (room != null) {
        // ✅ معالجة الفيديو المحلي
        final localParticipant = room.localParticipant;
        if (localParticipant != null) {
          _handleParticipant(localParticipant);
        }

        // ✅ معالجة الفيديو البعيد
        for (final participant in room.participants.values) {
          if (participant is! LocalParticipant) {
            _handleParticipant(participant);
          }
        }

        // ✅ الاستماع للمشاركين الجدد
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
        ToastService.showSuccess('📞 جاري الاتصال...');
      }
    } catch (e) {
      await _audioPlayer.stop();
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
    _callTimer?.cancel();

    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _callTimer?.cancel();
        return;
      }

      setState(() => _callDuration++);
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

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    _liveKit.setSpeakerphone(_isSpeakerOn);
    ToastService.showInfo(_isSpeakerOn ? '🔊 مكبر الصوت مفعل' : '🔇 مكبر الصوت معطل');
  }

  void _toggleHold() {
    setState(() => _isOnHold = !_isOnHold);
    if (_isOnHold) {
      _liveKit.room?.localParticipant?.setMicrophoneEnabled(false);
      ToastService.showInfo('⏸️ تم وضع المكالمة في الانتظار');
    } else {
      _liveKit.room?.localParticipant?.setMicrophoneEnabled(!_isMuted);
      ToastService.showInfo('▶️ تم استئناف المكالمة');
    }
  }

  Future<void> _endCall() async {
    if (_callLifecycleEnded) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    _callLifecycleEnded = true;
    _callTimer?.cancel();
    _callTimer = null;

    SoundManager().stopAll();
    SoundManager().playCallEnd();

    try {
      final callId = widget.callId;

      if (callId != null && callId.trim().isNotEmpty) {
        if (_callDuration > 0) {
          await _callService.endCall(
            callId,
            durationSeconds: _callDuration,
          );
        } else if (widget.isOutgoing) {
          await _callService.cancelCall(callId);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Call lifecycle update failed: $e');
    } finally {
      await _liveKit.endCall();

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ فيديو الطرف الآخر
          Container(
            color: Colors.black87,
            child: _isRemoteVideoReady && _remoteVideoTrack != null
                ? VideoTrackRenderer(_remoteVideoTrack!)
                : _buildConnectingScreen(isDark),
          ),
          // ✅ فيديو المستخدم (Picture-in-Picture)
          if (widget.isVideo && _hasCameraPermission && _localVideoTrack != null && _errorMessage.isEmpty)
            Positioned(
              top: 60,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  // ✅ تبديل حجم الفيديو المصغر
                },
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
            ),
          // ✅ واجهة التحكم
          if (_errorMessage.isEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // ✅ مدة المكالمة
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
                  // ✅ أزرار التحكم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ✅ كتم الصوت
                      _callButton(
                        icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMuted ? AppColors.error : Colors.white,
                        onTap: _toggleMute,
                        label: _isMuted ? 'كتم' : 'صوت',
                      ),
                      // ✅ الكاميرا
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: _isCameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                          color: _isCameraOn ? Colors.white : AppColors.error,
                          onTap: _toggleCamera,
                          label: _isCameraOn ? 'كاميرا' : 'إيقاف',
                        ),
                      // ✅ تعليق المكالمة
                      _callButton(
                        icon: _isOnHold ? Icons.play_arrow_rounded : Icons.pause_rounded,
                        color: _isOnHold ? Colors.orange : Colors.white,
                        onTap: _toggleHold,
                        label: _isOnHold ? 'استئناف' : 'انتظار',
                      ),
                      // ✅ إنهاء المكالمة
                      _callButton(
                        icon: Icons.call_end_rounded,
                        color: AppColors.error,
                        size: 60,
                        onTap: _endCall,
                        label: 'إنهاء',
                      ),
                      // ✅ مكبر الصوت
                      _callButton(
                        icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: _isSpeakerOn ? AppColors.info : Colors.white,
                        onTap: _toggleSpeaker,
                        label: _isSpeakerOn ? 'مكبر' : 'سماعة',
                      ),
                      // ✅ تبديل الكاميرا
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: Icons.switch_camera_rounded,
                          color: Colors.white,
                          onTap: () {},
                          label: 'تبديل',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          // ✅ اسم الطبيب وحالة الاتصال
          if (_errorMessage.isEmpty)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // ✅ صورة الطبيب
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    backgroundImage: NetworkImage(ImageKit.doctor1),
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
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
                    _isConnecting ? 'جاري الاتصال...' : _isOnHold ? '⏸️ في الانتظار' : 'متصل',
                    style: TextStyle(
                      color: _isOnHold ? Colors.orange : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectingScreen(bool isDark) {
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
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _checkPermissions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('إعادة المحاولة'),
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
    String? label,
  }) {
    return Column(
      children: [
        GestureDetector(
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
              size: size * 0.45,
            ),
          ),
        ),
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
