import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/appointment_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class BookingScreen extends StatefulWidget {
  final String? doctorId;

  const BookingScreen({
    super.key,
    this.doctorId,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final AppointmentService _appointmentService = AppointmentService();

  bool _isLoading = false;
  bool _isLoadingDoctor = true;

  DateTime _selectedDate = DateTime.now();
  String _selectedTime = '10:00';

  String _doctorName = '';
  String _doctorSpecialty = '';
  String? _clinicAddress;
  String? _clinicPhone;

  String? _doctorError;

  final List<String> _availableTimes = const [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
    '18:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctor();
  }

  Future<void> _loadDoctor() async {
    final doctorId = widget.doctorId?.trim();

    if (doctorId == null || doctorId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoadingDoctor = false;
        _doctorError = 'لم يتم تحديد الطبيب المطلوب حجز الموعد معه';
      });

      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (!doc.exists) {
        throw Exception('ملف الطبيب غير موجود');
      }

      final data = doc.data();

      if (data == null) {
        throw Exception('بيانات الطبيب غير متوفرة');
      }

      if (!mounted) return;

      setState(() {
        _doctorName = data['name']?.toString() ?? '';
        _doctorSpecialty = data['specialty']?.toString() ?? '';
        _clinicAddress = data['clinicAddress']?.toString();
        _clinicPhone = data['clinicPhone']?.toString();
        _isLoadingDoctor = false;
      });

      if (_doctorName.isEmpty) {
        setState(() {
          _doctorError = 'بيانات الطبيب غير مكتملة';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingDoctor = false;
        _doctorError = 'تعذر تحميل بيانات الطبيب';
      });

      debugPrint('❌ Error loading doctor: $e');
    }
  }

  Future<void> _bookAppointment() async {
    if (_isLoadingDoctor) return;

    if (widget.doctorId == null ||
        widget.doctorId!.trim().isEmpty) {
      ToastService.showError('❌ لم يتم تحديد الطبيب');
      return;
    }

    if (_doctorName.isEmpty) {
      ToastService.showError('❌ بيانات الطبيب غير مكتملة');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _appointmentService.bookAppointment(
        doctorId: widget.doctorId!.trim(),
        doctorName: _doctorName,
        doctorSpecialty: _doctorSpecialty,
        date: _selectedDate,
        time: _selectedTime,
        type: 'in_person',
        notes: '',
        clinicAddress: _clinicAddress,
        clinicPhone: _clinicPhone,
      );

      if (!mounted) return;

      ToastService.showSuccess('✅ تم إرسال طلب حجز الموعد');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      debugPrint('❌ Booking error: $e');

      ToastService.showError(
        '❌ فشل حجز الموعد',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now)
          ? now
          : _selectedDate,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 30),
      ),
    );

    if (date == null || !mounted) return;

    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'حجز موعد',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingDoctor
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _doctorError != null
              ? _buildErrorState(isDark)
              : _buildBookingContent(isDark),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: isDark
                  ? Colors.white70
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              _doctorError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDoctor,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingContent(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorCard(isDark),

          const SizedBox(height: 24),

          const Text(
            'اختر التاريخ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          _buildDateSelector(isDark),

          const SizedBox(height: 20),

          const Text(
            'اختر الوقت',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          _buildTimeSelector(isDark),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed:
                  _isLoading ? null : _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'حجز الموعد',
                      style: TextStyle(
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

  Widget _buildDoctorCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A2540)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(
              Icons.medical_services_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _doctorName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
                if (_doctorSpecialty.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    _doctorSpecialty,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white70
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A2540)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _selectDate,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A2540)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedTime,
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
        dropdownColor: isDark
            ? const Color(0xFF1A2540)
            : Colors.white,
        items: _availableTimes.map((time) {
          return DropdownMenuItem<String>(
            value: time,
            child: Text(time),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedTime = value;
            });
          }
        },
      ),
    );
  }
}
