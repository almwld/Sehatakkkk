import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/medication/medication_model.dart';
import 'package:sehatak/core/services/medication/medication_service.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final MedicationService _medicationService = MedicationService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _remainingPillsController = TextEditingController();

  MedicationDosageForm _selectedForm = MedicationDosageForm.tablet;
  MedicationFrequency _selectedFrequency = MedicationFrequency.once;
  List<TimeOfDay> _selectedTimes = [TimeOfDay.now()];
  List<int> _selectedDays = [1, 2, 3, 4, 5, 6, 7];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int? _reorderThreshold;
  bool _isLoading = false;

  final List<String> _daysLabels = ['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: '➕ إضافة دواء جديد',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ اسم الدواء
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم الدواء *',
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ الجرعة
                  TextField(
                    controller: _dosageController,
                    decoration: const InputDecoration(
                      labelText: 'الجرعة (مثال: 500mg)',
                      prefixIcon: Icon(Icons.science),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ شكل الدواء
                  DropdownButtonFormField<MedicationDosageForm>(
                    value: _selectedForm,
                    decoration: const InputDecoration(
                      labelText: 'شكل الدواء',
                      prefixIcon: Icon(Icons.medication_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: MedicationDosageForm.values.map((form) {
                      return DropdownMenuItem(
                        value: form,
                        child: Text(form.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedForm = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ✅ التكرار
                  DropdownButtonFormField<MedicationFrequency>(
                    value: _selectedFrequency,
                    decoration: const InputDecoration(
                      labelText: 'تكرار الجرعة',
                      prefixIcon: Icon(Icons.repeat),
                      border: OutlineInputBorder(),
                    ),
                    items: MedicationFrequency.values.map((freq) {
                      return DropdownMenuItem(
                        value: freq,
                        child: Text(freq.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedFrequency = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // ✅ أوقات الجرعات
                  const Text(
                    '🕐 أوقات الجرعات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._selectedTimes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final time = entry.value;
                    return Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            leading: const Icon(Icons.access_time),
                            title: Text(${time.hour.toString().padLeft(2, 0)}:${time.minute.toString().padLeft(2, 0)}),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: _selectedTimes.length > 1
                                  ? () {
                                      setState(() {
                                        _selectedTimes.removeAt(index);
                                      });
                                    }
                                  : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _selectTime(index);
                          },
                        ),
                      ],
                    );
                  }).toList(),
                  TextButton(
                    onPressed: _addTime,
                    child: const Text('➕ إضافة وقت آخر'),
                  ),
                  const SizedBox(height: 12),

                  // ✅ أيام الأسبوع
                  const Text(
                    '📅 أيام الأسبوع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      final isSelected = _selectedDays.contains(day);
                      return ChoiceChip(
                        label: Text(_daysLabels[index]),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            if (isSelected) {
                              _selectedDays.remove(day);
                            } else {
                              _selectedDays.add(day);
                            }
                          });
                        },
                        selectedColor: AppColors.primary,
                        backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // ✅ تاريخ البدء
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: 'تاريخ البدء',
                    subtitle: '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                    onTap: () => _selectDate(true),
                  ),
                  const SizedBox(height: 8),

                  // ✅ تاريخ الانتهاء
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: 'تاريخ الانتهاء (اختياري)',
                    subtitle: Text(
                      _endDate != null
                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                          : 'غير محدد',
                    ),
                    onTap: () => _selectDate(false),
                  ),
                  const SizedBox(height: 12),

                  // ✅ عدد الحبات المتبقية
                  TextField(
                    controller: _remainingPillsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'عدد الحبات المتبقية',
                      prefixIcon: Icon(Icons.medication),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ حد إعادة الطلب
                  TextField(
                    controller: _remainingPillsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'حد إعادة الطلب (اختياري)',
                      prefixIcon: Icon(Icons.notification_important),
                      border: OutlineInputBorder(),
                      hintText: 'مثال: 5 حبات',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ تعليمات
                  TextField(
                    controller: _instructionsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'تعليمات الاستخدام (اختياري)',
                      prefixIcon: Icon(Icons.info),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ✅ ملاحظات
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات (اختياري)',
                      prefixIcon: Icon(Icons.note),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ زر الحفظ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveMedication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '💾 حفظ الدواء',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void _addTime() {
    setState(() {
      _selectedTimes.add(TimeOfDay.now());
    });
  }

  Future<void> _selectTime(int index) async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index],
    );
    if (time != null) {
      setState(() {
        _selectedTimes[index] = time;
      });
    }
  }

  Future<void> _selectDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      setState(() {
        if (isStart) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال اسم الدواء'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء تحديد وقت للجرعة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final remainingPills = int.tryParse(_remainingPillsController.text) ?? 0;
      
      await _medicationService.addMedication(
        name: _nameController.text,
        dosage: _dosageController.text.isNotEmpty ? _dosageController.text : null,
        form: _selectedForm,
        frequency: _selectedFrequency,
        times: _selectedTimes,
        daysOfWeek: _selectedDays,
        startDate: _startDate,
        endDate: _endDate,
        instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        remainingPills: remainingPills,
        reorderThreshold: null,
      );

      setState(() => _isLoading = false);
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم إضافة الدواء بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
