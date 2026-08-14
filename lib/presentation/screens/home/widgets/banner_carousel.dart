import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class BannerCarousel extends StatefulWidget {
  final List<String> images;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final Duration autoPlayAnimationDuration;
  final bool showIndicator;
  final EdgeInsets indicatorPadding;
  final Color indicatorColor;
  final Color indicatorActiveColor;
  final double indicatorSize;
  final double indicatorActiveSize;
  final Function(int)? onPageChanged;

  const BannerCarousel({
    super.key,
    required this.images,
    this.height = 160,
    this.viewportFraction = 0.95,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.showIndicator = true,
    this.indicatorPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.indicatorColor = Colors.white,
    this.indicatorActiveColor = Colors.white,
    this.indicatorSize = 8,
    this.indicatorActiveSize = 20,
    this.onPageChanged,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  void _goToSlide(int index) {
    if (index >= 0 && index < widget.images.length) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) const {
    if (widget.images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
            height: widget.height,
            autoPlay: widget.autoPlay,
            autoPlayInterval: widget.autoPlayInterval,
            autoPlayAnimationDuration: widget.autoPlayAnimationDuration,
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            viewportFraction: widget.viewportFraction,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
              if (widget.onPageChanged != null) {
                widget.onPageChanged!(index);
              }
            },
          ),
          items: widget.images.map((url) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AppImage(
                  imageUrl: url,
                  height: widget.height,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            );
          }).toList(),
        ),
        
        // ✅ مؤشرات التمرير
        if (widget.showIndicator && widget.images.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.images.asMap().entries.map((entry) {
                final index = entry.key;
                final isActive = _currentIndex == index;
                return GestureDetector(
                  onTap: () => _goToSlide(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isActive ? widget.indicatorActiveSize : widget.indicatorSize,
                    height: widget.indicatorSize,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive 
                          ? widget.indicatorActiveColor 
                          : widget.indicatorColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                              )
                            ]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        
        // ✅ أزرار التنقل (اختياري)
        if (widget.images.length > 1)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  final prevIndex = _currentIndex > 0 
                      ? _currentIndex - 1 
                      : widget.images.length - 1;
                  _goToSlide(prevIndex);
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: GestureDetector(
              onTap: () {
                final nextIndex = _currentIndex < widget.images.length - 1 
                    ? _currentIndex + 1 
                    : 0;
                _goToSlide(nextIndex);
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ✅ BannerCarousel مع تحميل من الشبكة (NetworkBannerCarousel)
class NetworkBannerCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;

  const NetworkBannerCarousel({
    super.key,
    required this.imageUrls,
    this.height = 160,
    this.autoPlay = true,
  });

  @override
  Widget build(BuildContext context) const {
    return BannerCarousel(
      images: imageUrls,
      height: height,
      autoPlay: autoPlay,
    );
  }
}
