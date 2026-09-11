import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/review_model.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class ReviewsScreen extends StatefulWidget {
  final String targetId;
  final ReviewTarget target;
  final String targetName;
  final bool isProvider;
  const ReviewsScreen({super.key, required this.targetId, required this.target, required this.targetName, this.isProvider = false});
  @override State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance.collection('reviews').where('targetId', isEqualTo: widget.targetId).where('target', isEqualTo: widget.target.name).orderBy('createdAt', descending: true).snapshots();
    return Scaffold(
      appBar: CustomAppBar(title: Text('تقييمات ${widget.targetName}'), backgroundColor: AppColors.primary, foregroundColor: Colors.white, actions: [if (!widget.isProvider) IconButton(icon: const Icon(Icons.add), onPressed: _showAddReviewDialog)]),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: stream, builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final reviews = snapshot.data?.docs.map((d) => ReviewModel.fromFirestore(d.data(), d.id)).toList() ?? [];
        if (reviews.isEmpty) return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star_border, size: 64, color: Colors.grey), const SizedBox(height: 12), const Text('لا توجد تقييمات'), if (!widget.isProvider) ElevatedButton(onPressed: _showAddReviewDialog, child: const Text('أضف تقييمك'))]));
        final average = reviews.fold<double>(0, (sum, r) => sum + r.rating) / reviews.length;
        return Column(children: [Padding(padding: const EdgeInsets.all(16), child: Row(children: [Text(average.toStringAsFixed(1), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.primary)), const SizedBox(width: 10), Text('${reviews.length} تقييم')])), Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: reviews.length, itemBuilder: (_, i) => _buildReviewCard(reviews[i]))) ]);
      }),
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwner = user?.uid == review.userId;
    final liked = review.likedBy?.contains(user?.uid) == true;
    final disliked = review.dislikedBy?.contains(user?.uid) == true;
    return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [CircleAvatar(child: Text(review.userName.isEmpty ? 'م' : review.userName[0])), const SizedBox(width: 10), Expanded(child: Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold))), ...List.generate(5, (i) => Icon(i < review.rating.round() ? Icons.star : Icons.star_border, color: Colors.amber, size: 15))]),
      if (review.comment != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(review.comment!)),
      const SizedBox(height: 8),
      Row(children: [TextButton.icon(onPressed: () => _toggleLike(review), icon: Icon(liked ? Icons.thumb_up : Icons.thumb_up_outlined, size: 16), label: Text('${review.likes}')), TextButton.icon(onPressed: () => _toggleDislike(review), icon: Icon(disliked ? Icons.thumb_down : Icons.thumb_down_outlined, size: 16), label: Text('${review.dislikes}')), const Spacer(), if (widget.isProvider && review.providerResponse == null) TextButton(onPressed: () => _showProviderResponseDialog(review), child: const Text('رد')), if (isOwner) IconButton(onPressed: () => _deleteReview(review), icon: const Icon(Icons.delete_outline))]),
      if (review.providerResponse != null) Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(8)), child: Text('رد المقدم: ${review.providerResponse}')),
    ])));
  }

  Future<void> _toggleLike(ReviewModel review) async {
    final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) return;
    final liked = List<String>.from(review.likedBy ?? []), disliked = List<String>.from(review.dislikedBy ?? []);
    if (liked.contains(uid)) { liked.remove(uid); } else { liked.add(uid); disliked.remove(uid); }
    await FirebaseFirestore.instance.collection('reviews').doc(review.id).update({'likes': liked.length, 'dislikes': disliked.length, 'likedBy': liked, 'dislikedBy': disliked});
  }
  Future<void> _toggleDislike(ReviewModel review) async {
    final uid = FirebaseAuth.instance.currentUser?.uid; if (uid == null) return;
    final liked = List<String>.from(review.likedBy ?? []), disliked = List<String>.from(review.dislikedBy ?? []);
    if (disliked.contains(uid)) { disliked.remove(uid); } else { disliked.add(uid); liked.remove(uid); }
    await FirebaseFirestore.instance.collection('reviews').doc(review.id).update({'likes': liked.length, 'dislikes': disliked.length, 'likedBy': liked, 'dislikedBy': disliked});
  }
  Future<void> _deleteReview(ReviewModel review) async { await FirebaseFirestore.instance.collection('reviews').doc(review.id).delete(); }

  void _showAddReviewDialog() {
    final comment = TextEditingController(); double rating = 5;
    showDialog(context: context, builder: (dialogContext) => StatefulBuilder(builder: (_, setDialogState) => AlertDialog(title: const Text('إضافة تقييم'), content: Column(mainAxisSize: MainAxisSize.min, children: [Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(onPressed: () => setDialogState(() => rating = i + 1.0), icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber)))), TextField(controller: comment, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب تعليقك...'))]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), ElevatedButton(onPressed: () async { final user = FirebaseAuth.instance.currentUser; if (user == null) { ToastService.showError(context, 'يرجى تسجيل الدخول'); return; } await FirebaseFirestore.instance.collection('reviews').add({'userId': user.uid, 'userName': user.displayName ?? 'مستخدم', 'userPhoto': user.photoURL, 'target': widget.target.name, 'targetId': widget.targetId, 'targetName': widget.targetName, 'rating': rating, 'comment': comment.text.trim(), 'likes': 0, 'dislikes': 0, 'likedBy': <String>[], 'dislikedBy': <String>[], 'isVerified': false, 'createdAt': DateTime.now().toIso8601String()}); if (dialogContext.mounted) Navigator.pop(dialogContext); if (mounted) ToastService.showSuccess(context, 'تم إضافة تقييمك'); }, child: const Text('نشر التقييم'))])));
  }

  void _showProviderResponseDialog(ReviewModel review) {
    final controller = TextEditingController();
    showDialog(context: context, builder: (dialogContext) => AlertDialog(title: const Text('رد على التقييم'), content: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب ردك...')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')), ElevatedButton(onPressed: () async { final text = controller.text.trim(); if (text.isEmpty) { ToastService.showError(context, 'يرجى كتابة الرد'); return; } await FirebaseFirestore.instance.collection('reviews').doc(review.id).update({'providerResponse': text, 'providerResponseAt': DateTime.now().toIso8601String()}); if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: const Text('نشر الرد'))]));
  }
}
