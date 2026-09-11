import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:sehatak/core/services/secure_storage_service.dart';

class EncryptionService {
  static final _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();
  final _storage = SecureStorageService();

  Future<String> encryptMessage(String message, String chatId) async {
    try {
      final key = await _getOrCreateKey(chatId);
      final iv = generateIV();
      final encrypted = _crypt(utf8.encode(message), key, iv, true);
      return '${base64.encode(iv)}:${base64.encode(encrypted)}';
    } catch (_) {
      return message;
    }
  }

  Future<String> decryptMessage(String value, String chatId) async {
    try {
      final parts = value.split(':');
      if (parts.length != 2) return value;
      final key = await _getOrCreateKey(chatId);
      return utf8.decode(_crypt(base64.decode(parts[1]), key, base64.decode(parts[0]), false));
    } catch (_) {
      return value;
    }
  }

  Future<Uint8List> encryptFile(Uint8List data, String chatId) async {
    try {
      final key = await _getOrCreateKey(chatId);
      final iv = generateIV();
      return Uint8List.fromList([...iv, ..._crypt(data, key, iv, true)]);
    } catch (_) {
      return data;
    }
  }

  Future<Uint8List> decryptFile(Uint8List data, String chatId) async {
    try {
      if (data.length < 16) return data;
      final key = await _getOrCreateKey(chatId);
      return _crypt(data.sublist(16), key, data.sublist(0, 16), false);
    } catch (_) {
      return data;
    }
  }

  Future<Uint8List> _getOrCreateKey(String chatId) async {
    final stored = await _storage.read('encryption_key_$chatId');
    if (stored != null) return base64.decode(stored);
    final key = generateKey();
    await _storage.write('encryption_key_$chatId', base64.encode(key));
    return key;
  }

  Uint8List generateKey() {
    final random = FortunaRandom();
    random.seed(KeyParameter(Uint8List.fromList(List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch + i))));
    return random.nextBytes(32);
  }

  Uint8List generateIV() {
    final random = FortunaRandom();
    random.seed(KeyParameter(Uint8List.fromList(List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch + i * 17))));
    return random.nextBytes(16);
  }

  Uint8List _crypt(List<int> input, Uint8List key, Uint8List iv, bool encrypt) {
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));
    final params = ParametersWithIV<KeyParameter>(KeyParameter(key), iv);
    cipher.init(
      encrypt,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(params, null),
    );
    return cipher.process(Uint8List.fromList(input));
  }
}
