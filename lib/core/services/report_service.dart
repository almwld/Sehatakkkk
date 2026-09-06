import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/user_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getReports({String? userId}) {
    Query<Map<String, dynamic>> query = _firestore.collection('reports');
    if (userId != null) {
      query = query.where('generatedFor', isEqualTo: userId);
    }
    return query.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => {'id': doc.id, ...doc.data()})
              .toList(),
        );
  }

  Future<Map<String, dynamic>?> getReport(String reportId) async {
    final doc = await _firestore.collection('reports').doc(reportId).get();
    if (!doc.exists) return null;
    return {'id': doc.id, ...?doc.data()};
  }

  Future<Map<String, dynamic>> generateRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? providerId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('payments');
    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    final snap = await query
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    final payments = snap.docs.map((doc) => doc.data()).toList();
    final totalRevenue = payments.fold<double>(
      0,
      (sum, payment) => sum + ((payment['amount'] as num?)?.toDouble() ?? 0),
    );
    final platformCommission = totalRevenue * 0.15;

    return {
      'totalRevenue': totalRevenue,
      'platformCommission': platformCommission,
      'providerRevenue': totalRevenue - platformCommission,
      'totalPayments': payments.length,
      'payments': payments,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> generateBookingsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? providerId,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('bookings');
    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    final snap = await query
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    final bookings = snap.docs.map((doc) => doc.data()).toList();
    int countStatus(String status) =>
        bookings.where((booking) => booking['status'] == status).length;

    return {
      'totalBookings': bookings.length,
      'confirmed': countStatus('confirmed'),
      'completed': countStatus('completed'),
      'cancelled': countStatus('cancelled'),
      'pending': countStatus('pending'),
      'bookings': bookings,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> generateUsersReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snap = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .get();

    final users = snap.docs.map((doc) =>
        UserModel.fromFirestore(doc.data(), doc.id)).toList();

    final roles = <String, int>{
      'user': 0,
      'doctor': 0,
      'pharmacist': 0,
      'lab': 0,
      'veterinarian': 0,
      'admin': 0,
    };
    for (final user in users) {
      final role = user.role.toString().split('.').last;
      roles[role] = (roles[role] ?? 0) + 1;
    }

    return {
      'totalUsers': users.length,
      'roles': roles,
      'users': users.map((user) => user.toFirestore()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> generateFullReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final results = await Future.wait([
      generateRevenueReport(startDate: startDate, endDate: endDate),
      generateBookingsReport(startDate: startDate, endDate: endDate),
      generateUsersReport(startDate: startDate, endDate: endDate),
    ]);

    return {
      'revenue': results[0],
      'bookings': results[1],
      'users': results[2],
      'generatedAt': DateTime.now().toIso8601String(),
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
    };
  }

  String exportToCSV(Map<String, dynamic> report) {
    final buffer = StringBuffer('التقرير,القيمة\n');
    report.forEach((key, value) {
      if (value is Map) {
        value.forEach((subKey, subValue) {
          buffer.writeln('$key.$subKey,$subValue');
        });
      } else {
        buffer.writeln('$key,$value');
      }
    });
    return buffer.toString();
  }

  Future<void> deleteReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).delete();
  }
}
