import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import 'package:sehatak/core/services/secure_storage_service.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final SecureStorageService _storage = SecureStorageService();

  // ✅ تشفير رسالة
  Future<String> encryptMessage(String message, String chatId) async {
    try {
      // ✅ الحصول على مفتاح التشفير
      final key = await _getOrCreateKey(chatId);
      final iv = generateIV();

      // ✅ تشفير النص
      final encrypted = _encryptAES(message, key, iv);

      // ✅ إرجاع النص المشفر مع IV
      return base64.encode(iv) + ':' + base64.encode(encrypted);
    } catch (e) {
      print('❌ Encryption error: $e');
      return message;
    }
  }

  // ✅ فك تشفير رسالة
  Future<String> decryptMessage(String encryptedMessage, String chatId) async {
    try {
      // ✅ فصل IV عن النص المشفر
      final parts = encryptedMessage.split(':');
      if (parts.length != 2) return encryptedMessage;

      final iv = base64.decode(parts[0]);
      final encrypted = base64.decode(parts[1]);

      // ✅ الحصول على مفتاح التشفير
      final key = await _getOrCreateKey(chatId);

      // ✅ فك التشفير
      return _decryptAES(encrypted, key, iv);
    } catch (e) {
      print('❌ Decryption error: $e');
      return encryptedMessage;
    }
  }

  // ✅ تشفير الملفات
  Future<Uint8List> encryptFile(Uint8List fileData, String chatId) async {
    try {
      final key = await _getOrCreateKey(chatId);
      final iv = generateIV();

      // ✅ تشفير الملف
      final encrypted = _encryptAESBytes(fileData, key, iv);

      // ✅ إضافة IV إلى بداية الملف المشفر
      final result = Uint8List(iv.length + encrypted.length);
      result.setAll(0, iv);
      result.setAll(iv.length, encrypted);

      return result;
    } catch (e) {
      print('❌ File encryption error: $e');
      return fileData;
    }
  }

  // ✅ فك تشفير الملفات
  Future<Uint8List> decryptFile(Uint8List encryptedData, String chatId) async {
    try {
      // ✅ استخراج IV
      final iv = encryptedData.sublist(0, 16);
      final encrypted = encryptedData.sublist(16);

      // ✅ الحصول على مفتاح التشفير
      final key = await _getOrCreateKey(chatId);

      // ✅ فك التشفير
      return _decryptAESBytes(encrypted, key, iv);
    } catch (e) {
      print('❌ File decryption error: $e');
      return encryptedData;
    }
  }

  // ============================================================
  // 🔑 إدارة المفاتيح
  // ============================================================

  Future<Uint8List> _getOrCreateKey(String chatId) async {
    final key = await _storage.read('encryption_key_$chatId');
    if (key != null) {
      return base64.decode(key);
    }

    // ✅ إنشاء مفتاح جديد
    final newKey = generateKey();
    await _storage.write('encryption_key_$chatId', base64.encode(newKey));
    return newKey;
  }

  Uint8List generateKey() {
    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(Uint8List.fromList(
        List.generate(32, (_) => DateTime.now().millisecondsSinceEpoch % 256),
      )));
    final key = Uint8List(32);
    secureRandom.nextBytes(key);
    return key;
  }

  Uint8List generateIV() {
    final secureRandom = SecureRandom('Fortuna')
      ..seed(KeyParameter(Uint8List.fromList(
        List.generate(16, (_) => DateTime.now().millisecondsSinceEpoch % 256),
      )));
    final iv = Uint8List(16);
    secureRandom.nextBytes(iv);
    return iv;
  }

  // ============================================================
  // 🔐 خوارزميات التشفير
  // ============================================================

  Uint8List _encryptAES(String plaintext, Uint8List key, Uint8List iv) {
    final cipher = AESEngine()
      ..init(true, CipherParametersWithIV(KeyParameter(key), iv));
    final plaintextBytes = utf8.encode(plaintext);
    final padded = _padPKCS7(plaintextBytes, 16);
    final encrypted = Uint8List(padded.length);
    cipher.processBytes(padded, 0, padded.length, encrypted, 0);
    return encrypted;
  }

  String _decryptAES(Uint8List encrypted, Uint8List key, Uint8List iv) {
    final cipher = AESEngine()
      ..init(false, CipherParametersWithIV(KeyParameter(key), iv));
    final decrypted = Uint8List(encrypted.length);
    cipher.processBytes(encrypted, 0, encrypted.length, decrypted, 0);
    final unpadded = _unpadPKCS7(decrypted);
    return utf8.decode(unpadded);
  }

  Uint8List _encryptAESBytes(Uint8List data, Uint8List key, Uint8List iv) {
    final cipher = AESEngine()
      ..init(true, CipherParametersWithIV(KeyParameter(key), iv));
    final padded = _padPKCS7(data, 16);
    final encrypted = Uint8List(padded.length);
    cipher.processBytes(padded, 0, padded.length, encrypted, 0);
    return encrypted;
  }

  Uint8List _decryptAESBytes(Uint8List encrypted, Uint8List key, Uint8List iv) {
    final cipher = AESEngine()
      ..init(false, CipherParametersWithIV(KeyParameter(key), iv));
    final decrypted = Uint8List(encrypted.length);
    cipher.processBytes(encrypted, 0, encrypted.length, decrypted, 0);
    return _unpadPKCS7(decrypted);
  }

  // ============================================================
  // 🛠️ مساعدات PKCS7
  // ============================================================

  Uint8List _padPKCS7(Uint8List data, int blockSize) {
    final padding = blockSize - (data.length % blockSize);
    final padded = Uint8List(data.length + padding);
    padded.setAll(0, data);
    padded.fillRange(data.length, padded.length, padding);
    return padded;
  }

  Uint8List _unpadPKCS7(Uint8List data) {
    final padding = data[data.length - 1];
    return data.sublist(0, data.length - padding);
  }
}
