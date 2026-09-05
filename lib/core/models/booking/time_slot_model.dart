class TimeSlotModel {
  final String id;
  final String date;
  final String time;
  final bool isBooked;
  final bool isPast;

  const TimeSlotModel({
    required this.id,
    required this.date,
    required this.time,
    this.isBooked = false,
    this.isPast = false,
  });

  factory TimeSlotModel.fromMap(Map<String, dynamic> map) {
    return TimeSlotModel(
      id: map['id'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      isBooked: map['isBooked'] ?? false,
      isPast: map['isPast'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'isBooked': isBooked,
      'isPast': isPast,
    };
  }

  bool get isAvailable => !isBooked && !isPast;
}
