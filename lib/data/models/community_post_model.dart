class CommunityPostModel {
  final int id;
  final String author;
  final String avatar;
  final String? image;
  final String title;
  final String content;
  int likes;
  int comments;
  int shares;
  final String time;
  bool liked;
  final List<String> commentList;

  CommunityPostModel({
    required this.id,
    required this.author,
    required this.avatar,
    this.image,
    required this.title,
    required this.content,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.time,
    required this.liked,
    required this.commentList,
  });

  factory CommunityPostModel.fromJson(Map<String, dynamic> json) => CommunityPostModel(
    id: json['id'] ?? 0,
    author: json['author'] ?? '',
    avatar: json['avatar'] ?? '',
    image: json['image'],
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    likes: json['likes'] ?? 0,
    comments: json['comments'] ?? 0,
    shares: json['shares'] ?? 0,
    time: json['time'] ?? '',
    liked: json['liked'] ?? false,
    commentList: List<String>.from(json['commentList'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'author': author,
    'avatar': avatar,
    'image': image,
    'title': title,
    'content': content,
    'likes': likes,
    'comments': comments,
    'shares': shares,
    'time': time,
    'liked': liked,
    'commentList': commentList,
  };
}
