import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/presentation/screens/reviews/reviews_screen.dart';
import 'package:sehatak/core/models/review_model.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

/// Professional counterpart of the patient's "My Health" profile.
/// All counters are read from the same Firestore collections used by booking,
/// chat and review features; no placeholder ratings or booking totals are shown.
class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  String _t(BuildContext context, String value) =>
      AppStrings.of(context).translate(value);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text(_t(context, 'يجب تسجيل الدخول لعرض الملف'))),
      );
    }
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doctorRef = FirebaseFirestore.instance.collection('doctors').doc(user.uid);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userRef.snapshots(),
      builder: (context, userSnapshot) {
        final userData = userSnapshot.data?.data() ?? <String, dynamic>{};
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: doctorRef.snapshots(),
          builder: (context, doctorSnapshot) {
            final doctorData = doctorSnapshot.data?.data() ?? <String, dynamic>{};
            final data = <String, dynamic>{...userData, ...doctorData};
            final name = (data['name'] ?? data['displayName'] ?? user.displayName ?? _t(context, 'الطبيب')).toString();
            final email = (data['email'] ?? user.email ?? '').toString();
            final specialty = (data['specialty'] ?? data['specialization'] ?? data['specialtyName'] ?? _t(context, 'التخصص غير محدد')).toString();
            final hospital = (data['hospital'] ?? data['clinic'] ?? data['clinicAddress'] ?? '').toString();
            final photo = ImageKit.doctorPhoto(data);
            final doctorNumber = (data['doctorNumber'] ?? data['licenseNumber'] ?? data['medicalLicense'] ?? '—').toString();
            return Scaffold(
              appBar: AppBar(
                title: Text(_t(context, 'ملف الطبيب')),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  await Future.wait([userRef.get(), doctorRef.get()]);
                },
                child: ListView(
                  padding: const EdgeInsets.all(14),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        children: [
                          ClipOval(
                            child: AppImage(
                              imageUrl: photo,
                              width: 88,
                              height: 88,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                width: 88, height: 88,
                                color: Colors.white24,
                                alignment: Alignment.center,
                                child: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 42),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(name, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
                          Text(specialty, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          if (email.isNotEmpty) Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          if (hospital.isNotEmpty) Text(hospital, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          Text('${_t(context, 'رقم الطبيب')}: $doctorNumber', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _badge(context, data['isVerified'] == true ? 'موثق' : 'قيد التحقق'),
                              _badge(context, data['isAvailable'] == true ? 'متاح للحجز' : 'غير متاح حالياً'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(_t(context, 'الأداء والتفاعلات'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _stats(context, user.uid),
                    const SizedBox(height: 16),
                    _infoCard(context, 'البيانات المهنية', [
                      _infoRow(context, Icons.workspace_premium_outlined, 'التخصص', specialty),
                      _infoRow(context, Icons.local_hospital_outlined, 'المستشفى / العيادة', hospital.isEmpty ? 'غير محدد' : hospital),
                      _infoRow(context, Icons.payments_outlined, 'سعر الاستشارة', data['consultationFee'] == null ? 'غير محدد' : '${data['consultationFee']} ر.ي'),
                      _infoRow(context, Icons.event_available_outlined, 'حالة استقبال الحجوزات', data['acceptingAppointments'] == false ? 'متوقف' : 'يستقبل الحجوزات'),
                    ]),
                    const SizedBox(height: 16),
                    _infoCard(context, 'التفاعلات والخدمات', [
                      _infoRow(context, Icons.chat_bubble_outline, 'الدردشة', data['messageSettings'] is Map && (data['messageSettings'] as Map)['enabled'] == false ? 'غير مفعلة' : 'مفعلة'),
                      _infoRow(context, Icons.call_outlined, 'المكالمات', data['acceptingCalls'] == false ? 'غير مفعلة' : 'مفعلة'),
                      _infoRow(context, Icons.video_call_outlined, 'مكالمات الفيديو', data['acceptingVideo'] == false ? 'غير مفعلة' : 'مفعلة'),
                    ]),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _stats(BuildContext context, String uid) {
    final appointments = FirebaseFirestore.instance.collection('appointments').where('doctorId', isEqualTo: uid).snapshots();
    final chats = FirebaseFirestore.instance.collection('chats').where('participants', arrayContains: uid).snapshots();
    final reviews = FirebaseFirestore.instance.collection('reviews').where('targetId', isEqualTo: uid).where('target', isEqualTo: ReviewTarget.doctor.name).snapshots();
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: appointments,
      builder: (context, appointmentSnapshot) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: chats,
        builder: (context, chatSnapshot) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: reviews,
          builder: (context, reviewSnapshot) {
            final bookingCount = appointmentSnapshot.data?.docs.length ?? 0;
            final chatCount = chatSnapshot.data?.docs.where((d) => (d.data()['participants'] as List?)?.length == 2).length ?? 0;
            final reviewDocs = reviewSnapshot.data?.docs ?? [];
            final average = reviewDocs.isEmpty ? 0.0 : reviewDocs.fold<double>(0, (sum, d) => sum + ((d.data()['rating'] as num?)?.toDouble() ?? 0)) / reviewDocs.length;
            return Column(
              children: [
                Row(children: [
                  Expanded(child: _statCard(context, 'الحجوزات', '$bookingCount', Icons.calendar_month)),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard(context, 'المحادثات', '$chatCount', Icons.forum_outlined)),
                ]),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: _statCard(context, 'التقييم', reviewDocs.isEmpty ? '—' : average.toStringAsFixed(1), Icons.star, suffix: reviewDocs.isEmpty ? '' : ' / 5')),
                  const SizedBox(width: 8),
                  Expanded(child: _statCard(context, 'عدد التقييمات', '${reviewDocs.length}', Icons.rate_review_outlined)),
                ]),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewsScreen(targetId: uid, target: ReviewTarget.doctor, targetName: _t(context, 'الطبيب'), isProvider: true))),
                    icon: const Icon(Icons.reviews_outlined),
                    label: Text(_t(context, 'عرض التقييمات والرد عليها')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _badge(BuildContext context, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
    child: Text(_t(context, value), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
  );

  Widget _statCard(BuildContext context, String title, String value, IconData icon, {String suffix = ''}) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Icon(icon, color: AppColors.primary, size: 25),
      const SizedBox(width: 9),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$value$suffix', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        Text(_t(context, title), style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ])),
    ]),
  );

  Widget _infoCard(BuildContext context, String title, List<Widget> rows) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_t(context, title), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 8),
        ...rows,
      ]),
    ),
  );

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Icon(icon, size: 19, color: AppColors.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(_t(context, label), style: const TextStyle(fontSize: 12))),
      Flexible(child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  );
}
