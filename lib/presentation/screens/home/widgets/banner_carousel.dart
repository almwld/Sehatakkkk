import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> images;

  const BannerCarousel({super.key, required this.images});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160.h,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: true,
            viewportFraction: 0.95,
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
          items: widget.images.map((url) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: AppImage(
                  url: url,
                  height: 160.h,
                  width: double.infinity,
                ),
              ),
            );
          }).toList(),
        ),
        Positioned(
          bottom: 12.h,
          left: 16.w,
          child: Row(
            children: widget.images.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = _currentIndex == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isActive ? 20.w : 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
