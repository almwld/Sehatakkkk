import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatelessWidget {
  final String path;
  final double width;
  final double height;
  final bool repeat;

  const LottieAnimation({
    super.key,
    required this.path,
    this.width = 200,
    this.height = 200,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      path,
      width: width,
      height: height,
      repeat: repeat,
      fit: BoxFit.contain,
    );
  }
}

// ✅ Animations جاهزة للاستخدام
class SuccessAnimation extends StatelessWidget {
  const SuccessAnimation({super.key, this.size = 200});
  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      path: 'assets/animations/success.json',
      width: size,
      height: size,
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key, this.size = 100});
  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      path: 'assets/animations/loading.json',
      width: size,
      height: size,
    );
  }
}

class EmptyAnimation extends StatelessWidget {
  const EmptyAnimation({super.key, this.size = 200});
  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      path: 'assets/animations/empty.json',
      width: size,
      height: size,
    );
  }
}

class ErrorAnimation extends StatelessWidget {
  const ErrorAnimation({super.key, this.size = 200});
  final double size;

  @override
  Widget build(BuildContext context) {
    return LottieAnimation(
      path: 'assets/animations/error.json',
      width: size,
      height: size,
    );
  }
}
