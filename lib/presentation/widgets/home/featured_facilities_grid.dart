import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_details_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_detail_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class FeaturedFacilitiesGrid extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final bool isHospital;
  final bool isDark;

  const FeaturedFacilitiesGrid({
    super.key,
    required this.title,
    required this.items,
    required this.isHospital,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF173131),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: .82,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _FacilityCard(
              item: items[index],
              isHospital: isHospital,
              isDark: isDark,
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

  String _string(String key, [String fallback = '']) =>
      item[key]?.toString().trim().isNotEmpty == true
          ? item[key].toString().trim()
          : fallback;

  double? _rating() {
    final value = item['rating'];
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final id = _string('id');
    final image = _string('imageUrl', _string('image'));
    final name = _string('name', isHospital ? 'مستشفى' : 'مختبر');
    final location = _string('location', _string('address', 'صنعاء'));
    final rating = _rating();
    final isOpen = item['open'] == true;

    return Material(
      color: isDark ? const Color(0xFF1A2540) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
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
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 96,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: image.isEmpty
                        ? Container(
                            width: double.infinity,
                            color: AppColors.primary.withOpacity(.08),
                            alignment: Alignment.center,
                            child: Text(
                              isHospital ? '🏥' : '🔬',
                              style: const TextStyle(fontSize: 30),
                            ),
                          )
                        : AppImage(
                            imageUrl: image,
                            width: double.infinity,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                  ),
                  if (rating != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.68),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '★ ${rating.toStringAsFixed(1)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (isHospital)
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xCC2E7D32)
                              : const Color(0xCCC62828),
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
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 9.5,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 28,
                      child: FilledButton(
                        onPressed: () {
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
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: Text(
                          isHospital ? 'تفاصيل' : 'حجز / تفاصيل',
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
