// ============================================================
// 📁 lib/presentation/screens/booking/booking_screen.dart
// 📅 شاشة حجز موعد - الإصدار المتقدم
// ============================================================

import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/booking/specialty_model.dart';
import 'package:sehatak/core/models/booking/doctor_booking_model.dart';
import 'package:sehatak/core/models/booking/time_slot_model.dart';
import 'package:sehatak/core/services/booking/booking_repository.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/core/services/toast_service.dart';

class BookingScreen extends StatefulWidget {
  final String? doctorId;
  const BookingScreen({super.key, this.doctorId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingRepository _repository = BookingRepository();
  int _currentStep = 0;
  bool _isLoading = true;
  bool _isBooking = false;

  // ✅ البيانات
  List<SpecialtyModel> _specialties = [];
  List<DoctorBookingModel> _doctors = [];
  List<TimeSlotModel> _timeSlots = [];

  // ✅ الاختيارات
  SpecialtyModel? _selectedSpecialty;
  DoctorBookingModel? _selectedDoctor;
  TimeSlotModel? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _specialties = await _repository.getSpecialties();
      _doctors = await _repository.getDoctors();

      // إذا كان هناك doctorId محدد
      if (widget.doctorId != null) {
        _selectedDoctor = _doctors.firstWhere(
          (d) => d.id == widget.doctorId,
          orElse: () => _doctors.first,
        );
        if (_selectedDoctor != null) {
          _selectedSpecialty = _specialties.firstWhere(
            (s) => s.id == _selectedDoctor!.specialtyId,
            orElse: () => _specialties.first,
          );
          _currentStep = 1;
          await _loadTimeSlots();
        }
      }
    } catch (e) {
      ToastService.showError('❌ فشل تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimeSlots() async {
    if (_selectedDoctor == null) return;
    _timeSlots = await _repository.getTimeSlots(
      doctorId: _selectedDoctor!.id,
    );
  }

  void _nextStep() {
    setState(() => _currentStep++);
    if (_currentStep == 2) _loadTimeSlots();
  }

  void _prevStep() {
    setState(() => _currentStep--);
  }

  Future<void> _confirmBooking() async {
    if (_selectedDoctor == null || _selectedTimeSlot == null) {
      ToastService.showError('❌ يرجى اختيار الطبيب والموعد');
      return;
    }

    setState(() => _isBooking = true);

    try {
      final booking = await _repository.confirmBooking(
        doctorId: _selectedDoctor!.id,
        doctorName: _selectedDoctor!.name,
        date: DateTime.now(),
        time: _selectedTimeSlot!.time,
      );

      ToastService.showSuccess('✅ تم حجز الموعد بنجاح!');
      
      // العودة إلى الشاشة السابقة
      Navigator.pop(context, booking);
    } catch (e) {
      ToastService.showError('❌ فشل حجز الموعد: $e');
    } finally {
      setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'حجز موعد',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadData,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ شريط التقدم
                _buildProgressBar(isDark),
                const SizedBox(height: 16),

                // ✅ المحتوى
                Expanded(
                  child: _buildStepContent(isDark),
                ),

                // ✅ أزرار التنقل
                _buildNavigationButtons(isDark),
              ],
            ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(bool isDark) {
    switch (_currentStep) {
      case 0:
        return _buildSpecialtiesStep(isDark);
      case 1:
        return _buildDoctorsStep(isDark);
      case 2:
        return _buildTimeSlotsStep(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // 📍 الخطوة 1: اختيار التخصص
  // ============================================================
  Widget _buildSpecialtiesStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر التخصص',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر التخصص الطبي المناسب',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                final isSelected = _selectedSpecialty?.id == specialty.id;
                return _buildSpecialtyCard(specialty, isSelected, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSpecialty = specialty;
          // فلترة الأطباء حسب التخصص
          _doctors = _doctors.where((d) => d.specialtyId == specialty.id).toList();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 8,
            ),
          ] : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              specialty.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 6),
            Text(
              specialty.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${specialty.doctorCount} طبيب',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 👨‍⚕️ الخطوة 2: اختيار الطبيب
  // ============================================================
  Widget _buildDoctorsStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اختر الطبيب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اختر الطبيب المناسب لحالتك',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _doctors.length,
              itemBuilder: (context, index) {
                final doctor = _doctors[index];
                final isSelected = _selectedDoctor?.id == doctor.id;
                return _buildDoctorCard(doctor, isSelected, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorBookingModel doctor, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDoctor = doctor;
          _timeSlots = [];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.grey[700]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                doctor.name[0],
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.rating}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${doctor.reviewsCount})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (doctor.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'متاح',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ⏰ الخطوة 3: اختيار الوقت
  // ============================================================
  Widget _buildTimeSlotsStep(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'اختر الوقت',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedDoctor?.name ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () {
                  // TODO: اختيار تاريخ
                  ToastService.showInfo('📅 اختيار تاريخ قريباً');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.8,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final slot = _timeSlots[index];
                final isSelected = _selectedTimeSlot?.id == slot.id;
                return _buildTimeSlotCard(slot, isSelected, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlotCard(TimeSlotModel slot, bool isSelected, bool isDark) {
    final isAvailable = slot.isAvailable;
    return GestureDetector(
      onTap: isAvailable
          ? () => setState(() => _selectedTimeSlot = slot)
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : isAvailable
                    ? (isDark ? Colors.grey[700]! : Colors.grey[200]!)
                    : Colors.red.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isAvailable
              ? (isSelected ? AppColors.primary.withOpacity(0.05) : null)
              : Colors.grey.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              slot.time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isAvailable
                    ? (isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black87))
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              slot.date,
              style: TextStyle(
                fontSize: 10,
                color: isAvailable
                    ? (isDark ? Colors.grey[400] : Colors.grey[600])
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔘 أزرار التنقل
  // ============================================================
  Widget _buildNavigationButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1121) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('السابق'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentStep == 2
                  ? (_isBooking ? null : _confirmBooking)
                  : _currentStep == 0
                      ? (_selectedSpecialty != null ? _nextStep : null)
                      : (_selectedDoctor != null ? _nextStep : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isBooking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentStep == 2 ? 'حجز' : 'التالي',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
