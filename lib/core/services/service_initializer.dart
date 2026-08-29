import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    // ✅ تجنب التهيئة المزدوجة
    if (_initialized) return;
    
    try {
      print('🔄 Initializing services...');
      
      // ✅ تهيئة SharedPreferences
      await SharedPreferences.getInstance();
      print('✅ SharedPreferences initialized');
      
      // ✅ تهيئة Firebase Messaging فقط إذا كان المستخدم مسجلاً
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseMessaging.instance.getToken();
          print('✅ Firebase Messaging initialized for user: ${user.uid}');
        } else {
          print('ℹ️ No user logged in, skipping Firebase Messaging');
        }
      } catch (e) {
        print('⚠️ Error initializing Firebase Messaging: $e');
      }
      
      _initialized = true;
      print('✅ Services initialized successfully');
    } catch (e) {
      print('❌ Error initializing services: $e');
      // ✅ لا نعيد طرح الخطأ لضمان عدم تعليق التطبيق
    }
  }
}
