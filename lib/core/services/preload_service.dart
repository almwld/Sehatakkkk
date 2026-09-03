import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreloadService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> preloadEssentialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final user = _auth.currentUser;

      if (user != null) {
        // ✅ تحميل بيانات المستخدم
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null) {
            await prefs.setString('user_name', data['name'] ?? '');
            await prefs.setString('user_photo', data['photoUrl'] ?? '');
            await prefs.setString('user_email', data['email'] ?? '');
          }
        }

        // ✅ تحديث حالة الاتصال
        await _firestore.collection('users').doc(user.uid).update({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      print('✅ PreloadService: Essential data loaded');
    } catch (e) {
      print('❌ PreloadService error: $e');
    }
  }
}
