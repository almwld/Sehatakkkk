import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  // 🎵 تشغيل نغمة رنين المكالمة
  Future<void> playCallRingtone() async {
    try {
      await _player.play(AssetSource('audio/call_ringtone.mp3'));
      await _player.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
      print('🔔 Ringtone playing');
    } catch (e) {
      print('⚠️ Ringtone error: $e');
      // ✅ استخدام نغمة بديلة
      try {
        await _player.play(AssetSource('audio/notification.mp3'));
        await _player.setReleaseMode(ReleaseMode.loop);
        _isPlaying = true;
      } catch (_) {}
    }
  }

  // 🎵 تشغيل صوت إرسال رسالة
  Future<void> playMessageSent() async {
    try {
      await _player.play(AssetSource('audio/message_sent.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Message sent sound error: $e');
    }
  }

  // 🎵 تشغيل صوت استلام رسالة
  Future<void> playMessageReceived() async {
    try {
      await _player.play(AssetSource('audio/message_received.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Message received sound error: $e');
    }
  }

  // 🎵 تشغيل نغمة إشعار
  Future<void> playNotification() async {
    try {
      await _player.play(AssetSource('audio/notification.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Notification sound error: $e');
    }
  }

  // 🎵 تشغيل تنبيه الدواء
  Future<void> playMedicationReminder() async {
    try {
      await _player.play(AssetSource('audio/medication_reminder.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Medication reminder sound error: $e');
    }
  }

  // 🎵 تشغيل صوت بدء المكالمة
  Future<void> playCallStart() async {
    try {
      await _player.play(AssetSource('audio/call_start.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Call start sound error: $e');
    }
  }

  // 🎵 تشغيل صوت إنهاء المكالمة
  Future<void> playCallEnd() async {
    try {
      await _player.play(AssetSource('audio/call_end.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Call end sound error: $e');
    }
  }

  // 🎵 تشغيل نغمة انتظار
  Future<void> playRingback() async {
    try {
      await _player.play(AssetSource('audio/ringback.mp3'));
      await _player.setReleaseMode(ReleaseMode.loop);
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Ringback sound error: $e');
    }
  }

  // 🎵 تشغيل صوت الخطأ
  Future<void> playError() async {
    try {
      await _player.play(AssetSource('audio/error.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Error sound error: $e');
    }
  }

  // 🎵 تشغيل صوت النجاح
  Future<void> playSuccess() async {
    try {
      await _player.play(AssetSource('audio/success.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('⚠️ Success sound error: $e');
    }
  }

  // 🎵 إيقاف جميع النغمات
  Future<void> stopAll() async {
    try {
      await _player.stop();
      _isPlaying = false;
      print('🔇 All sounds stopped');
    } catch (e) {
      print('⚠️ Stop all sounds error: $e');
    }
  }

  // 🎵 إيقاف النغمة الحالية
  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print('⚠️ Stop sound error: $e');
    }
  }

  // 🎵 ضبط مستوى الصوت
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('⚠️ Set volume error: $e');
    }
  }

  // 🎵 التحقق من حالة التشغيل
  bool get isPlaying => _isPlaying;

  // 🎵 التخلص من الموارد
  void dispose() {
    _player.stop();
    _player.dispose();
    _isPlaying = false;
  }
}
