import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/medication_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'add_medication_screen.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> {
  final MedicationService _service = MedicationService();
  final List<String> _filters = const ['الكل', 'المتبقية', 'المكتملة'];
  String _filter = 'الكل';

  @override
  void initState() {
    super.initState();
    _service.init();
  }

  Future<void> _toggle(String id, bool enabled) async {
    try {
      await _service.toggleReminder(id, enabled);
      if (mounted) {
        ToastService.showSuccess(enabled ? 'تم تفعيل التنبيه' : 'تم إيقاف التنبيه');
      }
    } catch (_) {
      if (mounted) ToastService.showError('تعذر تحديث التنبيه');
    }
  }

  Future<void> _taken(String id) async {
    try {
      await _service.markAsTaken(id);
      if (mounted) ToastService.showSuccess('تم تسجيل تناول الدواء');
    } catch (_) {
      if (mounted) ToastService.showError('تعذر تسجيل الجرعة');
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف الدواء'),
        content: const Text('هل تريد حذف هذا الدواء وإلغاء تنبيهاته؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.deleteMedication(id);
    } catch (_) {
      if (mounted) ToastService.showError('تعذر الحذف');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('تذكير الأدوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMedicationScreen()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _service.watchUpcomingMedications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('تعذر تحميل الأدوية: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final all = snapshot.data!;
          List<Map<String, dynamic>> meds = List<Map<String, dynamic>>.from(all);
          if (_filter == 'المتبقية') {
            meds = meds.where((m) => m['taken'] != true).toList();
          } else if (_filter == 'المكتملة') {
            meds = meds.where((m) => m['taken'] == true).toList();
          }

          final reminders = all.where((m) => m['reminderEnabled'] != false).length;
          final taken = all.where((m) => m['taken'] == true).length;

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _stat('💊', 'الأدوية', '${all.length}'),
                    _stat('⏰', 'التنبيهات', '$reminders'),
                    _stat('✅', 'المتناولة', '$taken'),
                  ],
                ),
              ),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final filter = _filters[index];
                    return ChoiceChip(
                      label: Text(filter),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: meds.isEmpty
                    ? const Center(child: Text('لا توجد أدوية في هذه القائمة'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(14),
                        itemCount: meds.length,
                        itemBuilder: (_, index) => _medicationCard(meds[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _medicationCard(Map<String, dynamic> medicine) {
    final id = medicine['id'].toString();
    final enabled = medicine['reminderEnabled'] != false;
    final taken = medicine['taken'] == true;
    final dose = (medicine['dose'] ?? '').toString();
    final frequency = (medicine['frequency'] ?? '').toString();
    final times = medicine['times'] is List
        ? (medicine['times'] as List).join('، ')
        : (medicine['time'] ?? '').toString();
    final name = (medicine['name'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: const CircleAvatar(
          backgroundColor: Color(0x1A0A8F83),
          child: Icon(Icons.medication, color: AppColors.primary),
        ),
        title: Text(
          dose.isEmpty ? name : '$name — $dose',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          frequency + (times.isEmpty ? '' : ' • $times'),
        ),
        trailing: SizedBox(
          width: 92,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Switch(
                value: enabled,
                onChanged: (value) => _toggle(id, value),
                activeColor: AppColors.primary,
              ),
              TextButton(
                onPressed: taken ? null : () => _taken(id),
                child: Text(taken ? 'تم' : 'تناول'),
              ),
            ],
          ),
        ),
        onLongPress: () => _delete(id),
      ),
    );
  }

  Widget _stat(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}
