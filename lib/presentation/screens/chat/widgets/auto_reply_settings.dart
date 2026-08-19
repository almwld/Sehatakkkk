import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AutoReplySettings extends StatefulWidget {
  final bool isEnabled;
  final String replyMessage;
  final Function(bool, String) onChanged;

  const AutoReplySettings({
    super.key,
    required this.isEnabled,
    required this.replyMessage,
    required this.onChanged,
  });

  @override
  State<AutoReplySettings> createState() => _AutoReplySettingsState();
}

class _AutoReplySettingsState extends State<AutoReplySettings> {
  late bool _isEnabled;
  late TextEditingController _controller;
  final List<String> _quickReplies = [
    'شكراً لتواصلك، سأرد عليك قريباً',
    'أنا مشغول حالياً، سأعود إليك خلال ساعة',
    'تم استلام رسالتك، سأتواصل معك قريباً',
    'أنا في موعد طبي، سأرد بعد قليل',
    'شكراً لك، تم استلام طلبك',
  ];

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.isEnabled;
    _controller = TextEditingController(text: widget.replyMessage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveChanges() {
    widget.onChanged(_isEnabled, _controller.text.trim());
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
          // ✅ تفعيل الرد التلقائي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🤖 الردود التلقائية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: _isEnabled,
                onChanged: (value) {
                  setState(() => _isEnabled = value);
                  _saveChanges();
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_isEnabled) ...[
            // ✅ حقل الرسالة
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة الرد التلقائي...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              onChanged: (_) => _saveChanges(),
            ),
            const SizedBox(height: 12),

            // ✅ ردود سريعة
            const Text(
              'ردود سريعة:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickReplies.map((reply) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.text = reply;
                    });
                    _saveChanges();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                    ),
                    child: Text(
                      reply,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // ✅ حالة الرد التلقائي
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEnabled
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEnabled ? Icons.check_circle : Icons.block,
                    color: _isEnabled ? Colors.green : Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isEnabled
                        ? '✅ الرد التلقائي مفعل'
                        : '⏸️ الرد التلقائي غير مفعل',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isEnabled ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
