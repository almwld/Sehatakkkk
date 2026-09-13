import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'tour_manager.dart';

/// خطوة جولة تعتمد على نص ظاهر فعلياً في الشاشة.
class ScreenTourStep {
  const ScreenTourStep({
    required this.targetText,
    required this.title,
    required this.description,
    required this.accentColor,
    this.emoji = '✨',
    this.position = ScreenTooltipPosition.bottom,
    this.actionHint,
  });

  final String targetText;
  final String title;
  final String description;
  final Color accentColor;
  final String emoji;
  final ScreenTooltipPosition position;
  final String? actionHint;
}

enum ScreenTooltipPosition { top, bottom, left, right, center }

/// جولة مباشرة فوق الشاشة الحالية: OverlayEntry + RenderBox، بلا Navigator.
class ScreenGuidedTour extends StatefulWidget {
  const ScreenGuidedTour({
    super.key,
    required this.child,
    required this.steps,
    required this.tourKey,
    this.startDelay = const Duration(milliseconds: 800),
  });

  final Widget child;
  final List<ScreenTourStep> steps;
  final String tourKey;
  final Duration startDelay;

  @override
  State<ScreenGuidedTour> createState() => _ScreenGuidedTourState();
}

class _ScreenGuidedTourState extends State<ScreenGuidedTour>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlay;
  Timer? _timer;
  late final AnimationController _pulse;
  int _index = 0;
  bool _busy = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _timer = Timer(widget.startDelay, _start);
    });
  }

  Future<void> _start() async {
    if (_disposed || !mounted || widget.steps.isEmpty) return;
    if (await TourManager.hasSeen(widget.tourKey)) return;
    await _prepare();
    if (_disposed || !mounted) return;
    _insert();
  }

  Element? _findTarget(String text) {
    Element? result;
    void visit(Element element) {
      if (result != null) return;
      final widget = element.widget;
      if (widget is Text && widget.data != null && widget.data!.contains(text)) {
        result = element;
        return;
      }
      element.visitChildren(visit);
    }
    context.visitChildElements(visit);
    return result;
  }

  Future<void> _prepare() async {
    for (var attempt = 0; attempt < 24; attempt++) {
      if (_disposed || !mounted) return;
      final element = _findTarget(widget.steps[_index].targetText);
      if (element != null) {
        try {
          await Scrollable.ensureVisible(
            element,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            alignment: .18,
          );
        } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 90));
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  Rect? _targetRect() {
    final element = _findTarget(widget.steps[_index].targetText);
    final render = element?.renderObject;
    if (render is! RenderBox || !render.hasSize) return null;
    return render.localToGlobal(Offset.zero) & render.size;
  }

  void _insert() {
    _overlay?.remove();
    _overlay = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  Future<void> _move(int delta) async {
    if (_busy) return;
    final next = _index + delta;
    if (next < 0) return;
    if (next >= widget.steps.length) {
      await _close();
      return;
    }
    _busy = true;
    _index = next;
    await _prepare();
    if (!_disposed) _overlay?.markNeedsBuild();
    _busy = false;
  }

  Future<void> _close() async {
    await TourManager.markAsSeen(widget.tourKey);
    if (_disposed) return;
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _overlay?.remove();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Widget _buildOverlay() {
    final size = MediaQuery.sizeOf(context);
    final step = widget.steps[_index];
    final raw = _targetRect();
    final target = (raw ?? Rect.fromCenter(center: size.center(Offset.zero), width: 2, height: 2)).inflate(12);
    final bubble = _bubble(step.position, target, size);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _move(1),
                child: CustomPaint(painter: _SpotlightPainter(target, step.accentColor)),
              ),
            ),
            if (raw != null)
              Positioned.fromRect(
                rect: target,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, __) => CustomPaint(
                      painter: _PulsePainter(step.accentColor, _pulse.value),
                    ),
                  ),
                ),
              ),
            Positioned.fromRect(
              rect: bubble,
              child: _TourBubble(
                step: step,
                index: _index,
                total: widget.steps.length,
                onSkip: _close,
                onPrevious: () => _move(-1),
                onNext: () => _move(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Rect _bubble(ScreenTooltipPosition position, Rect target, Size size) {
    const height = 280.0;
    final width = size.width < 352 ? size.width - 32 : 320.0;
    double left = (size.width - width) / 2;
    double top = (size.height - height) / 2;
    switch (position) {
      case ScreenTooltipPosition.bottom:
        left = target.center.dx - width / 2;
        top = target.bottom + 24;
        break;
      case ScreenTooltipPosition.top:
        left = target.center.dx - width / 2;
        top = target.top - height - 24;
        break;
      case ScreenTooltipPosition.left:
        left = target.left - width - 24;
        top = target.center.dy - height / 2;
        break;
      case ScreenTooltipPosition.right:
        left = target.right + 24;
        top = target.center.dy - height / 2;
        break;
      case ScreenTooltipPosition.center:
        break;
    }
    final maxLeft = (size.width - width - 16).clamp(16.0, double.infinity).toDouble();
    final maxTop = (size.height - height - 16).clamp(16.0, double.infinity).toDouble();
    left = left.clamp(16.0, maxLeft).toDouble();
    top = top.clamp(16.0, maxTop).toDouble();
    return Rect.fromLTWH(left, top, width, height);
  }
}

class _TourBubble extends StatelessWidget {
  const _TourBubble({required this.step, required this.index, required this.total, required this.onSkip, required this.onPrevious, required this.onNext});
  final ScreenTourStep step;
  final int index;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xCC182329) : const Color(0xD9FFFFFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF172126);
    final bodyColor = isDark ? Colors.white70 : const Color(0xFF405057);
    final borderColor = step.accentColor.withOpacity(isDark ? .48 : .34);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1.1),
              boxShadow: [
                BoxShadow(
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  color: Colors.black.withOpacity(isDark ? .42 : .20),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: step.accentColor.withOpacity(.18), shape: BoxShape.circle, border: Border.all(color: step.accentColor.withOpacity(.24))), child: Text(step.emoji, style: const TextStyle(fontSize: 22))),
                  const SizedBox(width: 10),
                  Expanded(child: Text(step.title, style: TextStyle(color: titleColor, fontSize: 18, fontWeight: FontWeight.w900))),
                ]),
                const SizedBox(height: 12),
                Text(step.description, textAlign: TextAlign.right, style: TextStyle(color: bodyColor, fontSize: 14, height: 1.6)),
                if (step.actionHint != null) ...[
                  const SizedBox(height: 10),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: step.accentColor.withOpacity(.10), borderRadius: BorderRadius.circular(10)), child: Text(step.actionHint!, textAlign: TextAlign.right, style: TextStyle(color: step.accentColor, fontSize: 12, fontWeight: FontWeight.w700))),
                ],
                const Spacer(),
                Row(children: [TextButton(onPressed: onSkip, style: TextButton.styleFrom(foregroundColor: bodyColor), child: const Text('تخطي')), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(isDark ? .08 : .45), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(.16))), child: Text('${index + 1}/$total', style: TextStyle(color: bodyColor, fontWeight: FontWeight.w800)))]),
                Row(children: [
                  if (index > 0) ...[
                    OutlinedButton(onPressed: onPrevious, style: OutlinedButton.styleFrom(foregroundColor: step.accentColor, side: BorderSide(color: step.accentColor.withOpacity(.40))), child: const Text('السابق')),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: FilledButton(onPressed: onNext, style: FilledButton.styleFrom(backgroundColor: step.accentColor, foregroundColor: Colors.white), child: Text(index == total - 1 ? 'تم' : 'التالي'))),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter(this.rect, this.color);
  final Rect rect;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final hole = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    canvas.drawPath(Path.combine(PathOperation.difference, full, hole), Paint()..color = Colors.black.withOpacity(.78));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 3);
  }
  @override
  bool shouldRepaint(covariant _SpotlightPainter old) => old.rect != rect || old.color != color;
}

class _PulsePainter extends CustomPainter {
  _PulsePainter(this.color, this.value);
  final Color color;
  final double value;
  @override
  void paint(Canvas canvas, Size size) {
    final t = (value < .5 ? value * 2 : (1 - value) * 2).clamp(0.0, 1.0);
    final paint = Paint()..color = color.withOpacity(.70 * (1 - t))..style = PaintingStyle.stroke..strokeWidth = 4 + t * 3;
    canvas.drawRRect(RRect.fromRectAndRadius((Offset.zero & size).inflate(t * 10), const Radius.circular(16)), paint);
  }
  @override
  bool shouldRepaint(covariant _PulsePainter old) => old.value != value || old.color != color;
}
