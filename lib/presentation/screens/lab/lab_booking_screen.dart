import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/lab/lab_booking_model.dart';
import 'package:sehatak/core/models/lab/sample_collection_method.dart';
import 'package:sehatak/core/services/lab_service.dart';

class LabBookingScreen extends StatefulWidget {
  final String? consultationId;
  final String? labId;
  final String? testId;

  const LabBookingScreen({
    super.key,
    this.consultationId,
    this.labId,
    this.testId,
  });

  @override
  State<LabBookingScreen> createState() => _LabBookingScreenState();
}

// ... باقي الكود كما هو
