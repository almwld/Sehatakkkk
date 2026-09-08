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

  const BannerCarousel({
    super.key,
    required this.images,
    this.height = 160,
    this.viewportFraction = .92,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.autoPlayAnimationDuration = const Duration(milliseconds: 800),
    this.showIndicator = true,
    this.indicatorPadding = const EdgeInsets.symmetric(horizontal: 4),
    this.indicatorColor = Colors.white,
    this.indicatorActiveColor = Colors.white,
    this.indicatorSize = 8,
    this.indicatorActiveSize = 20,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    return Stack(
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
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
          items: widget.images.map((url) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AppImage(imageUrl: url, height: widget.height, width: double.infinity, fit: BoxFit.cover),
                ),
              )).toList(),
        ),
        if (widget.showIndicator && widget.images.length > 1)
          Positioned(
            bottom: 8,
            left: 16,
            child: Row(
              children: widget.images.asMap().entries.map((entry) {
                final active = entry.key == _currentIndex;
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: active ? widget.indicatorActiveSize : widget.indicatorSize,
                    height: 6,
                    margin: widget.indicatorPadding,
                    decoration: BoxDecoration(
                      color: active ? widget.indicatorActiveColor : widget.indicatorColor.withOpacity(.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class NetworkBannerCarousel extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool autoPlay;
  const NetworkBannerCarousel({super.key, required this.imageUrls, this.height = 160, this.autoPlay = true});

  @override
  Widget build(BuildContext context) => BannerCarousel(images: imageUrls, height: height, autoPlay: autoPlay);
}
