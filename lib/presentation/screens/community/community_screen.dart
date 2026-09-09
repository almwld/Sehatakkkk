import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';
import 'package:sehatak/core/services/community_share_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:video_player/video_player.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final _query = FirebaseFirestore.instance.collection('community_posts');

  Stream<QuerySnapshot<Map<String, dynamic>>> _posts() => _query
      .where('isPublished', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();

  Future<void> _share(CommunityPostModel post) async {
    try {
      await _query.doc(post.id).update({'shares': FieldValue.increment(1)});
      await CommunityShareService.sharePost(context, post);
    } catch (_) {
      await Share.share('${post.title}\n${post.content ?? ''}', subject: 'منشور من صحتك');
    }
  }

  Future<void> _toggleLike(CommunityPostModel post) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('سجل الدخول للتفاعل مع المنشورات');
      return;
    }
    final postRef = _query.doc(post.id);
    final likeRef = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('liked_posts').doc(post.id);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final postSnap = await tx.get(postRef);
      final likeSnap = await tx.get(likeRef);
      final likes = (postSnap.data()?['likes'] as num?)?.toInt() ?? 0;
      if (likeSnap.exists) {
        tx.update(postRef, {'likes': likes > 0 ? likes - 1 : 0});
        tx.delete(likeRef);
      } else {
        tx.update(postRef, {'likes': likes + 1});
        tx.set(likeRef, {'postId': post.id, 'likedAt': FieldValue.serverTimestamp()});
      }
    });
  }

  Future<void> _comment(CommunityPostModel post) async {
    final controller = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, MediaQuery.of(sheetContext).viewInsets.bottom + 16),
        child: Row(children: [
          Expanded(child: TextField(controller: controller, autofocus: true, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب تعليقك...', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton(onPressed: () => Navigator.pop(sheetContext, controller.text.trim()), icon: const Icon(Icons.send_rounded, color: AppColors.primary)),
        ]),
      ),
    );
    controller.dispose();
    if (text == null || text.trim().isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _message('سجل الدخول لإضافة تعليق');
      return;
    }
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = userDoc.data() ?? <String, dynamic>{};
    await FirebaseFirestore.instance.collection('comments').add({
      'postId': post.id,
      'userId': user.uid,
      'userName': (data['name'] ?? user.displayName ?? 'مستخدم').toString(),
      'userAvatar': data['avatar'],
      'comment': text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
      'repliesCount': 0,
    });
    await _query.doc(post.id).update({'comments': FieldValue.increment(1)});
  }

  Future<void> _showComments(CommunityPostModel post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CommentsSheet(postId: post.id, onAdd: () => _comment(post)),
    );
  }

  void _message(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF081A1A) : const Color(0xFFF6F9F9),
      appBar: AppBar(title: const Text('مجتمع صحتك'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _posts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('تعذر تحميل المجتمع\n${snapshot.error}', textAlign: TextAlign.center));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('لا توجد منشورات منشورة حالياً'));
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) => _PostCard(
                post: CommunityPostModel.fromFirestore(docs[index]),
                dark: dark,
                onLike: _toggleLike,
                onComment: _comment,
                onComments: _showComments,
                onShare: _share,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPostModel post;
  final bool dark;
  final Future<void> Function(CommunityPostModel) onLike;
  final Future<void> Function(CommunityPostModel) onComment;
  final Future<void> Function(CommunityPostModel) onComments;
  final Future<void> Function(CommunityPostModel) onShare;

  const _PostCard({required this.post, required this.dark, required this.onLike, required this.onComment, required this.onComments, required this.onShare});

  @override
  Widget build(BuildContext context) {
    final image = post.images?.isNotEmpty == true ? post.images!.first : post.imageUrl;
    return Container(
      decoration: BoxDecoration(color: dark ? const Color(0xFF102A2A) : Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 8), child: Row(children: [
          CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.12), child: Text(post.userName.isEmpty ? 'ص' : post.userName.characters.first, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Flexible(child: Text(post.userName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131)))), if (post.isVerified == true) const Padding(padding: EdgeInsetsDirectional.only(start: 5), child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 16))]),
            Text('${post.category ?? 'عام'} • ${post.timeAgo}', style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : Colors.grey[600])),
          ])),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text(post.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131)))),
        if ((post.content ?? '').trim().isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(14, 6, 14, 10), child: Text(post.content!, style: TextStyle(height: 1.5, color: dark ? Colors.white70 : Colors.black87))),
        if (image != null && image.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: ClipRRect(borderRadius: BorderRadius.circular(16), child: AppImage(imageUrl: image, height: 250, width: double.infinity, fit: BoxFit.cover))),
        if (post.images != null && post.images!.length > 1) Padding(padding: const EdgeInsets.all(10), child: SizedBox(height: 78, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: post.images!.length, separatorBuilder: (_, __) => const SizedBox(width: 8), itemBuilder: (_, i) => ClipRRect(borderRadius: BorderRadius.circular(10), child: AppImage(imageUrl: post.images![i], width: 92, height: 78, fit: BoxFit.cover))))),
        Padding(padding: const EdgeInsets.fromLTRB(10, 6, 10, 8), child: Row(children: [
          _Action(icon: post.isLiked ? Icons.favorite : Icons.favorite_border, label: '${post.likes}', color: post.isLiked ? Colors.red : null, onTap: () => onLike(post)),
          _Action(icon: Icons.mode_comment_outlined, label: '${post.comments}', onTap: () => onComments(post)),
          _Action(icon: Icons.share_outlined, label: '${post.shares}', onTap: () => onShare(post)),
          const Spacer(),
          if (post.comments > 0) TextButton(onPressed: () => onComment(post), child: const Text('أضف تعليقاً')),
        ])),
      ]),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7), child: Row(children: [Icon(icon, size: 20, color: color ?? Colors.grey[600]), const SizedBox(width: 4), Text(label, style: TextStyle(fontSize: 11, color: color ?? Colors.grey[600], fontWeight: FontWeight.w700))])));
}

