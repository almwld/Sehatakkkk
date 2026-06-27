import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum CallType { audio, video }

class JitsiService {
  static final JitsiService _instance = JitsiService._internal();
  factory JitsiService() => _instance;
  JitsiService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final JitsiMeet _jitsiMeet = JitsiMeet();

  bool _isInCall = false;

  Future<void> startCall({
    required String roomName,
    required String participantName,
    String? participantEmail,
    bool isVideo = true,
  }) async {
    try {
      final options = JitsiMeetingOptions()
        ..room = roomName
        ..subject = 'استشارة طبية'
        ..userDisplayName = participantName
        ..userEmail = participantEmail ?? ''
        ..audioOnly = !isVideo
        ..audioMuted = false
        ..videoMuted = false;

      await _jitsiMeet.joinMeeting(options);
      _isInCall = true;

      // ✅ حفظ سجل المكالمة
      await _saveCallRecord(roomName, participantName, isVideo);
    } catch (e) {
      print('❌ فشل بدء المكالمة: $e');
      rethrow;
    }
  }

  Future<void> endCall() async {
    try {
      await _jitsiMeet.leaveMeeting();
      _isInCall = false;
    } catch (e) {
      print('❌ فشل إنهاء المكالمة: $e');
    }
  }

  Future<void> _saveCallRecord(String roomName, String participantName, bool isVideo) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('calls').add({
      'roomName': roomName,
      'callerId': user.uid,
      'callerName': user.displayName ?? 'مستخدم',
      'participantName': participantName,
      'type': isVideo ? 'video' : 'audio',
      'status': 'completed',
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
    });
  }

  bool get isInCall => _isInCall;
}
