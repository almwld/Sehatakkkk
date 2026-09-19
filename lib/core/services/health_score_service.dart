import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthScoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Calculates the account health indicator only from the unified
  /// health_metrics/{uid} document. Missing measurements contribute nothing.
  static Future<double> calculateHealthScore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return 0;
      final snap = await _firestore.collection('health_metrics').doc(uid).get();
      final data = snap.data();
      if (data == null) return 0;

      double points = 0;
      int available = 0;

      final weight = (data['weight'] as num?)?.toDouble();
      if (weight != null && weight > 0) {
        available++;
        // Weight is a measurement, not a diagnosis; without height/age,
        // do not invent an "ideal" range. Award completeness only.
        points += 20;
      }

      final systolic = (data['systolic'] as num?)?.toInt();
      final diastolic = (data['diastolic'] as num?)?.toInt();
      if (systolic != null && diastolic != null) {
        available++;
        if (systolic >= 90 && systolic <= 120 && diastolic >= 60 && diastolic <= 80) points += 20;
        else if (systolic <= 140 && diastolic <= 90) points += 10;
      }

      final sugar = (data['blood_sugar'] as num?)?.toDouble();
      if (sugar != null && sugar > 0) {
        available++;
        if (sugar >= 70 && sugar <= 100) points += 20;
        else if (sugar <= 140) points += 10;
      }

      final sleep = ((data['sleep_hours'] ?? data['sleep']) as num?)?.toDouble();
      if (sleep != null && sleep > 0) {
        available++;
        if (sleep >= 7 && sleep <= 9) points += 20;
        else if (sleep >= 5 && sleep < 7) points += 10;
      }

      final steps = (data['steps'] as num?)?.toInt();
      if (steps != null && steps > 0) {
        available++;
        if (steps >= 10000) points += 20;
        else if (steps >= 5000) points += 10;
      }

      return available == 0 ? 0 : (points / (available * 20)) * 100;
    } catch (_) {
      return 0;
    }
  }
}
