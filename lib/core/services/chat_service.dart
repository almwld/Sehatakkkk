import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ رفع الوسائط (صورة أو صوت)
  Future<String> uploadMedia(File file, String type) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = file.uri.pathSegments.last;
      final path = '${dir.path}/$fileName';
      await file.copy(path);
      print('✅ Media saved locally: $path');
      return path;
    } catch (e) {
      print('❌ Failed to save media: $e');
      rethrow;
    }
  }

  // ... (بقية الدوال)
}
