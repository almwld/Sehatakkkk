import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final String hospitalId;
  final Map<String, dynamic>? hospitalData;

  const HospitalDetailsScreen({super.key, required this.hospitalId, this.hospitalData});

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);
  String _field(Map<String, dynamic> data, String key, {String fallback = ''}) =>
      localizedField(data, key, AppStrings.of(context).locale, fallback: fallback);

  List<String> _strings(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item?.toString().trim() ?? '').where((item) => item.isNotEmpty).toList();
  }

  String _image(Map<String, dynamic> data) {
    for (final key in ['coverUrl', 'facilityCoverUrl', 'imageUrl', 'image', 'photoUrl']) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.startsWith('https://') || value.startsWith('http://')) return value;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF0B1121) : const Color(0xFFF5F8F9);
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('hospitals').doc(widget.hospitalId).snapshots(),
      builder: (context, snapshot) {
        final hospital = snapshot.data?.data() ?? widget.hospitalData ?? <String, dynamic>{};
        final name = _field(hospital, 'name', fallback: _t('المستشفى'));
        final location = _field(hospital, 'location', fallback: _field(hospital, 'address', fallback: _field(hospital, 'city', fallback: _t('الموقع غير محدد'))));
        final services = _strings(hospital['services']);
        final emergency = hospital['emergency'] == true || hospital['hasEmergency'] == true;
        final open = hospital['isOpen'] == true || hospital['open'] == true || hospital['isAvailable'] == true;
        final image = _image(hospital);
        return Scaffold(
          backgroundColor: background,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 235,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
                    if (image.isNotEmpty) AppImage(imageUrl: image, width: double.infinity, height: 235, fit: BoxFit.cover)
                    else Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF087F78), Color(0xFF0A8F83), Color(0xFF176F9A)])), child: const Center(child: Icon(Icons.local_hospital_rounded, color: Colors.white70, size: 76))),
                    DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(.05), Colors.black.withOpacity(.68)]))),
                    PositionedDirectional(start: 18, end: 18, bottom: 22, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 7),
                      Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Colors.white70), const SizedBox(width: 5), Expanded(child: Text(location, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 12)))]),
                    ])),
                  ]),
                ),
              ),
              if (snapshot.hasError)
                SliverToBoxAdapter(child: _notice(_t('تعذر تحديث بيانات المستشفى'), dark, warning: true)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(children: [
                    Expanded(child: _infoTile(Icons.circle, _t(open ? 'حالة المستشفى: متاح' : 'حالة المستشفى: غير متاح'), open ? const Color(0xFF16845B) : Colors.orange, dark)),
                    const SizedBox(width: 9),
                    Expanded(child: _infoTile(Icons.emergency_outlined, _t(emergency ? 'قسم الطوارئ متاح' : 'معلومات الطوارئ غير متوفرة'), emergency ? Colors.red : Colors.grey, dark)),
                  ]),
                ),
              ),
              SliverToBoxAdapter(child: _sectionTitle(_t('نبذة عن المستشفى'), dark)),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(_field(hospital, 'description', fallback: _field(hospital, 'about', fallback: _t('لم تتم إضافة نبذة عن المستشفى بعد.'))), style: TextStyle(color: dark ? Colors.white70 : const Color(0xFF52616B), height: 1.6)),
              )),
              SliverToBoxAdapter(child: _sectionTitle(_t('الأقسام الطبية'), dark)),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('hospital_departments').where('hospitalId', isEqualTo: widget.hospitalId).snapshots(),
                builder: (context, departmentSnapshot) {
                  if (departmentSnapshot.hasError) return SliverToBoxAdapter(child: _notice(_t('تعذر تحميل الأقسام حالياً'), dark));
                  if (!departmentSnapshot.hasData) return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2))));
                  final departments = departmentSnapshot.data!.docs.where((doc) => doc.data()['isActive'] != false).toList();
                  if (departments.isEmpty) return SliverToBoxAdapter(child: _empty(_t('لم تُنشر أقسام طبية لهذا المستشفى بعد'), dark));
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.5),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final data = departments[index].data();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: dark ? const Color(0xFF142333) : Colors.white, borderRadius: BorderRadius.circular(15)),
                          child: Row(children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 19)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_field(data, 'name', fallback: _t('قسم طبي')), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: dark ? Colors.white : const Color(0xFF263746)))),
                          ]),
                        );
                      }, childCount: departments.length),
                    ),
                  );
                },
              ),
              if (services.isNotEmpty) ...[
                SliverToBoxAdapter(child: _sectionTitle(_t('الخدمات الطبية'), dark)),
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(spacing: 8, runSpacing: 8, children: services.map((service) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(.09), borderRadius: BorderRadius.circular(22), border: Border.all(color: AppColors.primary.withOpacity(.12))),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 15), const SizedBox(width: 6), Text(service, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700))]),
                  )).toList()),
                )),
              ],
              SliverToBoxAdapter(child: _sectionTitle(_t('الكادر الصحي'), dark)),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('hospital_staff').where('hospitalId', isEqualTo: widget.hospitalId).where('isPublic', isEqualTo: true).where('status', isEqualTo: 'active').snapshots(),
                builder: (context, staffSnapshot) {
                  if (staffSnapshot.hasError) return SliverToBoxAdapter(child: _notice(_t('تعذر تحميل بيانات الكادر الصحي'), dark));
                  if (!staffSnapshot.hasData) return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(strokeWidth: 2))));
                  final staff = staffSnapshot.data!.docs;
                  if (staff.isEmpty) return SliverToBoxAdapter(child: _empty(_t('لم تُنشر ملفات الكادر الصحي لهذا المستشفى بعد'), dark));
                  return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
                    final member = staff[index].data();
                    final memberName = _field(member, 'displayName', fallback: _field(member, 'name', fallback: _t('عضو الكادر الصحي')));
                    final role = _field(member, 'jobTitle', fallback: _field(member, 'roleTitle', fallback: _field(member, 'specialty', fallback: _t('ممارس صحي'))));
                    final photo = member['photoUrl']?.toString() ?? member['imageUrl']?.toString() ?? '';
                    return Container(
                      margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 9),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: dark ? const Color(0xFF142333) : Colors.white, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        ClipRRect(borderRadius: BorderRadius.circular(14), child: photo.startsWith('http') ? AppImage(imageUrl: photo, width: 52, height: 52, fit: BoxFit.cover) : Container(width: 52, height: 52, color: AppColors.primary.withOpacity(.10), child: const Icon(Icons.person_outline, color: AppColors.primary))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(memberName, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF263746))),
                          const SizedBox(height: 4),
                          Text(role, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                          if ((member['departmentName'] ?? '').toString().trim().isNotEmpty) Text(member['departmentName'].toString(), style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 11)),
                        ])),
                        if (member['isVerified'] == true) const Icon(Icons.verified_rounded, color: AppColors.primary, size: 19),
                      ]),
                    );
                  }, childCount: staff.length));
                },
              ),
              SliverToBoxAdapter(child: _sectionTitle(_t('معلومات التواصل'), dark)),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(color: dark ? const Color(0xFF142333) : Colors.white, borderRadius: BorderRadius.circular(17)),
                  child: Column(children: [
                    _contactRow(Icons.location_on_outlined, location, dark),
                    if ((hospital['phone'] ?? '').toString().trim().isNotEmpty) _contactRow(Icons.phone_outlined, hospital['phone'].toString(), dark),
                    if ((hospital['email'] ?? '').toString().trim().isNotEmpty) _contactRow(Icons.email_outlined, hospital['email'].toString(), dark),
                    if ((hospital['website'] ?? '').toString().trim().isNotEmpty) _contactRow(Icons.language_outlined, hospital['website'].toString(), dark),
                  ]),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, bool dark) => SliverToBoxAdapter(
    child: Padding(padding: const EdgeInsets.fromLTRB(16, 22, 16, 11), child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF1E3440)))),
  );

  Widget _infoTile(IconData icon, String text, Color color, bool dark) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(color: dark ? const Color(0xFF142333) : Colors.white, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 7), Expanded(child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: dark ? Colors.white70 : const Color(0xFF475866))))]),
  );

  Widget _contactRow(IconData icon, String value, bool dark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [Icon(icon, color: AppColors.primary, size: 18), const SizedBox(width: 10), Expanded(child: Text(value, style: TextStyle(color: dark ? Colors.white70 : const Color(0xFF475866))))]),
  );

  Widget _notice(String text, bool dark, {bool warning = false}) => Padding(
    padding: const EdgeInsets.all(16),
    child: Text(text, style: TextStyle(color: warning ? Colors.orange : (dark ? Colors.white60 : Colors.black54))),
  );

  Widget _empty(String text, bool dark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white54 : Colors.black45, fontSize: 12)),
  );
}
