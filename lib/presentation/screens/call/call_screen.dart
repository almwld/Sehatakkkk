import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:sehatak/core/services/livekit_service.dart';
import 'package:sehatak/core/constants/app_colors.dart';

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
  bool _hasCameraPermission = false;
  bool _hasMicrophonePermission = false;
  
  VideoTrack? _remoteVideoTrack;
  VideoTrack? _localVideoTrack;
  bool _isRemoteVideoReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    _liveKit.endCall();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();
    
    setState(() {
      _hasCameraPermission = cameraStatus.isGranted;
      _hasMicrophonePermission = microphoneStatus.isGranted;
    });

    if (!_hasCameraPermission && widget.isVideo) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'يرجى منح إذن الكاميرا';
      });
      return;
    }

    if (!_hasMicrophonePermission) {
      setState(() {
        _isConnecting = false;
        _errorMessage = 'يرجى منح إذن الميكروفون';
      });
      return;
    }

    _startCall();
  }

  void _startCall() async {
    try {
      await _liveKit.startCall(
        roomName: widget.chatId,
        callerName: widget.doctorName,
        isVideo: widget.isVideo && _hasCameraPermission,
      );

      final room = _liveKit.room;
      if (room != null) {
        // ✅ معالجة المشارك المحلي
        if (room.localParticipant != null) {
          _handleParticipant(room.localParticipant!);
        }
        
        // ✅ استخدام participants بدلاً من remoteParticipants
        for (final participant in room.participants.values) {
          if (!participant.isLocal) {
            _handleParticipant(participant);
          }
        }
        
        // ✅ الاستماع للمشاركين الجدد
        room.onParticipantConnected = (participant) {
          _handleParticipant(participant);
        };
      }

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

  void _handleParticipant(Participant participant) {
    // ✅ البحث عن VideoTrack
    for (final publication in participant.videoTrackPublications.values) {
      final track = publication.track;
      if (track is VideoTrack) {
        setState(() {
          if (participant.isLocal) {
            _localVideoTrack = track;
          } else {
            _remoteVideoTrack = track;
            _isRemoteVideoReady = true;
          }
        });
        print('✅ Video track found for: ${participant.identity}');
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

  void _toggleCamera() async {
    final newState = await _liveKit.toggleCamera();
    setState(() {
      _isCameraOn = newState;
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _liveKit.room?.localParticipant?.setMicrophoneEnabled(!_isMuted);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            color: Colors.black87,
            child: _isRemoteVideoReady && _remoteVideoTrack != null
                ? VideoTrackRenderer(_remoteVideoTrack!)
                : Center(
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
                      ],
                    ),
                  ),
          ),
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
                        onTap: _toggleMute,
                      ),
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                          color: _isCameraOn ? Colors.white : AppColors.error,
                          onTap: _toggleCamera,
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
                      if (widget.isVideo && _hasCameraPermission)
                        _callButton(
                          icon: Icons.switch_camera,
                          color: Colors.white,
                          onTap: () {},
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
