import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/patient/patient_medical_history.dart';
import 'package:sehatak/presentation/screens/patient/patient_prescriptions.dart';
import 'package:sehatak/presentation/screens/patient/patient_appointments.dart';
import 'package:sehatak/presentation/screens/vaccination/vaccination_screen.dart';
import 'package:sehatak/presentation/screens/medical_reports/medical_reports_screen.dart';
import 'package:sehatak/presentation/screens/health/health_dashboard.dart';
import 'package:sehatak/presentation/screens/notifications/notifications_screen.dart';
import 'package:sehatak/presentation/screens/wallet/wallet_screen.dart';
import 'package:sehatak/presentation/screens/emergencies/emergency_numbers.dart';
import 'package:sehatak/presentation/screens/blood_donation/blood_donation_screen.dart';
import 'package:sehatak/presentation/screens/consultation/consultation_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';
import 'package:sehatak/presentation/screens/pharmacy/pharmacy_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';
import 'package:sehatak/presentation/screens/lab/labs_list_screen.dart';
import 'package:sehatak/presentation/screens/medication/medicines_screen.dart';
import 'package:sehatak/presentation/screens/blood_pressure/blood_pressure_screen.dart';
import 'package:sehatak/presentation/screens/glucose_tracker/glucose_tracker_screen.dart';
import 'package:sehatak/presentation/screens/weight_tracker/weight_tracker_screen.dart';
import 'package:sehatak/presentation/screens/sleep_tracker/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// 🎨 CustomPainter للدائرة المتدرجة
// ============================================================
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    this.strokeWidth = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startAngle = -90 * (3.14159 / 180);
    final sweepAngle = 360 * (3.14159 / 180) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PatientDashboard extends StatefulWidget {
  final ScrollController? scrollController;
  const PatientDashboard({super.key, this.scrollController});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  // ============================================================
  // 📊 متغيرات الحالة
  // ============================================================
  String _userName = 'مستخدم';
  String _userEmail = '';
  String _userRole = 'مريض';
  String _userId = '';
  String _userPhone = '';
  String _patientNumber = 'SH-2024-0012';
  String _userAvatar = '';
  String _subscriptionType = 'مجاني';
  String _subscriptionColor = '#6C757D'; // ✅ اللون الرمادي للباقة المجانية
  bool _isLoading = true;
  bool _isSharing = false;
  bool _isOffline = false;
  final ImagePicker _picker = ImagePicker();
  
  Map<String, dynamic> _cachedUserData = {};
  List<Map<String, dynamic>> _cachedVitals = [];
  bool _dataLoaded = false;

  // ============================================================
  // 📦 المؤشرات الحيوية الأصلية
  // ============================================================
  final List<Map<String, dynamic>> _vitals = [
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.red,
      'maxValue': 180,
      'currentValue': 120,
      'screen': const BloodPressureScreen()
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'سكر الدم',
      'value': '98',
      'unit': 'مجم/دل',
      'color': Colors.orange,
      'maxValue': 200,
      'currentValue': 98,
      'screen': const GlucoseTrackerScreen()
    },
    {
      'icon': 'assets/images/tracking/fitness.png',
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
      'maxValue': 100,
      'currentValue': 85,
      'screen': const SleepTrackerScreen()
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
      'maxValue': 120,
      'currentValue': 72,
      'screen': const WeightTrackerScreen()
    },
    {
      'icon': 'assets/images/tracking/nutrition.png',
      'label': 'التغذية',
      'value': 'جيد',
      'unit': '',
      'color': Colors.teal,
      'maxValue': 10,
      'currentValue': 8,
      'screen': const HealthDashboard()
    },
    {
      'icon': 'assets/images/tracking/mental_health.png',
      'label': 'الصحة النفسية',
      'value': 'ممتاز',
      'unit': '',
      'color': Colors.indigo,
      'maxValue': 10,
      'currentValue': 9,
      'screen': const HealthDashboard()
    },
  ];

  final List<Map<String, dynamic>> _services = [
    {'icon': 'assets/images/services/calendar_booking.png', 'label': 'المواعيد', 'color': Colors.green, 'screen': const PatientAppointments()},
    {'icon': 'assets/images/services/medications.png', 'label': 'الأدوية', 'color': Colors.orange, 'screen': const MedicinesScreen()},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'المختبرات', 'color': Colors.purple, 'screen': const LabsListScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'الأطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': 'assets/images/services/pharmacy.png', 'label': 'الصيدلية', 'color': Colors.red, 'screen': const PharmacyScreen()},
    {'icon': 'assets/images/services/health_tips.png', 'label': 'صحتي', 'color': Colors.teal, 'screen': const HealthDashboard()},
    {'icon': 'assets/images/services/medical_records.png', 'label': 'السجلات الطبية', 'color': Colors.blueGrey, 'screen': const PatientMedicalHistory()},
    {'icon': 'assets/images/services/notifications.png', 'label': 'الإشعارات', 'color': Colors.cyan, 'screen': const NotificationsScreen()},
    {'icon': 'assets/images/services/wallet.png', 'label': 'المحفظة', 'color': Colors.brown, 'screen': const WalletScreen()},
    {'icon': 'assets/images/services/emergency.png', 'label': 'طوارئ', 'color': Colors.red, 'screen': const EmergencyNumbers()},
    {'icon': 'assets/images/services/blood_donation.png', 'label': 'تبرع بالدم', 'color': Colors.deepOrange, 'screen': const BloodDonationScreen()},
    {'icon': 'assets/images/services/video_consultation.png', 'label': 'استشارة فيديو', 'color': Colors.indigo, 'screen': const ConsultationScreen()},
    {'icon': 'assets/images/services/ai_assistant.png', 'label': 'المساعد الذكي', 'color': Colors.cyan, 'screen': const AiChatbotScreen()},
    {'icon': 'assets/images/services/packages.png', 'label': 'الباقات', 'color': Colors.amber, 'screen': const SubscriptionsScreen()},
  ];

  // ============================================================
  // 🔄 دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadUserDataInBackground();
  }

  // ============================================================
  // 💾 تحميل البيانات المخزنة محلياً
  // ============================================================
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cachedUserName = prefs.getString('cached_user_name');
      final cachedUserEmail = prefs.getString('cached_user_email');
      final cachedUserRole = prefs.getString('cached_user_role');
      final cachedPatientNumber = prefs.getString('cached_patient_number');
      final cachedSubscriptionType = prefs.getString('cached_subscription_type');
      final cachedUserAvatar = prefs.getString('cached_user_avatar');
      
      if (cachedUserName != null) {
        setState(() {
          _userName = cachedUserName;
          _userEmail = cachedUserEmail ?? '';
          _userRole = cachedUserRole ?? 'مريض';
          _patientNumber = cachedPatientNumber ?? _generatePatientNumber();
          _subscriptionType = cachedSubscriptionType ?? 'مجاني';
          _subscriptionColor = _getSubscriptionColor(_subscriptionType);
          _userAvatar = cachedUserAvatar ?? '';
          _dataLoaded = true;
        });
      }
    } catch (e) {
      print('⚠️ Error loading cached data: $e');
    }
  }

  // ============================================================
  // 💾 حفظ البيانات محلياً
  // ============================================================
  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_name', _userName);
      await prefs.setString('cached_user_email', _userEmail);
      await prefs.setString('cached_user_role', _userRole);
      await prefs.setString('cached_patient_number', _patientNumber);
      await prefs.setString('cached_subscription_type', _subscriptionType);
      await prefs.setString('cached_user_avatar', _userAvatar);
      print('✅ Data saved to cache');
    } catch (e) {
      print('⚠️ Error saving to cache: $e');
    }
  }

  // ============================================================
  // 📥 تحميل البيانات من Firebase (خلفية)
  // ============================================================
  Future<void> _loadUserDataInBackground() async {
    try {
      await Future.delayed(const Duration(seconds: 10));
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      _userId = user.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              setState(() => _isOffline = true);
              throw Exception('Connection timeout');
            },
          );

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _userName = data?['name'] ?? user.displayName ?? 'مستخدم';
          _userEmail = user.email ?? '';
          _userRole = data?['role'] ?? data?['type'] ?? 'مريض';
          _userPhone = data?['phone'] ?? '';
          _userAvatar = data?['avatar'] ?? '';
          _patientNumber = data?['patientNumber'] ?? _generatePatientNumber();
          _subscriptionType = data?['subscriptionType'] ?? 'مجاني';
          _subscriptionColor = _getSubscriptionColor(_subscriptionType);
          _isOffline = false;
          _isLoading = false;
        });
        
        await _saveToCache();
        
        if (doc.data()?['patientNumber'] == null) {
          await _savePatientNumber();
        }
      } else {
        setState(() {
          _userName = user.displayName ?? 'مستخدم';
          _userEmail = user.email ?? '';
          _userRole = 'مريض';
          _isLoading = false;
        });
        await _savePatientNumber();
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // 🆔 توليد رقم المريض
  // ============================================================
  String _generatePatientNumber() {
    final now = DateTime.now();
    final year = now.year;
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8, 12);
    return 'SH-$year-$random';
  }

  // ============================================================
  // 🎨 ألوان الباقة حسب النوع
  // ============================================================
  String _getSubscriptionColor(String type) {
    switch (type.toLowerCase()) {
      case 'ذهبية': case 'gold': 
        return '#FFD700'; // ذهبي
      case 'ماسية': case 'diamond': 
        return '#00BCD4'; // فيروزي
      case 'فضية': case 'silver': 
        return '#9E9E9E'; // فضي
      case 'برونزية': case 'bronze': 
        return '#CD7F32'; // برونزي
      case 'عائلية': case 'family': 
        return '#4CAF50'; // أخضر
      case 'مجاني': case 'free': 
        return '#6C757D'; // ✅ رمادي للباقة المجانية
      default: 
        return '#6C757D'; // رمادي افتراضي
    }
  }

  // ============================================================
  // 💾 حفظ رقم المريض في Firebase
  // ============================================================
  Future<void> _savePatientNumber() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'patientNumber': _patientNumber,
        'name': _userName,
        'email': _userEmail,
        'role': _userRole,
        'phone': _userPhone,
        'subscriptionType': _subscriptionType,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _saveToCache();
      print('✅ Patient number saved: $_patientNumber');
    } catch (e) {
      print('❌ Error saving patient number: $e');
    }
  }

  // ============================================================
  // 📸 رفع الصورة
  // ============================================================
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      
      if (image == null) return;
      
      ToastService.showInfo('⏳ جاري رفع الصورة...');
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      final ref = FirebaseStorage.instance
          .ref()
          .child('users/${user.uid}/avatar.jpg');
      
      await ref.putFile(File(image.path));
      final downloadUrl = await ref.getDownloadURL();
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'avatar': downloadUrl});
      
      setState(() {
        _userAvatar = downloadUrl;
      });
      
      await _saveToCache();
      ToastService.showSuccess('✅ تم رفع الصورة بنجاح');
    } catch (e) {
      ToastService.showError('❌ فشل رفع الصورة: $e');
    }
  }

  // ============================================================
  // 📤 مشاركة الملف الصحي
  // ============================================================
  Future<void> _shareProfile() async {
    setState(() => _isSharing = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      final shareText = '''
🏥 ملفي الصحي - صحتك (Sehatak)

👤 الاسم: $_userName
📧 البريد: $_userEmail
📱 الهاتف: $_userPhone
🆔 رقم المريض: $_patientNumber
👤 الدور: $_userRole
💳 الباقة: $_subscriptionType
📅 تاريخ الانضمام: ${DateTime.now().toLocal().toString().split(' ')[0]}

📊 إحصائيات سريعة:
• ضغط الدم: 120/80 مم زئبق
• سكر الدم: 98 مجم/دل
• الوزن: 72 كجم
• اللياقة: 85%

🩺 الخدمات المتاحة:
✓ المواعيد الطبية
✓ الأدوية والوصفات
✓ المختبرات والتحاليل
✓ الاستشارات الطبية
✓ الصيدلية والتوصيل
✓ السجلات الطبية

🔗 تم إنشاء هذا الملف بواسطة تطبيق صحتك - Sehatak
📱 حمل التطبيق الآن!
''';

      await Share.share(shareText, subject: 'ملفي الصحي - صحتك');
      ToastService.showSuccess('✅ تم مشاركة الملف الصحي بنجاح');
    } catch (e) {
      ToastService.showError('❌ فشل مشاركة الملف: $e');
    }
    setState(() => _isSharing = false);
  }

  // ============================================================
  // 📱 عرض الباركود
  // ============================================================
  void _showQRCode() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📱 ملفي الصحي', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildQRCode(),
              ),
              const SizedBox(height: 12),
              Text('رقم المريض: $_patientNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              Text('$_userName • $_userRole', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => ToastService.showSuccess('✅ تم حفظ الباركود'),
                      icon: const Icon(Icons.download),
                      label: const Text('تحميل'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 بناء الباركود
  // ============================================================
  Widget _buildQRCode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 120, color: AppColors.primary),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _patientNumber,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏷️ عنوان لوحة المستخدم
  // ============================================================
  String _getDashboardTitle() {
    return 'لوحة المستخدم';
  }

  // ============================================================
  // 🖼️ عرض الأيقونة
  // ============================================================
  Widget _buildIcon(String path, {double size = 40, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.circle, color: color ?? AppColors.primary, size: size);
      },
    );
  }

  // ============================================================
  // 🏗️ بناء الواجهة الرئيسية
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_getDashboardTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isOffline)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('📶 غير متصل', style: TextStyle(fontSize: 9, color: Colors.orange)),
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _userRole,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),
            ),
          ),
          IconButton(
            icon: _isSharing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Icon(Icons.share),
            onPressed: _isSharing ? null : _shareProfile,
            tooltip: 'مشاركة الملف الصحي',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: _showQRCode,
            tooltip: 'عرض الباركود',
          ),
        ],
      ),
      body: _isLoading && !_dataLoaded
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPatientCard(isDark),
                  const SizedBox(height: 16),
                  _buildActiveSubscriptionCard(isDark),
                  const SizedBox(height: 16),
                  const Text('المؤشرات الحيوية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildVitalsGrid(isDark),
                  const SizedBox(height: 16),
                  const Text('وصول سريع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildQuickAccess(isDark),
                  const SizedBox(height: 16),
                  const Text('الخدمات الطبية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildServicesList(isDark),
                  const SizedBox(height: 16),
                  const Text('الأمراض المزمنة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildChronicConditions(isDark),
                  const SizedBox(height: 16),
                  const Text('التطعيمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildVaccinations(isDark),
                  const SizedBox(height: 16),
                  const Text('الحساسية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildAllergies(isDark),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 🏥 بطاقة المريض
  // ============================================================
  Widget _buildPatientCard(bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientProfile()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    backgroundImage: _userAvatar.isNotEmpty
                        ? NetworkImage(_userAvatar)
                        : null,
                    child: _userAvatar.isEmpty
                        ? Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'م',
                            style: const TextStyle(fontSize: 30, color: Colors.white),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _userName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _userEmail,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'رقم المريض: $_patientNumber',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const Text(
              'العمر: 29 سنة • فصيلة الدم: O+',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVitalStat('assets/images/tracking/blood_pressure.png', 'الدم', 'O+'),
                _buildVitalStat('assets/images/tracking/weight_tracking.png', 'الوزن', '72 كجم'),
                _buildVitalStat('assets/images/tracking/fitness.png', 'الطول', '175 سم'),
                _buildVitalStat('assets/images/tracking/blood_pressure.png', 'الضغط', 'طبيعي'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📊 إحصائية حيوية صغيرة
  // ============================================================
  Widget _buildVitalStat(String iconPath, String label, String value) {
    return Column(
      children: [
        _buildIcon(iconPath, size: 28, color: Colors.white),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }

  // ============================================================
  // 💳 الباقة النشطة - ألوان حسب النوع مع اللون الرمادي للمجانية
  // ============================================================
  Widget _buildActiveSubscriptionCard(bool isDark) {
    // ✅ ألوان الباقات حسب النوع
    final Map<String, Color> subscriptionColors = {
      'ذهبية': Colors.amber,
      'ماسية': Colors.cyan,
      'فضية': Colors.grey,
      'برونزية': Colors.brown,
      'عائلية': Colors.green,
      'مجاني': Colors.purple, // ✅ رمادي للباقة المجانية
    };

    final Map<String, String> subscriptionIcons = {
      'ذهبية': '⭐',
      'ماسية': '💎',
      'فضية': '🥈',
      'برونزية': '🥉',
      'عائلية': '👨‍👩‍👧‍👦',
      'مجاني': '🆓', // ✅ أيقونة مجانية
    };

    final Color subscriptionColor = subscriptionColors[_subscriptionType] ?? Colors.grey;
    final String subscriptionIcon = subscriptionIcons[_subscriptionType] ?? '🆓';
    final String subscriptionStatus = _subscriptionType == 'مجاني' ? 'مجانية' : 'مفعّلة';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SubscriptionsScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [subscriptionColor, subscriptionColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: subscriptionColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  subscriptionIcon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الباقة النشطة',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'الباقة $_subscriptionType',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'مميزات حصرية',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          subscriptionStatus,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📊 المؤشرات الحيوية - المؤشرات الأصلية مع رسم بياني دائري
  // ============================================================
  Widget _buildVitalsGrid(bool isDark) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        final color = vital['color'] as Color;
        final maxValue = vital['maxValue'] as double;
        final currentValue = vital['currentValue'] as double;
        final percentage = (currentValue / maxValue).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => vital['screen'] as Widget));
          },
          child: Container(
            padding: const EdgeInsets.all(10),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CustomPaint(
                        painter: CircularProgressPainter(
                          progress: percentage,
                          backgroundColor: color.withOpacity(0.15),
                          progressColor: color,
                          strokeWidth: 6,
                        ),
                        child: const SizedBox(width: 60, height: 60),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildIcon(vital['icon'] as String, size: 20, color: color),
                        const SizedBox(height: 2),
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  vital['value'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  vital['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ⚡ وصول سريع
  // ============================================================
  Widget _buildQuickAccess(bool isDark) {
    final quickServices = [
      {'icon': 'assets/images/services/calendar_booking.png', 'label': 'المواعيد', 'screen': const PatientAppointments()},
      {'icon': 'assets/images/services/medical_records.png', 'label': 'السجلات', 'screen': const PatientMedicalHistory()},
      {'icon': 'assets/images/services/medications.png', 'label': 'الوصفات', 'screen': const PatientPrescriptions()},
      {'icon': 'assets/images/services/laboratory.png', 'label': 'التحاليل', 'screen': const PatientMedicalHistory()},
      {'icon': 'assets/images/services/health_tips.png', 'label': 'التطعيمات', 'screen': const VaccinationScreen()},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: quickServices.map((service) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => service['screen'] as Widget));
          },
          child: Column(
            children: [
              _buildIcon(service['icon'] as String, size: 56, color: AppColors.primary),
              const SizedBox(height: 4),
              Text(
                service['label'] as String,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 📋 قائمة الخدمات
  // ============================================================
  Widget _buildServicesList(bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        final color = service['color'] as Color;
        return GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => service['screen'] as Widget));
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildIcon(service['icon'] as String, size: 36, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        'اضغط للانتقال',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_left,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🩺 الأمراض المزمنة
  // ============================================================
  Widget _buildChronicConditions(bool isDark) {
    final conditions = [
      {'name': 'ارتفاع ضغط الدم', 'diagnosed': '15 مارس 2023', 'status': 'تحت السيطرة', 'color': AppColors.error, 'icon': Icons.favorite_border},
      {'name': 'الربو', 'diagnosed': '10 يناير 2021', 'status': 'خفيف', 'color': AppColors.warning, 'icon': Icons.air},
      {'name': 'التهاب المعدة', 'diagnosed': '5 أغسطس 2019', 'status': 'تم الشفاء', 'color': AppColors.info, 'icon': Icons.restaurant},
    ];

    return Column(
      children: conditions.map((condition) {
        final color = condition['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A2540) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Icon(condition['icon'] as IconData, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      condition['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'تم التشخيص: ${condition['diagnosed']}',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  condition['status'] as String,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  // 💉 التطعيمات
  // ============================================================
  Widget _buildVaccinations(bool isDark) {
    final vaccines = [
      {'name': 'كوفيد-19', 'info': 'فايزر • جرعتين', 'date': 'آخر: يناير 2025', 'done': true},
      {'name': 'الإنفلونزا', 'info': 'سنوي', 'date': 'آخر: أكتوبر 2025', 'done': true},
      {'name': 'التهاب الكبد ب', 'info': '3 جرعات', 'date': 'مكتمل: 2019', 'done': true},
      {'name': 'الكزاز', 'info': 'كل 10 سنوات', 'date': 'القادم: 2028', 'done': false},
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        children: vaccines.map((vaccine) {
          final done = vaccine['done'] as bool;
          return Column(
            children: [
              if (vaccines.indexOf(vaccine) > 0) const Divider(),
              Row(
                children: [
                  _buildIcon(
                    done ? 'assets/images/services/health_tips.png' : 'assets/images/services/emergency.png',
                    size: 36,
                    color: done ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vaccine['name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
                        ),
                        Text(
                          '${vaccine['info']} • ${vaccine['date']}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // 🤧 الحساسية
  // ============================================================
  Widget _buildAllergies(bool isDark) {
    final allergies = [
      {'icon': 'assets/images/services/emergency.png', 'name': 'فول سوداني', 'color': AppColors.error},
      {'icon': 'assets/images/services/medications.png', 'name': 'بنسلين', 'color': AppColors.warning},
      {'icon': 'assets/images/services/health_tips.png', 'name': 'حبوب لقاح', 'color': AppColors.info},
      {'icon': 'assets/images/services/medical_records.png', 'name': 'وبر القطط', 'color': AppColors.purple},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: allergies.map((allergy) {
        final color = allergy['color'] as Color;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(allergy['icon'] as String, size: 24, color: color),
              const SizedBox(width: 4),
              Text(
                allergy['name'] as String,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
