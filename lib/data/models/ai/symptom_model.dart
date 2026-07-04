class SymptomModel {
  final String id;
  final String name;
  final String icon;
  final String category;
  final List<String> relatedSymptoms;

  SymptomModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
    this.relatedSymptoms = const [],
  });
}

class DiagnosisResult {
  final String condition;
  final String description;
  final String severity; // عالية، متوسطة، منخفضة
  final double confidence;
  final List<String> recommendations;
  final List<String> relatedConditions;

  DiagnosisResult({
    required this.condition,
    required this.description,
    required this.severity,
    required this.confidence,
    this.recommendations = const [],
    this.relatedConditions = const [],
  });
}
