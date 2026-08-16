import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HealthCalendarScreen extends StatefulWidget {
  const HealthCalendarScreen({super.key});

  @override
  State<HealthCalendarScreen> createState() => _HealthCalendarScreenState();
}

class _HealthCalendarScreenState extends State<HealthCalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  final List<Map<String, dynamic>> _eventTypes = [
    {'icon': Icons.medical_services_rounded, 'label': 'موعد طبي', 'color': AppColors.primary},
    {'icon': Icons.medication_rounded, 'label': 'تذكير دواء', 'color': AppColors.warning},
    {'icon': Icons.science_rounded, 'label': 'تحليل', 'color': AppColors.purple},
    {'icon': Icons.fitness_center_rounded, 'label': 'تمارين', 'color': AppColors.success},
    {'icon': Icons.favorite_rounded, 'label': 'متابعة صحية', 'color': AppColors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    final user = _auth.currentUser;
    if (user != null) {
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final eventsData = data['calendarEvents'] as List? ?? [];
          
          final Map<DateTime, List<Map<String, dynamic>>> tempEvents = {};
          for (final event in eventsData) {
            final date = (event['date'] as Timestamp).toDate();
            final dateKey = DateTime(date.year, date.month, date.day);
            if (!tempEvents.containsKey(dateKey)) {
              tempEvents[dateKey] = [];
            }
            tempEvents[dateKey]!.add({
              'title': event['title'] ?? 'حدث',
              'type': event['type'] ?? 'موعد طبي',
              'time': event['time'] ?? '10:00 ص',
              'notes': event['notes'] ?? '',
            });
          }
          setState(() => _events = tempEvents);
        }
      } catch (e) {
        print('❌ Error loading events: $e');
      }
    }

    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  void _addEvent(DateTime date, Map<String, dynamic> event) {
    final dateKey = DateTime(date.year, date.month, date.day);
    setState(() {
      if (!_events.containsKey(dateKey)) {
        _events[dateKey] = [];
      }
      _events[dateKey]!.add(event);
    });

    // ✅ حفظ في Firestore
    _saveEventsToFirestore();
  }

  Future<void> _saveEventsToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final eventsList = [];
      for (final entry in _events.entries) {
        final date = entry.key;
        for (final event in entry.value) {
          eventsList.add({
            'date': Timestamp.fromDate(date),
            'title': event['title'],
            'type': event['type'],
            'time': event['time'],
            'notes': event['notes'],
          });
        }
      }
      
      await _firestore.collection('users').doc(user.uid).set({
        'calendarEvents': eventsList,
      }, SetOptions(merge: true));
    } catch (e) {
      print('❌ Error saving events: $e');
    }
  }

  void _showAddEventDialog(DateTime date) {
    final titleController = TextEditingController();
    String selectedType = 'موعد طبي';
    String selectedTime = '10:00 ص';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة حدث جديد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            // ✅ عنوان الحدث
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الحدث',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ نوع الحدث
            DropdownButtonFormField<String>(
              value: selectedType,
              items: _eventTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['label'] as String,
                  child: Row(
                    children: [
                      Icon(type['icon'] as IconData, color: type['color'] as Color, size: 16),
                      const SizedBox(width: 8),
                      Text(type['label'] as String),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => selectedType = value!,
              decoration: const InputDecoration(
                labelText: 'نوع الحدث',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // ✅ الوقت
            TextField(
              controller: TextEditingController(text: selectedTime),
              decoration: const InputDecoration(
                labelText: 'الوقت',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        _addEvent(date, {
                          'title': titleController.text,
                          'type': selectedType,
                          'time': selectedTime,
                          'notes': '',
                        });
                        Navigator.pop(context);
                        ToastService.showSuccess(context, '✅ تم إضافة الحدث');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('إضافة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: CustomAppBar(
        title: const Text('التقويم الصحي', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddEventDialog(_selectedDay),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ✅ التقويم
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (format) => setState(() => _calendarFormat = format),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  eventLoader: _getEventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 3,
                    markerDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 8),
                // ✅ أحداث اليوم
                _buildDayEvents(isDark),
              ],
            ),
    );
  }

  Widget _buildDayEvents(bool isDark) {
    final events = _getEventsForDay(_selectedDay);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'أحداث ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (events.isNotEmpty)
                  Text(
                    '${events.length} حدث',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (events.isEmpty)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy_rounded, size: 40, color: AppColors.grey),
                      SizedBox(height: 8),
                      Text(
                        'لا توجد أحداث في هذا اليوم',
                        style: TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط على + لإضافة حدث',
                        style: TextStyle(color: AppColors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final type = _eventTypes.firstWhere(
                      (t) => t['label'] == event['type'],
                      orElse: () => _eventTypes[0],
                    );
                    final color = type['color'] as Color;
                    final icon = type['icon'] as IconData;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(icon, color: color, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${event['time']} • ${event['type']}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.grey),
                            onPressed: () {
                              // حذف الحدث
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
