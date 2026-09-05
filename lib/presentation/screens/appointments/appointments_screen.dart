import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/appointment_service.dart';
import 'package:sehatak/presentation/screens/booking/booking_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() =>
      _AppointmentsScreenState();
}

class _AppointmentsScreenState
    extends State<AppointmentsScreen> {
  final AppointmentService _appointmentService =
      AppointmentService();

  String _filter = 'all';

  final Map<String, String> _statusLabels = const {
    'pending': 'قيد الانتظار',
    'confirmed': 'مؤكد',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',
  };

  final Map<String, Color> _statusColors = {
    'pending': Colors.orange,
    'confirmed': Colors.green,
    'completed': Colors.blue,
    'cancelled': Colors.red,
  };

  List<Map<String, dynamic>> _filterAppointments(
    List<Map<String, dynamic>> appointments,
  ) {
    if (_filter == 'all') {
      return appointments;
    }

    return appointments
        .where(
          (appointment) =>
              appointment['status'] == _filter,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('المواعيد'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _appointmentService
            .watchPatientAppointments(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildErrorState(
              isDark,
              snapshot.error.toString(),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          final appointments =
              snapshot.data ?? <Map<String, dynamic>>[];

          final filtered =
              _filterAppointments(appointments);

          return Column(
            children: [
              _buildFilterBar(isDark),

              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildAppointmentCard(
                            filtered[index],
                            isDark,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const BookingScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterBar(bool isDark) {
    final filters = [
      {'key': 'all', 'label': 'الكل'},
      {'key': 'pending', 'label': 'قيد الانتظار'},
      {'key': 'confirmed', 'label': 'مؤكد'},
      {'key': 'completed', 'label': 'مكتمل'},
      {'key': 'cancelled', 'label': 'ملغي'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final key = filter['key'] as String;
          final label = filter['label'] as String;
          final isSelected = _filter == key;

          return GestureDetector(
            onTap: () {
              setState(() {
                _filter = key;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 4,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? const Color(0xFF1A2540)
                        : Colors.grey[200],
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? Colors.grey[400]
                            : Colors.grey[700],
                    fontSize: 12,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    bool isDark,
  ) {
    final status =
        appointment['status']?.toString() ??
            'pending';

    final color =
        _statusColors[status] ?? Colors.grey;

    final label =
        _statusLabels[status] ?? status;

    final date = _readDate(
      appointment['date'],
    );

    final time =
        appointment['time']?.toString() ??
            '--:--';

    final doctorName =
        appointment['doctorName']?.toString() ??
            'طبيب';

    final specialty =
        appointment['doctorSpecialty']?.toString() ??
            '';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1A2540)
            : Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset:
                const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.calendar_today,
              color: color,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),

                if (specialty.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      size: 14,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),

                    Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),

                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
                  color.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime _readDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    return DateTime.now();
  }

  Widget _buildErrorState(
    bool isDark,
    String error,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: isDark
                  ? Colors.grey[500]
                  : Colors.grey[600],
            ),

            const SizedBox(height: 16),

            const Text(
              'تعذر تحميل المواعيد',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'تحقق من الاتصال والصلاحيات.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.grey[400]
                    : Colors.grey[600],
              ),
            ),

            const SizedBox(height: 8),

            if (error.isNotEmpty)
              Text(
                error,
                maxLines: 2,
                overflow:
                    TextOverflow.ellipsis,
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? Colors.grey[500]
                      : Colors.grey[500],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: isDark
                ? Colors.grey[600]
                : Colors.grey[300],
          ),

          const SizedBox(height: 16),

          Text(
            'لا توجد مواعيد',
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
              color: isDark
                  ? Colors.white
                  : Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'ابدأ بحجز موعد جديد من صفحة الطبيب',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? Colors.grey[400]
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
