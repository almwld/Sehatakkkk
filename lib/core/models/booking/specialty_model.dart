class SpecialtyModel {
  final String id;
  final String name;
  final String icon;
  final int doctorCount;

  const SpecialtyModel({
    required this.id,
    required this.name,
    required this.icon,
    this.doctorCount = 0,
  });

  factory SpecialtyModel.fromMap(Map<String, dynamic> map) {
    return SpecialtyModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🫀',
      doctorCount: map['doctorCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'doctorCount': doctorCount,
    };
  }
}