class _CommentsSheet extends StatelessWidget {
  final String postId;
  final VoidCallback onAdd;
  const _CommentsSheet({required this.postId, required this.onAdd});
  @override
  Widget build(BuildContext context) => SizedBox(height: MediaQuery.of(context).size.height * .72, child: Column(children: [
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [const Expanded(child: Text('التعليقات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900))), IconButton(onPressed: onAdd, icon: const Icon(Icons.add_comment_outlined, color: AppColors.primary))])),
    const Divider(height: 1),
    Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: FirebaseFirestore.instance.collection('comments').where('postId', isEqualTo: postId).orderBy('timestamp', descending: true).limit(100).snapshots(), builder: (_, snap) {
      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
      if (snap.data!.docs.isEmpty) return const Center(child: Text('لا توجد تعليقات بعد'));
      return ListView.separated(padding: const EdgeInsets.all(16), itemCount: snap.data!.docs.length, separatorBuilder: (_, __) => const Divider(), itemBuilder: (_, i) { final d = snap.data!.docs[i].data(); return ListTile(leading: CircleAvatar(child: Text((d['userName']?.toString() ?? 'م').characters.first)), title: Text(d['userName']?.toString() ?? 'مستخدم', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(d['comment']?.toString() ?? '')); });
    }))
  ]));
}

class CommunityVideo extends StatefulWidget {
  final String url;
  const CommunityVideo({super.key, required this.url});
  @override
  State<CommunityVideo> createState() => _CommunityVideoState();
}

class _CommunityVideoState extends State<CommunityVideo> {
  VideoPlayerController? _controller;
  @override
  void initState() { super.initState(); _init(); }
  Future<void> _init() async { final c = VideoPlayerController.networkUrl(Uri.parse(widget.url)); await c.initialize(); if (!mounted) { await c.dispose(); return; } setState(() => _controller = c); }
  @override
  void dispose() { _controller?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) { final c = _controller; if (c == null || !c.value.isInitialized) return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())); return GestureDetector(onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()), child: AspectRatio(aspectRatio: c.value.aspectRatio, child: Stack(fit: StackFit.expand, children: [VideoPlayer(c), if (!c.value.isPlaying) const Center(child: Icon(Icons.play_circle_fill_rounded, size: 64, color: Colors.white))]))); }
}
