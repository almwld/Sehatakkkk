import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedAccountsService {
  static const String _key = 'sehatak_saved_accounts';

  static Future<List<Map<String, dynamic>>> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveCurrentAccount(User user) async {
    final email = user.email?.trim();
    if (email == null || email.isEmpty) return;

    final provider = user.providerData.isNotEmpty
        ? user.providerData.first.providerId
        : 'password';

    final account = <String, dynamic>{
      'uid': user.uid,
      'email': email,
      'name': user.displayName?.trim().isNotEmpty == true
          ? user.displayName!.trim()
          : email.split('@').first,
      'photoUrl': user.photoURL ?? '',
      'provider': provider,
      'savedAt': DateTime.now().millisecondsSinceEpoch,
    };

    final accounts = await loadAccounts();
    accounts.removeWhere((item) =>
        item['uid'] == user.uid ||
        (item['email']?.toString().toLowerCase() == email.toLowerCase()));
    accounts.insert(0, account);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(accounts.take(5).toList()));
  }

  static Future<void> removeAccount(String uid) async {
    final accounts = await loadAccounts();
    accounts.removeWhere((item) => item['uid']?.toString() == uid);
    final prefs = await SharedPreferences.getInstance();
    if (accounts.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, jsonEncode(accounts));
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
