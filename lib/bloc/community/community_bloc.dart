// ============================================================
// 📁 lib/bloc/community/community_bloc.dart
// 🧠 منطق المجتمع
// ============================================================

import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/bloc/community/community_event.dart';
import 'package:sehatak/bloc/community/community_state.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NextcloudService _nextcloud = NextcloudService();

  CommunityBloc() : super(const CommunityState()) {
    on<FetchCommunityPosts>(_onFetchPosts);
    on<LoadMoreCommunityPosts>(_onLoadMore);
    on<CreateCommunityPost>(_onCreatePost);
    on<DeleteCommunityPost>(_onDeletePost);
    on<ToggleLikePost>(_onToggleLike);
    on<SaveCommunityPost>(_onSavePost);
    on<ReportCommunityPost>(_onReportPost);
    on<ShareCommunityPost>(_onSharePost);
    on<AddCommunityComment>(_onAddComment);
  }

  // ============================================================
  // 📋 جلب المنشورات
  // ============================================================
  Future<void> _onFetchPosts(
    FetchCommunityPosts event,
    Emitter<CommunityState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(status: CommunityStatus.loading));

    try {
      Query query = _firestore
          .collection('community_posts')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(event.limit);

      if (event.lastDocId != null) {
        final lastDoc = await _firestore
            .collection('community_posts')
            .doc(event.lastDocId)
            .get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();
      final posts = snapshot.docs
          .map((doc) => CommunityPostModel.fromFirestore(doc))
          .toList();

      emit(state.copyWith(
        status: CommunityStatus.loaded,
        posts: posts,
        hasMore: posts.length == event.limit,
        lastDocId: posts.isNotEmpty ? posts.last.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'فشل تحميل المنشورات: $e',
      ));
    }
  }

  // ============================================================
  // 📋 تحميل المزيد
  // ============================================================
  Future<void> _onLoadMore(
    LoadMoreCommunityPosts event,
    Emitter<CommunityState> emit,
  ) async {
    if (state.isLoading || !state.hasMore) return;

    emit(state.copyWith(status: CommunityStatus.loading));

    try {
      Query query = _firestore
          .collection('community_posts')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(
            await _firestore.collection('community_posts').doc(state.lastDocId).get()
          )
          .limit(event.limit);

      final snapshot = await query.get();
      final newPosts = snapshot.docs
          .map((doc) => CommunityPostModel.fromFirestore(doc))
          .toList();

      emit(state.copyWith(
        status: CommunityStatus.loaded,
        posts: [...state.posts, ...newPosts],
        hasMore: newPosts.length == event.limit,
        lastDocId: newPosts.isNotEmpty ? newPosts.last.id : state.lastDocId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'فشل تحميل المزيد: $e',
      ));
    }
  }

  // ============================================================
  // 📝 إنشاء منشور
  // ============================================================
  Future<void> _onCreatePost(
    CreateCommunityPost event,
    Emitter<CommunityState> emit,
  ) async {
    emit(state.copyWith(
      status: CommunityStatus.creating,
      isUploading: true,
      uploadProgress: 0,
    ));

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      // 📤 رفع الملفات
      List<String> uploadedUrls = [];
      if (event.files != null && event.files!.isNotEmpty) {
        for (var i = 0; i < event.files!.length; i++) {
          final file = event.files![i];
          final result = await _nextcloud.uploadFile(
            file: File(file.path!),
            path: 'community/${user.uid}',
            fileName: file.name,
            onProgress: (sent, total) {
              final progress = (i + sent / total) / event.files!.length;
              emit(state.copyWith(uploadProgress: progress));
            },
          );

          if (result.success && result.url != null) {
            uploadedUrls.add(result.url!);
          }
        }
      }

      // 👤 جلب بيانات المستخدم
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final userName = userData['name'] ?? user.displayName ?? 'مستخدم';

      // 📝 إنشاء المنشور
      final post = CommunityPostModel(
        id: '',
        userId: user.uid,
        userName: userName,
        userAvatar: userData['avatar'] ?? userName[0],
        title: event.title,
        content: event.content,
        imageUrl: uploadedUrls.isNotEmpty ? uploadedUrls[0] : null,
        images: uploadedUrls,
        category: event.category ?? 'عام',
        isDoctorPost: userData['role'] == 'doctor',
        isVerified: userData['isVerified'] ?? false,
        createdAt: DateTime.now(),
        isPublished: true,
      );

      // 💾 حفظ في Firestore
      final docRef = await _firestore.collection('community_posts').add(post.toFirestore());
      final savedPost = post.copyWith(id: docRef.id);

      emit(state.copyWith(
        status: CommunityStatus.loaded,
        posts: [savedPost, ...state.posts],
        isUploading: false,
        uploadProgress: 0,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'فشل إنشاء المنشور: $e',
        isUploading: false,
        uploadProgress: 0,
      ));
    }
  }

  // ============================================================
  // 🗑️ حذف منشور
  // ============================================================
  Future<void> _onDeletePost(
    DeleteCommunityPost event,
    Emitter<CommunityState> emit,
  ) async {
    emit(state.copyWith(status: CommunityStatus.deleting));

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final postDoc = await _firestore.collection('community_posts').doc(event.postId).get();
      if (!postDoc.exists) throw Exception('المنشور غير موجود');

      final postData = postDoc.data()!;
      if (postData['userId'] != user.uid) {
        throw Exception('ليس لديك صلاحية الحذف');
      }

      // حذف الملفات من NextCloud
      final mediaUrls = List<String>.from(postData['mediaUrls'] ?? []);
      for (final url in mediaUrls) {
        final path = url.replaceAll(
          '${_nextcloud.baseUrl}/remote.php/dav/files/${_nextcloud.username}/',
          '',
        );
        await _nextcloud.deleteFile(path);
      }

      await _firestore.collection('community_posts').doc(event.postId).delete();

      final posts = List<CommunityPostModel>.from(state.posts)
          ..removeWhere((p) => p.id == event.postId);

      emit(state.copyWith(
        status: CommunityStatus.loaded,
        posts: posts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CommunityStatus.error,
        errorMessage: 'فشل حذف المنشور: $e',
      ));
    }
  }

  // ============================================================
  // ❤️ تفاعلات
  // ============================================================
  Future<void> _onToggleLike(
    ToggleLikePost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final postRef = _firestore.collection('community_posts').doc(event.postId);
      final likeRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('liked_posts')
          .doc(event.postId);

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) return;

        final likeDoc = await transaction.get(likeRef);
        final currentLikes = (postDoc.data()?['likes'] as num?)?.toInt() ?? 0;

        if (likeDoc.exists) {
          transaction.update(postRef, {'likes': currentLikes - 1});
          transaction.delete(likeRef);
        } else {
          transaction.update(postRef, {'likes': currentLikes + 1});
          transaction.set(likeRef, {
            'postId': event.postId,
            'likedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // تحديث الحالة المحلية
      final posts = List<CommunityPostModel>.from(state.posts);
      if (event.index < posts.length) {
        final post = posts[event.index];
        final isLiked = post.isLiked;
        posts[event.index] = post.copyWith(
          isLiked: !isLiked,
          likes: isLiked ? post.likes - 1 : post.likes + 1,
        );
        emit(state.copyWith(posts: posts));
      }
    } catch (e) {
      // تجاهل الخطأ في الواجهة
    }
  }

  Future<void> _onSavePost(
    SaveCommunityPost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final saveRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('saved_posts')
          .doc(event.postId);

      final doc = await saveRef.get();
      if (doc.exists) {
        await saveRef.delete();
      } else {
        final postDoc = await _firestore.collection('community_posts').doc(event.postId).get();
        await saveRef.set({
          'postId': event.postId,
          'title': postDoc.data()?['title'] ?? '',
          'imageUrl': postDoc.data()?['imageUrl'] ?? '',
          'savedAt': FieldValue.serverTimestamp(),
        });
      }

      final posts = List<CommunityPostModel>.from(state.posts);
      if (event.index < posts.length) {
        final post = posts[event.index];
        posts[event.index] = post.copyWith(isSaved: !post.isSaved);
        emit(state.copyWith(posts: posts));
      }
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  Future<void> _onReportPost(
    ReportCommunityPost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      await _firestore.collection('reports').add({
        'postId': event.postId,
        'userId': user.uid,
        'reason': event.reason ?? 'محتوى غير مناسب',
        'reportedAt': FieldValue.serverTimestamp(),
      });

      final posts = List<CommunityPostModel>.from(state.posts);
      if (event.index < posts.length) {
        posts[event.index] = posts[event.index].copyWith(isReported: true);
        emit(state.copyWith(posts: posts));
      }
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  Future<void> _onSharePost(
    ShareCommunityPost event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      await _firestore
          .collection('community_posts')
          .doc(event.postId)
          .update({'shares': FieldValue.increment(1)});

      final posts = List<CommunityPostModel>.from(state.posts);
      if (event.index < posts.length) {
        final post = posts[event.index];
        posts[event.index] = post.copyWith(shares: post.shares + 1);
        emit(state.copyWith(posts: posts));
      }
    } catch (e) {
      // تجاهل الخطأ
    }
  }

  Future<void> _onAddComment(
    AddCommunityComment event,
    Emitter<CommunityState> emit,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      await _firestore.runTransaction((transaction) async {
        final postRef = _firestore.collection('community_posts').doc(event.postId);
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) return;

        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data() ?? {};
        final userName = userData['name'] ?? user.displayName ?? 'مستخدم';

        final commentRef = postRef.collection('comments').doc();
        transaction.set(commentRef, {
          'userId': user.uid,
          'userName': userName,
          'userAvatar': userData['avatar'] ?? userName[0],
          'comment': event.comment,
          'timestamp': FieldValue.serverTimestamp(),
          'replies': [],
        });

        final currentComments = (postDoc.data()?['comments'] as num?)?.toInt() ?? 0;
        transaction.update(postRef, {'comments': currentComments + 1});
      });

      final posts = List<CommunityPostModel>.from(state.posts);
      if (event.index < posts.length) {
        final post = posts[event.index];
        posts[event.index] = post.copyWith(comments: post.comments + 1);
        emit(state.copyWith(posts: posts));
      }
    } catch (e) {
      // تجاهل الخطأ
    }
  }
}
