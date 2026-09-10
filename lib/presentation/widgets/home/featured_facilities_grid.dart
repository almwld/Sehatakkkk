import 'package:flutter/material.dart';

import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_details_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_detail_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

/// العرض الموحد للمرافق المميزة داخل الصفحة الرئيسية.
/// البيانات تأتي من HomeState عبر [items] ولا توجد بيانات منشآت ثابتة هنا.
class FeaturedFacilitiesGrid extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool isHospital;
  final bool isDark;
  final VoidCallback? onSeeAll;

  const FeaturedFacilitiesGrid({
    super.key,
    required this.title,
    required this.items,
    required this.isHospital,
    required this.isDark,
    this.onSeeAll,
  });

  void _seeAll() {
    if (onSeeAll != null) {
      onSeeAll!();
      return;
    }
    AppRouter.router.push(isHospital ? AppRouter.hospitals : AppRouter.labs);
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF173131),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _seeAll,
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) => SizedBox(
                width: 170,
                child: _FacilityCard(
                  item: items[index],
                  isHospital: isHospital,
                  isDark: isDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isHospital;
  final bool isDark;

  const _FacilityCard({
    required this.item,
    required this.isHospital,
    required this.isDark,
  });

  String _string(String key, [String fallback = '']) {
    final value = item[key]?.toString().trim();
    return value == null || value.isEmpty ? fallback : value;
  }

  double? _rating() {
    final value = item['rating'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  void _open(BuildContext context) {
    final id = _string('id');
    if (id.isEmpty) return;

    if (isHospital) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => HospitalDetailsScreen(
            hospitalId: id,
            hospitalData: item,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LabDetailScreen(labId: id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = _string('id');
    final image = _string('imageUrl', _string('image', _string('photoUrl')));
    final name = _string('name', isHospital ? 'مستشفى' : 'مختبر');
    final location = _string('location', _string('city', _string('address')));
    final rating = _rating();
    final isOpen = item['open'] == true || item['isOpen'] == true;
    final homeService = item['homeService'] == true || item['deliveryAvailable'] == true;

    return Material(
      color: isDark ? const Color(0xFF162039) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: id.isEmpty ? null : () => _open(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: image.isEmpty
                        ? Container(
                            color: AppColors.primary.withOpacity(.08),
                            alignment: Alignment.center,
                            child: Text(
                              isHospital ? '🏥' : '🔬',
                              style: const TextStyle(fontSize: 38),
                            ),
                          )
                        : Hero(
                            tag: '${isHospital ? 'hospital' : 'lab'}_$id',
                            child: AppImage(
                              imageUrl: image,
                              width: double.infinity,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.68),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 11),
                            const SizedBox(width: 2),
                            Text(
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (isHospital && item.containsKey('open'))
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOpen ? const Color(0xCC2E7D32) : const Color(0xCCC62828),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isOpen ? 'مفتوح' : 'مغلق',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  if (!isHospital && homeService)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xCC1976D2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'خدمة منزلية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (location.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 9.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: FilledButton(
                        onPressed: id.isEmpty ? null : () => _open(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isHospital ? 'تفاصيل' : 'حجز',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
