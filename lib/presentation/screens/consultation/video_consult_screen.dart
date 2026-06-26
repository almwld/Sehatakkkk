import 'package:flutter/material.dart';
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
  final List<String> _availableTimes = [
    '9:00 ص', '10:00 ص', '11:00 ص', '12:00 م',
    '2:00 م', '3:00 م', '4:00 م', '5:00 م',
  ];

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('الاستشارات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
        body: const Center(child: Text('يرجى تسجيل الدخول')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الاستشارات الطبية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('طلب استشارة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // ✅ اختيار الطبيب
            const Text('اختر الطبيب', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  hint: const Text('اختر طبيباً'),
                  items: doctors.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['name'] ?? 'طبيب'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedDoctor = value!),
                );
              },
            ),
            const SizedBox(height: 12),
            // ✅ نوع الاستشارة
            const Text('نوع الاستشارة', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      color: selected ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type == 'فيديو' ? '📹 فيديو' : type == 'صوتي' ? '🎤 صوتي' : '💬 نصي',
                      style: TextStyle(color: selected ? Colors.white : AppColors.darkGrey),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // ✅ التاريخ
            const Text('التاريخ', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  locale: const Locale('ar', 'YE'),
                );
                if (date != null) setState(() => _selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEEE، dd MMMM yyyy', 'ar').format(_selectedDate)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ الوقت
            const Text('الوقت', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      color: selected ? AppColors.primary : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(color: selected ? Colors.white : AppColors.darkGrey),
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
                  backgroundColor: (_selectedDoctor.isNotEmpty && _selectedTime != null) ? AppColors.primary : AppColors.grey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('طلب استشارة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
            // ✅ الاستشارات السابقة
            const Text('الاستشارات السابقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('لا توجد استشارات سابقة', style: TextStyle(color: AppColors.grey)),
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
                                Text(data['doctorName'] ?? 'طبيب', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(data['type'] ?? 'استشارة', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                                Text(DateFormat('dd/MM/yyyy').format(date), style: const TextStyle(fontSize: 9, color: AppColors.grey)),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم طلب الاستشارة بنجاح'), backgroundColor: AppColors.success),
      );
      setState(() {
        _selectedDoctor = '';
        _selectedTime = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشل الطلب: $e'), backgroundColor: AppColors.error),
      );
    }
  }
}
