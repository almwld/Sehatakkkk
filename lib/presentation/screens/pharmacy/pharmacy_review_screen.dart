import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class PharmacyReviewScreen extends StatefulWidget {
  final String pharmacyId;

  const PharmacyReviewScreen({super.key, required this.pharmacyId});

  @override
  State<PharmacyReviewScreen> createState() => _PharmacyReviewScreenState();
}

class _PharmacyReviewScreenState extends State<PharmacyReviewScreen> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();

  final List<Map<String, dynamic>> _reviews = [
    {'user': 'أحمد محمد', 'rating': 5, 'comment': 'صيدلية ممتازة وأسعار مناسبة', 'date': 'منذ يومين', 'avatar': 'أ'},
    {'user': 'سارة علي', 'rating': 4, 'comment': 'خدمة سريعة وتوصيل ممتاز', 'date': 'منذ 5 أيام', 'avatar': 'س'},
    {'user': 'خالد حسن', 'rating': 5, 'comment': 'صيدلي محترف ونصائح مفيدة', 'date': 'منذ أسبوع', 'avatar': 'خ'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: '⭐ تقييم الصيدلية',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ إضافة تقييم
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📝 أضف تقييمك',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () => setState(() => _rating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'اكتب تقييمك هنا...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0B1121) : Colors.white,
                    ),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _rating > 0
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ تم إضافة تقييمك بنجاح'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              setState(() {
                                _rating = 0;
                                _reviewController.clear();
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('إرسال التقييم'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ قائمة التقييمات
            const Text(
              '🗣️ تقييمات العملاء',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._reviews.map((review) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A2540) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        review['avatar'],
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                review['user'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: List.generate(5, (index) {
                                  return Icon(
                                    index < review['rating'] ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 14,
                                  );
                                }),
                              ),
                            ],
                          ),
                          Text(
                            review['comment'],
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                          Text(
                            review['date'],
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
