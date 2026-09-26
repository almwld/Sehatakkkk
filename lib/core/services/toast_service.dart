import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  static String _message(Object value, [String? legacy]) => (legacy ?? value.toString()).trim();

  static Future<void> showSuccess(Object messageOrContext, [String? legacyMessage]) => showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.success);
  static Future<void> showError(Object messageOrContext, [String? legacyMessage]) => showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.error);
  static Future<void> showWarning(Object messageOrContext, [String? legacyMessage]) => showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.warning);
  static Future<void> showInfo(Object messageOrContext, [String? legacyMessage]) => showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.info);
  static Future<void> showLoading(Object messageOrContext, [String? legacyMessage]) => showToast(message: _message(messageOrContext, legacyMessage), type: ToastType.loading);

  static Future<void> showToast({required String message, ToastType type = ToastType.info, bool top = false, Color? backgroundColor, Color textColor = Colors.white, Duration duration = const Duration(seconds: 3), ToastGravity gravity = ToastGravity.BOTTOM}) async {
    if (message.trim().isEmpty) return;
    final color = backgroundColor ?? _colorFor(type);
    if (top) { _showOverlay(message, type, color, textColor, duration); return; }
    await Fluttertoast.showToast(msg: message, toastLength: duration.inSeconds <= 2 ? Toast.LENGTH_SHORT : Toast.LENGTH_LONG, gravity: gravity, backgroundColor: color.withOpacity(0.86), textColor: textColor, fontSize: 14);
  }

  static void _showOverlay(String message, ToastType type, Color color, Color textColor, Duration duration) {
    final overlay = _navigatorKey?.currentState?.overlay;
    if (overlay == null) return;
    _overlayTimer?.cancel(); _overlayEntry?.remove();
    final entry = OverlayEntry(builder: (_) => _ToastOverlay(message: message, type: type, color: color, textColor: textColor, onDismiss: _dismissOverlay));
    _overlayEntry = entry; overlay.insert(entry); _overlayTimer = Timer(duration, _dismissOverlay);
  }

  static void _dismissOverlay() { _overlayTimer?.cancel(); _overlayTimer = null; final entry = _overlayEntry; _overlayEntry = null; entry?.remove(); }
  static Color _colorFor(ToastType type) => switch (type) { ToastType.success => _success, ToastType.error => _error, ToastType.warning => _warning, ToastType.info => _info, ToastType.loading => _loading };
}

enum ToastType { success, error, warning, info, loading }

class _ToastOverlay extends StatelessWidget {
  final String message; final ToastType type; final Color color; final Color textColor; final VoidCallback onDismiss;
  const _ToastOverlay({required this.message, required this.type, required this.color, required this.textColor, required this.onDismiss});
  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 8;
    const glass = Color(0xCC0A8F83);
    const glassEdge = Color(0x665DE0D2);
    return Positioned(
      top: top,
      left: 14,
      right: 14,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              constraints: const BoxConstraints(minHeight: 54),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: glass.withOpacity(.72),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: glassEdge, width: 1),
                boxShadow: const [
                  BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 7)),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0x335DE0D2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0x665DE0D2)),
                    ),
                    alignment: Alignment.center,
                    child: Text(_symbol, style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(color: textColor, fontSize: 13, height: 1.25, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: onDismiss,
                    icon: Icon(Icons.close_rounded, color: textColor.withOpacity(.82), size: 19),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  String get _symbol => switch (type) { ToastType.success => '✓', ToastType.error => '×', ToastType.warning => '!', ToastType.info => 'i', ToastType.loading => '⌛' };
}
