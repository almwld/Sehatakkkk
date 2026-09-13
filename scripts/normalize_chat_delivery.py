from pathlib import Path

path = Path('lib/presentation/screens/chat/chat_detail_screen.dart')
text = path.read_text(encoding='utf-8')
start = text.find('  Future<void> _markConversationSeen() async {')
end = text.find('\n  void _sendText(', start)
if start >= 0 and end > start:
    canonical = "  Future<void> _markConversationSeen() async {\n    if (_markingSeen) return;\n    _markingSeen = true;\n    try {\n      // أولاً نثبت التسليم ثم القراءة حتى تظهر ✓✓ للطرف المرسل بصورة صحيحة.\n      await _chatService.markAsDelivered(widget.chatId);\n      await _chatService.markAsRead(widget.chatId);\n    } catch (e) {\n      debugPrint('Chat mark-as-read failed: $e');\n    } finally {\n      _markingSeen = false;\n    }\n  }\n"
    block = text[start:end]
    if block != canonical:
        path.write_text(text[:start] + canonical + text[end:], encoding='utf-8')
        print('[updated] chat_detail delivery/read synchronization')
    else:
        print('[ok] chat_detail delivery/read synchronization')
else:
    raise SystemExit('Could not locate _markConversationSeen block')
