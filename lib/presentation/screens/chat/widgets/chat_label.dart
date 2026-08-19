import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class ChatLabel extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ChatLabel({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LabelManager extends StatefulWidget {
  final List<String> labels;
  final Function(List<String>) onLabelsChanged;

  const LabelManager({
    super.key,
    required this.labels,
    required this.onLabelsChanged,
  });

  @override
  State<LabelManager> createState() => _LabelManagerState();
}

class _LabelManagerState extends State<LabelManager> {
  final TextEditingController _controller = TextEditingController();
  final List<Color> _availableColors = [
    AppColors.primary,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  Color _selectedColor = AppColors.primary;

  void _addLabel() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.labels.contains(text)) {
      widget.onLabelsChanged([...widget.labels, text]);
      _controller.clear();
    }
  }

  void _removeLabel(String label) {
    widget.onLabelsChanged(widget.labels.where((l) => l != label).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إدارة التصنيفات',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // ✅ إضافة تصنيف جديد
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: 'اسم التصنيف...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onSubmitted: (_) => _addLabel(),
                ),
              ),
              const SizedBox(width: 8),
              // ✅ اختيار اللون
              DropdownButton<Color>(
                value: _selectedColor,
                items: _availableColors.map((color) {
                  return DropdownMenuItem(
                    value: color,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (color) {
                  if (color != null) setState(() => _selectedColor = color);
                },
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.primary),
                onPressed: _addLabel,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ التصنيفات الحالية
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.labels.map((label) {
              return ChatLabel(
                label: label,
                color: _availableColors[widget.labels.indexOf(label) % _availableColors.length],
                onDelete: () => _removeLabel(label),
              );
            }).toList(),
          ),
          if (widget.labels.isEmpty)
            const Text(
              'لا توجد تصنيفات',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
        ],
      ),
    );
  }
}
