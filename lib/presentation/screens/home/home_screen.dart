// ... (نفس الاستيرادات)

// ✅ في HomeTab، استبدل _banners بـ:
final List<Map<String, dynamic>> _banners = ImageService.bannerData;

// ✅ استبدل CarouselSlider بـ:
CarouselSlider(
  options: CarouselOptions(
    height: 180,
    autoPlay: true,
    autoPlayInterval: const Duration(seconds: 3),
    autoPlayAnimationDuration: const Duration(milliseconds: 800),
    autoPlayCurve: Curves.fastOutSlowIn,
    enlargeCenterPage: true,
    viewportFraction: 0.92,
    onPageChanged: (index, reason) => setState(() => _currentBanner = index),
  ),
  items: _banners.map((banner) {
    return ImageService.buildBannerCard(banner);
  }).toList(),
),
