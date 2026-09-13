import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pulse_widget.dart';
import 'spotlight_painter.dart';
import 'tour_step.dart';

/// جولة تعريفية مباشرة فوق الشاشة الحالية باستخدام OverlayEntry.
class GuidedTour extends StatefulWidget {
  const GuidedTour({
    super.key,
    required this.child,
    required this.steps,
    this.onComplete,
    this.highlightColor = Colors.blue,
  });

  final Widget child;
  final List<TourStep> steps;
  final VoidCallback? onComplete;
  final Color highlightColor;

  @override
  State<GuidedTour> createState() => _GuidedTourState();
}

class _GuidedTourState extends State<GuidedTour> {
  static const _storageKey = 'has_seen_home_tour';
  static const _bubbleWidth = 300.0;
  static const _spacing = 24.0;

  OverlayEntry? _overlay;
  int _index = 0;
  bool _showing = false;
  bool _disposed = false;
  Timer? _startupTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startupTimer = Timer(const Duration(milliseconds: 800), _tryShow);
    });
  }

  Future<void> _tryShow() async {
    if (_disposed || !mounted || widget.steps.isEmpty || _showing) return;
    final prefs = await SharedPreferences.getInstance();
    if (_disposed || !mounted || prefs.getBool(_storageKey) == true) return;
    _index = 0;
    await _prepareTarget();
    if (_disposed || !mounted) return;
    _showing = true;
    _insertOverlay();
  }

  Future<void> _prepareTarget() async {
    final step = widget.steps[_index];
    final context = step.key.currentContext;
    if (context == null) return;
    try {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        alignment: .15,
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
    } catch (_) {
      // الهدف قد يكون في عنصر غير قابل للتمرير؛ لا نوقف الجولة بسببه.
    }
  }

  void _insertOverlay() {
    _overlay?.remove();
    _overlay = OverlayEntry(builder: (_) => _buildOverlay());
    final overlay = Overlay.of(context, rootOverlay: true);
    overlay.insert(_overlay!);
  }

  Rect? _targetRect() {
    final context = widget.steps[_index].key.currentContext;
    final renderObject = context?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final offset = renderObject.localToGlobal(Offset.zero);
    return offset & renderObject.size;
  }

  Future<void> _next() async {
    if (_index >= widget.steps.length - 1) {
      await _finish();
      return;
    }
    _index++;
    await _prepareTarget();
    if (!_disposed && mounted) _overlay?.markNeedsBuild();
  }

  Future<void> _previous() async {
    if (_index == 0) return;
    _index--;
    await _prepareTarget();
    if (!_disposed && mounted) _overlay?.markNeedsBuild();
  }

  Future<void> _skip() async {
    await _persistAndClose();
  }

  Future<void> _finish() async {
    await _persistAndClose();
    widget.onComplete?.call();
  }

  Future<void> _persistAndClose() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, true);
    if (_disposed) return;
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _showing = false);
  }

  @override
  void dispose() {
    _disposed = true;
    _startupTimer?.cancel();
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Widget _buildOverlay() {
    final size = MediaQuery.sizeOf(context);
    final step = widget.steps[_index];
    final rawTarget = _targetRect();
    final target = rawTarget == null
        ? Rect.fromCenter(center: size.center(Offset.zero), width: 1, height: 1)
        : rawTarget.inflate(12);
    final bubbleRect = _bubbleRect(step.position, target, size);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _next,
                child: CustomPaint(
                  painter: SpotlightPainter(
                    targetRect: target,
                    highlightColor: widget.highlightColor,
                  ),
                ),
              ),
            ),
            if (step.showPulse && rawTarget != null)
              Positioned(
                left: target.left,
                top: target.top,
                child: SizedBox(
                  width: target.width,
                  height: target.height,
                  child: PulseWidget(
                    size: Size(target.width, target.height),
                    color: widget.highlightColor,
                  ),
                ),
              ),
            Positioned.fromRect(
              rect: bubbleRect,
              child: _TooltipBubble(
                step: step,
                index: _index,
                total: widget.steps.length,
                onSkip: _skip,
                onPrevious: _previous,
                onNext: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Rect _bubbleRect(TooltipPosition position, Rect target, Size screen) {
    const height = 228.0;
    final maxLeft = screen.width - _bubbleWidth - 16;
    final maxTop = screen.height - height - 16;
    double left = (screen.width - _bubbleWidth) / 2;
    double top = (screen.height - height) / 2;

    switch (position) {
      case TooltipPosition.bottom:
        left = target.center.dx - _bubbleWidth / 2;
        top = target.bottom + _spacing;
        break;
      case TooltipPosition.top:
        left = target.center.dx - _bubbleWidth / 2;
        top = target.top - height - _spacing;
        break;
      case TooltipPosition.left:
        left = target.left - _bubbleWidth - _spacing;
        top = target.center.dy - height / 2;
        break;
      case TooltipPosition.right:
        left = target.right + _spacing;
        top = target.center.dy - height / 2;
        break;
      case TooltipPosition.center:
        break;
    }

    left = left.clamp(16.0, maxLeft < 16 ? 16.0 : maxLeft);
    top = top.clamp(16.0, maxTop < 16 ? 16.0 : maxTop);
    return Rect.fromLTWH(left, top, _bubbleWidth, height);
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    required this.step,
    required this.index,
    required this.total,
    required this.onSkip,
    required this.onPrevious,
    required this.onNext,
  });

  final TourStep step;
  final int index;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 300,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 24,
              offset: const Offset(0, 8),
              color: Colors.black.withOpacity(.25),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${step.emoji}  ${step.title}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              step.description,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                TextButton(onPressed: onSkip, child: const Text('تخطي الجولة')),
                const Spacer(),
                Text(
                  '${index + 1}/$total',
                  style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black54),
                ),
              ],
            ),
            Row(
              children: [
                if (index > 0)
                  OutlinedButton.icon(
                    onPressed: onPrevious,
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('السابق'),
                  ),
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNext,
                    icon: Icon(index == total - 1 ? Icons.check_rounded : Icons.arrow_back_rounded, size: 18),
                    label: Text(index == total - 1 ? 'تم' : 'التالي'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
