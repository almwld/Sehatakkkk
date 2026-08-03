import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/medication/medication_model.dart';
import 'package:sehatak/core/services/medication/medication_service.dart';
import 'package:sehatak/presentation/screens/medication/add_medication_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_detail_screen.dart';
import 'package:sehatak/presentation/screens/medication/medication_history_screen.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen> with SingleTickerProviderStateMixin {
  final MedicationService _medicationService = MedicationService();
  List<MedicationModel> _medications = [];
  List<MedicationModel> _todayMedications = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initService();
  }

  Future<void> _initService() async {
    await _medicationService.initNotifications();
    _loadData();
  }

  void _loadData() {
    _medicationService.getMedications().listen((medications) {
      setState(() {
        _medications = medications;
        _isLoading = false;
      });
    });
    
    _loadTodayMedications();
  }

  Future<void> _loadTodayMedications() async {
    final today = await _medicationService.getTodayMedications();
    setState(() {
      _todayMedications = today;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('💊 تذكير الأدوية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '📋 اليوم'),
            Tab(text: '📦 جميع الأدوية'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicationHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddMedicationScreen(),
                ),
              ).then((_) => _loadData());
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTodayTab(isDark),
                _buildAllMedicationsTab(isDark),
              ],
            ),
    );
  }

  // ✅ تبويب اليوم
  Widget _buildTodayTab(bool isDark) {
    if (_todayMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد أدوية اليوم',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف دواء جديد أو تحقق من قائمة الأدوية',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddMedicationScreen(),
                  ),
                ).then((_) => _loadData());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('➕ إضافة دواء'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _todayMedications.length,
      itemBuilder: (context, index) {
        final med = _todayMedications[index];
        final isTaken = med.logs.isNotEmpty && med.logs.last.takenAt.day == DateTime.now().day;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicationDetailScreen(medicationId: med.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isTaken
                  ? Border.all(color: Colors.green, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (med.form as MedicationDosageForm).color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    med.formIcon,
                    color: (med.form as MedicationDosageForm).color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${med.dosage ?? ''} • ${med.formText}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: med.times.map((time) {
                          final timeStr = ${time.hour.toString().padLeft(2, 0)}:${time.minute.toString().padLeft(2, 0)};
                          final isTimePassed = _isTimePassed(time);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTimePassed && !isTaken
                                  ? Colors.red.withOpacity(0.1)
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 11,
                                color: isTimePassed && !isTaken
                                    ? Colors.red
                                    : Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (isTaken)
                      const Icon(Icons.check_circle, color: Colors.green, size: 28)
                    else
                      ElevatedButton(
                        onPressed: () {
                          _showTakeDialog(med);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text('تناولت'),
                      ),
                    const SizedBox(height: 4),
                    if (med.remainingPills > 0)
                      Text(
                        '${med.remainingPills} حبة متبقية',
                        style: TextStyle(
                          fontSize: 10,
                          color: med.needsRenewal ? Colors.red : Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ تبويب جميع الأدوية
  Widget _buildAllMedicationsTab(bool isDark) {
    if (_medications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication_outlined, size: 64, color: isDark ? Colors.grey[600] : Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'لا توجد أدوية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف أدويتك للحصول على تذكيرات',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final med = _medications[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MedicationDetailScreen(medicationId: med.id),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (med.form as MedicationDosageForm).color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    med.formIcon,
                    color: (med.form as MedicationDosageForm).color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        med.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${med.dosage ?? ''} • ${med.frequencyText}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (med.needsRenewal)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'نفذ المخزون',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTakeDialog(MedicationModel med) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('💊 ${med.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('هل تناولت الدواء؟'),
            const SizedBox(height: 8),
            Text(
              'الجرعة: ${med.dosage ?? ''}',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('تخطي'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _medicationService.logMedication(med.id, true);
              Navigator.pop(context);
              await _loadTodayMedications();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ تم تسجيل تناول الدواء'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('✅ تناولت'),
          ),
        ],
      ),
    );
  }

  bool _isTimePassed(TimeOfDay time) {
    final now = TimeOfDay.now();
    return time.hour < now.hour || (time.hour == now.hour && time.minute < now.minute);
  }
}

extension MedicationDosageFormExtension on MedicationDosageForm {
  Color get color {
    switch (this) {
      case MedicationDosageForm.tablet: return Colors.blue;
      case MedicationDosageForm.capsule: return Colors.purple;
      case MedicationDosageForm.syrup: return Colors.orange;
      case MedicationDosageForm.injection: return Colors.red;
      case MedicationDosageForm.drops: return Colors.cyan;
      case MedicationDosageForm.cream: return Colors.pink;
      case MedicationDosageForm.spray: return Colors.teal;
      case MedicationDosageForm.patch: return Colors.green;
    }
  }
}
