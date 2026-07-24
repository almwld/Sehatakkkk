import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/models/report_model.dart';
import 'package:sehatak/core/models/booking_model.dart';
import 'package:sehatak/core/models/user_model.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ إنشاء تقرير
  Future<ReportModel> createReport({
    required String title,
    required String description,
    required ReportType type,
    required ReportCategory category,
    required DateTime startDate,
    required DateTime endDate,
    String? generatedBy,
    String? generatedFor,
    bool isPublic = false,
  }) async {
    final report = ReportModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      category: category,
      data: {},
      startDate: startDate,
      endDate: endDate,
      generatedBy: generatedBy,
      generatedFor: generatedFor,
      isPublic: isPublic,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('reports').add(report.toFirestore());
    return report;
  }

  // ✅ جلب التقارير
  Stream<List<ReportModel>> getReports({String? userId}) {
    Query query = _firestore.collection('reports');

    if (userId != null) {
      query = query.where('generatedFor', isEqualTo: userId);
    }

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ReportModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }

  // ✅ جلب تقرير محدد
  Future<ReportModel?> getReport(String reportId) async {
    final doc = await _firestore.collection('reports').doc(reportId).get();
    if (!doc.exists) return null;
    return ReportModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
  }

  // ✅ توليد تقرير الإيرادات
  Future<Map<String, dynamic>> generateRevenueReport({
    required DateTime startDate,
    required DateTime endDate,
    String? providerId,
  }) async {
    Query query = _firestore.collection('payments');

    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    final snap = await query
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .get();

    final payments = snap.docs.map((doc) => doc.data()).toList();
    
    final totalRevenue = payments.fold(0, (sum, p) => sum + (p['amount'] as int? ?? 0));
    final platformCommission = totalRevenue * 0.15;
    final providerRevenue = totalRevenue - platformCommission;

    return {
      'totalRevenue': totalRevenue,
      'platformCommission': platformCommission,
      'providerRevenue': providerRevenue,
      'totalPayments': payments.length,
      'payments': payments,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  // ✅ توليد تقرير الحجوزات
  Future<Map<String, dynamic>> generateBookingsReport({
    required DateTime startDate,
    required DateTime endDate,
    String? providerId,
  }) async {
    Query query = _firestore.collection('bookings');

    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    final snap = await query
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .get();

    final bookings = snap.docs.map((doc) {
      return BookingModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    final confirmed = bookings.where((b) => b.status == BookingStatus.confirmed).length;
    final completed = bookings.where((b) => b.status == BookingStatus.completed).length;
    final cancelled = bookings.where((b) => b.status == BookingStatus.cancelled).length;
    final pending = bookings.where((b) => b.status == BookingStatus.pending).length;

    return {
      'totalBookings': bookings.length,
      'confirmed': confirmed,
      'completed': completed,
      'cancelled': cancelled,
      'pending': pending,
      'bookings': bookings.map((b) => b.toFirestore()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  // ✅ توليد تقرير المستخدمين
  Future<Map<String, dynamic>> generateUsersReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final snap = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .get();

    final users = snap.docs.map((doc) {
      return UserModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    final roles = {
      'user': 0,
      'doctor': 0,
      'pharmacist': 0,
      'lab': 0,
      'veterinarian': 0,
      'admin': 0,
    };

    for (final user in users) {
      roles[user.role.toString().split('.').last] = (roles[user.role.toString().split('.').last] ?? 0) + 1;
    }

    return {
      'totalUsers': users.length,
      'roles': roles,
      'users': users.map((u) => u.toFirestore()).toList(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  // ✅ توليد تقرير شامل
  Future<Map<String, dynamic>> generateFullReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final revenue = await generateRevenueReport(startDate: startDate, endDate: endDate);
    final bookings = await generateBookingsReport(startDate: startDate, endDate: endDate);
    final users = await generateUsersReport(startDate: startDate, endDate: endDate);

    return {
      'revenue': revenue,
      'bookings': bookings,
      'users': users,
      'generatedAt': DateTime.now().toIso8601String(),
      'period': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
    };
  }

  // ✅ تصدير التقرير كـ CSV
  String exportToCSV(Map<String, dynamic> report) {
    final buffer = StringBuffer();
    
    // ✅ رأس CSV
    buffer.writeln('التقرير,القيمة');
    
    // ✅ البيانات
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

  // ✅ حذف تقرير
  Future<void> deleteReport(String reportId) async {
    await _firestore.collection('reports').doc(reportId).delete();
  }
}
