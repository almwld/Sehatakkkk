import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores Nextcloud/WebDAV credentials and per-chat encryption material in the
/// platform secure store. No credential is persisted in Firestore or source.
class SecureChatCredentialsService {
  SecureChatCredentialsService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _baseUrlKey = 'sehatak.nextcloud.base_url';
  static const _usernameKey = 'sehatak.nextcloud.username';
  static const _appPasswordKey = 'sehatak.nextcloud.app_password';

  Future<void> saveNextcloudCredentials({
    required String baseUrl,
    required String username,
    required String appPassword,
  }) async {
    final normalized = baseUrl.trim().replaceFirst(RegExp(r'/$'), '');
    if (normalized.isEmpty || username.trim().isEmpty || appPassword.isEmpty) {
      throw ArgumentError('بيانات Nextcloud غير مكتملة');
    }
    await _storage.write(key: _baseUrlKey, value: normalized);
    await _storage.write(key: _usernameKey, value: username.trim());
    await _storage.write(key: _appPasswordKey, value: appPassword);
  }

  Future<NextcloudCredentials?> readNextcloudCredentials() async {
    final baseUrl = await _storage.read(key: _baseUrlKey);
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _appPasswordKey);
    if ([baseUrl, username, password].any((v) => v == null || v!.isEmpty)) {
      return null;
    }
    return NextcloudCredentials(
      baseUrl: baseUrl!,
      username: username!,
      appPassword: password!,
    );
  }

  Future<void> clearNextcloudCredentials() async {
    await Future.wait([
      _storage.delete(key: _baseUrlKey),
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _appPasswordKey),
    ]);
  }
}

class NextcloudCredentials {
  const NextcloudCredentials({
    required this.baseUrl,
    required this.username,
    required this.appPassword,
  });

  final String baseUrl;
  final String username;
  final String appPassword;
}
