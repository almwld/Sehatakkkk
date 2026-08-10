import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final IconData icon;

  const ImagePlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.icon = Icons.image,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: width * 0.4,
      ),
    );
  }
}
