// ============================================================
// 📁 lib/presentation/widgets/educational/camera_tutorial_overlay.dart
// 📷 تراكب إرشادات الكاميرا المتحركة
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CameraTutorialOverlay extends StatefulWidget {
  final VoidCallback onDismiss;
  final bool isMeasuring;

  const CameraTutorialOverlay({
    super.key,
    required this.onDismiss,
    this.isMeasuring = false,
  });

  @override
  State<CameraTutorialOverlay> createState() => _CameraTutorialOverlayState();
}

class _CameraTutorialOverlayState extends State<CameraTutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1.5),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          setState(() => _isVisible = false);
          widget.onDismiss();
        },
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeController,
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ✅ أيقونة الكاميرا المتحركة
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  width: 80 + 10 * _pulseController.value,
                                  height: 80 + 10 * _pulseController.value,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    widget.isMeasuring
                                        ? Icons.camera
                                        : Icons.camera_alt,
                                    size: 40,
                                    color: Colors.blue.shade700,
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // ✅ النص التعليمي
                            Text(
                              widget.isMeasuring
                                  ? '📸 حافظ على ثبات إصبعك'
                                  : '👆 ضع إصبعك على الكاميرا',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              widget.isMeasuring
                                  ? 'تأكد من تغطية الفلاش بالكامل\nوعدم تحريك إصبعك'
                                  : 'اضغط على زر البدء ثم ضع إصبعك\nعلى الكاميرا الخلفية والفلاش',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // ✅ رسم توضيحي لوضع الإصبع
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.phone_android,
                                    size: 40,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                    color: Colors.blue.shade300,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.fingerprint,
                                      color: Colors.blue,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 20,
                                    color: Colors.blue.shade300,
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.flash_on,
                                    size: 30,
                                    color: Colors.orange.shade400,
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // ✅ زر الإغلاق
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() => _isVisible = false);
                                  widget.onDismiss();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('فهمت ✅'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
