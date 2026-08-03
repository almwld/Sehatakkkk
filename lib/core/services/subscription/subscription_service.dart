import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/models/subscription/subscription_model.dart';
import 'package:sehatak/core/models/transaction_model.dart';
import 'package:sehatak/core/services/payment_service.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PaymentService _paymentService = PaymentService();

  // ✅ الحصول على اشتراك المستخدم
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

  // ✅ إنشاء اشتراك جديد
  Future<SubscriptionModel> createSubscription({
    required SubscriptionPlan plan,
    required PaymentMethod method,
    required String? transactionId,
    bool isYearly = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('الرجاء تسجيل الدخول');

    final planDetails = SubscriptionPlanDetails.getPlanDetails(plan);
    final price = isYearly ? planDetails.priceYearly : planDetails.priceMonthly;
    
    final id = _firestore.collection('subscriptions').doc().id;
    final now = DateTime.now();
    final endDate = isYearly 
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));

    final subscription = SubscriptionModel(
      id: id,
      userId: user.uid,
      plan: plan,
      status: SubscriptionStatus.active,
      startDate: now,
      endDate: endDate,
      price: price,
      paymentProvider: method,
      transactionId: transactionId,
      features: planDetails.features,
      trialDays: planDetails.trialDays,
      createdAt: now,
      updatedAt: now,
    );

    await _firestore.collection('subscriptions').doc(id).set(subscription.toFirestore());
    
    // ✅ تحديث دور المستخدم
    await _updateUserRole(plan);
    
    return subscription;
  }

  // ✅ تجديد الاشتراك
  Future<void> renewSubscription(String subscriptionId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('الرجاء تسجيل الدخول');
    
    final doc = await _firestore.collection('subscriptions').doc(subscriptionId).get();
    if (!doc.exists) throw Exception('الاشتراك غير موجود');
    
    final subscription = SubscriptionModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    final newEndDate = subscription.endDate.add(const Duration(days: 30));
    
    await _firestore.collection('subscriptions').doc(subscriptionId).update({
      'endDate': newEndDate.toIso8601String(),
      'status': 'active',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ إلغاء الاشتراك
  Future<void> cancelSubscription(String subscriptionId) async {
    await _firestore.collection('subscriptions').doc(subscriptionId).update({
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ جلب تاريخ الاشتراكات
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

  // ✅ معالجة الدفع للاشتراك
  Future<Map<String, dynamic>> processSubscriptionPayment({
    required SubscriptionPlan plan,
    required PaymentMethod method,
    bool isYearly = false,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('الرجاء تسجيل الدخول');

    final planDetails = SubscriptionPlanDetails.getPlanDetails(plan);
    final amount = isYearly ? planDetails.priceYearly : planDetails.priceMonthly;
    final planName = isYearly ? '${planDetails.name} (سنوي)' : planDetails.name;

    // ✅ معالجة الدفع
    final paymentResult = await _paymentService.processPayment(
      userId: user.uid,
      amount: amount,
      type: TransactionType.subscription,
      method: method,
      description: 'اشتراك ${planName}',
    );

    if (!paymentResult['success']) {
      return {
        'success': false,
        'error': paymentResult['error'],
      };
    }

    // ✅ إنشاء الاشتراك
    final subscription = await createSubscription(
      plan: plan,
      method: method,
      transactionId: paymentResult['paymentId'],
      isYearly: isYearly,
    );

    return {
      'success': true,
      'subscription': subscription,
      'paymentId': paymentResult['paymentId'],
    };
  }

  // ✅ تحديث دور المستخدم بناءً على الباقة
  Future<void> _updateUserRole(SubscriptionPlan plan) async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    String role = 'user';
    switch (plan) {
      case SubscriptionPlan.premium:
      case SubscriptionPlan.family:
        role = 'premium_user';
        break;
      case SubscriptionPlan.enterprise:
        role = 'enterprise_user';
        break;
      case SubscriptionPlan.basic:
        role = 'basic_user';
        break;
      default:
        role = 'user';
    }
    
    await _firestore.collection('users').doc(user.uid).update({
      'subscriptionRole': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ✅ التحقق من صلاحية الاشتراك
  Future<bool> checkSubscriptionAccess(String requiredPlan) async {
    final subscription = await getUserSubscription();
    if (subscription == null) return false;
    
    if (!subscription.isActive) return false;
    
    final planPriority = {
      'free': 0,
      'basic': 1,
      'premium': 2,
      'family': 3,
      'enterprise': 4,
    };
    
    final userPriority = planPriority[subscription.planName.toLowerCase()] ?? 0;
    final requiredPriority = planPriority[requiredPlan.toLowerCase()] ?? 0;
    
    return userPriority >= requiredPriority;
  }

  // ✅ التحقق من وجود اشتراك تجريبي
  Future<bool> hasTrialUsed() async {
    final user = _auth.currentUser;
    if (user == null) return true;
    
    final snap = await _firestore
        .collection('subscriptions')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'trial')
        .limit(1)
        .get();
    
    return snap.docs.isNotEmpty;
  }
}
