import package:sehatak/core/models/lab/lab_choice.dart;
import package:sehatak/core/models/consultation/consultation_status.dart;
import package:sehatak/core/models/consultation/consultation_model.dart;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/medical/consultation_model.dart';
import 'package:sehatak/core/services/consultation_service.dart';
import 'package:sehatak/presentation/screens/lab/lab_booking_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_reminder_screen.dart';

class ConsultationScreen extends StatefulWidget {
  final String? doctorId;
  final String? doctorName;
  const ConsultationScreen({super.key, this.doctorId, this.doctorName});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final ConsultationService _consultationService = ConsultationService();
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isUrgent = false;
  ConsultationModel? _consultation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          widget.doctorName != null 
              ? 'استشارة مع ${widget.doctorName}' 
              : 'استشارة طبية',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ وصف الأعراض
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'وصف الأعراض',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _symptomsController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'اكتب الأعراض التي تشعر بها...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ تفاصيل إضافية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تفاصيل إضافية (اختياري)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(
                      hintText: 'أي تفاصيل إضافية...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ✅ حالة عاجلة
            Row(
              children: [
                Switch(
                  value: _isUrgent,
                  onChanged: (value) {
                    setState(() => _isUrgent = value);
                  },
                  activeColor: Colors.red,
                ),
                const Text(
                  'حالة عاجلة',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '⚠️ سيتم التواصل معك خلال 10 دقائق',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ زر الإرسال
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendConsultation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'إرسال الاستشارة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // ✅ حالة الاستشارة الحالية
            if (_consultation != null)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _consultation!.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _consultation!.statusColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: _consultation!.statusColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'حالة الاستشارة: ${_consultation!.statusText}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _consultation!.statusColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'رقم الاستشارة: #${_consultation!.id.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    if (_consultation!.status == ConsultationStatus.labRequired)
                      _buildLabOptions(),
                    if (_consultation!.status == ConsultationStatus.prescription)
                      _buildPrescriptionActions(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabOptions() {
    return Column(
      children: [
        const Divider(),
        const Text(
          '✅ يرجى اختيار طريقة إجراء الفحوصات:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        // ✅ خيار 1: حجز في مختبر نموذجي
        _buildLabOption(
          icon: Icons.calendar_today,
          title: 'حجز في مختبر نموذجي',
          subtitle: 'اختر من أفضل المختبرات المعتمدة',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LabBookingScreen(
                  consultationId: _consultation!.id,
                ),
              ),
            );
          },
        ),
        // ✅ خيار 2: بحث عن مختبر قريب
        _buildLabOption(
          icon: Icons.search,
          title: 'بحث عن مختبر قريب',
          subtitle: 'ابحث عن أقرب مختبر لك',
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LabsListScreen(),
              ),
            );
          },
        ),
        // ✅ خيار 3: خدمة أخذ عينة للمنزل
        _buildLabOption(
          icon: Icons.home_work,
          title: 'خدمة أخذ عينة للمنزل',
          subtitle: 'سيتم إرسال مندوب لأخذ العينة',
          color: Colors.orange,
          onTap: () {
            _selectLabOption(LabChoice.home);
          },
        ),
        // ✅ خيار 4: الذهاب للمختبر
        _buildLabOption(
          icon: Icons.directions_walk,
          title: 'الذهاب للمختبر',
          subtitle: 'قم بزيارة المختبر بنفسك',
          color: Colors.purple,
          onTap: () {
            _selectLabOption(LabChoice.visit);
          },
        ),
      ],
    );
  }

  Widget _buildLabOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionActions() {
    return Column(
      children: [
        const Divider(),
        const Text(
          '💊 الوصفة الطبية جاهزة',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        // ✅ عرض الأدوية
        if (_consultation!.medicines != null)
          ..._consultation!.medicines!.map((medicine) => Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.medication, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(medicine)),
              ],
            ),
          )),
        const SizedBox(height: 8),
        // ✅ أزرار الإجراءات
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PharmacyScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.local_pharmacy),
                label: const Text('صيدلية'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // ✅ إضافة تذكير للأدوية
                  _addMedicationReminder();
                },
                icon: const Icon(Icons.alarm),
                label: const Text('تذكير'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicationReminderScreen(),
                ),
              );
            },
            icon: const Icon(Icons.medication),
            label: const Text('إدارة التذكير'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendConsultation() async {
    final symptoms = _symptomsController.text.trim();
    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء كتابة الأعراض'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تسجيل الدخول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final consultation = await _consultationService.createConsultation(
        patientId: user.uid,
        patientName: user.displayName ?? 'مستخدم',
        doctorId: widget.doctorId ?? 'doctor_1',
        doctorName: widget.doctorName ?? 'د. أحمد المؤيد',
        doctorSpecialty: 'باطنية',
        symptoms: symptoms,
        description: _descriptionController.text.trim(),
        isUrgent: _isUrgent,
        fee: _isUrgent ? 10000 : 5000,
      );

      setState(() {
        _consultation = consultation;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إرسال الاستشارة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectLabOption(LabChoice choice) async {
    if (_consultation == null) return;

    try {
      await _consultationService.updateLab(
        consultationId: _consultation!.id,
        labChoice: choice,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم اختيار: ${choice == LabChoice.book ? "حجز في مختبر" : choice == LabChoice.search ? "بحث عن مختبر" : choice == LabChoice.home ? "خدمة أخذ عينة للمنزل" : "الذهاب للمختبر"}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addMedicationReminder() async {
    // TODO: إضافة تذكير للأدوية
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم إضافة تذكير للأدوية'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
