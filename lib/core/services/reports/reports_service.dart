import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/data/models/reports/report_model.dart';

class ReportsService {
  static final ReportsService _instance = ReportsService._internal();
  factory ReportsService() => _instance;
  ReportsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // 📊 جلب إحصائيات المستخدم
  // ============================================================
  Future<UserStatsModel> getUserStats(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    return UserStatsModel(
      totalAppointments: 24,
      completedAppointments: 18,
      cancelledAppointments: 3,
      pendingAppointments: 3,
      totalOrders: 12,
      completedOrders: 10,
      totalConsultations: 8,
      totalSpent: 12500,
      totalSaved: 3500,
      lastActive: DateTime.now().subtract(const Duration(hours: 2)),
    );
  }

  // ============================================================
  // 📈 جلب بيانات الرسم البياني
  // ============================================================
  Future<List<ChartDataModel>> getChartData(
    String userId,
    ChartType type,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final List<ChartDataModel> data = [];
    final now = DateTime.now();

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      data.add(
        ChartDataModel(
          label: _formatDate(date),
          value: _generateRandomValue(type),
          date: date,
        ),
      );
    }

    return data;
  }

  // ============================================================
  // 📋 جلب التقارير الطبية
  // ============================================================
  Future<List<MedicalReportModel>> getMedicalReports(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      MedicalReportModel(
        id: '1',
        title: 'تقرير الفحص السنوي',
        date: DateTime.now().subtract(const Duration(days: 5)),
        doctor: 'د. أحمد المولد',
        type: 'فحص عام',
        status: 'مكتمل',
        summary: 'جميع المؤشرات طبيعية، ينصح بمتابعة النشاط البدني',
        details: 'تم إجراء الفحص الشامل وتبين أن جميع المؤشرات ضمن المعدلات الطبيعية',
      ),
      MedicalReportModel(
        id: '2',
        title: 'تقرير تحاليل الدم',
        date: DateTime.now().subtract(const Duration(days: 12)),
        doctor: 'د. خالد النخلاني',
        type: 'مختبر',
        status: 'مكتمل',
        summary: 'نسبة السكر مرتفعة قليلاً، ينصح بمراجعة النظام الغذائي',
        details: 'تم إجراء تحاليل الدم الشاملة وتبين ارتفاع طفيف في نسبة السكر',
      ),
      MedicalReportModel(
        id: '3',
        title: 'تقرير الأشعة',
        date: DateTime.now().subtract(const Duration(days: 20)),
        doctor: 'د. أسماء الهندي',
        type: 'أشعة',
        status: 'قيد المراجعة',
        summary: 'جاري تحليل النتائج من قبل الأخصائي',
        details: 'تم إجراء أشعة الصدر وسيتم إرسال النتائج خلال 48 ساعة',
      ),
      MedicalReportModel(
        id: '4',
        title: 'تقرير متابعة الضغط',
        date: DateTime.now().subtract(const Duration(days: 30)),
        doctor: 'د. محمد العلاي',
        type: 'متابعة',
        status: 'مكتمل',
        summary: 'قراءات الضغط طبيعية، استمر على العلاج الحالي',
        details: 'تم متابعة قراءات الضغط لمدة شهر وتبين استقرارها',
      ),
    ];
  }

  // ============================================================
  // 💊 جلب تقارير الأدوية
  // ============================================================
  Future<List<MedicationReportModel>> getMedicationReports(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      MedicationReportModel(
        id: '1',
        name: 'بار.ييتامول 500mg',
        dosage: 'مرة كل 8 ساعات',
        duration: '7 أيام',
        startDate: DateTime.now().subtract(const Duration(days: 7)),
        endDate: DateTime.now(),
        status: 'مكتمل',
        prescribedBy: 'د. أحمد المولد',
        notes: 'للمساعدة في تخفيف الآلام',
      ),
      MedicationReportModel(
        id: '2',
        name: 'أموكسيسيلين 500mg',
        dosage: 'مرة كل 12 ساعة',
        duration: '10 أيام',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        status: 'نشط',
        prescribedBy: 'د. خالد النخلاني',
        notes: 'مضاد حيوي لعلاج الالتهاب',
      ),
      MedicationReportModel(
        id: '3',
        name: 'لوسارتان 50mg',
        dosage: 'مرة يومياً',
        duration: 'شهر',
        startDate: DateTime.now().subtract(const Duration(days: 15)),
        endDate: DateTime.now().add(const Duration(days: 15)),
        status: 'نشط',
        prescribedBy: 'د. محمد العلاي',
        notes: 'لعلاج ارتفاع ضغط الدم',
      ),
    ];
  }

  // ============================================================
  // 🛠️ دوال مساعدة
  // ============================================================
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

  double _generateRandomValue(ChartType type) {
    switch (type) {
      case ChartType.appointments:
        return (10 + DateTime.now().millisecondsSinceEpoch % 20).toDouble();
      case ChartType.orders:
        return (5 + DateTime.now().millisecondsSinceEpoch % 15).toDouble();
      case ChartType.spending:
        return (500 + DateTime.now().millisecondsSinceEpoch % 2000).toDouble();
      case ChartType.consultations:
        return (3 + DateTime.now().millisecondsSinceEpoch % 10).toDouble();
    }
  }
}
