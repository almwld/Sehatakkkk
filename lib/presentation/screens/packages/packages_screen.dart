import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/subscriptions/subscriptions_screen.dart';

/// Compatibility entry point for the legacy "الباقات" route.
/// The actual plans, billing period and payment flow live in SubscriptionsScreen.
class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) => const SubscriptionsScreen();
}
