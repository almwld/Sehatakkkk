import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========== 📁 Collections ==========
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get doctors => _firestore.collection('doctors');
  CollectionReference get appointments => _firestore.collection('appointments');
  CollectionReference get pharmacies => _firestore.collection('pharmacies');
  CollectionReference get chats => _firestore.collection('chats');

  // ========== 👨‍⚕️ الأطباء - بيانات حقيقية ==========
  Stream<List<Map<String, dynamic>>> getDoctors() {
    return doctors.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getDoctor(String doctorId) async {
    final doc = await doctors.doc(doctorId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        ...data,
      };
    }
    return null;
  }

  // ========== 💬 الدردشة - بيانات حقيقية ==========
  Future<String> createChat({
    required String doctorId,
    required String doctorName,
    required String patientId,
    required String patientName,
  }) async {
    final chatId = chats.doc().id;
    await chats.doc(chatId).set({
      'id': chatId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return chatId;
  }

  Future<void> sendMessage({
    required String chatId,
    required String text,
    String? imageUrl,
    String? audioUrl,
  }) async {
    final message = {
      'senderId': _auth.currentUser?.uid ?? 'unknown',
      'senderName': _auth.currentUser?.displayName ?? 'مستخدم',
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
    };

    await chats.doc(chatId).collection('messages').add(message);

    await chats.doc(chatId).update({
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserChats(String userId) {
    return chats
        .where('patientId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getDoctorChats(String doctorId) {
    return chats
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
}
