import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/insurance/insurance_companies.dart';

/// Backward-compatible route for the legacy insurance screen.
class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) => const InsuranceCompanies();
}
