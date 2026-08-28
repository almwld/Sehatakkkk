import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/reminder_sound_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'add_medication_screen.dart';

class MedicationReminderScreen extends StatefulWidget {
  const MedicationReminderScreen({super.key});

  @override
  State<MedicationReminderScreen> createState() => _MedicationReminderScreenState();
}

class _MedicationReminderScreenState extends State<MedicationReminderScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final ReminderSoundService _soundService = ReminderSoundService();
  
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'اليوم', 'متأخر', 'مكتمل'];
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // ✅ قائمة أيقونات الأدوية (PNG)
  final List<Map<String, dynamic>> _medicationIcons = [
    {'path': 'assets/images/medicines/medicine8.png', 'label': 'حبوب'},
    {'path': 'assets/images/medicines/medicine10.png', 'label': 'كبسولات'},
    {'path': 'assets/images/medicines/medicine9.png', 'label': 'شراب'},
    {'path': 'assets/images/medicines/medicine_1.png', 'label': 'دواء 1'},
    {'path': 'assets/images/medicines/medicine_2.png', 'label': 'دواء 2'},
    {'path': 'assets/images/medicines/medicine_3.png', 'label': 'دواء 3'},
    {'path': 'assets/images/medicines/medicine_4.png', 'label': 'دواء 4'},
  ];

  // ✅ قائمة الألوان
  final List<Color> _colors = [
    AppColors.primary,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.red,
    Colors.amber,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadMedications();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _soundService.dispose();
    super.dispose();
  }

  // ============================================================
  // 🔔 تهيئة الإشعارات
  // ============================================================
  Future<void> _initNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }

  // ============================================================
  // 📤 إرسال إشعار مع رنين
  // ============================================================
  Future<void> _sendNotification(String title, String body, int id) async {
    // ✅ تشغيل نغمة التذكير
    await _soundService.playReminderSound();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'تذكير الأدوية',
      channelDescription: 'تنبيهات لمواعيد تناول الأدوية',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('medication_reminder'),
      icon: '@mipmap/ic_launcher',
      styleInformation: const BigTextStyleInformation(''),
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _notifications.show(id, title, body, details);
  }

  // ============================================================
  // 📥 تحميل الأدوية من Firebase
  // ============================================================
  Future<void> _loadMedications() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .orderBy('time', descending: false)
          .get();

      _medications = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'time': data['time'] ?? '',
          'dose': data['dose'] ?? '',
          'taken': data['taken'] ?? false,
          'remaining': data['remaining'] ?? 0,
          'total': data['total'] ?? 0,
          'refillDate': data['refillDate'] ?? '',
          'icon': data['icon'] ?? 'assets/images/medicines/medicine8.png',
          'color': data['color'] ?? AppColors.primary.value,
          'notes': data['notes'] ?? '',
          'createdAt': data['createdAt']?.toDate() ?? DateTime.now(),
        };
      }).toList();

      // ✅ التحقق من المواعيد وإرسال إشعارات
      _checkDueMedications();
      
      setState(() => _isLoading = false);
    } catch (e) {
      ToastService.showError('خطأ في تحميل الأدوية');
      setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // ⏰ التحقق من الأدوية المستحقة
  // ============================================================
  void _checkDueMedications() {
    final now = DateTime.now();
    final currentTime = DateFormat('HH:mm').format(now);
    
    for (var med in _medications) {
      if (!med['taken'] && med['time'] == currentTime) {
        _sendNotification(
          '⏰ تذكير بتناول الدواء',
          'حان وقت تناول ${med['name']}',
          med['id'].hashCode,
        );
      }
    }
  }

  // ============================================================
  // ✅ تحديث حالة الدواء (تم تناوله)
  // ============================================================
  Future<void> _toggleTaken(String id, bool taken) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('medications')
          .doc(id)
          .update({
        'taken': taken,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        final index = _medications.indexWhere((m) => m['id'] == id);
        if (index != -1) {
          _medications[index]['taken'] = taken;
          if (taken) {
            _medications[index]['remaining'] = (_medications[index]['remaining'] as int) - 1;
            ToastService.showSuccess('✅ تم تسجيل تناول الدواء');
            // ✅ تشغيل صوت إشعار
            _soundService.playNotificationSound();
          }
        }
      });

      // ✅ إذا انتهت الكمية، إرسال إشعار لإعادة التعبئة
      final med = _medications.firstWhere((m) => m['id'] == id);
      if (taken && (med['remaining'] as int) <= 3) {
        _sendNotification(
          '⚠️ تنبيه: كمية الدواء قاربت على النفاد',
          '${med['name']} متبقي ${med['remaining']} جرعة فقط، يرجى إعادة التعبئة',
          id.hashCode + 1000,
        );
      }
    } catch (e) {
      ToastService.showError('خطأ في تحديث الحالة');
    }
  }

  // ============================================================
  // ❌ حذف دواء
  // ============================================================
  Future<void> _deleteMedication(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الدواء'),
        content: const Text('هل أنت متأكد من حذف هذا الدواء؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final user = _auth.currentUser;
                if (user == null) return;
                await _firestore
                    .collection('users')
                    .doc(user.uid)
                    .collection('medications')
                    .doc(id)
                    .delete();
                setState(() {
                  _medications.removeWhere((m) => m['id'] == id);
                });
                ToastService.showSuccess('🗑️ تم حذف الدواء');
              } catch (e) {
                ToastService.showError('خطأ في الحذف');
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ➕ إضافة دواء جديد
  // ============================================================
  void _addMedication() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddMedicationScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _loadMedications();
        ToastService.showSuccess('💊 تم إضافة الدواء بنجاح');
      }
    });
  }

  // ============================================================
  // 📊 الحصول على الأدوية المصفاة
  // ============================================================
  List<Map<String, dynamic>> get _filteredMedications {
    switch (_selectedFilter) {
      case 'اليوم':
        return _medications.where((m) => !m['taken']).toList();
      case 'متأخر':
        return _medications.where((m) => !m['taken'] && (m['remaining'] as int) < 5).toList();
      case 'مكتمل':
        return _medications.where((m) => m['taken']).toList();
      default:
        return _medications;
    }
  }

  // ============================================================
  // 🏗️ بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredMedications;
    final totalMedications = _medications.length;
    final takenToday = _medications.where((m) => m['taken']).length;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'تذكير الأدوية',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMedication,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMedications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                // ✅ الإحصائيات السريعة
                _buildStatsRow(isDark, totalMedications, takenToday),
                
                // ✅ الفلاتر
                _buildFilters(isDark),
                
                // ✅ قائمة الأدوية
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState(isDark)
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final med = filtered[index];
                              return _buildMedicationCard(med, isDark);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  // ============================================================
  // 📊 الإحصائيات
  // ============================================================
  Widget _buildStatsRow(bool isDark, int total, int taken) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('💊', 'الإجمالي', '$total', Colors.white),
          _buildStatItem('✅', 'متناول', '$taken', Colors.green),
          _buildStatItem('⏰', 'متبقي', '${total - taken}', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value, Color color) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  // ============================================================
  // 🏷️ الفلاتر
  // ============================================================
  Widget _buildFilters(bool isDark) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey[100]),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey[800]! : Colors.grey[300]!),
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[700]),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 💊 بطاقة الدواء - بإيقونات PNG
  // ============================================================
  Widget _buildMedicationCard(Map<String, dynamic> med, bool isDark) {
    final color = Color(med['color'] as int);
    final needsRefill = (med['remaining'] as int) < 5;
    final isTaken = med['taken'] as bool;
    final remaining = med['remaining'] as int;
    final total = med['total'] as int;
    final iconPath = med['icon'] as String;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
        border: isTaken
            ? Border.all(color: Colors.green.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ✅ أيقونة الدواء (PNG)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    iconPath,
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          '💊',
                          style: TextStyle(fontSize: 22),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      med['name'] ?? 'دواء',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          med['time'] ?? '--:--',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          med['dose'] ?? '',
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
              Checkbox(
                value: isTaken,
                activeColor: Colors.green,
                onChanged: (v) => _toggleTaken(med['id'], v!),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: remaining / total,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  color: needsRefill ? Colors.red : Colors.green,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$remaining/$total',
                style: TextStyle(
                  fontSize: 11,
                  color: needsRefill ? Colors.red : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  fontWeight: needsRefill ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          if (needsRefill)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'يحتاج إعادة تعبئة - ${med['refillDate'] ?? 'قريباً'}',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          if (med['notes'] != null && med['notes'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                med['notes'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 📭 حالة فارغة
  // ============================================================
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد أدوية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف دواء جديد للبدء',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addMedication,
            icon: const Icon(Icons.add),
            label: const Text('إضافة دواء'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
