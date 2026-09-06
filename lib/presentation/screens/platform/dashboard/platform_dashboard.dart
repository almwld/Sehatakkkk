import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class PlatformDashboard extends StatefulWidget {
  const PlatformDashboard({super.key});
  @override
  State<PlatformDashboard> createState() => _PlatformDashboardState();
}

class _PlatformDashboardState extends State<PlatformDashboard> {
  final _functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  bool _loading = true;
  bool _isAdmin = false;
  String? _error;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _pending = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول أولاً');
      final admin = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (admin.data()?['role'] != 'admin') throw Exception('هذه الشاشة مخصصة للمشرف فقط');
      final snapshot = await FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'doctor').get();
      if (!mounted) return;
      setState(() {
        _isAdmin = true;
        _pending = snapshot.docs.where((d) => (d.data()['verificationStatus']?.toString() ?? 'notSubmitted') == 'pending').toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _review(String doctorId, String decision) async {
    try {
      await _functions.httpsCallable('reviewDoctorVerification').call({'doctorId': doctorId, 'decision': decision});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decision == 'approve' ? 'تم اعتماد الطبيب' : 'تم رفض طلب الطبيب')));
      await _load();
    } on FirebaseFunctionsException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'تعذر تنفيذ القرار')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(title: 'إدارة التوثيق', backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null || !_isAdmin
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error ?? 'غير مصرح لك بالدخول', textAlign: TextAlign.center)))
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: _pending.isEmpty
                      ? ListView(children: const [SizedBox(height: 180), Center(child: Text('لا توجد طلبات توثيق معلقة حالياً'))])
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pending.length,
                          itemBuilder: (context, index) {
                            final data = _pending[index].data();
                            final doctorId = _pending[index].id;
                            final name = data['name']?.toString() ?? 'طبيب بدون اسم';
                            final specialty = data['specialty']?.toString() ?? 'غير محدد';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 5),
                                  Text(specialty),
                                  if (data['licenseNumber'] != null) ...[const SizedBox(height: 4), Text('رقم الترخيص: ${data['licenseNumber']}')],
                                  const SizedBox(height: 14),
                                  Row(children: [
                                    Expanded(child: OutlinedButton(onPressed: () => _review(doctorId, 'reject'), child: const Text('رفض'))),
                                    const SizedBox(width: 10),
                                    Expanded(child: ElevatedButton(onPressed: () => _review(doctorId, 'approve'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white), child: const Text('اعتماد'))),
                                  ])
                                ]),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
