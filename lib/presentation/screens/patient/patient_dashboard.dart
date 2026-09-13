import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/nextcloud_service.dart';
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
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDashboard extends StatefulWidget {
  final ScrollController? scrollController;

  const PatientDashboard({super.key, this.scrollController});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  String _userName = 'مريض';
  String _userEmail = '';
  String _userRole = 'مريض';
  String _userId = '';
  String _userPhone = '';
  String _patientNumber = 'SH-2024-0012';
  String _userAvatar = '';
  String _subscriptionType = 'مجانية';
  String _bloodType = 'O+';
  bool _isLoading = true;
  bool _isSharing = false;
  bool _isOffline = false;
  final ImagePicker _picker = ImagePicker();
  final NextcloudService _nextcloudService = NextcloudService();
  
  Map<String, dynamic> _cachedUserData = {};
  List<Map<String, dynamic>> _cachedVitals = [];
  bool _dataLoaded = false;

  final List<Map<String, dynamic>> _vitals = [
    {
      'icon': 'assets/images/tracking/blood_pressure.png',
      'label': 'ضغط الدم',
      'value': '120/80',
      'unit': 'مم زئبق',
      'color': Colors.red,
      'screen': const BloodPressureScreen(),
    },
    {
      'icon': 'assets/images/tracking/blood_sugar.png',
      'label': 'سكر الدم',
      'value': '98',
      'unit': 'مجم/دل',
      'color': Colors.orange,
      'screen': const GlucoseTrackerScreen(),
    },
    {
      'icon': 'assets/images/tracking/fitness.png',
      'label': 'اللياقة',
      'value': '85',
      'unit': '%',
      'color': Colors.green,
      'screen': const HealthDashboard(),
    },
    {
      'icon': 'assets/images/tracking/weight_tracking.png',
      'label': 'الوزن',
      'value': '72',
      'unit': 'كجم',
      'color': Colors.purple,
      'screen': const WeightTrackerScreen(),
    },
    {
      'icon': 'assets/images/tracking/nutrition.png',
      'label': 'التغذية',
      'value': 'جيد',
      'unit': '',
      'color': Colors.teal,
      'screen': const HealthDashboard(),
    },
    {
      'icon': 'assets/images/tracking/mental_health.png',
      'label': 'الصحة النفسية',
      'value': 'ممتاز',
      'unit': '',
      'color': Colors.indigo,
      'screen': const HealthDashboard(),
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

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadUserDataInBackground();
  }

  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserName = prefs.getString('cached_user_name');
      final cachedUserEmail = prefs.getString('cached_user_email');
      final cachedUserRole = prefs.getString('cached_user_role');
      final cachedPatientNumber = prefs.getString('cached_patient_number');
      final cachedSubscriptionType = prefs.getString('cached_subscription_type');
      final cachedUserAvatar = prefs.getString('cached_user_avatar');
      final cachedUserPhone = prefs.getString('cached_user_phone');
      final cachedBloodType = prefs.getString('cached_blood_type');
      if (cachedUserName != null) {
        setState(() {
          _userName = cachedUserName;
          _userEmail = cachedUserEmail ?? '';
          _userRole = cachedUserRole ?? 'مريض';
          _patientNumber = cachedPatientNumber ?? _generatePatientNumber();
          _subscriptionType = cachedSubscriptionType ?? 'مجانية';
          _userAvatar = cachedUserAvatar ?? '';
          _userPhone = cachedUserPhone ?? '';
          final cached = (cachedBloodType ?? 'O+').trim();
          _bloodType = cached.isEmpty ? 'O+' : cached;
          _dataLoaded = true;
        });
      }
    } catch (e) {
      print('⚠️ Error loading cached data: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_user_name', _userName);
      await prefs.setString('cached_user_email', _userEmail);
      await prefs.setString('cached_user_role', _userRole);
      await prefs.setString('cached_patient_number', _patientNumber);
      await prefs.setString('cached_subscription_type', _subscriptionType);
      await prefs.setString('cached_user_avatar', _userAvatar);
      await prefs.setString('cached_user_phone', _userPhone);
      await prefs.setString('cached_blood_type', _bloodType);
      print('✅ Data saved to cache');
    } catch (e) {
      print('⚠️ Error saving to cache: $e');
    }
  }

  Future<void> _loadUserDataInBackground() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
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
          _userName = data?['name'] ?? user.displayName ?? 'مريض';
          _userEmail = user.email ?? '';
          _userRole = data?['role'] ?? data?['type'] ?? 'مريض';
          _userPhone = data?['phone'] ?? '';
          _userAvatar = _firstNonEmpty([
            data?['avatar'],
            data?['photoUrl'],
            user.photoURL,
          ]);
          _patientNumber = data?['patientNumber'] ?? _generatePatientNumber();
          _subscriptionType = data?['subscriptionType'] ?? data?['subscription'] ?? 'مجانية';
          final savedBloodType = (data?['bloodType'] ?? '').toString().trim();
          _bloodType = savedBloodType.isEmpty ? 'O+' : savedBloodType;
          _isOffline = false;
          _isLoading = false;
        });
        await _saveToCache();
        if (doc.data()?['patientNumber'] == null) await _savePatientNumber();
      } else {
        setState(() {
          _userName = user.displayName ?? 'مريض';
          _userEmail = user.email ?? '';
          _userRole = 'مريض';
          _userAvatar = user.photoURL ?? '';
          _subscriptionType = 'مجانية';
          _bloodType = 'O+';
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

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _generatePatientNumber() {
    final now = DateTime.now();
    final year = now.year;
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(8, 12);
    return 'SH-$year-$random';
  }

  Future<void> _savePatientNumber() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
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

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(
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

      await _nextcloudService.loadConfig();
      final result = await _nextcloudService.uploadFile(
        file: File(image.path),
        path: 'profiles/${user.uid}',
        fileName: 'avatar.jpg',
        createShare: true,
      );
      if (!result.success) {
        ToastService.showError('❌ فشل رفع الصورة: ${result.error ?? 'خطأ غير معروف'}');
        return;
      }
      final avatarUrl = (result.url ?? '').trim();
      if (avatarUrl.isEmpty) {
        ToastService.showError('❌ تم رفع الصورة لكن رابط العرض غير متاح');
        return;
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'avatar': avatarUrl,
        'photoUrl': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      setState(() => _userAvatar = avatarUrl);
      await _saveToCache();
      ToastService.showSuccess('✅ تم رفع الصورة وحفظها بنجاح');
    } catch (e) {
      ToastService.showError('❌ فشل رفع الصورة: $e');
    }
  }

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
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQRCode() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code, size: 120, color: AppColors.primary),
          const SizedBox(height: 8),