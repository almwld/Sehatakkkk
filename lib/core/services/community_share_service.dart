import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class CommunityShareService {
  CommunityShareService._();

  static Future<void> sharePost(BuildContext context, CommunityPostModel post) async {
    final key = GlobalKey();
    final dialogFuture = showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: key,
            child: SizedBox(width: 360, child: _ShareCard(post: post)),
          ),
        ),
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 450));
    final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      await dialogFuture;
      return;
    }

    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    await dialogFuture;
    if (data == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/sehatak_post_${post.id.isEmpty ? DateTime.now().millisecondsSinceEpoch : post.id}.png');
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: 'منشور من منصة صحتك — الرعاية الصحية الرقمية',
      subject: 'منشور من صحتك',
    );
  }
}

class _ShareCard extends StatelessWidget {
  final CommunityPostModel post;
  const _ShareCard({required this.post});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [BoxShadow(blurRadius: 24, offset: Offset(0, 12), color: Color(0x33000000))],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                color: AppColors.primary,
                child: const Row(children: [
                  _BrandMark(),
                  SizedBox(width: 10),
                  Text('صحتك', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                  Spacer(),
                  Text('منصة الرعاية الصحية', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ]),
              ),
              if ((post.images?.isNotEmpty ?? false) || (post.imageUrl?.isNotEmpty ?? false))
                SizedBox(
                  height: 220,
                  child: AppImage(
                    imageUrl: (post.images?.isNotEmpty ?? false) ? post.images!.first : post.imageUrl!,
                    fit: BoxFit.cover,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(post.userName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(post.title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, height: 1.35)),
                  if ((post.content ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(post.content!, maxLines: 5, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.55)),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    Text('♥ ${post.likes}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    const SizedBox(width: 12),
                    Text('تعليقات ${post.comments}', style: const TextStyle(fontSize: 11, color: Colors.black54)),
                    const Spacer(),
                    const Text('sehatak', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 11)),
                  ]),
                ]),
              ),
            ],
          ),
        ),
      );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: const Text('ص', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 17)),
      );
}
