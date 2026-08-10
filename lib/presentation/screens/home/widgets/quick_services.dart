import 'package:flutter/material.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class QuickServiceItem {
  final String icon;
  final String label;
  final Color color;
  final Widget screen;
  final String? badge; // ✅ إضافة شارة (مثل "جديد"، "خصم")

  QuickServiceItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.screen,
    this.badge,
  });
}

class QuickServices extends StatelessWidget {
  final List<QuickServiceItem> services;
  final double height;
  final double itemWidth;
  final double iconSize;
  final EdgeInsets padding;
  final bool showLabels;
  final bool isScrollable;

  const QuickServices({
    super.key,
    required this.services,
    this.height = 90,
    this.itemWidth = 70,
    this.iconSize = 32,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.showLabels = true,
    this.isScrollable = true,
  });

  @override
  Widget build(BuildContext context) const {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (!isScrollable) {
      // ✅ عرض شبكي (Grid) غير قابل للتمرير
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return _buildServiceItem(context, services[index], isDark);
        },
      );
    }

    // ✅ عرض أفقي قابل للتمرير
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        padding: padding,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final service = services[index];
          return _buildServiceItem(context, service, isDark);
        },
      ),
    );
  }

  Widget _buildServiceItem(BuildContext context, QuickServiceItem service, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => service.screen),
      ),
      child: Container(
        width: itemWidth,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: service.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: service.color.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: service.color.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AppImage(
                    imageUrl: service.icon,
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                ),
                // ✅ شارة
                if (service.badge != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (showLabels) ...[
              const SizedBox(height: 6),
              Text(
                service.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ✅ QuickServices مع تحميل الشبكة (NetworkQuickServices)
class NetworkQuickServices extends StatelessWidget {
  final List<QuickServiceItem> services;

  const NetworkQuickServices({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) const {
    return QuickServices(
      services: services,
      height: 90,
      itemWidth: 70,
      iconSize: 32,
    );
  }
}

// ✅ QuickServices مع عرض شبكي (GridQuickServices)
class GridQuickServices extends StatelessWidget {
  final List<QuickServiceItem> services;
  final int crossAxisCount;

  const GridQuickServices({
    super.key,
    required this.services,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) const {
    return QuickServices(
      services: services,
      height: 0,
      itemWidth: 0,
      iconSize: 32,
      isScrollable: false,
    );
  }
}

// ✅ QuickServices مع تحريك (AnimatedQuickServices)
class AnimatedQuickServices extends StatelessWidget {
  final List<QuickServiceItem> services;

  const AnimatedQuickServices({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) const {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: QuickServices(services: services),
    );
  }
}
