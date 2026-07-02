import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class RateAppScreen extends StatefulWidget {
  const RateAppScreen({super.key});

  @override
  State<RateAppScreen> createState() => _RateAppScreenState();
}

class _RateAppScreenState extends State<RateAppScreen> {
  double _rating = 0;
  String _selectedFeedback = '';
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitted = false;

  final List<String> _feedbackOptions = [
    'ممتاز',
    'جيد جداً',
    'جيد',
    'متوسط',
    'سيء',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'قيّم التطبيق',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isSubmitted
          ? _buildSuccessState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ✅ أيقونة التقييم
                  _buildRatingIcon(),
                  const SizedBox(height: 24),
                  // ✅ نص التقييم
                  _buildRatingText(),
                  const SizedBox(height: 16),
                  // ✅ نجوم التقييم
                  _buildStars(),
                  const SizedBox(height: 24),
                  // ✅ خيارات التقييم السريع
                  _buildQuickFeedback(),
                  const SizedBox(height: 16),
                  // ✅ حقل النص الحر
                  _buildFeedbackTextField(isDark),
                  const SizedBox(height: 24),
                  // ✅ زر الإرسال
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildRatingIcon() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _rating > 0
                  ? [AppColors.amber, AppColors.primary]
                  : [AppColors.grey, AppColors.grey],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            _rating >= 4
                ? Icons.emoji_emotions_rounded
                : _rating >= 3
                    ? Icons.emoji_events_rounded
                    : _rating > 0
                        ? Icons.emoji_neutral_rounded
                        : Icons.star_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _rating >= 4
              ? '🌟 ممتاز!'
              : _rating >= 3
                  ? '👍 جيد جداً'
                  : _rating > 0
                      ? '😐 جيد'
                      : '⭐ قيمنا',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRatingText() {
    return Text(
      _rating > 0
          ? 'شكراً لتقييمك! ساعدنا في تحسين التطبيق'
          : 'كم تقيم تجربتك مع تطبيق صحتك؟',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.grey,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = starIndex.toDouble()),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(4),
            child: Icon(
              starIndex <= _rating
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 48,
              color: starIndex <= _rating
                  ? AppColors.amber
                  : AppColors.grey.withOpacity(0.3),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuickFeedback() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _feedbackOptions.map((option) {
        final isSelected = _selectedFeedback == option;
        return GestureDetector(
          onTap: () => setState(() => _selectedFeedback = option),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: Text(
              option,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFeedbackTextField(bool isDark) {
    return TextField(
      controller: _feedbackController,
      maxLines: 4,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: 'أخبرنا برأيك (اختياري)',
        hintText: 'اكتب ملاحظاتك هنا...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF1A2540) : Colors.white,
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _rating > 0 ? _submitRating : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _rating > 0 ? AppColors.primary : AppColors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Text(
          'إرسال التقييم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 60,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'شكراً لتقييمك!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'تقييمك يساعدنا في تحسين التطبيق',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isSubmitted = false;
                    _rating = 0;
                    _selectedFeedback = '';
                    _feedbackController.clear();
                  });
                },
                child: const Text('تقييم مجدد'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _openPlayStore(),
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('فتح في المتجر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _submitRating() {
    // ✅ هنا يمكن إرسال التقييم إلى Firebase
    print('⭐ Rating: $_rating');
    print('📝 Feedback: $_selectedFeedback');
    print('📝 Comment: ${_feedbackController.text}');

    setState(() {
      _isSubmitted = true;
    });
  }

  Future<void> _openPlayStore() async {
    final url = 'https://play.google.com/store/apps/details?id=com.sehatak.app';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن فتح المتجر حالياً'),
        ),
      );
    }
  }
}
