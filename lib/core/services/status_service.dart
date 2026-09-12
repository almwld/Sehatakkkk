import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'nextcloud_service.dart';
import '../models/status_model.dart';

class StatusService {
  StatusService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final NextcloudService _nextcloud = NextcloudService();

  CollectionReference<Map<String, dynamic>> get _statuses => _firestore.collection('statuses');

  Stream<List<UserStatusModel>> streamActiveStatuses() {
    return _statuses
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(DateTime.now()))
        .snapshots()
        .asyncMap(_withViewState)
        .map((items) {
      items.removeWhere((item) => !item.isValid || item.stories.isEmpty);
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  Future<List<UserStatusModel>> _withViewState(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final uid = _auth.currentUser?.uid;
    final items = <UserStatusModel>[];
    for (final document in snapshot.docs) {
      final viewed = uid == null
          ? false
          : (await document.reference.collection('views').doc(uid).get()).exists;
      items.add(UserStatusModel.fromDocument(document, isViewed: viewed));
    }
    return items;
  }

  Future<String> createStatus({
    required List<StoryItem> stories,
    String? userName,
    String? userImage,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول لإضافة حالة.');
    if (stories.isEmpty) throw StateError('أضف محتوى واحداً على الأقل.');

    final now = DateTime.now();
    final ref = _statuses.doc();
    await ref.set({
      'userId': user.uid,
      'userName': (userName ?? user.displayName ?? 'مستخدم').trim(),
      'userImage': userImage ?? user.photoURL,
      'stories': stories.map((story) => story.toMap()).toList(),
      'createdAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(hours: 24))),
      'createdBy': user.uid,
    });
    return ref.id;
  }

  Future<StoryItem> uploadMediaStory({
    required File file,
    required String type,
    Duration duration = const Duration(seconds: 5),
  }) async {
    await _nextcloud.loadConfig();
    final extension = file.path.contains('.') ? file.path.split('.').last : 'bin';
    final name = 'story_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final result = await _nextcloud.uploadFile(
      file: file,
      path: 'stories/${_auth.currentUser?.uid ?? 'anonymous'}',
      fileName: name,
      createShare: true,
    );
    if (!result.success || result.url == null || result.url!.isEmpty) {
      throw StateError(result.error ?? 'تعذر رفع الحالة.');
    }
    return StoryItem(type: type, url: result.url!, duration: duration);
  }

  Future<void> markViewed(UserStatusModel status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid == status.userId) return;
    await _statuses.doc(status.id).collection('views').doc(uid).set({
      'userId': uid,
      'viewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> addReaction({
    required UserStatusModel status,
    required String emoji,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _statuses.doc(status.id).collection('reactions').doc(uid).set({
      'userId': uid,
      'emoji': emoji,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addReply({
    required UserStatusModel status,
    required String text,
  }) async {
    final uid = _auth.currentUser?.uid;
    final clean = text.trim();
    if (uid == null || clean.isEmpty) return;
    final user = _auth.currentUser;
    await _statuses.doc(status.id).collection('replies').add({
      'userId': uid,
      'userName': user?.displayName ?? 'مستخدم',
      'text': clean,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
