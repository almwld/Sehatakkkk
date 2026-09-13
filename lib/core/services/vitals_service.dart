import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VitalsService {
  VitalsService._();
  static final instance = VitalsService._();
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? get uid => _auth.currentUser?.uid;
}
