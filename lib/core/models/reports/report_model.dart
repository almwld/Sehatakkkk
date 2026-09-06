class UserStatsModel {
  final int totalAppointments;
  final int completedAppointments;
  final int cancelledAppointments;
  final int pendingAppointments;
  final int totalOrders;
  final int completedOrders;
  final int totalConsultations;
  final double totalSpent;
  final double totalSaved;
  final DateTime lastActive;

  UserStatsModel({
    required this.totalAppointments,
    required this.completedAppointments,
    required this.cancelledAppointments,
    required this.pendingAppointments,
    required this.totalOrders,
    required this.completedOrders,
    required this.totalConsultations,
    required this.totalSpent,
    required this.totalSaved,
    required this.lastActive,
  });

  int get activeAppointments => pendingAppointments;
  double get completionRate => totalAppointments > 0
      ? (completedAppointments / totalAppointments) * 100
      : 0;
}

class ChartDataModel {
  final String label;
  final double value;
  final DateTime date;

  ChartDataModel({
    required this.label,
    required this.value,
    required this.date,
  });
}

enum ChartType {
  appointments,
  orders,
  spending,
  consultations,
}

class MedicalReportModel {
  final String id;
  final String title;
  final DateTime date;
  final String doctor;
  final String type;
  final String status;
  final String summary;
  final String details;

  MedicalReportModel({
    required this.id,
    required this.title,
    required this.date,
    required this.doctor,
    required this.type,
    required this.status,
    required this.summary,
    required this.details,
  });

  String get statusLabel {
    switch (status) {
      case 'مكتمل':
        return '✅ مكتمل';
      case 'قيد المراجعة':
        return '🔄 قيد المراجعة';
      default:
        return status;
    }
  }
}

class MedicationReportModel {
  final String id;
  final String name;
  final String dosage;
  final String duration;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String prescribedBy;
  final String notes;

  MedicationReportModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.prescribedBy,
    required this.notes,
  });

  String get statusLabel {
    switch (status) {
      case 'نشط':
        return '🟢 نشط';
      case 'مكتمل':
        return '✅ مكتمل';
      default:
        return status;
    }
  }

  int get remainingDays {
    final now = DateTime.now();
    final remaining = endDate.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }
}
