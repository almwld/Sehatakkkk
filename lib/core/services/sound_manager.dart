import 'package:audioplayers/audioplayers.dart';

/// Single source of truth for in-app audio effects and call tones.
class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _callPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  bool _callPlaying = false;
  bool _effectPlaying = false;

  Future<void> _playEffect(String asset, {double volume = 1.0}) async {
    try {
      await _effectPlayer.stop();
      await _effectPlayer.setReleaseMode(ReleaseMode.release);
      await _effectPlayer.setVolume(volume.clamp(0.0, 1.0));
      _effectPlaying = true;
      await _effectPlayer.play(AssetSource(asset));
    } catch (e) {
      _effectPlaying = false;
      print('⚠️ Audio effect error ($asset): $e');
    }
  }

  Future<void> playCallRingtone() async {
    try {
      await _callPlayer.stop();
      await _callPlayer.setReleaseMode(ReleaseMode.loop);
      await _callPlayer.setVolume(1.0);
      _callPlaying = true;
      await _callPlayer.play(AssetSource('audio/call_ringtone.mp3'));
      print('🔔 Incoming call ringtone playing');
    } catch (e) {
      _callPlaying = false;
      print('⚠️ Call ringtone error: $e');
    }
  }

  Future<void> playRingback() async {
    try {
      await _callPlayer.stop();
      await _callPlayer.setReleaseMode(ReleaseMode.loop);
      await _callPlayer.setVolume(1.0);
      _callPlaying = true;
      await _callPlayer.play(AssetSource('audio/ringback.mp3'));
      print('📞 Outgoing ringback playing');
    } catch (e) {
      _callPlaying = false;
      print('⚠️ Ringback error: $e');
    }
  }

  Future<void> playMessageSent() => _playEffect('audio/message_sent.mp3');
  Future<void> playMessageReceived() => _playEffect('audio/message_received.mp3');
  Future<void> playNotification() => _playEffect('audio/notification.mp3');
  Future<void> playMedicationReminder() => _playEffect('audio/medication_reminder.mp3', volume: 0.8);
  Future<void> playCallStart() => _playEffect('audio/call_start.mp3');
  Future<void> playCallEnd() => _playEffect('audio/call_end.mp3');
  Future<void> playError() => _playEffect('audio/error.mp3');
  Future<void> playSuccess() => _playEffect('audio/success.mp3');

  Future<void> stopCallAudio() async {
    try {
      await _callPlayer.stop();
    } finally {
      _callPlaying = false;
    }
  }

  Future<void> stopAll() async {
    await Future.wait([stopCallAudio(), _effectPlayer.stop()]);
    _effectPlaying = false;
    print('🔇 All app audio stopped');
  }

  Future<void> stop() => stopAll();

  Future<void> setVolume(double volume) async {
    final value = volume.clamp(0.0, 1.0);
    await Future.wait([
      _callPlayer.setVolume(value),
      _effectPlayer.setVolume(value),
    ]);
  }

  bool get isPlaying => _callPlaying || _effectPlaying;

  void dispose() {
    _callPlayer.stop();
    _effectPlayer.stop();
    _callPlayer.dispose();
    _effectPlayer.dispose();
    _callPlaying = false;
    _effectPlaying = false;
  }
}
