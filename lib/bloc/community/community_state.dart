// ============================================================
// 📁 lib/bloc/community/community_state.dart
// 📊 حالة المجتمع
// ============================================================

import 'package:equatable/equatable.dart';
import 'package:sehatak/core/models/community/community_post_model.dart';

enum CommunityStatus {
  initial,
  loading,
  loaded,
  error,
  creating,
  deleting,
  refreshing,
}

class CommunityState extends Equatable {
  final CommunityStatus status;
  final String? errorMessage;
  final List<CommunityPostModel> posts;
  final bool hasMore;
  final String? lastDocId;
  final bool isUploading;
  final double uploadProgress;

  const CommunityState({
    this.status = CommunityStatus.initial,
    this.errorMessage,
    this.posts = const [],
    this.hasMore = true,
    this.lastDocId,
    this.isUploading = false,
    this.uploadProgress = 0,
  });

  CommunityState copyWith({
    CommunityStatus? status,
    String? errorMessage,
    List<CommunityPostModel>? posts,
    bool? hasMore,
    String? lastDocId,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return CommunityState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      lastDocId: lastDocId ?? this.lastDocId,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  bool get isLoading => status == CommunityStatus.loading;
  bool get isCreating => status == CommunityStatus.creating;
  bool get isDeleting => status == CommunityStatus.deleting;
  bool get isRefreshing => status == CommunityStatus.refreshing;
  bool get hasError => status == CommunityStatus.error;
  bool get isLoaded => status == CommunityStatus.loaded;

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    posts,
    hasMore,
    lastDocId,
    isUploading,
    uploadProgress,
  ];
}
