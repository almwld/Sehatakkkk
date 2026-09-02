import 'package:flutter/material.dart';

class ChatInputBar extends StatefulWidget {
  final ValueChanged<String> onSend;
  final VoidCallback? onAttachment;
  final VoidCallback? onVoice;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onAttachment,
    this.onVoice,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          8,
          8,
          8,
          8,
        ),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color: colors.outlineVariant,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'مرفقات',
              onPressed: widget.onAttachment,
              icon: const Icon(
                Icons.attach_file_rounded,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                minLines: 1,
                maxLines: 5,
                textInputAction:
                    TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  filled: true,
                  fillColor:
                      colors.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 4),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (_, value, __) {
                final hasText =
                    value.text.trim().isNotEmpty;

                return IconButton(
                  tooltip: hasText
                      ? 'إرسال'
                      : 'رسالة صوتية',
                  onPressed: hasText
                      ? _send
                      : widget.onVoice,
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor:
                        colors.onPrimary,
                  ),
                  icon: Icon(
                    hasText
                        ? Icons.send_rounded
                        : Icons.mic_rounded,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
