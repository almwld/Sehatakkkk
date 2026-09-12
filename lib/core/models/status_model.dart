import 'package:cloud_firestore/cloud_firestore.dart';

class StoryItem {
  final String type;
  final String url;
  final String? text;
  final Duration duration;

  const StoryItem({
    required this.type,
    this.url = '',
    this.text,
    this.duration = const Duration(seconds: 5),
  });

  factory StoryItem.fromMap(Map<String, dynamic> data) {
    final seconds = (data['durationSeconds'] as num?)?.toInt() ?? 5;
    final safeSeconds = seconds.clamp(3, 15).toInt();
    return StoryItem(
      type: data['type']?.toString() ?? 'text',
      url: data['url']?.toString() ?? '',
      text: data['text']?.toString(),
      duration: Duration(seconds: safeSeconds),
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'url': url,
        'text': text,
        'durationSeconds': duration.inSeconds,
      };
}

class UserStatusModel {
  final String id;
  final String userId;
  final String userName;
  final String? userImage;
  final List<StoryItem> stories;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isViewed;

  const UserStatusModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.stories,
    required this.createdAt,
    required this.expiresAt,
    this.userImage,
    this.isViewed = false,
  });

  bool get isValid => DateTime.now().isBefore(expiresAt);

  factory UserStatusModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document, {
    bool isViewed = false,
  }) {
    final data = document.data() ?? <String, dynamic>{};
    final created = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final expires = (data['expiresAt'] as Timestamp?)?.toDate() ?? created.add(const Duration(hours: 24));
    final rawStories = data['stories'];
    final stories = rawStories is List
        ? rawStories.whereType<Map>().map((item) => StoryItem.fromMap(Map<String, dynamic>.from(item))).toList()
        : <StoryItem>[];

    return UserStatusModel(
      id: document.id,
      userId: data['userId']?.toString() ?? '',
      userName: data['userName']?.toString().trim().isNotEmpty == true ? data['userName'].toString() : 'مستخدم',
      userImage: data['userImage']?.toString(),
      stories: stories,
      createdAt: created,
      expiresAt: expires,
      isViewed: isViewed,
    );
  }
}
