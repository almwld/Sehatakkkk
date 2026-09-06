import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class VerificationScreen extends StatefulWidget {
  final dynamic userModel;

  const VerificationScreen({super.key, this.userModel});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _loading = true;
  bool _submitting = false;
  String _status = 'notSubmitted';
  bool _verified = false;
  String? _error;

  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
      final snapshot = await FirebaseFirestore.instance.collection('doctors').doc(user.uid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) throw Exception('ملف الطبيب غير موجود');
      if (!mounted) return;
      setState(() {
        _status = data['verificationStatus']?.toString() ?? 'notSubmitted';
        _verified = data['isVerified'] == true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _submit() async {
    if (_submitting || _verified) return;
    setState(() => _submitting = true);
    try {
      await _functions.httpsCallable('submitDoctorVerification').call();
      if (!mounted) return;
      setState(() {
        _status = 'pending';
        _verified = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلب التوثيق للمراجعة')));
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'تعذر إرسال طلب التوثيق')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String get _title {
    if (_verified) return 'الحساب موثق';
    switch (_status) {
      case 'pending': return 'طلب التوثيق قيد المراجعة';
      case 'rejected': return 'تم رفض طلب التوثيق';
      default: return 'توثيق حساب الطبيب';
    }
  }

  String get _description {
    if (_verified) return 'تم اعتماد حسابك ويمكن للمرضى العثور عليك وحجز المواعيد وبدء المحادثة معك.';
    if (_status == 'pending') return 'طلبك وصل إلى المراجعة. لن يظهر ملفك في دليل الأطباء حتى يتم اعتمادك.';
    if (_status == 'rejected') return 'يمكنك إعادة إرسال طلب التوثيق بعد تحديث بياناتك المطلوبة.';
    return 'أرسل طلب التوثيق ليتم مراجعته من مشرف المنصة.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'توثيق الحساب', backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.error_outline, size: 56), const SizedBox(height: 12), Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 20), ElevatedButton(onPressed: _loadStatus, child: const Text('إعادة المحاولة'))]))
              : Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [Icon(_verified ? Icons.verified : Icons.assignment_turned_in_outlined, size: 80, color: AppColors.primary), const SizedBox(height: 16), Text(_title, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 10), Text(_description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade700)), const SizedBox(height: 28), if (!_verified && _status != 'pending') SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submitting ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('إرسال طلب التوثيق')) , const SizedBox(height: 12), SizedBox(width: double.infinity, height: 50, child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('العودة')))]))
    );
  }
}
