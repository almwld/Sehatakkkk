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
import 'package:sehatak/presentation/screens/step_tracker/step_tracker_screen.dart';
import 'package:sehatak/presentation/screens/sleep/sleep_tracker_screen.dart';
import 'package:sehatak/presentation/screens/heart_rate/heart_rate_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/dashboard/role_based_dashboard_screen.dart';
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

  final List<Map<String, dynamic>> _trackingVitals = [
    {'icon': 'assets/icons/health/step_tracking.png', 'label': 'الخطوات', 'value': 'تتبع', 'unit': 'خطوة', 'color': const Color(0xFF0A8F83), 'screen': const StepTrackerScreen()},
    {'icon': 'assets/icons/health/sleep/sleep_tracking.png', 'label': 'النوم', 'value': 'تتبع', 'unit': 'ساعة', 'color': const Color(0xFF18A9A0), 'screen': const SleepTrackerScreen()},
    {'icon': 'assets/icons/health/heart_rate.png', 'label': 'النبض', 'value': 'قياس', 'unit': 'BPM', 'color': const Color(0xFF147D78), 'screen': const HeartRateScreen()},
  ];

  final List<Map<String, dynamic>> _services = [
    {'icon': 'assets/images/services/calendar_booking.png', 'label': 'المواعيد', 'color': Colors.green, 'screen': const PatientAppointments()},
    {'icon': 'assets/images/services/medications.png', 'label': 'الأدوية', 'color': Colors.orange, 'screen': const MedicinesScreen()},
    {'icon': 'assets/images/services/laboratory.png', 'label': 'المختبرات', 'color': Colors.purple, 'screen': const LabsListScreen()},
    {'icon': 'assets/images/services/consultation.png', 'label': 'الأطباء', 'color': AppColors.primary, 'screen': const DoctorsListScreen()},
    {'icon': 'assets/images/services/medications.png', 'label': 'الصيدلية', 'color': Colors.red, 'screen': const PharmacyScreen()},
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
          _userAvatar = data?['avatar'] ?? '';
          _patientNumber = data?['patientNumber'] ?? _generatePatientNumber();
          _subscriptionType = data?['subscriptionType'] ?? data?['subscription'] ?? 'مجانية';
          final savedBloodType = (data?['bloodType'] ?? '').toString().trim();
          _bloodType = savedBloodType.isEmpty ? 'O+' : savedBloodType;
          _isOffline = false;
          _isLoading = false;
        });
        
        await _saveToCache();
        
        if (doc.data()?['patientNumber'] == null) {
          await _savePatientNumber();
        }
      } else {
        setState(() {
          _userName = user.displayName ?? 'مريض';
          _userEmail = user.email ?? '';
          _userRole = 'مريض';
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

  void _openAccountManagement() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RoleBasedDashboardScreen(),
      ),
    );
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
🩸 فصيلة الدم: $_bloodType
🔢 رقم المريض: $_patientNumber
''';
      await Share.share(shareText, subject: 'ملفي الصحي - صحتك');
    } catch (e) {
      ToastService.showError('❌ فشل مشاركة الملف: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رمز QR للملف الصحي'),
        content: SizedBox(
          width: 200,
          height: 200,
          child: CustomPaint(
            painter: QRCodePainter(_patientNumber),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفي الصحي'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isOffline)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined),
            onPressed: _openAccountManagement,
            tooltip: 'إدارة الحساب',
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
                  const Text(
                    'المؤشرات الحيوية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildVitalsGrid(isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'وصول سريع',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildQuickAccess(isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'الخدمات الطبية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildServicesList(isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'الأمراض المزمنة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildChronicConditions(isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'التطعيمات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildVaccinations(isDark),
                  const SizedBox(height: 16),
                  const Text(
                    'الحساسية',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildAllergies(isDark),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildPatientCard(bool isDark) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PatientProfile()),
        );
        if (mounted) {
          _loadUserDataInBackground();
        }
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
            Text(
              'العمر: 29 سنة • فصيلة الدم: $_bloodType',
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildVitalStat('assets/images/services/blood_donation.png', 'الدم', _bloodType),
                _buildVitalStat('assets/images/services/health_tips.png', 'المؤشرات', 'موحدة'),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildActiveSubscriptionCard(bool isDark) {
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
          gradient: const LinearGradient(
            colors: [AppColors.primary, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _buildIcon('assets/images/services/packages.png', size: 34, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'الباقة النشطة',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const Text(
                    'الباقة المجانية',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.amber, size: 14),
                      const SizedBox(width: 4),
                      const Text(
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
                        child: const Text(
                          'مجانية',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w500),
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

  Widget _buildVitalsGrid(bool isDark) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('health_metrics').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final d = snapshot.data?.data() ?? const <String, dynamic>{};
        final values = <String, String>{
          'ضغط الدم': d['systolic'] != null && d['diastolic'] != null ? '${d['systolic']}/${d['diastolic']}' : 'غير متوفر',
          'سكر الدم': d['blood_sugar'] != null ? '${d['blood_sugar']}' : 'غير متوفر',
          'اللياقة': d['steps'] != null ? '${d['steps']}' : 'غير متوفر',
          'الوزن': d['weight'] != null ? '${d['weight']}' : 'غير متوفر',
          'التغذية': 'غير متوفر',
          'الصحة النفسية': 'غير متوفر',
          'الخطوات': d['steps'] != null ? '${d['steps']}' : 'تتبع',
          'النوم': d['sleep'] != null ? '${d['sleep']}' : 'تتبع',
          'النبض': d['heartRate'] != null ? '${d['heartRate']}' : 'قياس',
        };
        final all=[..._vitals,..._trackingVitals];
        return GridView.builder(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.9),itemCount:all.length,itemBuilder:(context,index){
          final vital=all[index];final label=vital['label'] as String;final value=values[label]??vital['value'] as String;final color=vital['color'] as Color;
          return GestureDetector(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>vital['screen'] as Widget)),child:Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:isDark?const Color(0xFF1A2540):Colors.white,borderRadius:BorderRadius.circular(14)),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
            _buildIcon(vital['icon'] as String,size:42,color:color),const SizedBox(height:6),Text(value,style:TextStyle(fontSize:14,fontWeight:FontWeight.bold,color:isDark?Colors.white:Colors.black87),maxLines:1,overflow:TextOverflow.ellipsis),Text(label,style:TextStyle(fontSize:10,color:isDark?Colors.grey[400]:Colors.grey[600]),maxLines:1,overflow:TextOverflow.ellipsis)
          ])));
        });
      },
    );
  }
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

  Widget _buildServicesList(bool isDark) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _services.length,
        itemBuilder: (context, index) {
          final service = _services[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => service['screen'] as Widget));
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A2540) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(service['icon'] as String, size: 36, color: service['color'] as Color),
                  const SizedBox(height: 6),
                  Text(
                    service['label'] as String,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChronicConditions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          _buildConditionRow('السكري', 'لا يوجد', Icons.check_circle, Colors.green),
          _buildConditionRow('ضغط الدم', 'طبيعي', Icons.check_circle, Colors.green),
          _buildConditionRow('الكوليسترول', 'طبيعي', Icons.check_circle, Colors.green),
          _buildConditionRow('الربو', 'لا يوجد', Icons.check_circle, Colors.green),
        ],
      ),
    );
  }

  Widget _buildConditionRow(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Text(value, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildVaccinations(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildIcon('assets/images/services/blood_donation.png', size: 40, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('جميع التطعيمات محدثة', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergies(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildIcon('assets/images/tracking/mental_health.png', size: 40, color: AppColors.primary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text('لا توجد حساسية مسجلة', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(String path, {double size = 40, Color? color}) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.health_and_safety, color: color, size: size);
      },
    );
  }
}

class QRCodePainter extends CustomPainter {
  final String data;

  QRCodePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final moduleSize = size.width / 21;
    for (int i = 0; i < 21; i++) {
      for (int j = 0; j < 21; j++) {
        if ((i + j + data.length) % 3 == 0 || (i * j) % 5 == 0) {
          canvas.drawRect(
            Rect.fromLTWH(i * moduleSize, j * moduleSize, moduleSize, moduleSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QRCodePainter oldDelegate) => oldDelegate.data != data;
}
