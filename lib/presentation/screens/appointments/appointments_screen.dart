import 'package:sehatak/core/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      ToastService.showError(context, '✅ تم إلغاء الموعد بنجاح');
        }

        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }

        final appointments = snapshot.data?.docs ?? [];
        final filtered = appointments.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final dateTime = (data['dateTime'] as Timestamp).toDate();
          if (type == 'upcoming') {
            return dateTime.isAfter(startOfDay) && data['status'] != 'cancelled';
          } else {
            return dateTime.isBefore(startOfDay) || data['status'] == 'cancelled';
          }
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(type == 'upcoming' ? Icons.calendar_today : Icons.history, size: 60, color: AppColors.grey),
                const SizedBox(height: 16),
                Text(
                  type == 'upcoming' ? 'لا توجد مواعيد قادمة' : 'لا توجد مواعيد سابقة',
                  style: const TextStyle(color: AppColors.grey, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  type == 'upcoming' ? 'أضف موعداً جديداً الآن' : 'ستظهر مواعيدك السابقة هنا',
                  style: const TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>;
            final dateTime = (data['dateTime'] as Timestamp).toDate();
            final isCancelled = data['status'] == 'cancelled';
            final isPast = dateTime.isBefore(startOfDay);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCancelled ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
                border: Border.all(
                  color: isCancelled ? Colors.grey[300]! : AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.grey[200] : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        DateFormat('dd').format(dateTime),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCancelled ? Colors.grey : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['doctorName'] ?? 'طبيب',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: isCancelled ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${DateFormat('EEEE', 'ar').format(dateTime)} - ${DateFormat('hh:mm a').format(dateTime)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: isCancelled ? Colors.grey : AppColors.grey,
                          ),
                        ),
                        if (data['notes'] != null && data['notes'].toString().isNotEmpty)
                          Text(
                            data['notes'],
                            style: TextStyle(fontSize: 10, color: AppColors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCancelled
                              ? Colors.grey[200]
                              : isPast
                                  ? AppColors.info.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isCancelled ? 'ملغي' : isPast ? 'منتهي' : 'قادم',
                          style: TextStyle(
                            fontSize: 9,
                            color: isCancelled ? Colors.grey : isPast ? AppColors.info : AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (!isCancelled && !isPast)
                        GestureDetector(
                          onTap: () => _cancelAppointment(doc.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'إلغاء',
                              style: TextStyle(fontSize: 9, color: AppColors.error),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddAppointmentDialog(BuildContext context) {
    final doctorCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('إضافة موعد جديد', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: doctorCtrl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'اسم الطبيب',
                    prefixIcon: const Icon(Icons.person, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateCtrl,
                  textAlign: TextAlign.right,
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('ar', 'YE'),
                    );
                    if (date != null) {
                      selectedDate = date;
                      setState(() => dateCtrl.text = DateFormat('yyyy-MM-dd').format(date));
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'التاريخ',
                    prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'اختر التاريخ',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: timeCtrl,
                  textAlign: TextAlign.right,
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      selectedTime = time;
                      setState(() => timeCtrl.text = time.format(context));
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'الوقت',
                    prefixIcon: const Icon(Icons.access_time, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'اختر الوقت',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: notesCtrl,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    prefixIcon: const Icon(Icons.note, color: AppColors.primary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: AppColors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (doctorCtrl.text.isEmpty || selectedDate == null || selectedTime == null) {
                  ToastService.showError(context, 'يرجى ملء جميع الحقول');
                  return;
                }

                final user = _auth.currentUser;
                if (user == null) return;

                try {
                  final dateTime = DateTime(
                    selectedDate!.year,
                    selectedDate!.month,
                    selectedDate!.day,
                    selectedTime!.hour,
                    selectedTime!.minute,
                  );

                  await _firestore.collection('appointments').add({
                    'patientId': user.uid,
                    'patientName': user.displayName ?? 'مريض',
                    'doctorName': doctorCtrl.text.trim(),
                    'dateTime': Timestamp.fromDate(dateTime),
                    'notes': notesCtrl.text.trim(),
                    'status': 'upcoming',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                  ToastService.showSuccess(context, '✅ تم إضافة الموعد بنجاح');
                } catch (e) {
                  ToastService.showError(context, '❌ فشل الإضافة: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}
