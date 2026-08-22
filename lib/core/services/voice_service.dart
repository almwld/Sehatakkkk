import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _recordingPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  Future<bool> checkPermissions() async {
    return await _recorder.hasPermission();
  }

  Future<void> startRecording() async {
    try {
      if (!await checkPermissions()) {
        throw Exception('لا توجد أذونات للتسجيل');
      }

      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${tempDir.path}/voice_$timestamp.m4a';

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: _recordingPath!,
      );

      _isRecording = true;
      _recordingDuration = Duration.zero;
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _recordingDuration += const Duration(seconds: 1);
      });

      print('✅ Recording started: $_recordingPath');
    } catch (e) {
      print('❌ Error starting recording: $e');
      rethrow;
    }
  }

  Future<String?> stopRecording({
    required String chatId,
    VoidCallback? onProgress,
  }) async {
    try {
      _recordingTimer?.cancel();
      _isRecording = false;

      if (_recordingPath == null) return null;

      final path = _recordingPath!;
      final file = File(path);
      
      if (!await file.exists()) {
        return null;
      }

      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage
          .ref()
          .child('chats/$chatId/audio/${DateTime.now().millisecondsSinceEpoch}.m4a');

      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        if (onProgress != null) {
          onProgress();
        }
        print('📤 Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      await _saveVoiceMessage(
        chatId: chatId,
        url: downloadUrl,
        duration: _recordingDuration,
      );

      await file.delete();

      _recordingPath = null;
      _recordingDuration = Duration.zero;

      return downloadUrl;
    } catch (e) {
      print('❌ Error stopping recording: $e');
      return null;
    }
  }

  Future<void> cancelRecording() async {
    _recordingTimer?.cancel();
    _isRecording = false;
    
    if (_recordingPath != null) {
      final file = File(_recordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _recordingPath = null;
    }
    _recordingDuration = Duration.zero;
    await _recorder.stop();
    print('✅ Recording cancelled');
  }

  Future<void> _saveVoiceMessage({
    required String chatId,
    required String url,
    required Duration duration,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final messageData = {
      'text': '🎤 رسالة صوتية',
      'senderId': user.uid,
      'senderName': user.displayName ?? 'مستخدم',
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'audio',
      'audioUrl': url,
      'duration': duration.inSeconds,
      'isRead': false,
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': '🎤 رسالة صوتية',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> playAudio(String url, VoidCallback onComplete) async {
    try {
      _isPlaying = true;
      
      final source = UrlSource(url);
      await _player.play(source);
      
      _player.onPlayerComplete.listen((event) {
        _isPlaying = false;
        onComplete();
      });
    } catch (e) {
      print('❌ Error playing audio: $e');
      _isPlaying = false;
    }
  }

  Future<void> stopAudio() async {
    await _player.stop();
    _isPlaying = false;
  }

  Duration get recordingDuration => _recordingDuration;
  bool get isRecording => _isRecording;
  bool get isPlaying => _isPlaying;

  void dispose() {
    _recordingTimer?.cancel();
    _player.dispose();
    _recorder.dispose();
  }
}
