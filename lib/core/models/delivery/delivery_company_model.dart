class DeliveryCompanyModel {
  final String id, name, logoPath;
  final String? logo;
  final double rating, baseFee, perKmFee;
  final int reviewCount, baseMinutes, minutesPerKm;
  final bool isActive;
  final List<String> coveredAreas;
  const DeliveryCompanyModel({required this.id, required this.name, this.logoPath = '', this.logo, this.rating = 0, this.reviewCount = 0, this.baseFee = 0, this.perKmFee = 0, this.baseMinutes = 30, this.minutesPerKm = 5, this.isActive = true, this.coveredAreas = const []});
  factory DeliveryCompanyModel.fromMap(Map<String, dynamic> d, String id) => DeliveryCompanyModel(id: id, name: d['name']?.toString() ?? 'شركة توصيل', logoPath: d['logoPath']?.toString() ?? '', logo: d['logo']?.toString(), rating: (d['rating'] as num?)?.toDouble() ?? 0, reviewCount: (d['reviewCount'] as num?)?.toInt() ?? 0, baseFee: (d['baseFee'] as num?)?.toDouble() ?? 0, perKmFee: (d['perKmFee'] as num?)?.toDouble() ?? 0, baseMinutes: (d['baseMinutes'] as num?)?.toInt() ?? 30, minutesPerKm: (d['minutesPerKm'] as num?)?.toInt() ?? 5, isActive: d['isActive'] != false, coveredAreas: List<String>.from(d['coveredAreas'] ?? const []));
}