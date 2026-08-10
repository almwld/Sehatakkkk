class LabModel {
  final String id;
  final String name;
  final String location;
  final String image;
  final double rating;
  final bool open;

  const LabModel({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    required this.open,
  });

  factory LabModel.fromJson(Map<String, dynamic> json) => LabModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    location: json['location'] ?? '',
    image: json['image'] ?? '',
    rating: (json['rating'] ?? 0.0).toDouble(),
    open: json['open'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'image': image,
    'rating': rating,
    'open': open,
  };
}
