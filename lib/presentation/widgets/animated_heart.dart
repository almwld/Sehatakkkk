// ============================================================
// 📁 lib/presentation/widgets/animated_heart.dart
// ❤️ قلب متحرك - بديل لحزمة animated_heart
// ============================================================

import 'package:flutter/material.dart';

class AnimatedHeart extends StatefulWidget {
  final double size;
  final Color color;
  final bool animated;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const AnimatedHeart({
    super.key,
    this.size = 80,
    this.color = Colors.red,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onTap,
  });

  @override
  State<AnimatedHeart> createState() => _AnimatedHeartState();
}

class _AnimatedHeartState extends State<AnimatedHeart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    // ✅ التحكم الرئيسي
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // ✅ حركة التكبير والتصغير
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // ✅ نبضات إضافية
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // ✅ دوران خفيف
    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // ✅ تغيير اللون
    _colorAnimation = ColorTween(
      begin: widget.color,
      end: widget.color.withOpacity(0.7),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animated) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.animated && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animated && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
    
    if (widget.color != oldWidget.color) {
      _colorAnimation = ColorTween(
        begin: widget.color,
        end: widget.color.withOpacity(0.7),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.animated ? _scaleAnimation.value : 1.0,
            child: Transform.rotate(
              angle: widget.animated ? _rotationAnimation.value : 0.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✅ الظل
                  if (widget.animated)
                    Container(
                      width: widget.size * 1.2,
                      height: widget.size * 1.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color.withOpacity(0.1 * _pulseAnimation.value),
                      ),
                    ),
                  
                  // ✅ القلب الرئيسي
                  Icon(
                    Icons.favorite,
                    color: widget.animated ? _colorAnimation.value : widget.color,
                    size: widget.size,
                  ),
                  
                  // ✅ نبضات إضافية (دوائر متوسعة)
                  if (widget.animated && _pulseAnimation.value > 0.5)
                    Container(
                      width: widget.size * (1.0 + _pulseAnimation.value * 0.3),
                      height: widget.size * (1.0 + _pulseAnimation.value * 0.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.color.withOpacity(0.2 * (1 - _pulseAnimation.value)),
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// 📦 ويدجت قلب صغير سريع الاستخدام
// ============================================================
class SmallAnimatedHeart extends StatelessWidget {
  final Color color;
  final bool animated;
  final double size;

  const SmallAnimatedHeart({
    super.key,
    this.color = Colors.red,
    this.animated = true,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedHeart(
      size: size,
      color: color,
      animated: animated,
      animationDuration: const Duration(milliseconds: 400),
    );
  }
}

// ============================================================
// ❤️ ويدجت قلب مع عداد
// ============================================================
class HeartWithCount extends StatelessWidget {
  final int count;
  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  const HeartWithCount({
    super.key,
    required this.count,
    required this.isLiked,
    required this.onTap,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedHeart(
            size: size,
            color: isLiked ? Colors.red : Colors.grey,
            animated: isLiked,
            animationDuration: const Duration(milliseconds: 300),
          ),
          const SizedBox(width: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isLiked ? Colors.red : Colors.grey,
            ),
            child: Text('$count'),
          ),
        ],
      ),
    );
  }
}
