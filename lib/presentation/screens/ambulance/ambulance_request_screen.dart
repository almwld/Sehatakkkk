import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/paramedic/paramedic_field_screen.dart';

class AmbulanceRequestScreen extends StatelessWidget {
  const AmbulanceRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParamedicFieldScreen(publicMode: true);
  }
}
