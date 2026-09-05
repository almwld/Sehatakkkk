class DoctorBookingModel {
  final String id;
  final String name;
  final String specialty;
  final String specialtyId;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final bool isAvailable;

  const DoctorBookingModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.specialtyId,
    this.imageUrl = '',
    this.rating = 0,
    this.reviewsCount = 0,
    this.isAvailable = true,
  });

  factory DoctorBookingModel.fromMap(Map<String, dynamic> map) {
    return DoctorBookingModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      specialty: map['specialty'] ?? '',
      specialtyId: map['specialtyId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: map['reviewsCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'specialtyId': specialtyId,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'isAvailable': isAvailable,
    };
  }
}
