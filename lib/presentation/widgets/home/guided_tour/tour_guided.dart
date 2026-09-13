import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'tour_manager.dart';
import 'tour_models.dart';
import 'tour_pulse.dart';
import 'tour_spotlight.dart';

/// جولة تعريفية مباشرة فوق الشاشة الحالية.
/// لا تنشئ شاشة جديدة ولا تستخدم Navigator؛ كل ما يظهر هو OverlayEntry.
class GuidedTour extends StatefulWidget {
  const GuidedTour({
    super.key,
    required this.child,
    required this.steps,
    this.tourKey = TourManager.homeKey,
    this.onComplete,
    this.startDelay = const Duration(milliseconds: 800),
  });

  final Widget child;
  final List<TourStep> steps;
  final String tourKey;
  final VoidCallback? onComplete;
  final Duration startDelay;

  @override
  State<GuidedTour> createState() => _GuidedTourState();
}

class _GuidedTourState extends State<GuidedTour> with SingleTickerProviderStateMixin {
  static const double _spacing = 24;
  static const double _targetPadding = 12;
  static const double _bubbleHeight = 280;

  OverlayEntry? _overlay;
  Timer? _startTimer;
  late final AnimationController _pulseController;
  int _index = 0;
  bool _showing = false;
  bool _disposed = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer = Timer(widget.startDelay, _tryShow);
    });
  }

  Future<void> _tryShow() async {
    if (_disposed || !mounted || _showing || widget.steps.isEmpty) return;
    if (await TourManager.hasSeen(widget.tourKey)) return;
    _index = 0;
    await _prepareTarget();
    if (_disposed || !mounted) return;
    _showing = true;
    _insertOverlay();
  }

  Future<void> _prepareTarget() async {
    for (var attempt = 0; attempt < 30; attempt++) {
      if (_disposed || !mounted) return;
      final targetContext = widget.steps[_index].key.currentContext;
      if (targetContext != null) {
        try {
          await Scrollable.ensureVisible(targetContext, duration: const Duration(milliseconds: 350), curve: Curves.easeOut, alignment: .15);
        } catch (_) {}
        await Future<void>.delayed(const Duration(milliseconds: 90));
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  void _insertOverlay() {
    _overlay?.remove();
    _overlay = OverlayEntry(builder: (_) => _buildOverlay());
    Overlay.of(context, rootOverlay: true).insert(_overlay!);
  }

  Rect? _targetRect() {
    final targetContext = widget.steps[_index].key.currentContext;
    final renderObject = targetContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    return renderObject.localToGlobal(Offset.zero) & renderObject.size;
  }

  Future<void> _next() async {
    if (_busy) return;
    if (_index >= widget.steps.length - 1) {
      await _finish();
      return;
    }
    _busy = true;
    _index++;
    await _prepareTarget();
    if (!_disposed && mounted) _overlay?.markNeedsBuild();
    _busy = false;
  }

  Future<void> _previous() async {
    if (_busy || _index == 0) return;
    _busy = true;
    _index--;
    await _prepareTarget();
    if (!_disposed && mounted) _overlay?.markNeedsBuild();
    _busy = false;
  }

  Future<void> _skip() async {
    await TourManager.markAsSkipped(widget.tourKey);
    await _close();
  }

  Future<void> _finish() async {
    await TourManager.markAsSeen(widget.tourKey);
    await _close(callComplete: true);
  }

  Future<void> _close({bool callComplete = false}) async {
    if (_disposed) return;
    _overlay?.remove();
    _overlay = null;
    _showing = false;
    if (mounted) setState(() {});
    if (callComplete) widget.onComplete?.call();
  }

  @override
  void dispose() {
    _disposed = true;
    _startTimer?.cancel();
    _overlay?.remove();
    _overlay = null;
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Widget _buildOverlay() {
    final screen = MediaQuery.sizeOf(context);
    final step = widget.steps[_index];
    final rawTarget = _targetRect();
    final target = (rawTarget ?? Rect.fromCenter(center: screen.center(Offset.zero), width: 1, height: 1)).inflate(_targetPadding);
    final bubble = _bubbleRect(step.position, target, screen);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(children: [
          Positioned.fill(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _next, child: CustomPaint(painter: SpotlightPainter(targetRect: target, highlightColor: step.accentColor)))),
          if (step.showPulse && rawTarget != null)
            Positioned(left: target.left, top: target.top, width: target.width, height: target.height, child: PulseWidget(controller: _pulseController, color: step.accentColor, size: Size(target.width, target.height))),
          Positioned.fromRect(rect: bubble, child: _TooltipBubble(step: step, index: _index, total: widget.steps.length, onSkip: _skip, onPrevious: _previous, onNext: _next)),
        ]),
      ),
    );
  }

  Rect _bubbleRect(TooltipPosition position, Rect target, Size screen) {
    final width = screen.width < 352 ? screen.width - 32 : 320.0;
    const height = _bubbleHeight;
    final maxLeft = screen.width - width - 16;
    final maxTop = screen.height - height - 16;
    double left = (screen.width - width) / 2;
    double top = (screen.height - height) / 2;
    switch (position) {
      case TooltipPosition.bottom:
        left = target.center.dx - width / 2;
        top = target.bottom + _spacing;
        break;
      case TooltipPosition.top:
        left = target.center.dx - width / 2;
        top = target.top - height - _spacing;
        break;
      case TooltipPosition.left:
        left = target.left - width - _spacing;
        top = target.center.dy - height / 2;
        break;
      case TooltipPosition.right:
        left = target.right + _spacing;
        top = target.center.dy - height / 2;
        break;
      case TooltipPosition.center:
        break;
    }
    left = left.clamp(16.0, maxLeft < 16 ? 16.0 : maxLeft).toDouble();
    top = top.clamp(16.0, maxTop < 16 ? 16.0 : maxTop).toDouble();
    return Rect.fromLTWH(left, top, width, height);
  }
}

