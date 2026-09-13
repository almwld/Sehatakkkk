import 'package:flutter/material.dart';

/// وميض مزدوج حول العنصر المستهدف في الجولة التعريفية.
class PulseWidget extends StatefulWidget {
  const PulseWidget({
    super.key,
    required this.size,
    this.color = Colors.blue,
  });

  final Size size;
  final Color color;

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final primary = Curves.easeOut.transform(_controller.value);
          final secondary = Curves.easeOut.transform(
            ((_controller.value + .28) % 1.0),
          );
          return Stack(
            alignment: Alignment.center,
            children: [
              _ring(primary, opacity: .60, scale: 1.0 + primary * .40),
              _ring(secondary, opacity: .42, scale: 1.0 + secondary * .40),
            ],
          );
        },
      ),
    );
  }

  Widget _ring(double progress, {required double opacity, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity * (1.0 - progress),
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color, width: 3),
          ),
        ),
      ),
    );
  }
}
