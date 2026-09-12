import 'package:flutter/material.dart';

/// Unified upload state indicator for chat media.
enum UploadStatus { uploading, delivered, pending, failed }

class MediaUploadStatusWidget extends StatelessWidget {
  const MediaUploadStatusWidget({
    super.key,
    required this.status,
    this.progress = 0.0,
    this.onRetry,
  });

  final UploadStatus status;
  final double progress;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(end: 10, bottom: 10, child: _indicator());
  }

  Widget _indicator() {
    switch (status) {
      case UploadStatus.uploading:
        final double safeProgress = progress.clamp(0.0, 1.0).toDouble();
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(color: Colors.black.withOpacity(.62), shape: BoxShape.circle, border: Border.all(color: Colors.white24)),
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(width: 34, height: 34, child: CircularProgressIndicator(value: safeProgress, strokeWidth: 3, backgroundColor: Colors.white24, valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
            Text('${(safeProgress * 100).round()}%', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ]),
        );
      case UploadStatus.delivered:
        return _circle(const Color(0xFF2EAD63), Icons.check);
      case UploadStatus.pending:
        return _circle(const Color(0xFFF39C12), Icons.schedule);
      case UploadStatus.failed:
        return GestureDetector(onTap: onRetry, child: _circle(const Color(0xFFE53935), Icons.refresh));
    }
  }

  Widget _circle(Color color, IconData icon) => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]),
    child: Icon(icon, color: Colors.white, size: 17),
  );
}
