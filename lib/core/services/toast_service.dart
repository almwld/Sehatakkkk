import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Unified application feedback. Bottom messages use Fluttertoast; top
/// messages use an animated OverlayEntry. No ScaffoldMessenger/SnackBar.
class ToastService {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static OverlayEntry? _overlayEntry;
  static Timer? _overlayTimer;

  static const _success = Color(0xFF4CAF50);
  static const _error = Color(0xFFF44336);
  static const _warning = Color(0xFFFF9800);
  static const _info = Color(0xFF2196F3);
  static const _loading = Color(0xFF0D5257);

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static Future<void> showSuccess(String message, {bool top = false}) => showToast(message: message, type: ToastType.success, top: top);
  static Future<void> showError(String message, {bool top = false}) => showToast(message: message, type: ToastType.error, top: top);
  static Future<void> showWarning(String message, {bool top = false}) => showToast(message: message, type: ToastType.warning, top: top);
  static Future<void> showInfo(String message, {bool top = false}) => showToast(message: message, type: ToastType.info, top: top);
  static Future<void> showLoading(String message, {bool top = true}) => showToast(message: message, type: ToastType.loading, top: top);

  static Future<void> showToast({
    required String message,
    ToastType type = ToastType.info,
    bool top = false,
    Color? backgroundColor,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) async {
    if (message.trim().isEmpty) return;
    if (top) {
      _showOverlay(message, type, backgroundColor ?? _colorFor(type), textColor, duration);
      return;
    }
    final color = backgroundColor ?? _colorFor(type);
    await Fluttertoast.showToast(
      msg: message,
      toastLength: duration.inSeconds <= 2 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG,
      gravity: gravity,
      backgroundColor: color.withOpacity(0.86),
      textColor: textColor,
      fontSize: 14,
    );
  }

  static void _showOverlay(String message, ToastType type, Color color, Color textColor, Duration duration) {
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) return;
    _overlayTimer?.cancel();
    _overlayEntry?.remove();

    final entry = OverlayEntry(
      builder: (_) => _ToastOverlay(
        message: message,
        type: type,
        color: color,
        textColor: textColor,
        onDismiss: _dismissOverlay,
      ),
    );
    _overlayEntry = entry;
    overlay.insert(entry);
    _overlayTimer = Timer(duration, _dismissOverlay);
  }

  static void _dismissOverlay() {
    _overlayTimer?.cancel();
    _overlayTimer = null;
    final entry = _overlayEntry;
    _overlayEntry = null;
    entry?.remove();
  }

  static Color _colorFor(ToastType type) {
    switch (type) {
      case ToastType.success: return _success;
      case ToastType.error: return _error;
      case ToastType.warning: return _warning;
      case ToastType.info: return _info;
      case ToastType.loading: return _loading;
    }
  }
}

enum ToastType { success, error, warning, info, loading }

class _ToastOverlay extends StatefulWidget {
  final String message;
  final ToastType type;
  final Color color;
  final Color textColor;
  final VoidCallback onDismiss;

  const _ToastOverlay({required this.message, required this.type, required this.color, required this.textColor, required this.onDismiss});

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
    reverseDuration: const Duration(milliseconds: 180),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _symbol {
    switch (widget.type) {
      case ToastType.success: return '✓';
      case ToastType.error: return '×';
      case ToastType.warning: return '!';
      case ToastType.info: return 'i';
      case ToastType.loading: return '⌛';
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final lightColor = Color.lerp(widget.color, Colors.white, 0.12)!;
    return Positioned(
      top: top + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: lightColor.withOpacity(0.86),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: widget.color.withOpacity(0.18), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), shape: BoxShape.circle),
                  child: Text(_symbol, style: TextStyle(color: widget.textColor, fontSize: 16, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.message, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,
                  style: TextStyle(color: widget.textColor, fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansArabicUI'))),
                const SizedBox(width: 8),
                InkWell(onTap: widget.onDismiss, borderRadius: BorderRadius.circular(18), child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text('×', style: TextStyle(color: widget.textColor, fontSize: 22, height: 1)),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
