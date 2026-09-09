import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/bloc/community/community_event.dart';
import 'package:sehatak/bloc/community/community_state.dart';
import 'package:sehatak/core/models/community_post_model.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NextcloudService _nextcloud = NextcloudService();

  CommunityBloc() : super(const CommunityState()) {
    on<FetchCommunityPosts>(_onFetchPosts);
    on<CreateCommunityPost>(_onCreatePost);
    on<DeleteCommunityPost>(_onDeletePost);
    on<ToggleLikePost>(_onToggleLike);
    on<SaveCommunityPost>(_onSavePost);
    on<ReportCommunityPost>(_onReportPost);
    on<ShareCommunityPost>(_onSharePost);
    on<AddCommunityComment>(_onAddComment);
  }

  Future<void> _onFetchPosts(FetchCommunityPosts event, Emitter<CommunityState> emit) async {
    if (state.isLoading) return;
    emit(state.copyWith(status: CommunityStatus.loading));
    try {
      final snapshot = await _firestore
          .collection('community_posts')
          .where('isPublished', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(event.limit)
          .get();
      final posts = snapshot.docs.map(CommunityPostModel.fromFirestore).toList();
      emit(state.copyWith(
        status: CommunityStatus.loaded,
        posts: posts,
        hasMore: posts.length == event.limit,
        lastDocId: posts.isNotEmpty ? posts.last.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, errorMessage: 'فشل تحميل المنشورات: $e'));
    }
  }

  Future<void> _onCreatePost(CreateCommunityPost event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.creating, isUploading: true, uploadProgress: 0));
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      final role = userData['role']?.toString();
      final verified = userData['isVerified'] == true;
      if (role != 'doctor' || !verified) {
        throw Exception('النشر متاح للأطباء الموثقين فقط');
      }

      final userName = (userData['name'] ?? user.displayName ?? 'طبيب').toString();
      final files = event.files ?? const <PlatformFile>[];
      final mediaUrls = <String>[];
      final mediaNames = <String>[];

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        if (file.path == null) continue;
        final upload = await _nextcloud.uploadFile(
          file: File(file.path!),
          path: 'sehatak/community/${user.uid}',
          fileName: '${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          onProgress: (sent, total) {
            if (total > 0) {
              final progress = ((i + sent / total) / files.length).clamp(0.0, 1.0);
              emit(state.copyWith(uploadProgress: progress));
            }
          },
        );
        if (!upload.success || upload.url == null) {
          throw Exception(upload.error ?? 'فشل رفع الوسائط إلى Nextcloud');
        }
        mediaUrls.add(upload.url!);
        mediaNames.add(file.name);
      }

      final tags = _extractTags('${event.title} ${event.content ?? ''}');
      final post = CommunityPostModel(
        id: '',
        userId: user.uid,
        userName: userName,
        userAvatar: userData['avatar']?.toString(),
        title: event.title.trim(),
        content: event.content?.trim(),
        imageUrl: mediaUrls.isEmpty ? null : mediaUrls.first,
        images: mediaUrls,
        category: event.category ?? 'عام',
        tags: tags,
        isDoctorPost: true,
        isVerified: true,
        createdAt: DateTime.now(),
        isPublished: true,
      );

      final docRef = await _firestore.collection('community_posts').add({
        ...post.toFirestore(),
        'mediaNames': mediaNames,
        'mediaCount': mediaUrls.length,
        'mediaStorage': 'nextcloud',
        'mediaOwnerId': user.uid,
      });
      final savedPost = post.copyWith(id: docRef.id);
      emit(state.copyWith(
        status: CommunityStatus.loaded,
        posts: [savedPost, ...state.posts],
        isUploading: false,
        uploadProgress: 0,
      ));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, errorMessage: 'فشل إنشاء المنشور: $e', isUploading: false, uploadProgress: 0));
    }
  }

  List<String> _extractTags(String value) {
    final matches = RegExp(r'#[\w\u0600-\u06FF]+').allMatches(value);
    return matches.map((m) => m.group(0)!).toSet().toList();
  }

  Future<void> _onDeletePost(DeleteCommunityPost event, Emitter<CommunityState> emit) async {
    emit(state.copyWith(status: CommunityStatus.deleting));
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      final ref = _firestore.collection('community_posts').doc(event.postId);
      final doc = await ref.get();
      if (!doc.exists || doc.data()?['userId'] != user.uid) throw Exception('ليس لديك صلاحية الحذف');
      await ref.delete();
      final posts = List<CommunityPostModel>.from(state.posts)..removeWhere((p) => p.id == event.postId);
      emit(state.copyWith(status: CommunityStatus.loaded, posts: posts));
    } catch (e) {
      emit(state.copyWith(status: CommunityStatus.error, errorMessage: 'فشل حذف المنشور: $e'));
    }
  }

  Future<void> _onToggleLike(ToggleLikePost event, Emitter<CommunityState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      final postRef = _firestore.collection('community_posts').doc(event.postId);
      final likeRef = _firestore.collection('users').doc(user.uid).collection('liked_posts').doc(event.postId);
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw Exception('المنشور غير موجود');
        final likeDoc = await transaction.get(likeRef);
        final likes = (postDoc.data()?['likes'] as num?)?.toInt() ?? 0;
        if (likeDoc.exists) {
          transaction.update(postRef, {'likes': likes > 0 ? likes - 1 : 0});
          transaction.delete(likeRef);
        } else {
          transaction.update(postRef, {'likes': likes + 1});
          transaction.set(likeRef, {'postId': event.postId, 'likedAt': FieldValue.serverTimestamp()});
        }
      });
      if (event.index < state.posts.length) {
        final posts = List<CommunityPostModel>.from(state.posts);
        final post = posts[event.index];
        posts[event.index] = post.copyWith(isLiked: !post.isLiked, likes: post.isLiked ? (post.likes > 0 ? post.likes - 1 : 0) : post.likes + 1);
        emit(state.copyWith(posts: posts));
      }
    } catch (_) {}
  }

  Future<void> _onSavePost(SaveCommunityPost event, Emitter<CommunityState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      final saveRef = _firestore.collection('users').doc(user.uid).collection('saved_posts').doc(event.postId);
      final doc = await saveRef.get();
      if (doc.exists) {
        await saveRef.delete();
      } else {
        await saveRef.set({'postId': event.postId, 'savedAt': FieldValue.serverTimestamp()});
      }
      if (event.index < state.posts.length) {
        final posts = List<CommunityPostModel>.from(state.posts);
        posts[event.index] = posts[event.index].copyWith(isSaved: !posts[event.index].isSaved);
        emit(state.copyWith(posts: posts));
      }
    } catch (_) {}
  }

  Future<void> _onReportPost(ReportCommunityPost event, Emitter<CommunityState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      await _firestore.collection('reports').add({
        'type': 'community_post',
        'postId': event.postId,
        'userId': user.uid,
        'reason': event.reason ?? 'محتوى غير مناسب',
        'reportedAt': FieldValue.serverTimestamp(),
      });
      if (event.index < state.posts.length) {
        final posts = List<CommunityPostModel>.from(state.posts);
        posts[event.index] = posts[event.index].copyWith(isReported: true);
        emit(state.copyWith(posts: posts));
      }
    } catch (_) {}
  }

  Future<void> _onSharePost(ShareCommunityPost event, Emitter<CommunityState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      await _firestore.collection('community_posts').doc(event.postId).update({
        'shares': FieldValue.increment(1),
        'lastSharedAt': FieldValue.serverTimestamp(),
      });
      await _firestore.collection('community_posts').doc(event.postId).collection('share_events').add({
        'userId': user.uid,
        'sharedAt': FieldValue.serverTimestamp(),
      });
      if (event.index < state.posts.length) {
        final posts = List<CommunityPostModel>.from(state.posts);
        posts[event.index] = posts[event.index].copyWith(shares: posts[event.index].shares + 1);
        emit(state.copyWith(posts: posts));
      }
    } catch (_) {}
  }

  Future<void> _onAddComment(AddCommunityComment event, Emitter<CommunityState> emit) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('يجب تسجيل الدخول');
      final postRef = _firestore.collection('community_posts').doc(event.postId);
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? <String, dynamic>{};
      final userName = (userData['name'] ?? user.displayName ?? 'مستخدم').toString();
      final commentRef = _firestore.collection('comments').doc();
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw Exception('المنشور غير موجود');
        final current = (postDoc.data()?['comments'] as num?)?.toInt() ?? 0;
        transaction.set(commentRef, {
          'postId': event.postId,
          'userId': user.uid,
          'userName': userName,
          'userAvatar': userData['avatar'],
          'comment': event.comment.trim(),
          'timestamp': FieldValue.serverTimestamp(),
          'repliesCount': 0,
        });
        transaction.update(postRef, {'comments': current + 1});
      });
      if (event.index < state.posts.length) {
        final posts = List<CommunityPostModel>.from(state.posts);
        posts[event.index] = posts[event.index].copyWith(comments: posts[event.index].comments + 1);
        emit(state.copyWith(posts: posts));
      }
    } catch (_) {}
  }
}
