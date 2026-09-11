import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlurHashImage extends StatelessWidget {
  final String imageUrl;
  final String blurHash;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const BlurHashImage({super.key, required this.imageUrl, required this.blurHash, this.width, this.height, this.fit = BoxFit.cover, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => SizedBox(
        width: width,
        height: height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
    return borderRadius == null ? image : ClipRRect(borderRadius: borderRadius!, child: image);
  }
}
