import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== 📁 Collections ==========
  CollectionReference get users => _firestore.collection('users');
  CollectionReference get doctors => _firestore.collection('doctors');
  CollectionReference get appointments => _firestore.collection('appointments');
  CollectionReference get pharmacies => _firestore.collection('pharmacies');
  CollectionReference get messages => _firestore.collection('messages');
  CollectionReference get orders => _firestore.collection('orders');
  CollectionReference get payments => _firestore.collection('payments');

  // ========== 👤 المستخدم ==========
  Future<void> saveUser(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await users.doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).update(data);
  }

  // ========== 👨‍⚕️ الأطباء ==========
  Stream<List<Map<String, dynamic>>> getDoctors() {
    return doctors.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  Future<Map<String, dynamic>?> getDoctor(String doctorId) async {
    final doc = await doctors.doc(doctorId).get();
    return doc.exists ? {'id': doc.id, ...doc.data()} : null;
  }

  // ========== 📅 المواعيد ==========
  Future<void> bookAppointment(Map<String, dynamic> data) async {
    await appointments.add(data);
  }

  Stream<List<Map<String, dynamic>>> getPatientAppointments(String patientId) {
    return appointments
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // ========== 💬 الدردشة ==========
  Future<void> sendMessage(String chatId, Map<String, dynamic> message) async {
    await messages.doc(chatId).collection('messages').add(message);
    await messages.doc(chatId).update({
      'lastMessage': message['text'],
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    return messages
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // ========== 🏥 الصيدلية ==========
  Stream<List<Map<String, dynamic>>> getPharmacies() {
    return pharmacies.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data()};
      }).toList();
    });
  }

  // ========== 📦 الطلبات ==========
  Future<void> createOrder(Map<String, dynamic> order) async {
    await orders.add(order);
  }

  Stream<QuerySnapshot> getUserOrders(String userId) {
    return orders.where('userId', isEqualTo: userId).snapshots();
  }
}
