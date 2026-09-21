import 'package:sehatak/presentation/screens/reports/medical_reports_screen.dart';

// Keep the legacy import path, but use the Firestore-backed implementation.
// This prevents the patient dashboard from showing hard-coded sample reports.
export 'package:sehatak/presentation/screens/reports/medical_reports_screen.dart';

class LegacyMedicalReportsScreen extends MedicalReportsScreen {
  const LegacyMedicalReportsScreen({super.key});
}
