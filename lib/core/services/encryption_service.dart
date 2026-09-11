import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:sehatak/core/services/secure_storage_service.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();
  final SecureStorageService _storage = SecureStorageService();

  Future<String> encryptMessage(String message, String chatId) async {
    try { final key = await _getOrCreateKey(chatId); final iv = generateIV(); final encrypted = _crypt(utf8.encode(message), key, iv, true); return '${base64.encode(iv)}:${base64.encode(encrypted)}'; } catch (_) { return message; }
  }
  Future<String> decryptMessage(String encryptedMessage, String chatId) async {
    try { final parts = encryptedMessage.split(':'); if (parts.length != 2) return encryptedMessage; final key = await _getOrCreateKey(chatId); final iv = base64.decode(parts[0]); final encrypted = base64.decode(parts[1]); return utf8.decode(_crypt(encrypted, key, iv, false)); } catch (_) { return encryptedMessage; }
  }
  Future<Uint8List> encryptFile(Uint8List data, String chatId) async { try { final key = await _getOrCreateKey(chatId); final iv = generateIV(); final encrypted = _crypt(data, key, iv, true); return Uint8List.fromList([...iv, ...encrypted]); } catch (_) { return data; } }
  Future<Uint8List> decryptFile(Uint8List data, String chatId) async { try { if (data.length < 16) return data; final key = await _getOrCreateKey(chatId); return _crypt(data.sublist(16), key, data.sublist(0, 16), false); } catch (_) { return data; } }

  Future<Uint8List> _getOrCreateKey(String chatId) async { final stored = await _storage.read('encryption_key_$chatId'); if (stored != null) return base64.decode(stored); final key = generateKey(); await _storage.write('encryption_key_$chatId', base64.encode(key)); return key; }
  Uint8List generateKey() { final r = FortunaRandom(); r.seed(KeyParameter(Uint8List.fromList(List.generate(32, (i) => DateTime.now().microsecondsSinceEpoch >> (i % 8))))); final out = Uint8List(32); r.nextBytes(out); return out; }
  Uint8List generateIV() { final r = FortunaRandom(); r.seed(KeyParameter(Uint8List.fromList(List.generate(32, (i) => DateTime.now().microsecondsSinceEpoch >> (i % 8))))); final out = Uint8List(16); r.nextBytes(out); return out; }

  Uint8List _crypt(List<int> input, Uint8List key, Uint8List iv, bool encrypt) {
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()));
    cipher.init(encrypt, PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(ParametersWithIV(KeyParameter(key), iv), null));
    return Uint8List.fromList(cipher.process(Uint8List.fromList(input)));
  }
}
