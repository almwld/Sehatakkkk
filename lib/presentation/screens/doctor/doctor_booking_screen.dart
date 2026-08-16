import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class DoctorBookingScreen extends StatefulWidget {
  final String doctorId;
  const DoctorBookingScreen({super.key, required this.doctorId});

  @override
  State<DoctorBookingScreen> createState() => _DoctorBookingScreenState();
}

class _DoctorBookingScreenState extends State<DoctorBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedType = 'استشارة عامة';
  bool _isLoading = false;

  final List<String> _consultationTypes = [
    'استشارة عامة',
    'استشارة تخصصية',
    'متابعة',
    'فحص دوري',
  ];

  Map<String, dynamic> _getDoctorData(String doctorId) {
    switch (doctorId) {
      case 'd1':
        return {'name': 'د. أحمد المولد', 'specialty': 'باطنية', 'image': ImageKit.doctor1};
      case 'd2':
        return {'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'image': ImageKit.doctor2};
      case 'd3':
        return {'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'image': ImageKit.doctor3};
      case 'd4':
        return {'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'image': ImageKit.doctor4};
      case 'd5':
        return {'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'image': ImageKit.doctor5};
      default:
        return {'name': 'د. غير معروف', 'specialty': 'عام', 'image': ImageKit.doctor1};
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final doctor = _getDoctorData(widget.doctorId);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'حجز موعد',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات الطبيب
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: ClipOval(
                            child: AppImage(
                              imageUrl: doctor['image'],
                              width: 72,
                              height: 72,
                              fit: BoxFit.cover,
                              errorWidget: const Icon(
                                Icons.person,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doctor['name'],
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doctor['specialty'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'متاح',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // تاريخ الموعد
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ الموعد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 7,
                            itemBuilder: (context, index) {
                              final date = DateTime.now().add(Duration(days: index));
                              final isSelected = date.day == _selectedDate.day &&
                                  date.month == _selectedDate.month &&
                                  date.year == _selectedDate.year;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedDate = date),
                                child: Container(
                                  width: 60,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark ? const Color(0xFF0B1121) : Colors.grey[100]),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        ['أحد', 'إثن', 'ثلاث', 'أربع', 'خميس', 'جمعة', 'سبت'][date.weekday % 7],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        date.day.toString(),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.white : Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الوقت
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'وقت الموعد',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            '09:00',
                            '09:30',
                            '10:00',
                            '10:30',
                            '11:00',
                            '11:30',
                            '12:00',
                            '12:30',
                            '13:00',
                            '13:30',
                            '14:00',
                            '14:30',
                          ].map((time) {
                            final parts = time.split(':');
                            final isSelected = parts[0] == _selectedTime.hour.toString() &&
                                parts[1] == _selectedTime.minute.toString();
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedTime = TimeOfDay(
                                    hour: int.parse(parts[0]),
                                    minute: int.parse(parts[1]),
                                  );
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF0B1121) : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  time,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // نوع الاستشارة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'نوع الاستشارة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _consultationTypes.map((type) {
                            final isSelected = type == _selectedType;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedType = type),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF0B1121) : Colors.grey[100]),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  type,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ملاحظات
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1A2540) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملاحظات',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'اكتب أي ملاحظات إضافية...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                            filled: true,
                            fillColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
                          ),
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // زر الحجز
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _bookAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الحجز',
                        style: TextStyle(
                          fontSize: 16,
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

  void _bookAppointment() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ToastService.showSuccess(context, '✅ تم حجز الموعد بنجاح!');
      Navigator.pop(context);
    });
  }
}
