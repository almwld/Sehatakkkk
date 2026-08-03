import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/subscription/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<SubscriptionModel?> getUserSubscription() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      
      final snap = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid)
          .where('status', whereIn: ['active', 'trial'])
          .orderBy('endDate', descending: true)
          .limit(1)
          .get();
      
      if (snap.docs.isNotEmpty) {
        return SubscriptionModel.fromFirestore(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<SubscriptionModel>> getSubscriptionHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];
      
      final snap = await _firestore
          .collection('subscriptions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();
      
      return snap.docs.map((doc) {
        return SubscriptionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
