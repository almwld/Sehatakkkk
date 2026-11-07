class DeliveryCompanyModel {
  final String id, name, logoPath;
  final String? logo;
  final String? nameEn, nameFr;
  final Map<String, dynamic> translations;
  final double rating, baseFee, perKmFee;
  final int reviewCount, baseMinutes, minutesPerKm;
  final bool isActive;
  final List<String> coveredAreas;

  const DeliveryCompanyModel({
    required this.id,
    required this.name,
    this.logoPath = '',
    this.logo,
    this.nameEn,
    this.nameFr,
    this.translations = const {},
    this.rating = 0,
    this.reviewCount = 0,
    this.baseFee = 0,
    this.perKmFee = 0,
    this.baseMinutes = 30,
    this.minutesPerKm = 5,
    this.isActive = true,
    this.coveredAreas = const [],
  });

  String localizedName(String languageCode) {
    final language = languageCode.toLowerCase();
    final direct = language == 'en'
        ? nameEn
        : language == 'fr'
            ? nameFr
            : null;
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();

    final translated = translations[language];
    if (translated is String && translated.trim().isNotEmpty) {
      return translated.trim();
    }
    if (translated is Map) {
      final translatedName = translated['name']?.toString().trim();
      if (translatedName != null && translatedName.isNotEmpty) {
        return translatedName;
      }
    }
    return name;
  }

  factory DeliveryCompanyModel.fromMap(Map<String, dynamic> data, String id) {
    final rawTranslations = data['translations'];
    return DeliveryCompanyModel(
      id: id,
      name: data['name']?.toString() ?? 'شركة توصيل',
      logoPath: data['logoPath']?.toString() ?? '',
      logo: data['logo']?.toString(),
      nameEn: (data['nameEn'] ?? data['name_en'] ?? data['nameEnglish'])?.toString(),
      nameFr: (data['nameFr'] ?? data['name_fr'] ?? data['nameFrench'])?.toString(),
      translations: rawTranslations is Map
          ? Map<String, dynamic>.from(rawTranslations)
          : const {},
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
      baseFee: (data['baseFee'] as num?)?.toDouble() ?? 0,
      perKmFee: (data['perKmFee'] as num?)?.toDouble() ?? 0,
      baseMinutes: (data['baseMinutes'] as num?)?.toInt() ?? 30,
      minutesPerKm: (data['minutesPerKm'] as num?)?.toInt() ?? 5,
      isActive: data['isActive'] != false,
      coveredAreas: List<String>.from(data['coveredAreas'] ?? const []),
    );
  }
}
