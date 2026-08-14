import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/booking/booking_service.dart';
import 'package:sehatak/data/models/booking/booking_model.dart';

class BookingScreen extends StatefulWidget {
  final String? doctorId;
  const BookingScreen({super.key, this.doctorId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  
  List<DoctorModel> _doctors = [];
  List<SpecialtyModel> _specialties = [];
  List<TimeSlotModel> _timeSlots = [];
  
  SpecialtyModel? _selectedSpecialty;
  DoctorModel? _selectedDoctor;
  TimeSlotModel? _selectedTimeSlot;
  
  bool _isLoading = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _specialties = await _bookingService.getSpecialties();
      _doctors = await _bookingService.getDoctors();
      _timeSlots = await _bookingService.getTimeSlots();
      
      if (widget.doctorId != null) {
        _selectedDoctor = _doctors.firstWhere(
          (d) => d.id == widget.doctorId,
          orElse: () => _doctors.first,
        );
        _selectedSpecialty = _specialties.firstWhere(
          (s) => s.id == _selectedDoctor?.specialtyId,
          orElse: () => _specialties.first,
        );
        _currentStep = 1;
      }
    } catch (e) {
      print('❌ Error loading data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'حجز موعد',
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_currentStep > 0)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
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
                // ✅ المحتوى حسب الخطوة
                Expanded(
                  child: IndexedStack(
                    index: _currentStep,
                    children: [
                      _buildSpecialtyStep(isDark),
                      _buildDoctorStep(isDark),
                      _buildTimeSlotStep(isDark),
                      _buildConfirmationStep(isDark),
                    ],
                  ),
                ),
                // ✅ أزرار التحكم
                _buildNavigationButtons(isDark, primaryColor),
              ],
            ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    final steps = ['التخصص', 'الطبيب', 'الموعد', 'التأكيد'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = _currentStep >= index;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF0D5257) : (isDark ? Colors.grey : Colors.grey),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isActive
                            ? Icon(Icons.check, color: Colors.white, size: 14)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isDark ? Colors.grey : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 9,
                        color: isActive ? const Color(0xFF0D5257) : (isDark ? Colors.grey : Colors.grey),
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep > index ? const Color(0xFF0D5257) : (isDark ? Colors.grey : Colors.grey),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // 📋 الخطوة 1: اختيار التخصص
  // ============================================================
  Widget _buildSpecialtyStep(bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _specialties.length,
      itemBuilder: (context, index) {
        final specialty = _specialties[index];
        final isSelected = _selectedSpecialty?.id == specialty.id;
        return _buildSpecialtyCard(specialty, isSelected, isDark);
      },
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSpecialty = specialty;
          // ✅ تصفية الأطباء حسب التخصص
          _doctors = _doctors.where((d) => d.specialtyId == specialty.id).toList();
          _currentStep = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D5257).withOpacity(0.05)
              : (isDark ? const Color(0xFF1A2540) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D5257) : (isDark ? Colors.grey! : Colors.grey!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0D5257).withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              specialty.icon,
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              specialty.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '${specialty.doctorCount} طبيب',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey : Colors.grey,
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
  Widget _buildDoctorStep(bool isDark) {
    if (_doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_rounded,
              size: 64,
              color: isDark ? Colors.grey : Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد أطباء في هذا التخصص',
              style: TextStyle(
                color: isDark ? Colors.grey : Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _doctors.length,
      itemBuilder: (context, index) {
        final doctor = _doctors[index];
        final isSelected = _selectedDoctor?.id == doctor.id;
        return _buildDoctorCard(doctor, isSelected, isDark);
      },
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDoctor = doctor;
          _currentStep = 2;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D5257).withOpacity(0.05)
              : (isDark ? const Color(0xFF1A2540) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0D5257) : (isDark ? Colors.grey! : Colors.grey!),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF0D5257).withOpacity(0.1),
              child: Text(
                doctor.name[0],
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D5257),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        doctor.rating.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${doctor.experience} سنة خبرة',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: doctor.isAvailable ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        doctor.isAvailable ? 'متاح' : 'غير متاح',
                        style: TextStyle(
                          fontSize: 11,
                          color: doctor.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🕐 الخطوة 3: اختيار الموعد
  // ============================================================
  Widget _buildTimeSlotStep(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: Color(0xFF0D5257)),
              const SizedBox(width: 8),
              Text(
                'اختر الوقت المناسب',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final slot = _timeSlots[index];
              final isSelected = _selectedTimeSlot?.id == slot.id;
              final isPast = slot.isPast;
              final isBooked = slot.isBooked;

              return _buildTimeSlotCard(slot, isSelected, isPast, isBooked, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotCard(
    TimeSlotModel slot,
    bool isSelected,
    bool isPast,
    bool isBooked,
    bool isDark,
  ) {
    final isAvailable = !isPast && !isBooked;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              setState(() {
                _selectedTimeSlot = slot;
                _currentStep = 3;
              });
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D5257).withOpacity(0.05)
              : (isDark ? const Color(0xFF1A2540) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D5257)
                : (isPast || isBooked
                    ? (isDark ? Colors.grey! : Colors.grey!)
                    : (isDark ? Colors.grey! : Colors.grey!)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isPast ? Icons.hourglass_empty_rounded : Icons.access_time_rounded,
              color: isPast ? Colors.grey : const Color(0xFF0D5257),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.time,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isPast ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    slot.date,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPast ? Colors.grey : (isDark ? Colors.grey : Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF0D5257))
            else if (isPast)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مضى',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              )
            else if (isBooked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'محجوز',
                  style: TextStyle(color: Colors.red, fontSize: 11),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'متاح',
                  style: TextStyle(color: Colors.green, fontSize: 11),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ✅ الخطوة 4: تأكيد الحجز
  // ============================================================
  Widget _buildConfirmationStep(bool isDark) {
    final doctor = _selectedDoctor!;
    final slot = _selectedTimeSlot!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تأكيد الحجز',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'يرجى مراجعة التفاصيل قبل التأكيد',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          // ✅ بطاقة التأكيد
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey! : Colors.grey!,
              ),
            ),
            child: Column(
              children: [
                _buildConfirmationRow(
                  'الطبيب',
                  doctor.name,
                  Icons.person_rounded,
                  isDark,
                ),
                _buildDivider(isDark),
                _buildConfirmationRow(
                  'التخصص',
                  doctor.specialty,
                  Icons.medical_services_rounded,
                  isDark,
                ),
                _buildDivider(isDark),
                _buildConfirmationRow(
                  'التاريخ',
                  slot.date,
                  Icons.calendar_today_rounded,
                  isDark,
                ),
                _buildDivider(isDark),
                _buildConfirmationRow(
                  'الوقت',
                  slot.time,
                  Icons.access_time_rounded,
                  isDark,
                ),
                _buildDivider(isDark),
                _buildConfirmationRow(
                  'السعر',
                  '${doctor.fee} ريال',
                  Icons.payment_rounded,
                  isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ✅ تحذير
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'سيتم إرسال تأكيد الحجز إلى بريدك الإلكتروني',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D5257), size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey : Colors.grey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey! : Colors.grey!,
    );
  }

  // ============================================================
  // 🧭 أزرار التحكم
  // ============================================================
  Widget _buildNavigationButtons(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('السابق'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep == 3
                  ? _confirmBooking
                  : () {
                      if (_currentStep == 0 && _selectedSpecialty == null) return;
                      if (_currentStep == 1 && _selectedDoctor == null) return;
                      if (_currentStep == 2 && _selectedTimeSlot == null) return;
                      setState(() => _currentStep++);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentStep == 3 ? 'تأكيد الحجز' : 'التالي'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    // ✅ محاكاة تأكيد الحجز
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ تم حجز الموعد بنجاح!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pop(context, true);
    });
  }
}
