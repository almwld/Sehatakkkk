class LabTestModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final String preparation;
  final String sampleType;
  final String turnaroundTime;
  final bool isAvailable;
  final double rating;
  final int reviews;
  final DateTime createdAt;

  LabTestModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.preparation,
    required this.sampleType,
    required this.turnaroundTime,
    required this.isAvailable,
    this.rating = 0.0,
    this.reviews = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'price': price,
      'preparation': preparation,
      'sampleType': sampleType,
      'turnaroundTime': turnaroundTime,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviews': reviews,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LabTestModel.fromMap(Map<String, dynamic> map) {
    return LabTestModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      preparation: map['preparation'] ?? '',
      sampleType: map['sampleType'] ?? '',
      turnaroundTime: map['turnaroundTime'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
