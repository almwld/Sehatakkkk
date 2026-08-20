import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  painkiller,
  antibiotic,
  vitamin,
  supplement,
  diabetes,
  heart,
  blood_pressure,
  allergy,
  digestive,
  respiratory,
  medical_device,
  skincare,
  haircare,
  makeup,
  fragrance,
  bodycare,
  oralcare,
  babycare,
  babydiapers,
  babyfood,
  babymilk,
  babyskin,
  babyhealth,
  babytoys,
  herbal,
  firstaid,
  medical_supplies,
}

class ProductModel {
  final String id;
  final String name;
  final String nameEn;
  final ProductCategory category;
  final String description;
  final double price;
  final double? discount;
  final String imageUrl;
  final String pharmacyId;
  final String pharmacyName;
  final String pharmacyImage;
  final String? manufacturer;
  final int stock;
  final String? dosage;
  final bool prescriptionRequired;
  final bool inStock;
  final double rating;
  final int reviews;
  final List<String> keywords;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.category,
    required this.description,
    required this.price,
    this.discount,
    required this.imageUrl,
    required this.pharmacyId,
    required this.pharmacyName,
    required this.pharmacyImage,
    this.manufacturer,
    required this.stock,
    this.dosage,
    this.prescriptionRequired = false,
    this.inStock = true,
    this.rating = 0,
    this.reviews = 0,
    this.keywords = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  String get categoryText {
    switch (category) {
      case ProductCategory.painkiller: return 'مسكنات';
      case ProductCategory.antibiotic: return 'مضادات حيوية';
      case ProductCategory.vitamin: return 'فيتامينات';
      case ProductCategory.supplement: return 'مكملات غذائية';
      case ProductCategory.diabetes: return 'أدوية السكري';
      case ProductCategory.heart: return 'أدوية القلب';
      case ProductCategory.blood_pressure: return 'أدوية الضغط';
      case ProductCategory.allergy: return 'أدوية الحساسية';
      case ProductCategory.digestive: return 'أدوية الجهاز الهضمي';
      case ProductCategory.respiratory: return 'أدوية الجهاز التنفسي';
      case ProductCategory.medical_device: return 'أجهزة طبية';
      case ProductCategory.skincare: return 'عناية بالبشرة';
      case ProductCategory.haircare: return 'عناية بالشعر';
      case ProductCategory.makeup: return 'مكياج';
      case ProductCategory.fragrance: return 'عطور';
      case ProductCategory.bodycare: return 'عناية بالجسم';
      case ProductCategory.oralcare: return 'عناية بالفم والأسنان';
      case ProductCategory.babycare: return 'عناية بالطفل';
      case ProductCategory.babydiapers: return 'حفاضات';
      case ProductCategory.babyfood: return 'أغذية أطفال';
      case ProductCategory.babymilk: return 'حليب أطفال';
      case ProductCategory.babyskin: return 'عناية ببشرة الطفل';
      case ProductCategory.babyhealth: return 'صحة الطفل';
      case ProductCategory.babytoys: return 'ألعاب أطفال';
      case ProductCategory.herbal: return 'منتجات عشبية';
      case ProductCategory.firstaid: return 'إسعافات أولية';
      case ProductCategory.medical_supplies: return 'مستلزمات طبية';
      default: return 'أخرى';
    }
  }

  Color get categoryColor {
    switch (category) {
      case ProductCategory.painkiller: return Colors.red;
      case ProductCategory.antibiotic: return Colors.purple;
      case ProductCategory.vitamin: return Colors.orange;
      case ProductCategory.supplement: return Colors.green;
      case ProductCategory.diabetes: return Colors.deepOrange;
      case ProductCategory.heart: return Colors.redAccent;
      case ProductCategory.blood_pressure: return Colors.teal;
      case ProductCategory.allergy: return Colors.cyan;
      case ProductCategory.digestive: return Colors.brown;
      case ProductCategory.respiratory: return Colors.lightGreen;
      case ProductCategory.medical_device: return Colors.blue;
      case ProductCategory.skincare: return Colors.pink;
      case ProductCategory.haircare: return Colors.deepPurple;
      case ProductCategory.makeup: return Colors.pinkAccent;
      case ProductCategory.fragrance: return Colors.deepPurpleAccent;
      case ProductCategory.bodycare: return Colors.lime;
      case ProductCategory.oralcare: return Colors.cyanAccent;
      case ProductCategory.babycare: return Colors.lightBlue;
      case ProductCategory.babydiapers: return Colors.blueGrey;
      case ProductCategory.babyfood: return Colors.amber;
      case ProductCategory.babymilk: return Colors.blue;
      case ProductCategory.babyskin: return Colors.pinkAccent;
      case ProductCategory.babyhealth: return Colors.redAccent;
      case ProductCategory.babytoys: return Colors.orangeAccent;
      case ProductCategory.herbal: return Colors.greenAccent;
      case ProductCategory.firstaid: return Colors.red;
      case ProductCategory.medical_supplies: return Colors.indigo;
      default: return Colors.grey;
    }
  }

  double get priceWithDiscount => discount != null ? price * (1 - discount! / 100) : price;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameEn': nameEn,
    'category': category.toString().split('.').last,
    'description': description,
    'price': price,
    'discount': discount,
    'imageUrl': imageUrl,
    'pharmacyId': pharmacyId,
    'pharmacyName': pharmacyName,
    'pharmacyImage': pharmacyImage,
    'manufacturer': manufacturer,
    'stock': stock,
    'dosage': dosage,
    'prescriptionRequired': prescriptionRequired,
    'inStock': inStock,
    'rating': rating,
    'reviews': reviews,
    'keywords': keywords,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'],
    name: json['name'],
    nameEn: json['nameEn'],
    category: _parseCategory(json['category']),
    description: json['description'],
    price: json['price'].toDouble(),
    discount: json['discount']?.toDouble(),
    imageUrl: json['imageUrl'],
    pharmacyId: json['pharmacyId'],
    pharmacyName: json['pharmacyName'],
    pharmacyImage: json['pharmacyImage'],
    manufacturer: json['manufacturer'],
    stock: json['stock'],
    dosage: json['dosage'],
    prescriptionRequired: json['prescriptionRequired'],
    inStock: json['inStock'],
    rating: json['rating'].toDouble(),
    reviews: json['reviews'],
    keywords: List<String>.from(json['keywords']),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
  );

  static ProductCategory _parseCategory(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ProductCategory.painkiller,
    );
  }
}
