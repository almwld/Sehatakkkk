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
  final String? imageUrl;
  final String pharmacyId;
  final String pharmacyName;
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
    this.imageUrl,
    required this.pharmacyId,
    required this.pharmacyName,
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

  double get priceWithDiscount {
    if (discount == null) return price;
    return price * (1 - discount! / 100);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nameEn': nameEn,
      'category': category.toString().split('.').last,
      'description': description,
      'price': price,
      'discount': discount,
      'imageUrl': imageUrl,
      'pharmacyId': pharmacyId,
      'pharmacyName': pharmacyName,
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
  }

  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      nameEn: data['nameEn'] ?? '',
      category: _parseCategory(data['category'] ?? 'painkiller'),
      description: data['description'] ?? '',
      price: data['price']?.toDouble() ?? 0,
      discount: data['discount']?.toDouble(),
      imageUrl: data['imageUrl'],
      pharmacyId: data['pharmacyId'] ?? '',
      pharmacyName: data['pharmacyName'] ?? '',
      manufacturer: data['manufacturer'],
      stock: data['stock'] ?? 0,
      dosage: data['dosage'],
      prescriptionRequired: data['prescriptionRequired'] ?? false,
      inStock: data['inStock'] ?? true,
      rating: data['rating']?.toDouble() ?? 0,
      reviews: data['reviews'] ?? 0,
      keywords: List<String>.from(data['keywords'] ?? []),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static ProductCategory _parseCategory(String value) {
    switch (value) {
      case 'painkiller': return ProductCategory.painkiller;
      case 'antibiotic': return ProductCategory.antibiotic;
      case 'vitamin': return ProductCategory.vitamin;
      case 'supplement': return ProductCategory.supplement;
      case 'diabetes': return ProductCategory.diabetes;
      case 'heart': return ProductCategory.heart;
      case 'blood_pressure': return ProductCategory.blood_pressure;
      case 'allergy': return ProductCategory.allergy;
      case 'digestive': return ProductCategory.digestive;
      case 'respiratory': return ProductCategory.respiratory;
      case 'medical_device': return ProductCategory.medical_device;
      case 'skincare': return ProductCategory.skincare;
      case 'haircare': return ProductCategory.haircare;
      case 'makeup': return ProductCategory.makeup;
      case 'fragrance': return ProductCategory.fragrance;
      case 'bodycare': return ProductCategory.bodycare;
      case 'oralcare': return ProductCategory.oralcare;
      case 'babycare': return ProductCategory.babycare;
      case 'babydiapers': return ProductCategory.babydiapers;
      case 'babyfood': return ProductCategory.babyfood;
      case 'babymilk': return ProductCategory.babymilk;
      case 'babyskin': return ProductCategory.babyskin;
      case 'babyhealth': return ProductCategory.babyhealth;
      case 'babytoys': return ProductCategory.babytoys;
      case 'herbal': return ProductCategory.herbal;
      case 'firstaid': return ProductCategory.firstaid;
      case 'medical_supplies': return ProductCategory.medical_supplies;
      default: return ProductCategory.painkiller;
    }
  }
}
