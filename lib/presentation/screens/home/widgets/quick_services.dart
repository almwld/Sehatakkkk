import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class QuickServiceItem {
  final String icon;
  final String label;
  final Color color;
  final Widget screen;

  QuickServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.screen,
  });
}

class QuickServices extends StatelessWidget {
  final List<QuickServiceItem> services;

  const QuickServices({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => service.screen),
            ),
            child: Container(
              width: 70.w,
              margin: EdgeInsets.only(right: 12.w),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: service.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: service.color.withOpacity(0.2),
                      ),
                    ),
                    child: AppImage(
                      url: service.icon,
                      width: 32.w,
                      height: 32.h,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    service.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
