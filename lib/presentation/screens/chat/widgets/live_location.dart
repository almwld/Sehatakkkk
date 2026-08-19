import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class LiveLocation extends StatefulWidget {
  final String chatId;
  final Function(double, double) onLocationUpdate;

  const LiveLocation({
    super.key,
    required this.chatId,
    required this.onLocationUpdate,
  });

  @override
  State<LiveLocation> createState() => _LiveLocationState();
}

class _LiveLocationState extends State<LiveLocation> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isSharing ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isSharing ? Colors.green : Colors.red).withOpacity(
                            0.3 + 0.3 * _pulseController.value,
                          ),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                _isSharing ? '📍 مشاركة الموقع المباشر' : '📍 الموقع غير مشترك',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _isSharing ? Colors.green : Colors.grey,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _isSharing ? Icons.stop : Icons.play_arrow,
                  color: _isSharing ? Colors.red : AppColors.primary,
                ),
                onPressed: () {
                  setState(() => _isSharing = !_isSharing);
                  if (_isSharing) {
                    // ✅ بدء مشاركة الموقع
                    _simulateLocationUpdate();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isSharing)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'مشاركة الموقع المباشر...',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'مباشر',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _simulateLocationUpdate() {
    if (!_isSharing) return;

    // ✅ محاكاة تحديث الموقع
    final lat = 15.369 + (DateTime.now().millisecondsSinceEpoch % 1000) / 10000;
    final lng = 44.191 + (DateTime.now().millisecondsSinceEpoch % 1000) / 10000;

    widget.onLocationUpdate(lat, lng);

    Future.delayed(const Duration(seconds: 3), _simulateLocationUpdate);
  }
}
