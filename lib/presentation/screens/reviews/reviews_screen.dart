import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/review_model.dart';

class ReviewsScreen extends StatefulWidget {
  final String targetId;
  final ReviewTarget target;
  final String targetName;
  final bool isProvider;
  
  const ReviewsScreen({
    super.key,
    required this.targetId,
    required this.target,
    required this.targetName,
    this.isProvider = false,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  double _averageRating = 0;
  int _totalReviews = 0;
  Map<int, int> _ratingDistribution = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('reviews')
          .where('targetId', isEqualTo: widget.targetId)
          .where('target', isEqualTo: widget.target.toString().split('.').last)
          .get();

      final reviews = snap.docs.map((doc) {
        return ReviewModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _totalReviews = reviews.length;
      
      if (_totalReviews > 0) {
        _averageRating = reviews.fold(0.0, (sum, r) => sum + r.rating) / _totalReviews;
        
        _ratingDistribution = {
          1: reviews.where((r) => r.rating.toInt() == 1).length,
          2: reviews.where((r) => r.rating.toInt() == 2).length,
          3: reviews.where((r) => r.rating.toInt() == 3).length,
          4: reviews.where((r) => r.rating.toInt() == 4).length,
          5: reviews.where((r) => r.rating.toInt() == 5).length,
        };
      }
    } catch (e) {
      print('Error loading stats: $e');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'تقييمات ${widget.targetName}',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!widget.isProvider)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddReviewDialog,
            ),
        ],
      ),
      body: Column(
        children: [
          // ✅ ملخص التقييمات
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              border: Border(bottom: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                // ✅ متوسط التقييم
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (index) {
                            return Icon(
                              index < _averageRating.round()
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 14,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // ✅ توزيع التقييمات
                Expanded(
                  child: Column(
                    children: [
                      ...List.generate(5, (index) {
                        final star = 5 - index;
                        final count = _ratingDistribution[star] ?? 0;
                        final percentage = _totalReviews > 0
                            ? (count / _totalReviews * 100)
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$star',
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey[200],
                                    color: Colors.amber,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$count',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ✅ قائمة التقييمات
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('targetId', isEqualTo: widget.targetId)
                        .where('target', isEqualTo: widget.target.toString().split('.').last)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('خطأ: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final reviews = snapshot.data?.docs.map((doc) {
                        return ReviewModel.fromFirestore(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        );
                      }).toList() ?? [];

                      if (reviews.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_border,
                                size: 64,
                                color: isDark ? Colors.grey[600] : Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد تقييمات',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'كن أول من يقيم ${widget.targetName}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                              if (!widget.isProvider)
                                const SizedBox(height: 16),
                              if (!widget.isProvider)
                                ElevatedButton(
                                  onPressed: _showAddReviewDialog,
                                  child: const Text('أضف تقييمك'),
                                ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviews[index];
                          return _buildReviewCard(review);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user?.uid == review.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        border: Border.all(
          color: review.isVerified ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ معلومات المستخدم
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: review.userPhoto != null
                    ? NetworkImage(review.userPhoto!)
                    : null,
                child: review.userPhoto == null
                    ? Text(
                        review.userName.isNotEmpty ? review.userName[0] : 'م',
                        style: const TextStyle(fontSize: 16),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.grey[500] : Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (review.isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'موثق',
                    style: TextStyle(fontSize: 8, color: Colors.green),
                  ),
                ),
            ],
          ),
          if (review.comment != null) ...[
            const SizedBox(height: 8),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.5,
              ),
            ),
          ],
          if (review.images != null && review.images!.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: review.images!.map((image) {
                  return Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          // ✅ رد المقدم
          if (review.providerResponse != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.reply, size: 14, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'رد المقدم',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.providerResponse!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  if (review.providerResponseAt != null)
                    Text(
                      _formatDate(review.providerResponseAt!),
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          // ✅ أزرار التفاعل
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleLike(review),
                child: Row(
                  children: [
                    Icon(
                      review.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid) == true
                          ? Icons.thumb_up
                          : Icons.thumb_up_outlined,
                      color: review.likedBy?.contains(FirebaseAuth.instance.currentUser?.uid) == true
                          ? Colors.blue
                          : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.likes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _toggleDislike(review),
                child: Row(
                  children: [
                    Icon(
                      review.dislikedBy?.contains(FirebaseAuth.instance.currentUser?.uid) == true
                          ? Icons.thumb_down
                          : Icons.thumb_down_outlined,
                      color: review.dislikedBy?.contains(FirebaseAuth.instance.currentUser?.uid) == true
                          ? Colors.red
                          : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${review.dislikes}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // ✅ رد المقدم (للمقدمين فقط)
              if (widget.isProvider && review.providerResponse == null)
                TextButton(
                  onPressed: () => _showProviderResponseDialog(review),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'رد',
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              // ✅ حذف (للمالك فقط)
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _deleteReview(review),
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike(ReviewModel review) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isLiked = review.likedBy?.contains(user.uid) ?? false;
    final likedBy = List<String>.from(review.likedBy ?? []);
    final dislikedBy = List<String>.from(review.dislikedBy ?? []);

    if (isLiked) {
      likedBy.remove(user.uid);
    } else {
      likedBy.add(user.uid);
      dislikedBy.remove(user.uid);
    }

    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(review.id)
        .update({
      'likes': likedBy.length,
      'dislikes': dislikedBy.length,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
    });
  }

  Future<void> _toggleDislike(ReviewModel review) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isDisliked = review.dislikedBy?.contains(user.uid) ?? false;
    final likedBy = List<String>.from(review.likedBy ?? []);
    final dislikedBy = List<String>.from(review.dislikedBy ?? []);

    if (isDisliked) {
      dislikedBy.remove(user.uid);
    } else {
      dislikedBy.add(user.uid);
      likedBy.remove(user.uid);
    }

    await FirebaseFirestore.instance
        .collection('reviews')
        .doc(review.id)
        .update({
      'likes': likedBy.length,
      'dislikes': dislikedBy.length,
      'likedBy': likedBy,
      'dislikedBy': dislikedBy,
    });
  }

  Future<void> _deleteReview(ReviewModel review) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: 'حذف التقييم',
        content: const Text('هل أنت متأكد من حذف هذا التقييم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(review.id)
          .delete();
    }
  }

  void _showProviderResponseDialog(ReviewModel review) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: 'رد على التقييم',
        content: TextField(
          controller: responseController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'اكتب ردك على هذا التقييم...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (responseController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('يرجى كتابة الرد'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(review.id)
                  .update({
                'providerResponse': responseController.text.trim(),
                'providerResponseAt': FieldValue.serverTimestamp(),
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم إرسال الرد'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('إرسال الرد'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول لإضافة تقييم'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    double rating = 0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'أضف تقييمك',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () => setState(() => rating = index + 1),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: commentController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'اكتب رأيك عن الخدمة...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                    ),
                    const Text('إخفاء الاسم'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: rating == 0
                        ? null
                        : () async {
                            final review = ReviewModel(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              userId: user.uid,
                              userName: user.displayName ?? 'مستخدم',
                              userPhoto: user.photoURL,
                              target: widget.target,
                              targetId: widget.targetId,
                              targetName: widget.targetName,
                              rating: rating,
                              comment: commentController.text,
                              isVerified: false,
                              createdAt: DateTime.now(),
                            );

                            await FirebaseFirestore.instance
                                .collection('reviews')
                                .add(review.toFirestore());

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ تم إضافة تقييمك'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('نشر التقييم'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} يوم';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
