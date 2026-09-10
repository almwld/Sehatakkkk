// ============================================================
// 📞 شاشة المكالمات المتكاملة
// ============================================================
// LiveKit + Connectivity + Permissions + SoundManager
// ============================================================

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/services/sound_manager.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class CallScreen extends StatefulWidget {
  final String chatId;
  final String? callId;
  final String doctorName;
  final String doctorId;
  final bool isVideo;
  final String? doctorImage;
  final bool isOutgoing;

  const CallScreen({
    super.key,
    required this.chatId,
    this.callId,
    required this.doctorName,
    required this.doctorId,
    this.isVideo = true,
    this.doctorImage,
    this.isOutgoing = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  // ═══ الخدمات ═══
  final LiveKitService _liveKit = LiveKitService();
  final Connectivity _connectivity = Connectivity();

  // ═══ حالة المكالمة ═══
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  int _callDuration = 0;
  bool _isConnecting = true;
  String _errorMessage = '';
  bool _hasCameraPermission = false;
  bool _isConnected = false;
  bool _isFrontCamera = true;

  // ═══ الفيديو ═══
  VideoTrack? _remoteVideoTrack;
  VideoTrack? _localVideoTrack;
  bool _isRemoteVideoReady = false;

  // ═══ Timer ═══
  bool _timerActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  @override
  void dispose() {
    SoundManager().stopAll();
    _liveKit.endCall();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ============================================================
  // 🚀 التهيئة
  // ============================================================

  Future<void> _initialize() async {
    await _checkConnectivity();
    if (_isConnected) {
      await _checkPermissions();
    }
  }

  // ============================================================
  // 🌐 التحقق من الإنترنت
  // ============================================================

  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result == ConnectivityResult.none) {
        setState(() {
          _isConnecting = false;
          _errorMessage =
              '⚠️ لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة والمحاولة مرة أخرى.';
        });
        _showNoInternetDialog();
      } else {
        setState(() => _isConnected = true);
      }
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'فشل التحقق من الاتصال: $e';
      });
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('⚠️ لا يوجد إنترنت'),
        content:
            const Text('يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.'),
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
              _initialize();
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔐 التحقق من الأذونات
  // ============================================================

  Future<void> _checkPermissions() async {
    try {
      if (widget.isVideo) {
        final cameraStatus = await Permission.camera.request();
        setState(() => _hasCameraPermission = cameraStatus.isGranted);
        if (!_hasCameraPermission) {
          setState(() {
            _isConnecting = false;
            _errorMessage = 'يرجى منح إذن الكاميرا';
          });
          return;
        }
      }

      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted) {
        setState(() {
          _isConnecting = false;
          _errorMessage = 'يرجى منح إذن الميكروفون';
        });
        return;
      }

      await _startCall();
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'فشل التحقق من الأذونات: $e';
      });
    }
  }

  // ============================================================
  // 📞 بدء المكالمة
  // ============================================================

  Future<void> _startCall() async {
    try {
      if (!_isConnected) {
        setState(() {
          _isConnecting = false;
          _errorMessage = '⚠️ لا يوجد اتصال بالإنترنت';
        });
        return;
      }

      // ✅ تشغيل رنين الاتصال
      SoundManager().playCallRingtone();

      // ✅ الاتصال بـ LiveKit
      await _liveKit.startCall(
        roomName: widget.chatId,
        callerName: widget.doctorName,
        isVideo: widget.isVideo && _hasCameraPermission,
      );

      // ✅ إيقاف الرنين
      SoundManager().stopAll();

      // ✅ التعامل مع المشاركين
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
          debugPrint('✅ Participant connected: ${event.participant.identity}');
        });

        room.events.on<TrackSubscribedEvent>((event) {
          _handleParticipant(event.participant);
        });

        room.events.on<TrackPublishedEvent>((event) {
          _handleParticipant(event.participant);
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

  // ============================================================
  // 📹 التعامل مع المشاركين
  // ============================================================

  void _handleParticipant(Participant participant) {
    try {
      for (final track in participant.videoTracks) {
        if (track.track != null && track.track is VideoTrack) {
          final videoTrack = track.track as VideoTrack;
          if (!mounted) return;
          setState(() {
            if (participant is LocalParticipant) {
              _localVideoTrack = videoTrack;
              debugPrint('✅ Local video track found');
            } else {
              _remoteVideoTrack = videoTrack;
              _isRemoteVideoReady = true;
              debugPrint('✅ Remote video track found');
            }
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error handling video tracks: $e');
    }
  }

  // ============================================================
  // ⏱️ مؤقت المكالمة
  // ============================================================

  void _startTimer() {
    if (_timerActive) return;
    _timerActive = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) {
        _timerActive = false;
        return;
      }
      setState(() => _callDuration++);
      _startTimer();
    });
  }

  // ============================================================
  // 🎛️ التحكم في المكالمة
  // ============================================================

  Future<void> _toggleCamera() async {
    try {
      final newState = await _liveKit.toggleCamera();
      if (mounted) setState(() => _isCameraOn = newState);
    } catch (e) {
      ToastService.showError('❌ فشل تبديل الكاميرا: $e');
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _liveKit.switchCamera();
      if (mounted) setState(() => _isFrontCamera = !_isFrontCamera);
      ToastService.showInfo('📷 تم تبديل الكاميرا');
    } catch (e) {
      ToastService.showError('❌ فشل تبديل الكاميرا: $e');
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _liveKit.room?.localParticipant?.setMicrophoneEnabled(!_isMuted);
    });
  }

  void _toggleSpeaker() {
    setState(() => _isSpeakerOn = !_isSpeakerOn);
    try {
      _liveKit.setSpeakerphone(_isSpeakerOn);
    } catch (e) {
      debugPrint('❌ Error setting speaker: $e');
    }
  }

  void _endCall() {
    SoundManager().stopAll();
    SoundManager().playCallEnd();
    _liveKit.endCall();
    Navigator.pop(context);
  }

  // ============================================================
  // 🏗️ واجهة المستخدم
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ═══ فيديو الطرف الآخر (ملء الشاشة) ═══
          Container(
            color: Colors.black87,
            child: _isRemoteVideoReady && _remoteVideoTrack != null
                ? VideoTrackRenderer(_remoteVideoTrack!)
                : _buildConnectingScreen(),
          ),

          // ═══ فيديو المستخدم (Picture-in-Picture) ═══
          if (widget.isVideo &&
              _hasCameraPermission &&
              _localVideoTrack != null &&
              _errorMessage.isEmpty)
            Positioned(
              top: 60,
              right: 20,
              child: GestureDetector(
                onTap: _switchCamera,
                child: Container(
                  width: 120,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: VideoTrackRenderer(_localVideoTrack!),
                  ),
                ),
              ),
            ),

          // ═══ مكان فيديو المستخدم (إذا لم يعمل) ═══
          if (widget.isVideo &&
              _hasCameraPermission &&
              _localVideoTrack == null &&
              _errorMessage.isEmpty)
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
                  child: Icon(
                    Icons.videocam_off_rounded,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              ),
            ),

          // ═══ معلومات الطبيب ═══
          if (_errorMessage.isEmpty)
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // ✅ صورة الطبيب (للمكالمات الصوتية)
                  if (!widget.isVideo || !_isRemoteVideoReady)
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: widget.doctorImage != null
                          ? NetworkImage(widget.doctorImage!)
                          : null,
                      child: widget.doctorImage == null
                          ? Text(
                              widget.doctorName.isNotEmpty
                                  ? widget.doctorName[0].toUpperCase()
                                  : 'ط',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.doctorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // ✅ حالة المكالمة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _callDuration == 0
                          ? 'جاري الاتصال...'
                          : _formatDuration(_callDuration),
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.orange,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // ═══ أزرار التحكم ═══
          if (_errorMessage.isEmpty)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // ✅ مؤقت المكالمة
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatDuration(_callDuration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ صف الأزرار
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // ═══ زر كتم الصوت (تركواز) ═══
                      _callButton(
                        icon: _isMuted
                            ? Icons.mic_off_rounded
                            : Icons.mic_rounded,
                        color: _isMuted
                            ? Colors.red
                            : const Color(0xFF00BCD4), // 🔵 تركواز
                        label: _isMuted ? 'إلغاء الكتم' : 'كتم',
                        onTap: _toggleMute,
                      ),

                      // ═══ زر الكاميرا (تركواز) - للفيديو فقط ═══
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: _isCameraOn
                              ? Icons.videocam_rounded
                              : Icons.videocam_off_rounded,
                          color: _isCameraOn
                              ? const Color(0xFF00BCD4) // 🔵 تركواز
                              : Colors.red,
                          label: _isCameraOn ? 'كاميرا' : 'إيقاف',
                          onTap: _toggleCamera,
                        ),

                      // ═══ زر إنهاء المكالمة (أحمر) ═══
                      _callButton(
                        icon: Icons.call_end_rounded,
                        color: Colors.red, // 🔴 أحمر
                        size: 65,
                        label: 'إنهاء',
                        onTap: _endCall,
                      ),

                      // ═══ زر مكبر الصوت (رمادي) ═══
                      _callButton(
                        icon: _isSpeakerOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        color: _isSpeakerOn
                            ? const Color(0xFF00BCD4) // 🔵 تركواز عند التفعيل
                            : Colors.grey, // ⚪ رمادي
                        label: _isSpeakerOn ? 'مكبر' : 'سماعة',
                        onTap: _toggleSpeaker,
                      ),

                      // ═══ زر تبديل الكاميرا (رمادي) - للفيديو فقط ═══
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: Icons.switch_camera_rounded,
                          color: Colors.grey, // ⚪ رمادي
                          label: 'تبديل',
                          onTap: _switchCamera,
                        ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎨 عناصر الواجهة
  // ============================================================

  Widget _buildConnectingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_errorMessage.isNotEmpty)
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 60,
            )
          else
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage.isNotEmpty ? _errorMessage : 'جاري الاتصال...',
              style: TextStyle(
                color: _errorMessage.isNotEmpty ? Colors.red : Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_isConnecting && _errorMessage.isEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'يرجى الانتظار',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _callButton({
    required IconData icon,
    required Color color,
    required String label,
    double size = 55,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: size * 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
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
