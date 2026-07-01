import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();

  // 🎵 تشغيل نغمة رنين المكالمة
  Future<void> playCallRingtone() async {
    try {
      await _player.setAsset('audio/call_ringtone.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل صوت إرسال رسالة
  Future<void> playMessageSent() async {
    try {
      await _player.setAsset('audio/message_sent.mp3');
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل صوت استلام رسالة
  Future<void> playMessageReceived() async {
    try {
      await _player.setAsset('audio/message_received.mp3');
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل نغمة إشعار
  Future<void> playNotification() async {
    try {
      await _player.setAsset('audio/notification.mp3');
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل تنبيه الدواء
  Future<void> playMedicationReminder() async {
    try {
      await _player.setAsset('audio/medication_reminder.mp3');
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل صوت بدء المكالمة
  Future<void> playCallStart() async {
    try {
      await _player.setAsset('audio/call_start.mp3');
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل صوت إنهاء المكالمة
  Future<void> playCallEnd() async {
    try {
      await _player.setAsset('audio/call_end.mp3');
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 تشغيل نغمة انتظار
  Future<void> playRingback() async {
    try {
      await _player.setAsset('audio/ringback.mp3');
      await _player.setLoopMode(LoopMode.one);
      await _player.resume();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 إيقاف جميع النغمات
  Future<void> stopAll() async {
    try {
      await _player.stop();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 إيقاف النغمة الحالية
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // 🎵 التخلص من الموارد
  void dispose() {
    _player.dispose();
  }
}
