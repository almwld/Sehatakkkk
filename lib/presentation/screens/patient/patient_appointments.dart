import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';

class PatientAppointments extends StatefulWidget {
  const PatientAppointments({super.key});

  @override
  State<PatientAppointments> createState() => _PatientAppointmentsState();
}

class _PatientAppointmentsState extends State<PatientAppointments>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _pastAppointments = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final querySnapshot = await _firestore
          .collection('appointments')
          .where('patientId', isEqualTo: user.uid)
          .orderBy('appointmentDate', descending: false)
          .get();

      final now = DateTime.now();
      List<Map<String, dynamic>> upcoming = [];
      List<Map<String, dynamic>> past = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final appointmentDate = (data['appointmentDate'] as Timestamp).toDate();
        final appointment = {
          'id': doc.id,
          ...data,
          'appointmentDate': appointmentDate,
        };

        if (appointmentDate.isAfter(now) || appointmentDate.isAtSameMomentAs(now)) {
          upcoming.add(appointment);
        } else {
          past.add(appointment);
        }
      }

      setState(() {
        _upcomingAppointments = upcoming;
        _pastAppointments = past;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading appointments: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
      _loadAppointments();
      ToastService.showSuccess(context, 'تم إلغاء الموعد بنجاح');
    } catch (e) {
      print('Error cancelling appointment: $e');
      ToastService.showError(context, 'فشل إلغاء الموعد');
    }
  }

  
}
