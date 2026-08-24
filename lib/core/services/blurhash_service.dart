import 'package:flutter/material.dart';
import 'package:blurhash/blurhash.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BlurHashImage extends StatelessWidget {
  final String imageUrl;
  final String blurHash;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const BlurHashImage({
    super.key,
    required this.imageUrl,
    required this.blurHash,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => BlurHash(
        hash: blurHash,
        imageFit: fit,
        width: width ?? 100,
        height: height ?? 100,
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
