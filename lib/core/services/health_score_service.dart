import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HealthScoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<double> calculateHealthScore() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return 0.0;

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_metrics')
          .doc('current')
          .get();

      if (!doc.exists) return 0.0;

      final data = doc.data()!;
      double score = 0.0;
      int metrics = 0;

      if (data['weight'] != null) {
        final weight = (data['weight'] as num).toDouble();
        if (weight >= 50 && weight <= 80) score += 20;
        else if (weight > 80 && weight <= 100) score += 10;
        metrics++;
      }

      if (data['systolic'] != null && data['diastolic'] != null) {
        final systolic = (data['systolic'] as num).toInt();
        final diastolic = (data['diastolic'] as num).toInt();
        if (systolic >= 90 && systolic <= 120 && diastolic >= 60 && diastolic <= 80) {
          score += 20;
        } else if (systolic >= 121 && systolic <= 140 && diastolic >= 81 && diastolic <= 90) {
          score += 10;
        }
        metrics++;
      }

      if (data['blood_sugar'] != null) {
        final sugar = (data['blood_sugar'] as num).toDouble();
        if (sugar >= 70 && sugar <= 100) score += 20;
        else if (sugar > 100 && sugar <= 140) score += 10;
        metrics++;
      }

      if (data['sleep_hours'] != null) {
        final sleep = (data['sleep_hours'] as num).toDouble();
        if (sleep >= 7 && sleep <= 9) score += 20;
        else if (sleep >= 5 && sleep < 7) score += 10;
        metrics++;
      }

      if (data['steps'] != null) {
        final steps = (data['steps'] as num).toInt();
        if (steps >= 10000) score += 20;
        else if (steps >= 5000) score += 10;
        metrics++;
      }

      return metrics > 0 ? (score / metrics) * 5 : 0.0;
    } catch (e) {
      return 0.0;
    }
  }
}
