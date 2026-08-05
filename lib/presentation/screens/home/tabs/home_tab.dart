// ... (الكود الكامل مع التعديلات)

// ============================================================
// 🎨 دالة مساعدة لعرض الأيقونات (SVG أو صور عادية)
// ============================================================
Widget _buildServiceIcon(String iconPath, Color color, {double size = 32}) {
  // ✅ إذا كانت أيقونة SVG
  if (iconPath.endsWith('.svg')) {
    return SvgPicture.asset(
      iconPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      placeholderBuilder: (_) => Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: Icon(Icons.circle, color: color, size: size * 0.6),
      ),
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: Icon(Icons.broken_image, color: Colors.red, size: size * 0.6),
        );
      },
    );
  }
  
  // ✅ إذا كانت صورة عادية (PNG/JPG)
  return AppImage(
    url: iconPath,
    width: size,
    height: size,
  );
}

// ============================================================
// 🚀 الخدمات السريعة
// ============================================================
Widget _buildQuickServicesRow() {
  return SizedBox(
    height: 90,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _quickServices.length,
      itemBuilder: (context, index) {
        final service = _quickServices[index];
        final color = service['color'] as Color;
        final iconPath = service['icon'] as String;
        
        return GestureDetector(
          onTap: () => _goTo(context, service['screen'] as Widget),
          child: Container(
            width: 70,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.2),
                    ),
                  ),
                  child: _buildServiceIcon(iconPath, color),
                ),
                const SizedBox(height: 6),
                Text(
                  service['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
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
