import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatak/app_router.dart';
import 'package:sehatak/core/models/dental/dental_models.dart';
import 'package:sehatak/core/services/dental_service.dart';
class DentalDoctorsScreen extends StatelessWidget { const DentalDoctorsScreen({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('أطباء الأسنان')),body: StreamBuilder<List<DentalDoctor>>(stream: DentalService().streamDoctors(),builder:(context,s){if(!s.hasData)return const Center(child:CircularProgressIndicator());final data=s.data!;return ListView.builder(itemCount:data.length,itemBuilder:(_,i){final d=data[i];return Card(child:ListTile(onTap:()=>context.push(AppRouter.dentalDoctorDetail.replaceFirst(':id',d.id)),title:Text(d.name),subtitle:Text('${d.specialty} • ${d.experienceYears} سنوات خبرة'),trailing:Text('★${d.rating.toStringAsFixed(1)}')));});}));} }
