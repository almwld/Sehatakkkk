import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StoriesView extends StatefulWidget {
  const StoriesView({super.key});

  @override
  State<StoriesView> createState() => _StoriesViewState();
}

class _StoriesViewState extends State<StoriesView> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _stories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('stories')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        _stories = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'userId': data['userId'] ?? '',
            'userName': data['userName'] ?? 'مستخدم',
            'image': data['image'] ?? '',
            'text': data['text'] ?? '',
            'timestamp': data['timestamp'],
            'viewers': data['viewers'] ?? [],
            'isMine': data['userId'] == user.uid,
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ToastService.showError('❌ فشل تحميل الحالات: $e');
    }
  }

  Future<void> _addStory() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ✅ رفع الصورة
      final ref = FirebaseStorage.instance
          .ref()
          .child('stories/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putFile(File(image.path));
      final imageUrl = await ref.getDownloadURL();

      // ✅ حفظ في Firestore
      await FirebaseFirestore.instance.collection('stories').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'مستخدم',
        'image': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'viewers': [],
      });

      ToastService.showSuccess('✅ تم إضافة الحالة بنجاح');
      _loadStories();
    } catch (e) {
      ToastService.showError('❌ فشل إضافة الحالة: $e');
    }
  }

  void _viewStory(Map<String, dynamic> story) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewer(story: story),
      ),
    );
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    try {
      final date = (timestamp as Timestamp).toDate();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
      if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
      if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الحالات'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _addStory,
            tooltip: 'إضافة حالة',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? _buildEmptyState(isDark)
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    return _buildStoryCard(story, isDark);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStory,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_photo_alternate, color: Colors.white),
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story, bool isDark) {
    final isMine = story['isMine'] as bool? ?? false;
    final viewers = (story['viewers'] as List).length;
    final imageUrl = story['image'] as String;
    final userName = story['userName'] as String;
    final time = _formatTime(story['timestamp']);

    return GestureDetector(
      onTap: () => _viewStory(story),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: imageUrl.isNotEmpty
              ? DecorationImage(
                  image: CachedNetworkImageProvider(imageUrl),
                  fit: BoxFit.cover,
                )
              : null,
          color: Colors.grey[900],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // ✅ اسم المستخدم
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$viewers مشاهدة',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ✅ علامة "قصتي"
              if (isMine)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'قصتي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حالات',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف حالة جديدة لمشاركتها مع الآخرين',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addStory,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('إضافة حالة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 📸 عارض الحالة (Story Viewer)
// ============================================================

class StoryViewer extends StatefulWidget {
  final Map<String, dynamic> story;

  const StoryViewer({super.key, required this.story});

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.story['image'] as String;
    final userName = widget.story['userName'] as String;
    final text = widget.story['text'] as String;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) => setState(() => _isPaused = true),
        onTapUp: (_) => setState(() => _isPaused = false),
        onTapCancel: () => setState(() => _isPaused = false),
        onLongPress: () => setState(() => _isPaused = true),
        onLongPressUp: () => setState(() => _isPaused = false),
        child: Stack(
          children: [
            // ✅ صورة الحالة
            Center(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 80,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 80,
                    ),
            ),
            // ✅ شريط التقدم
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _isPaused ? _progressController.value : _progressController.value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // ✅ معلومات المستخدم
            Positioned(
              top: 50,
              left: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Text(
                      userName.isNotEmpty ? userName[0] : 'م',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'منذ دقيقة',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ زر الإغلاق
            Positioned(
              top: 50,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // ✅ نص الحالة
            if (text.isNotEmpty)
              Positioned(
                bottom: 80,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
