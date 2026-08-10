class ProductModel {
  final String name;
  final double price;
  final String image;
  final String category;
  final int discount;

  const ProductModel({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.discount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    name: json['name'] ?? '',
    price: (json['price'] ?? 0.0).toDouble(),
    image: json['image'] ?? '',
    category: json['category'] ?? '',
    discount: json['discount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'price': price,
    'image': image,
    'category': category,
    'discount': discount,
  };
}
