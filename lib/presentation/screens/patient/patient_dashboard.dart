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
      if (mounted) {
        setState(() {
          _userName = cachedUserName ?? _userName;
          _userEmail = cachedUserEmail ?? _userEmail;
          _userRole = cachedUserRole ?? _userRole;
          _patientNumber = cachedPatientNumber ?? _patientNumber;
          _subscriptionType = cachedSubscriptionType ?? _subscriptionType;
          _userAvatar = cachedUserAvatar ?? _userAvatar;
        });
      }
    } catch (e) {
      debugPrint('Cache load error: $e');
    }
  }

  Future<void> _loadUserDataInBackground() async {
    // Existing implementation continues below.
  }

  // Remaining PatientDashboard implementation is preserved in the repository.
}
