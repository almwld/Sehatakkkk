import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PollWidget extends StatefulWidget {
  final String question;
  final List<String> options;
  final Duration duration;
  final VoidCallback? onVote;

  const PollWidget({
    super.key,
    required this.question,
    required this.options,
    this.duration = const Duration(minutes: 5),
    this.onVote,
  });

  @override
  State<PollWidget> createState() => _PollWidgetState();
}

class _PollWidgetState extends State<PollWidget> {
  int? _selectedOption;
  List<int> _votes = [];
  bool _hasVoted = false;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _votes = List.generate(widget.options.length, (_) => 0);
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(widget.duration, () {
      if (mounted) {
        setState(() => _isExpired = true);
      }
    });
  }

  void _vote(int index) {
    if (_hasVoted || _isExpired) return;

    setState(() {
      _selectedOption = index;
      _votes[index]++;
      _hasVoted = true;
    });

    if (widget.onVote != null) widget.onVote!();
  }

  int _getTotalVotes() {
    return _votes.fold(0, (sum, vote) => sum + vote);
  }

  double _getPercentage(int votes) {
    final total = _getTotalVotes();
    return total == 0 ? 0 : (votes / total) * 100;
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
          // ✅ السؤال
          Row(
            children: [
              const Icon(Icons.poll, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // ✅ الوقت المتبقي
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isExpired ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isExpired ? 'انتهى' : '${widget.duration.inMinutes} د',
                  style: TextStyle(
                    fontSize: 10,
                    color: _isExpired ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ الخيارات
          ...widget.options.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;
            final percentage = _getPercentage(_votes[index]);
            final isSelected = _selectedOption == index;

            return GestureDetector(
              onTap: () => _vote(index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.1)
                      : (isDark ? const Color(0xFF0B1121) : Colors.grey[50]),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // ✅ شريط التقدم
                    if (_hasVoted || _isExpired)
                      Positioned.fill(
                        child: FractionallySizedBox(
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    // ✅ النص
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : null,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (_hasVoted || _isExpired)
                          Text(
                            '${percentage.toStringAsFixed(0)}%',
                            style: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),

          // ✅ عدد المصوتين
          Row(
            children: [
              const Icon(Icons.people, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                '${_getTotalVotes()} صوت',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              if (_hasVoted)
                const Text(
                  '✅ تم التصويت',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
