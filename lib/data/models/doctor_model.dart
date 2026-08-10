class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String image;
  final String gender;

  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.image,
    this.gender = 'male',
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    specialty: json['specialty'] ?? '',
    rating: (json['rating'] ?? 0.0).toDouble(),
    reviews: json['reviews'] ?? 0,
    image: json['image'] ?? '',
    gender: json['gender'] ?? 'male',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'specialty': specialty,
    'rating': rating,
    'reviews': reviews,
    'image': image,
    'gender': gender,
  };
}
