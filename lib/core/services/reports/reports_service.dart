import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/reports/report_model.dart';

class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserStatsModel> getUserStats(String userId) async {
    if (userId.trim().isEmpty) {
      return _emptyStats();
    }

    final results = await Future.wait([
      _firestore.collection('appointments').where('patientId', isEqualTo: userId).get(),
      _firestore.collection('orders').where('userId', isEqualTo: userId).get(),
      _firestore.collection('consultations').where('patientId', isEqualTo: userId).get(),
      _firestore.collection('users').doc(userId).get(),
    ]);

    final appointments = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final orders = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final consultations = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final user = results[3] as DocumentSnapshot<Map<String, dynamic>>;

    final appointmentStatuses = appointments.docs
        .map((d) => _string(d.data()['status']).toLowerCase())
        .toList();
    final orderData = orders.docs.map((d) => d.data()).toList();

    return UserStatsModel(
      totalAppointments: appointments.size,
      completedAppointments: appointmentStatuses.where((s) => s == 'completed').length,
      cancelledAppointments: appointmentStatuses.where((s) => s == 'cancelled').length,
      pendingAppointments: appointmentStatuses.where((s) => s == 'pending' || s == 'confirmed').length,
      totalOrders: orders.size,
      completedOrders: orderData.where((d) => _string(d['status']).toLowerCase() == 'delivered').length,
      totalConsultations: consultations.size,
      totalSpent: orderData.fold<double>(0, (sum, d) => sum + _number(d['total'])),
      totalSaved: orderData.fold<double>(0, (sum, d) => sum + _number(d['discount'])),
      lastActive: _dateFrom(user.data()?['lastActive']) ??
          _dateFrom(user.data()?['updatedAt']) ??
          _dateFrom(user.data()?['createdAt']) ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Future<List<ChartDataModel>> getChartData(String userId, ChartType type) async {
    if (userId.trim().isEmpty) return [];

    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    QuerySnapshot<Map<String, dynamic>> snapshot;
    String dateField;

    switch (type) {
      case ChartType.appointments:
        snapshot = await _firestore.collection('appointments').where('patientId', isEqualTo: userId).get();
        dateField = 'date';
        break;
      case ChartType.orders:
      case ChartType.spending:
        snapshot = await _firestore.collection('orders').where('userId', isEqualTo: userId).get();
        dateField = 'createdAt';
        break;
      case ChartType.consultations:
        snapshot = await _firestore.collection('consultations').where('patientId', isEqualTo: userId).get();
        dateField = 'createdAt';
        break;
    }

    final totals = <DateTime, double>{
      for (int i = 0; i < 7; i++) start.add(Duration(days: i)): 0,
    };

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = _dateFrom(data[dateField]);
      if (date == null) continue;
      final day = DateTime(date.year, date.month, date.day);
      if (!totals.containsKey(day)) continue;

      final value = switch (type) {
        ChartType.appointments => 1.0,
        ChartType.orders => 1.0,
        ChartType.consultations => 1.0,
        ChartType.spending => _number(data['total']),
      };
      totals[day] = totals[day]! + value;
    }

    return totals.entries
        .map((entry) => ChartDataModel(
              label: _formatDate(entry.key),
              value: entry.value,
              date: entry.key,
            ))
        .toList();
  }

  Future<List<MedicalReportModel>> getMedicalReports(String userId) async {
    if (userId.trim().isEmpty) return [];

    final snapshot = await _firestore
        .collection('consultations')
        .where('patientId', isEqualTo: userId)
        .get();

    final reports = <MedicalReportModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final hasMedicalContent = data['diagnosis'] != null ||
          data['labResult'] != null ||
          data['labTests'] != null ||
          data['prescription'] != null;
      if (!hasMedicalContent) continue;

      final date = _dateFrom(data['updatedAt']) ?? _dateFrom(data['createdAt']);
      if (date == null) continue;
      final diagnosis = _string(data['diagnosis']);
      final labResult = _string(data['labResult']);
      final status = _string(data['status']);
      final summary = diagnosis.isNotEmpty
          ? diagnosis
          : labResult.isNotEmpty
              ? labResult
              : 'توجد نتائج أو وصفة مرتبطة بهذه الاستشارة.';

      reports.add(MedicalReportModel(
        id: doc.id,
        title: 'تقرير استشارة طبية',
        date: date,
        doctor: _string(data['doctorName']),
        type: labResult.isNotEmpty || data['labTests'] != null ? 'مختبر' : 'استشارة',
        status: status.isNotEmpty ? status : 'غير محدد',
        summary: summary,
        details: _buildDetails(data),
      ));
    }

    reports.sort((a, b) => b.date.compareTo(a.date));
    return reports;
  }

  Future<List<MedicationReportModel>> getMedicationReports(String userId) async {
    if (userId.trim().isEmpty) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('medications')
        .get();

    final reports = <MedicationReportModel>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final startDate = _dateFrom(data['startDate']);
      final endDate = _dateFrom(data['endDate']);
      final createdAt = _dateFrom(data['createdAt']);
      final start = startDate ?? createdAt;
      if (start == null) continue;

      reports.add(MedicationReportModel(
        id: doc.id,
        name: _string(data['name']),
        dosage: _joinNonEmpty([_string(data['dose']), _string(data['frequency'])]),
        duration: _durationText(start, endDate),
        startDate: start,
        endDate: endDate ?? start,
        status: data['active'] == true ? 'نشط' : 'غير نشط',
        prescribedBy: _string(data['prescribedBy']),
        notes: _string(data['notes']),
      ));
    }

    reports.sort((a, b) => b.startDate.compareTo(a.startDate));
    return reports;
  }

  UserStatsModel _emptyStats() => UserStatsModel(
        totalAppointments: 0,
        completedAppointments: 0,
        cancelledAppointments: 0,
        pendingAppointments: 0,
        totalOrders: 0,
        completedOrders: 0,
        totalConsultations: 0,
        totalSpent: 0,
        totalSaved: 0,
        lastActive: DateTime.fromMillisecondsSinceEpoch(0),
      );

  static String _string(dynamic value) => value?.toString().trim() ?? '';

  static double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(_string(value)) ?? 0;
  }

  static DateTime? _dateFrom(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String _formatDate(DateTime date) => '${date.day}/${date.month}';

  static String _joinNonEmpty(List<String> values) =>
      values.where((value) => value.isNotEmpty).join(' - ');

  static String _durationText(DateTime start, DateTime? end) {
    if (end == null) return 'غير محددة';
    final days = end.difference(start).inDays.abs();
    if (days == 0) return 'يوم واحد';
    return '$days يوم';
  }

  static String _buildDetails(Map<String, dynamic> data) {
    final parts = <String>[];
    final labResult = _string(data['labResult']);
    final diagnosis = _string(data['diagnosis']);
    final instructions = _string(data['medicineInstructions']);
    if (diagnosis.isNotEmpty) parts.add('التشخيص: $diagnosis');
    if (labResult.isNotEmpty) parts.add('نتيجة المختبر: $labResult');
    if (instructions.isNotEmpty) parts.add('تعليمات الدواء: $instructions');
    if (data['prescription'] != null) parts.add('توجد وصفة طبية مرتبطة بالاستشارة.');
    return parts.join('\n');
  }
}
