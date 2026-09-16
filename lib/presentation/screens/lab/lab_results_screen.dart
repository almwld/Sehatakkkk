import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/lab/lab_booking_model.dart';
import 'package:sehatak/core/services/lab_service.dart';

class LabResultsScreen extends StatefulWidget {
  final String bookingId;
  const LabResultsScreen({super.key, required this.bookingId});

  @override
  State<LabResultsScreen> createState() => _LabResultsScreenState();
}

class _LabResultsScreenState extends State<LabResultsScreen> {
  final _service = LabService();
  LabBookingModel? _booking;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final booking = await _service.getLabBooking(widget.bookingId);
      if (!mounted) return;
      setState(() { _booking = booking; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _value(dynamic value) => value?.toString().trim() ?? '';

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('نتائج الفحوصات'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _booking == null
              ? const Center(child: Text('تعذر تحميل نتيجة الحجز.'))
              : _content(_booking!, dark),
    );
  }

  Widget _content(LabBookingModel booking, bool dark) {
    final results = booking.results ?? const <String, dynamic>{};
    if (results.isEmpty && (booking.resultFile == null || booking.resultFile!.isEmpty)) {
      return const Center(child: Text('لم يتم نشر نتائج هذا الحجز بعد.'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(booking, dark),
        const SizedBox(height: 12),
        if (results.isNotEmpty) ...[
          Text('النتائج المسجلة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          ...results.entries.map((entry) => Card(
                color: dark ? const Color(0xFF1A2540) : Colors.white,
                child: ListTile(
                  title: Text(entry.key, style: TextStyle(fontWeight: FontWeight.w700, color: dark ? Colors.white : Colors.black87)),
                  subtitle: Text(_value(entry.value), style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700])),
                ),
              )),
        ],
        if (booking.resultFile != null && booking.resultFile!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            color: dark ? const Color(0xFF1A2540) : Colors.white,
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.primary),
              title: const Text('ملف النتيجة'),
              subtitle: const Text('تم حفظ ملف النتيجة لهذا الحجز.'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _header(LabBookingModel booking, bool dark) => Card(
        color: dark ? const Color(0xFF1A2540) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(booking.labName, style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
            const SizedBox(height: 6),
            Text('رقم الحجز: ${booking.id}', style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700])),
            const SizedBox(height: 4),
            Text('عدد الفحوصات: ${booking.tests.length}', style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700])),
          ]),
        ),
      );
}
