import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
class ProductModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final double? discountPrice;
  final String image;
  final String pharmacyId;
  final String pharmacyName;
  final int stock;
  final String unit;
  final bool isAvailable;
  final List<String>? tags;
  final double rating;
  final int reviews;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.image,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.stock,
    required this.unit,
    required this.isAvailable,
    this.tags,
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
      'discountPrice': discountPrice,
      'image': image,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
      'stock': stock,
      'unit': unit,
      'isAvailable': isAvailable,
      'tags': tags,
      'rating': rating,
      'reviews': reviews,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      discountPrice: map['discountPrice']?.toDouble(),
      image: map['image'] ?? '',
      pharmacyId: map['pharmacyId'] ?? '',
      pharmacyName: map['pharmacyName'] ?? '',
      stock: map['stock'] ?? 0,
      unit: map['unit'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews'] ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
