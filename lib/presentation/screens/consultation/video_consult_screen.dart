import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class VideoConsultScreen extends StatefulWidget {
  const VideoConsultScreen({super.key});

  @override
  State<VideoConsultScreen> createState() => _VideoConsultScreenState();
}

class _VideoConsultScreenState extends State<VideoConsultScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _selectedDoctor = '';
  String _selectedType = 'فيديو';
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;

  final List<String> _consultTypes = ['فيديو', 'صوتي', 'نصي'];
  String _displayTime(String time) {
    if (AppStrings.of(context).locale.languageCode == 'ar') return time;
    return time.replaceAll(' ص', ' AM').replaceAll(' م', ' PM');
  }

  final List<String> _availableTimes = [
    '9:00 ص', '10:00 ص', '11:00 ص', '12:00 م',
    '2:00 م', '3:00 م', '4:00 م', '5:00 م',
  ];

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: CustomAppBar(title: AppStrings.of(context).translate('الاستشارات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: Center(child: Text(AppStrings.of(context).translate('يرجى تسجيل الدخول'))),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: Text(AppStrings.of(context).translate('الاستشارات الطبية'), style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.of(context).translate('طلب استشارة'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // ✅ اختيار الطبيب
            Text(AppStrings.of(context).translate('اختر الطبيب'), style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('doctors').where('available', isEqualTo: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                final doctors = snapshot.data?.docs ?? [];
                return DropdownButtonFormField<String>(
                  value: _selectedDoctor.isEmpty ? null : _selectedDoctor,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  hint: Text(AppStrings.of(context).translate('اختر طبيباً')),
                  items: doctors.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['name'] ?? AppStrings.of(context).translate('طبيب')),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedDoctor = value!),
                );
              },
            ),
            const SizedBox(height: 12),
            // ✅ نوع الاستشارة
            Text(AppStrings.of(context).translate('نوع الاستشارة'), style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _consultTypes.map((type) {
                final selected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type == 'فيديو' ? '📹 ${AppStrings.of(context).translate('فيديو')}' : type == 'صوتي' ? '🎤 ${AppStrings.of(context).translate('صوتي')}' : '💬 ${AppStrings.of(context).translate('نصي')}',
                      style: TextStyle(color: selected ? Colors.white : Colors.grey.shade700),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // ✅ التاريخ
            Text(AppStrings.of(context).translate('التاريخ'), style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  locale: AppStrings.of(context).locale,
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE، dd MMMM yyyy', AppStrings.of(context).locale.languageCode).format(_selectedDate)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ الوقت
            Text(AppStrings.of(context).translate('الوقت'), style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableTimes.map((time) {
                final selected = _selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTime = time),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(color: selected ? Colors.white : Colors.grey.shade700),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // ✅ زر الطلب
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedDoctor.isNotEmpty && _selectedTime != null) ? _requestConsultation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_selectedDoctor.isNotEmpty && _selectedTime != null) ? AppColors.primary : Colors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppStrings.of(context).translate('طلب استشارة'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            // ✅ الاستشارات السابقة
            Text(AppStrings.of(context).translate('الاستشارات السابقة'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('consultations')
                  .where('patientId', isEqualTo: user.uid)
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final consults = snapshot.data?.docs ?? [];
                if (consults.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(AppStrings.of(context).translate('لا توجد استشارات سابقة'), style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: consults.length,
                  itemBuilder: (context, index) {
                    final data = consults[index].data() as Map<String, dynamic>;
                    final date = (data['createdAt'] as Timestamp).toDate();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: data['type'] == 'فيديو' ? AppColors.primary.withOpacity(0.1) : AppColors.info.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              data['type'] == 'فيديو' ? Icons.videocam : data['type'] == 'صوتي' ? Icons.call : Icons.chat,
                              color: data['type'] == 'فيديو' ? AppColors.primary : AppColors.info,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['doctorName'] ?? AppStrings.of(context).translate('طبيب'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(AppStrings.of(context).translate(data['type'] ?? 'استشارة'), style: TextStyle(fontSize: 10, color: Colors.grey)),
                                Text(DateFormat('dd/MM/yyyy').format(date), style: TextStyle(fontSize: 9, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: data['status'] == 'completed' ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              data['status'] == 'completed' ? 'منتهية' : 'قيد الانتظار',
                              style: TextStyle(
                                fontSize: 9,
                                color: data['status'] == 'completed' ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestConsultation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = await _firestore.collection('consultations').add({
        'patientId': user.uid,
        'patientName': user.displayName ?? 'مريض',
        'doctorId': _selectedDoctor,
        'doctorName': 'طبيب',
        'type': _selectedType,
        'date': Timestamp.fromDate(_selectedDate),
        'time': _selectedTime,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ تحديث حالة الطبيب
      await _firestore.collection('consultations').doc(docRef.id).update({
        'doctorName': 'طبيب', // يمكن جلب اسم الطبيب من Firestore
      });

      ToastService.showSuccess(context, AppStrings.of(context).locale.languageCode == 'ar' ? '✅ تم طلب الاستشارة بنجاح' : AppStrings.of(context).locale.languageCode == 'fr' ? '✅ Consultation demandée avec succès' : '✅ Consultation requested successfully');
      setState(() {
        _selectedDoctor = '';
        _selectedTime = null;
      });
    } catch (e) {
      ToastService.showError(context, AppStrings.of(context).locale.languageCode == 'ar' ? '❌ فشل الطلب: $e' : AppStrings.of(context).locale.languageCode == 'fr' ? '❌ Échec de la demande : $e' : '❌ Request failed: $e');
    }
  }
}
