class MedicalRecord {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String title;
  final String type;
  final String description;
  final DateTime date;
  final List<String> attachments;
  final Map<String, dynamic> metadata;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.title,
    required this.type,
    required this.description,
    required this.date,
    this.attachments = const [],
    this.metadata = const {},
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      patientName: json['patientName'] ?? '',
      doctorName: json['doctorName'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      attachments: List<String>.from(json['attachments'] ?? []),
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'doctorName': doctorName,
    'title': title,
    'type': type,
    'description': description,
    'date': date,
    'attachments': attachments,
    'metadata': metadata,
  };
}
