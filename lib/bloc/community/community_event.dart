// ============================================================
// 📁 lib/bloc/community/community_event.dart
// 🎯 أحداث المجتمع
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();
  @override
  List<Object?> get props => [];
}

// ✅ جلب المنشورات
class FetchCommunityPosts extends CommunityEvent {
  final int limit;
  final String? lastDocId;
  const FetchCommunityPosts({this.limit = 10, this.lastDocId});
  @override
  List<Object?> get props => [limit, lastDocId];
}

// ✅ إنشاء منشور
class CreateCommunityPost extends CommunityEvent {
  final String title;
  final String? content;
  final List<PlatformFile>? files;
  final String? category;
  const CreateCommunityPost({
    required this.title,
    this.content,
    this.files,
    this.category,
  });
  @override
  List<Object?> get props => [title, content, files, category];
}

// ✅ حذف منشور
class DeleteCommunityPost extends CommunityEvent {
  final String postId;
  const DeleteCommunityPost({required this.postId});
  @override
  List<Object?> get props => [postId];
}

// ✅ إعجاب
class ToggleLikePost extends CommunityEvent {
  final String postId;
  final int index;
  const ToggleLikePost({required this.postId, required this.index});
  @override
  List<Object?> get props => [postId, index];
}

// ✅ حفظ
class SaveCommunityPost extends CommunityEvent {
  final String postId;
  final int index;
  const SaveCommunityPost({required this.postId, required this.index});
  @override
  List<Object?> get props => [postId, index];
}

// ✅ إبلاغ
class ReportCommunityPost extends CommunityEvent {
  final String postId;
  final int index;
  final String? reason;
  const ReportCommunityPost({required this.postId, required this.index, this.reason});
  @override
  List<Object?> get props => [postId, index, reason];
}

// ✅ مشاركة
class ShareCommunityPost extends CommunityEvent {
  final String postId;
  final int index;
  const ShareCommunityPost({required this.postId, required this.index});
  @override
  List<Object?> get props => [postId, index];
}

// ✅ إضافة تعليق
class AddCommunityComment extends CommunityEvent {
  final String postId;
  final int index;
  final String comment;
  const AddCommunityComment({
    required this.postId,
    required this.index,
    required this.comment,
  });
  @override
  List<Object?> get props => [postId, index, comment];
}

// ✅ تحميل المزيد
class LoadMoreCommunityPosts extends CommunityEvent {
  final int limit;
  const LoadMoreCommunityPosts({this.limit = 10});
  @override
  List<Object?> get props => [limit];
}
