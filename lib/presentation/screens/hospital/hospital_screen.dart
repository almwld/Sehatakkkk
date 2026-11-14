import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_details_screen.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});
  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen> {
  final TextEditingController _search = TextEditingController();
  String _filter = 'all';

  String _t(String value) => AppStrings.of(context).translate(value);
  String _field(Map<String, dynamic> data, String key, {String fallback = ''}) =>
      localizedField(data, key, AppStrings.of(context).locale, fallback: fallback);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Map<String, dynamic> hospital) {
    final query = _search.text.trim().toLowerCase();
    final name = _field(hospital, 'name').toLowerCase();
    final city = _field(hospital, 'city').toLowerCase();
    final address = _field(hospital, 'address').toLowerCase();
    final type = _field(hospital, 'type').toLowerCase();
    final textMatch = query.isEmpty || '$name $city $address $type'.contains(query);
    final emergency = hospital['emergency'] == true || hospital['hasEmergency'] == true;
    final open = hospital['isOpen'] == true || hospital['open'] == true || hospital['isAvailable'] == true;
    final filterMatch = _filter == 'all' ||
        (_filter == 'emergency' && emergency) ||
        (_filter == 'open' && open);
    return textMatch && filterMatch;
  }

  String _image(Map<String, dynamic> data, int index) {
    for (final key in ['coverUrl', 'facilityCoverUrl', 'imageUrl', 'image', 'photoUrl']) {
      final value = data[key]?.toString().trim() ?? '';
      if (value.startsWith('https://') || value.startsWith('http://')) return value;
    }
    return [ImageKit.hospital1, ImageKit.hospital2, ImageKit.hospital3][index % 3];
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final background = dark ? const Color(0xFF0B1121) : const Color(0xFFF4F7F8);
    return Scaffold(
      backgroundColor: background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 158,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Text(_t('المستشفيات'), style: const TextStyle(fontWeight: FontWeight.w900)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF087F78), Color(0xFF0A8F83), Color(0xFF176F9A)],
                  ),
                ),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 82, 20, 18),
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    _t('اكتشف المستشفيات والأقسام والخدمات الطبية في مكان واحد'),
                    maxLines: 2,
                    style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: _t('ابحث باسم المستشفى أو المدينة أو التخصص'),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close)),
                  filled: true,
                  fillColor: dark ? const Color(0xFF172536) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: BorderSide.none),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('all', _t('الكل'), Icons.grid_view_rounded, dark),
                  _filterChip('open', _t('متاح الآن'), Icons.check_circle_outline, dark),
                  _filterChip('emergency', _t('الطوارئ'), Icons.emergency_outlined, dark),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('hospitals').where('isPublished', isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _message(Icons.cloud_off_outlined, _t('تعذر تحميل المستشفيات. تحقق من الاتصال وحاول مجدداً.'), dark),
                );
              }
              if (!snapshot.hasData) {
                return const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
              }
              final hospitals = snapshot.data!.docs
                  .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
                  .where(_matches)
                  .toList()
                ..sort((a, b) => _field(a, 'name').compareTo(_field(b, 'name')));
              if (hospitals.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _message(Icons.local_hospital_outlined, _search.text.isEmpty
                      ? _t('لا توجد مستشفيات منشورة حالياً')
                      : _t('لا توجد نتائج تطابق بحثك'), dark),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _hospitalCard(hospitals[index], index, dark),
                    childCount: hospitals.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label, IconData icon, bool dark) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        avatar: Icon(icon, size: 17, color: selected ? Colors.white : AppColors.primary),
        label: Text(label),
        selectedColor: AppColors.primary,
        backgroundColor: dark ? const Color(0xFF172536) : Colors.white,
        labelStyle: TextStyle(color: selected ? Colors.white : (dark ? Colors.white70 : const Color(0xFF344054)), fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13), side: BorderSide(color: selected ? AppColors.primary : Colors.transparent)),
      ),
    );
  }

  Widget _hospitalCard(Map<String, dynamic> hospital, int index, bool dark) {
    final name = _field(hospital, 'name', fallback: _t('مستشفى'));
    final location = _field(hospital, 'location', fallback: _field(hospital, 'address', fallback: _field(hospital, 'city')));
    final type = _field(hospital, 'type', fallback: _field(hospital, 'ownership', fallback: _t('مستشفى عام')));
    final emergency = hospital['emergency'] == true || hospital['hasEmergency'] == true;
    final open = hospital['isOpen'] == true || hospital['open'] == true || hospital['isAvailable'] == true;
    final rating = hospital['rating'];
    final ratingText = rating is num ? rating.toStringAsFixed(1) : '';
    final services = hospital['services'] is List ? (hospital['services'] as List).where((e) => e != null && e.toString().trim().isNotEmpty).take(3).toList() : const [];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF142333) : Colors.white,
        borderRadius: BorderRadius.circular(21),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? .10 : .045), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => HospitalDetailsScreen(hospitalId: hospital['id'].toString(), hospitalData: hospital),
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 158,
                width: double.infinity,
                child: Stack(fit: StackFit.expand, children: [
                  AppImage(imageUrl: _image(hospital, index), width: double.infinity, height: 158, fit: BoxFit.cover),
                  DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(.04), Colors.black.withOpacity(.58)]))),
                  PositionedDirectional(
                    start: 13, bottom: 13,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: open ? const Color(0xFF087F58) : Colors.black.withOpacity(.65), borderRadius: BorderRadius.circular(30)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(open ? Icons.check_circle : Icons.info_outline, color: Colors.white, size: 14),
                        const SizedBox(width: 5),
                        Text(_t(open ? 'متاح' : 'تحقق من أوقات العمل'), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                  if (emergency)
                    PositionedDirectional(end: 12, top: 12, child: _badge(_t('الطوارئ'), const Color(0xFFD94343))),
                  if (ratingText.isNotEmpty)
                    PositionedDirectional(end: 12, bottom: 13, child: _badge('★ $ratingText', const Color(0xFF202B35))),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF172B36))),
                  const SizedBox(height: 7),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location.isEmpty ? _t('الموقع غير محدد') : location, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54))),
                    const SizedBox(width: 8),
                    Text(type, style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : Colors.black54)),
                  ]),
                  if (services.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(spacing: 6, runSpacing: 6, children: services.map((service) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(.09), borderRadius: BorderRadius.circular(20)),
                      child: Text(service.toString(), style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700)),
                    )).toList()),
                  ],
                  const SizedBox(height: 13),
                  Row(children: [
                    if (hospital['isVerified'] == true) const Icon(Icons.verified_rounded, color: AppColors.primary, size: 17),
                    if (hospital['isVerified'] == true) const SizedBox(width: 5),
                    Expanded(child: Text(_t(hospital['isVerified'] == true ? 'منشأة موثقة' : 'ملف المستشفى'), style: TextStyle(fontSize: 11, color: dark ? Colors.white54 : Colors.black45))),
                    Text(_t('عرض التفاصيل'), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(width: 3),
                    const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 12),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withOpacity(.92), borderRadius: BorderRadius.circular(30)),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
  );

  Widget _message(IconData icon, String message, bool dark) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 48, color: AppColors.primary.withOpacity(.65)),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center, style: TextStyle(color: dark ? Colors.white70 : Colors.black54, height: 1.5)),
      ]),
    ),
  );
}
