class HospitalModel {
  final String id;
  final String name;
  final String location;
  final String image;
  final double rating;
  final String specialty;
  final bool open;

  const HospitalModel({
    required this.id,
    required this.name,
    required this.location,
    required this.image,
    required this.rating,
    required this.specialty,
    required this.open,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) => HospitalModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    location: json['location'] ?? '',
    image: json['image'] ?? '',
    rating: (json['rating'] ?? 0.0).toDouble(),
    specialty: json['specialty'] ?? '',
    open: json['open'] ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'image': image,
    'rating': rating,
    'specialty': specialty,
    'open': open,
  };
}
