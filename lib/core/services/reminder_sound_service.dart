import 'package:audioplayers/audioplayers.dart';

class ReminderSoundService {
  static final ReminderSoundService _instance = ReminderSoundService._internal();
  factory ReminderSoundService() => _instance;
  ReminderSoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  // ✅ تشغيل نغمة التذكير
  Future<void> playReminderSound() async {
    try {
      await _player.play(
        AssetSource('audio/medication_reminder.mp3'),
        volume: 0.8,
      );
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // ✅ إيقاف الصوت
  Future<void> stopSound() async {
    try {
      await _player.stop();
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  // ✅ تشغيل نغمة إشعار عامة
  Future<void> playNotificationSound() async {
    try {
      await _player.play(
        AssetSource('audio/notification.mp3'),
        volume: 0.6,
      );
    } catch (e) {
      print('⚠️ Sound error: $e');
    }
  }

  void dispose() {
    _player.dispose();
  }
}
