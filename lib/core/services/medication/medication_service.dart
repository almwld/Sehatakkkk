import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/medication/medication_model.dart';

class MedicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ جلب جميع الأدوية
  Future<List<MedicationModel>> getMedications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final snap = await _firestore
          .collection('medications')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snap.docs.map((doc) {
        return MedicationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ جلب أدوية اليوم
  Future<List<MedicationModel>> getTodayMedications() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final today = DateTime.now();
      final dayOfWeek = today.weekday;
      
      final snap = await _firestore
          .collection('medications')
          .where('userId', isEqualTo: user.uid)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snap.docs
          .map((doc) => MedicationModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .where((med) => med.daysOfWeek.contains(dayOfWeek))
          .where((med) => med.isActive)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ تسجيل تناول الدواء
  Future<void> logMedication(String id, bool taken, {String? notes, String? skippedReason}) async {
    try {
      final log = MedicationLog(
        takenAt: DateTime.now(),
        taken: taken,
        notes: notes,
        skippedReason: skippedReason,
      );
      
      await _firestore.collection('medications').doc(id).update({
        'logs': FieldValue.arrayUnion([log.toMap()]),
        'lastTaken': DateTime.now().toIso8601String(),
        'remainingPills': FieldValue.increment(taken ? -1 : 0),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // تجاهل
    }
  }
}
