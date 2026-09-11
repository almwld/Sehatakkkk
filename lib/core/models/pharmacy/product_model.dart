import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ProductCategory { painkiller, antibiotic, vitamin, supplement, medicalDevice, skincare, baby, diabetes, heart, bloodPressure, allergy, digestive, respiratory, neurology, dermatology, ophthalmology, dental, womenHealth, menHealth, elderly, firstAid, medicalSupplies }

class ProductModel {
  final String id, name, nameEn, description;
  final ProductCategory category;
  final double price;
  final double? discount;
  final String? imageUrl, manufacturer, barcode, dosage, usage, sideEffects, interactions, storageInstructions;
  final int stockQuantity, reviewsCount;
  final bool prescriptionRequired, inStock;
  final double rating;
  final List<String> keywords;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final List<String>? alternativeProducts;
  final Map<String, dynamic>? metadata;

  ProductModel({required this.id, required this.name, required this.nameEn, required this.category, required this.description, required this.price, this.discount, this.imageUrl, this.manufacturer, this.barcode, required this.stockQuantity, this.dosage, this.usage, this.sideEffects, this.interactions, this.prescriptionRequired = false, this.inStock = true, this.rating = 0.0, this.reviewsCount = 0, this.keywords = const [], required this.createdAt, this.expiryDate, this.storageInstructions, this.alternativeProducts, this.metadata});

  String get categoryText => switch (category) {
    ProductCategory.painkiller => 'مسكنات', ProductCategory.antibiotic => 'مضادات حيوية', ProductCategory.vitamin => 'فيتامينات', ProductCategory.supplement => 'مكملات غذائية', ProductCategory.medicalDevice => 'أجهزة طبية', ProductCategory.skincare => 'عناية بالبشرة', ProductCategory.baby => 'منتجات أطفال', ProductCategory.diabetes => 'أدوية السكري', ProductCategory.heart => 'أدوية القلب', ProductCategory.bloodPressure => 'أدوية الضغط', ProductCategory.allergy => 'أدوية الحساسية', ProductCategory.digestive => 'أدوية الجهاز الهضمي', ProductCategory.respiratory => 'أدوية الجهاز التنفسي', ProductCategory.neurology => 'أدوية الأعصاب', ProductCategory.dermatology => 'أدوية جلدية', ProductCategory.ophthalmology => 'أدوية العيون', ProductCategory.dental => 'عناية بالأسنان', ProductCategory.womenHealth => 'صحة المرأة', ProductCategory.menHealth => 'صحة الرجل', ProductCategory.elderly => 'رعاية كبار السن', ProductCategory.firstAid => 'إسعافات أولية', ProductCategory.medicalSupplies => 'مستلزمات طبية',
  };
  IconData get categoryIcon => Icons.medication;
  Color get categoryColor => Colors.teal;
  double get priceWithDiscount => discount != null ? price * (1 - discount! / 100) : price;
  double get discountAmount => discount != null ? price * discount! / 100 : 0.0;
  bool get isDiscounted => discount != null && discount! > 0;
  bool get isLowStock => stockQuantity < 10;
  bool get isOutOfStock => stockQuantity <= 0;

  Map<String, dynamic> toFirestore() => {
    'name': name, 'nameEn': nameEn, 'category': category.name, 'description': description, 'price': price, 'discount': discount, 'imageUrl': imageUrl, 'manufacturer': manufacturer, 'barcode': barcode, 'stockQuantity': stockQuantity, 'dosage': dosage, 'usage': usage, 'sideEffects': sideEffects, 'interactions': interactions, 'prescriptionRequired': prescriptionRequired, 'inStock': inStock, 'rating': rating, 'reviewsCount': reviewsCount, 'keywords': keywords, 'createdAt': createdAt.toIso8601String(), 'expiryDate': expiryDate?.toIso8601String(), 'storageInstructions': storageInstructions, 'alternativeProducts': alternativeProducts, 'metadata': metadata,
  };
  Map<String, dynamic> toJson() => toFirestore();

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) => ProductModel(id: id, name: data['name']?.toString() ?? '', nameEn: data['nameEn']?.toString() ?? '', category: _parseCategory(data['category']?.toString() ?? 'supplement'), description: data['description']?.toString() ?? '', price: (data['price'] as num?)?.toDouble() ?? 0.0, discount: (data['discount'] as num?)?.toDouble(), imageUrl: data['imageUrl']?.toString(), manufacturer: data['manufacturer']?.toString(), barcode: data['barcode']?.toString(), stockQuantity: (data['stockQuantity'] as num?)?.toInt() ?? 0, dosage: data['dosage']?.toString(), usage: data['usage']?.toString(), sideEffects: data['sideEffects']?.toString(), interactions: data['interactions']?.toString(), prescriptionRequired: data['prescriptionRequired'] == true, inStock: data['inStock'] != false, rating: (data['rating'] as num?)?.toDouble() ?? 0.0, reviewsCount: (data['reviewsCount'] as num?)?.toInt() ?? 0, keywords: List<String>.from(data['keywords'] ?? const []), createdAt: _dateValue(data['createdAt']) ?? DateTime.now(), expiryDate: _dateValue(data['expiryDate']), storageInstructions: data['storageInstructions']?.toString(), alternativeProducts: data['alternativeProducts'] == null ? null : List<String>.from(data['alternativeProducts']), metadata: data['metadata'] is Map ? Map<String, dynamic>.from(data['metadata']) : null);
  factory ProductModel.fromJson(Map<String, dynamic> data) => ProductModel.fromFirestore(data, data['id']?.toString() ?? '');
  static DateTime? _dateValue(dynamic value) { if (value is Timestamp) return value.toDate(); if (value is DateTime) return value; return value is String ? DateTime.tryParse(value) : null; }
  static ProductCategory _parseCategory(String value) => ProductCategory.values.firstWhere((c) => c.name == value, orElse: () => ProductCategory.painkiller);
}
