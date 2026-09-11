import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Unified feedback service. Supports both the current API and legacy
/// calls that passed BuildContext as the first positional argument.
class ToastService {
  static GlobalKey<NavigatorState>? _navigatorKey;
  static OverlayEntry? _overlayEntry;
  static Timer? _overlayTimer;
  static const _success = Color(0xFF4CAF50);
  static const _error = Color(0xFFF44336);
  static const _warning = Color(0xFFFF9800);
  static const _info = Color(0xFF2196F3);
  static const _loading = Color(0xFF0D5257);

  static void setNavigatorKey(GlobalKey<NavigatorState> key) => _navigatorKey = key;

  static Future<void> showSuccess(Object messageOrContext, [String? legacyMessage], {bool top = false, Color? backgroundColor, Duration duration = const Duration(seconds: 3), ToastGravity gravity = ToastGravity.BOTTOM, TextStyle? style}) =>
      showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.success, top: top, backgroundColor: backgroundColor, duration: duration, gravity: gravity);

  static Future<void> showError(Object messageOrContext, [String? legacyMessage], {bool top = false, Color? backgroundColor, Duration duration = const Duration(seconds: 3), ToastGravity gravity = ToastGravity.BOTTOM, TextStyle? style}) =>
      showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.error, top: top, backgroundColor: backgroundColor, duration: duration, gravity: gravity);

  static Future<void> showWarning(Object messageOrContext, [String? legacyMessage], {bool top = false, Color? backgroundColor, Duration duration = const Duration(seconds: 3), ToastGravity gravity = ToastGravity.BOTTOM, TextStyle? style}) =>
      showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.warning, top: top, backgroundColor: backgroundColor, duration: duration, gravity: gravity);

  static Future<void> showInfo(Object messageOrContext, [String? legacyMessage], {bool top = false, Color? backgroundColor, Duration duration = const Duration(seconds: 3), ToastGravity gravity = ToastGravity.BOTTOM, TextStyle? style}) =>
      showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.info, top: top, backgroundColor: backgroundColor, duration: duration, gravity: gravity);

  static Future<void> showLoading(Object messageOrContext, [String? legacyMessage], {bool top = true, Color? backgroundColor, Duration duration = const Duration(seconds: 3), ToastGravity gravity = ToastGravity.BOTTOM, TextStyle? style}) =>
      showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.loading, top: top, backgroundColor: backgroundColor, duration: duration, gravity: gravity);

  static String _message(Object value, String? legacy) => (legacy ?? value.toString()).trim();

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
    final entry = OverlayEntry(builder: (_) => _ToastOverlay(message: message, type: type, color: color, textColor: textColor, onDismiss: _dismissOverlay));
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

class _ToastOverlay extends StatelessWidget {
  final String message;
  final ToastType type;
  final Color color;
  final Color textColor;
  final VoidCallback onDismiss;
  const _ToastOverlay({required this.message, required this.type, required this.color, required this.textColor, required this.onDismiss});
  @override
  Widget build(BuildContext context) => Positioned(
    top: MediaQuery.of(context).padding.top + 8,
    left: 16, right: 16,
    child: Material(
      color: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: Color.lerp(color, Colors.white, 0.12)!.withOpacity(0.86), borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Text(_symbol, style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(child: Text(message, maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: TextStyle(color: textColor, fontSize: 14))),
          IconButton(onPressed: onDismiss, icon: Text('×', style: TextStyle(color: textColor, fontSize: 22))),
        ]),
      ),
    ),
  );
  String get _symbol { switch (type) { case ToastType.success: return '✓'; case ToastType.error: return '×'; case ToastType.warning: return '!'; case ToastType.info: return 'i'; case ToastType.loading: return '⌛'; } }
}
