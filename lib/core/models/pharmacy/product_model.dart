import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ProductCategory {
  painkiller,
  antibiotic,
  vitamin,
  supplement,
  medicalDevice,
  skincare,
  baby,
  diabetes,
  heart,
  bloodPressure,
  allergy,
  digestive,
  respiratory,
  neurology,
  dermatology,
  ophthalmology,
  dental,
  womenHealth,
  menHealth,
  elderly,
  firstAid,
  medicalSupplies,
}

class ProductModel {
  final String id;
  final String name;
  final String nameEn;
  final ProductCategory category;
  final String description;
  final double price;
  final double? discount;
  final String? imageUrl;
  final String? manufacturer;
  final String? barcode;
  final int stockQuantity;
  final String? dosage;
  final String? usage;
  final String? sideEffects;
  final String? interactions;
  final bool prescriptionRequired;
  final bool inStock;
  final double rating;
  final int reviewsCount;
  final List<String> keywords;
  final DateTime createdAt;
  final DateTime? expiryDate;
  final String? storageInstructions;
  final List<String>? alternativeProducts;
  final Map<String, dynamic>? metadata;

  ProductModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.description,
    required this.price,
    this.discount,
    this.imageUrl,
    this.manufacturer,
    this.barcode,
    required this.stockQuantity,
    this.dosage,
    this.usage,
    this.sideEffects,
    this.interactions,
    this.prescriptionRequired = false,
    this.inStock = true,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.keywords = const [],
    required this.createdAt,
    this.expiryDate,
    this.storageInstructions,
    this.alternativeProducts,
    this.metadata,
  });

  String get categoryText {
    switch (category) {
      case ProductCategory.painkiller: return 'مسكنات';
      case ProductCategory.antibiotic: return 'مضادات حيوية';
      case ProductCategory.vitamin: return 'فيتامينات';
      case ProductCategory.supplement: return 'مكملات غذائية';
      case ProductCategory.medicalDevice: return 'أجهزة طبية';
      case ProductCategory.skincare: return 'عناية بالبشرة';
      case ProductCategory.baby: return 'منتجات أطفال';
      case ProductCategory.diabetes: return 'أدوية السكري';
      case ProductCategory.heart: return 'أدوية القلب';
      case ProductCategory.bloodPressure: return 'أدوية الضغط';
      case ProductCategory.allergy: return 'أدوية الحساسية';
      case ProductCategory.digestive: return 'أدوية الجهاز الهضمي';
      case ProductCategory.respiratory: return 'أدوية الجهاز التنفسي';
      case ProductCategory.neurology: return 'أدوية الأعصاب';
      case ProductCategory.dermatology: return 'أدوية جلدية';
      case ProductCategory.ophthalmology: return 'أدوية العيون';
      case ProductCategory.dental: return 'عناية بالأسنان';
      case ProductCategory.womenHealth: return 'صحة المرأة';
      case ProductCategory.menHealth: return 'صحة الرجل';
      case ProductCategory.elderly: return 'رعاية كبار السن';
      case ProductCategory.firstAid: return 'إسعافات أولية';
      case ProductCategory.medicalSupplies: return 'مستلزمات طبية';
      default: return 'أخرى';
    }
  }

  IconData get categoryIcon {
    switch (category) {
      case ProductCategory.painkiller: return Icons.medication;
      case ProductCategory.antibiotic: return Icons.health_and_safety;
      case ProductCategory.vitamin: return Icons.apple;
      case ProductCategory.supplement: return Icons.fitness_center;
      case ProductCategory.medicalDevice: return Icons.medical_services;
      case ProductCategory.skincare: return Icons.spa;
      case ProductCategory.baby: return Icons.child_care;
      case ProductCategory.diabetes: return Icons.bloodtype;
      case ProductCategory.heart: return Icons.favorite;
      case ProductCategory.bloodPressure: return Icons.monitor_heart;
      case ProductCategory.allergy: return Icons.allergies;
      case ProductCategory.digestive: return Icons.restaurant;
      case ProductCategory.respiratory: return Icons.air;
      case ProductCategory.neurology: return Icons.psychology;
      case ProductCategory.dermatology: return Icons.skin;
      case ProductCategory.ophthalmology: return Icons.visibility;
      case ProductCategory.dental: return Icons.dentistry;
      case ProductCategory.womenHealth: return Icons.pregnant_woman;
      case ProductCategory.menHealth: return Icons.male;
      case ProductCategory.elderly: return Icons.elderly;
      case ProductCategory.firstAid: return Icons.emergency;
      case ProductCategory.medicalSupplies: return Icons.inventory;
      default: return Icons.medication;
    }
  }

  Color get categoryColor {
    switch (category) {
      case ProductCategory.painkiller: return Colors.red;
      case ProductCategory.antibiotic: return Colors.purple;
      case ProductCategory.vitamin: return Colors.green;
      case ProductCategory.supplement: return Colors.orange;
      case ProductCategory.medicalDevice: return Colors.blue;
      case ProductCategory.skincare: return Colors.pink;
      case ProductCategory.baby: return Colors.lightBlue;
      case ProductCategory.diabetes: return Colors.deepOrange;
      case ProductCategory.heart: return Colors.redAccent;
      case ProductCategory.bloodPressure: return Colors.teal;
      case ProductCategory.allergy: return Colors.cyan;
      case ProductCategory.digestive: return Colors.brown;
      case ProductCategory.respiratory: return Colors.lightGreen;
      case ProductCategory.neurology: return Colors.indigo;
      case ProductCategory.dermatology: return Colors.purpleAccent;
      case ProductCategory.ophthalmology: return Colors.blueAccent;
      case ProductCategory.dental: return Colors.cyanAccent;
      case ProductCategory.womenHealth: return Colors.pinkAccent;
      case ProductCategory.menHealth: return Colors.blueGrey;
      case ProductCategory.elderly: return Colors.grey;
      case ProductCategory.firstAid: return Colors.redAccent;
      case ProductCategory.medicalSupplies: return Colors.lime;
      default: return Colors.grey;
    }
  }

  double get priceWithDiscount => discount != null ? price * (1 - discount! / 100) : price;
  double get discountAmount => discount != null ? price * discount! / 100 : 0.0;
  bool get isDiscounted => discount != null && discount! > 0;
  bool get isLowStock => stockQuantity < 10;
  bool get isOutOfStock => stockQuantity <= 0;

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'nameEn': nameEn,
    'category': category.toString().split('.').last,
    'description': description,
    'price': price,
    'discount': discount,
    'imageUrl': imageUrl,
    'manufacturer': manufacturer,
    'barcode': barcode,
    'stockQuantity': stockQuantity,
    'dosage': dosage,
    'usage': usage,
    'sideEffects': sideEffects,
    'interactions': interactions,
    'prescriptionRequired': prescriptionRequired,
    'inStock': inStock,
    'rating': rating,
    'reviewsCount': reviewsCount,
    'keywords': keywords,
    'createdAt': createdAt.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'storageInstructions': storageInstructions,
    'alternativeProducts': alternativeProducts,
    'metadata': metadata,
  };

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) => ProductModel(
    id: id,
    name: data['name'] ?? '',
    nameEn: data['nameEn'] ?? '',
    category: _parseCategory(data['category'] ?? 'supplement'),
    description: data['description'] ?? '',
    price: data['price']?.toDouble() ?? 0.0,
    discount: data['discount']?.toDouble(),
    imageUrl: data['imageUrl'],
    manufacturer: data['manufacturer'],
    barcode: data['barcode'],
    stockQuantity: data['stockQuantity'] ?? 0,
    dosage: data['dosage'],
    usage: data['usage'],
    sideEffects: data['sideEffects'],
    interactions: data['interactions'],
    prescriptionRequired: data['prescriptionRequired'] ?? false,
    inStock: data['inStock'] ?? true,
    rating: data['rating']?.toDouble() ?? 0.0,
    reviewsCount: data['reviewsCount'] ?? 0,
    keywords: List<String>.from(data['keywords'] ?? []),
    createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
    expiryDate: data['expiryDate'] != null ? DateTime.parse(data['expiryDate']) : null,
    storageInstructions: data['storageInstructions'],
    alternativeProducts: data['alternativeProducts'] != null ? List<String>.from(data['alternativeProducts']) : null,
    metadata: data['metadata'],
  );

  static ProductCategory _parseCategory(String value) {
    switch (value) {
      case 'antibiotic': return ProductCategory.antibiotic;
      case 'vitamin': return ProductCategory.vitamin;
      case 'supplement': return ProductCategory.supplement;
      case 'medicalDevice': return ProductCategory.medicalDevice;
      case 'skincare': return ProductCategory.skincare;
      case 'baby': return ProductCategory.baby;
      case 'diabetes': return ProductCategory.diabetes;
      case 'heart': return ProductCategory.heart;
      case 'bloodPressure': return ProductCategory.bloodPressure;
      case 'allergy': return ProductCategory.allergy;
      case 'digestive': return ProductCategory.digestive;
      case 'respiratory': return ProductCategory.respiratory;
      case 'neurology': return ProductCategory.neurology;
      case 'dermatology': return ProductCategory.dermatology;
      case 'ophthalmology': return ProductCategory.ophthalmology;
      case 'dental': return ProductCategory.dental;
      case 'womenHealth': return ProductCategory.womenHealth;
      case 'menHealth': return ProductCategory.menHealth;
      case 'elderly': return ProductCategory.elderly;
      case 'firstAid': return ProductCategory.firstAid;
      case 'medicalSupplies': return ProductCategory.medicalSupplies;
      default: return ProductCategory.painkiller;
    }
  }
}
