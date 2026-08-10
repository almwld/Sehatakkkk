class ArticleModel {
  final String title;
  final String category;
  final String time;
  final String image;

  const ArticleModel({
    required this.title,
    required this.category,
    required this.time,
    required this.image,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
    title: json['title'] ?? '',
    category: json['category'] ?? '',
    time: json['time'] ?? '',
    image: json['image'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'category': category,
    'time': time,
    'image': image,
  };
}
