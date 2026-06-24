import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';

class ServicesCarousel extends StatefulWidget {
  const ServicesCarousel({super.key});
  @override
  State<ServicesCarousel> createState() => _ServicesCarouselState();
}

class _ServicesCarouselState extends State<ServicesCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = [
    {'title': 'استشارات طبية فورية', 'subtitle': 'تواصل مع أفضل الأطباء', 'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600', 'icon': Icons.videocam, 'color': const Color(0xFF3B82F6)},
    {'title': 'صيدلية وتوصيل أدوية', 'subtitle': 'اطلب أدويتك واصلك لباب بيتك', 'image': 'https://images.unsplash.com/photo-1585435557343-3b092031a831?w=600', 'icon': Icons.local_pharmacy, 'color': const Color(0xFF10B981)},
    {'title': 'حجز المواعيد', 'subtitle': 'احجز موعدك بضغطة زر', 'image': 'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=600', 'icon': Icons.calendar_month, 'color': const Color(0xFF8B5CF6)},
    {'title': 'تحاليل مخبرية', 'subtitle': 'نتائج دقيقة وسريعة', 'image': 'https://images.unsplash.com/photo-1581595220892-b0739db3ba8c?w=600', 'icon': Icons.science, 'color': const Color(0xFFF59E0B)},
    {'title': 'سجل صحي إلكتروني', 'subtitle': 'بياناتك الطبية في مكان آمن', 'image': 'https://images.unsplash.com/photo-1579154204601-01588f351e67?w=600', 'icon': Icons.folder, 'color': const Color(0xFFEC4899)},
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () => _autoSlide());
  }

  void _autoSlide() {
    if (!mounted) return;
    _currentPage = _currentPage < _slides.length - 1 ? _currentPage + 1 : 0;
    _pageController.animateToPage(_currentPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    Future.delayed(const Duration(seconds: 3), () => _autoSlide());
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(height: 180, child: PageView.builder(
        controller: _pageController, itemCount: _slides.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) {
          final s = _slides[i];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)]),
            child: Stack(children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: CachedNetworkImage(imageUrl: s['image'], fit: BoxFit.cover, height: 180, width: double.infinity, placeholder: (_, __) => Container(color: Colors.grey.shade200))),
              Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)]))),
              Positioned(bottom: 16, left: 16, right: 16, child: Row(children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: s['color'], borderRadius: BorderRadius.circular(10)), child: Icon(s['icon'], color: Colors.white, size: 22)),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s['title'], style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), Text(s['subtitle'], style: const TextStyle(color: Colors.white70, fontSize: 13))])),
              ])),
            ]),
          );
        },
      )),
      const SizedBox(height: 10),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_slides.length, (i) => AnimatedContainer(duration: const Duration(milliseconds: 300), margin: const EdgeInsets.symmetric(horizontal: 4), width: _currentPage == i ? 24 : 8, height: 8, decoration: BoxDecoration(color: _currentPage == i ? AppColors.primary : AppColors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(4))))),
      const SizedBox(height: 14),
    ]);
  }
}