/// فقاعة الجولة بتصميم زجاجي شفاف مع ضبابية حقيقية للخلفية.
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({required this.step, required this.index, required this.total, required this.onSkip, required this.onPrevious, required this.onNext});
  final TourStep step;
  final int index;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF15242A) : const Color(0xFFF7FCFB);
    final foreground = isDark ? Colors.white : const Color(0xFF172126);
    final secondary = isDark ? Colors.white.withOpacity(.78) : const Color(0xFF45565C);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            decoration: BoxDecoration(
              color: baseColor.withOpacity(isDark ? .72 : .68),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(isDark ? .20 : .58), width: 1),
              boxShadow: [
                BoxShadow(blurRadius: 24, spreadRadius: 1, offset: const Offset(0, 8), color: Colors.black.withOpacity(isDark ? .38 : .18)),
                BoxShadow(blurRadius: 8, spreadRadius: -2, color: step.accentColor.withOpacity(.10)),
              ],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: step.accentColor.withOpacity(.18), shape: BoxShape.circle, border: Border.all(color: step.accentColor.withOpacity(.28))), child: Text(step.emoji, style: const TextStyle(fontSize: 22))),
                const SizedBox(width: 10),
                Expanded(child: Text(step.title, style: TextStyle(color: foreground, fontSize: 18, fontWeight: FontWeight.w900))),
              ]),
              const SizedBox(height: 12),
              Text(step.description, textAlign: TextAlign.right, style: TextStyle(color: secondary, fontSize: 14, height: 1.6)),
              if (step.actionHint != null) ...[
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: step.accentColor.withOpacity(.10), borderRadius: BorderRadius.circular(10), border: Border.all(color: step.accentColor.withOpacity(.16))), child: Text(step.actionHint!, textAlign: TextAlign.right, style: TextStyle(color: step.accentColor, fontSize: 12, fontWeight: FontWeight.w700))),
              ],
              const Spacer(),
              Row(children: [TextButton(onPressed: onSkip, style: TextButton.styleFrom(foregroundColor: secondary), child: const Text('تخطي')), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(isDark ? .08 : .48), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(.14))), child: Text('${index + 1}/$total', style: TextStyle(color: foreground.withOpacity(.82), fontWeight: FontWeight.w800)))]),
              const SizedBox(height: 6),
              Row(children: [
                if (index > 0) ...[
                  OutlinedButton.icon(onPressed: onPrevious, icon: const Icon(Icons.arrow_forward_rounded, size: 18), label: const Text('السابق'), style: OutlinedButton.styleFrom(foregroundColor: step.accentColor, side: BorderSide(color: step.accentColor.withOpacity(.38))),),
                  const SizedBox(width: 8),
                ],
                Expanded(child: FilledButton.icon(onPressed: onNext, style: FilledButton.styleFrom(backgroundColor: step.accentColor.withOpacity(.92), foregroundColor: Colors.white), icon: Icon(index == total - 1 ? Icons.check_rounded : Icons.arrow_back_rounded, size: 18), label: Text(index == total - 1 ? 'تم' : 'التالي'))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
