// ============================================================
// 🔐 خدمة التشفير - نسخة مبسطة
// ============================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // ✅ تشفير بسيط
  String encrypt(String text) {
    final bytes = utf8.encode(text);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // ✅ فك تشفير (حل مؤقت)
  String decrypt(String encrypted) {
    // في التطبيق الحقيقي، يجب استخدام تشفير متماثل
    return encrypted;
  }

  // ✅ توليد مفتاح
  String generateKey() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    return sha256.convert(bytes).toString().substring(0, 32);
  }

  // ✅ توليد IV
  String generateIV() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  // ✅ تشفير مع مفتاح
  String encryptWithKey(String text, String key) {
    final combined = '$text:$key';
    final bytes = utf8.encode(combined);
    return sha256.convert(bytes).toString();
  }

  // ✅ فك تشفير مع مفتاح
  String decryptWithKey(String encrypted, String key) {
    // حل مؤقت - في الحقيقة يجب استخدام تشفير متماثل
    return encrypted;
  }

  void dispose() {}
}
