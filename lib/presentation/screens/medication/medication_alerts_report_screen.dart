import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class MedicationAlertsReportScreen extends StatefulWidget {
  const MedicationAlertsReportScreen({super.key});
  @override State<MedicationAlertsReportScreen> createState() => _MedicationAlertsReportScreenState();
}

class _MedicationAlertsReportScreenState extends State<MedicationAlertsReportScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);

  String _localizedAlertField(Map<String, dynamic> item, String field, {String fallback = ''}) {
    final raw = item[field]?.toString() ?? '';
    return localizedField(item, field, AppStrings.of(context).locale, fallback: fallback.isEmpty ? _t(raw) : fallback).trim();
  }

  List<Map<String, dynamic>> _items = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance(); final raw = prefs.getString('medication_alerts_report');
    if (raw == null) return;
    try { final decoded = jsonDecode(raw); if (decoded is List && mounted) setState(() => _items = decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()); } catch (_) {}
  }
  Future<void> _clear() async { final prefs = await SharedPreferences.getInstance(); await prefs.remove('medication_alerts_report'); if (mounted) setState(() => _items = []); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('تقرير التنبيهات')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              onPressed: _clear,
              icon: SvgPicture.asset(AppAssets.deleteIcon, width: 22, height: 22,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
            ),
        ],
      ),
      body: _items.isEmpty
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              SvgPicture.asset(AppAssets.notificationBellIcon, width: 64, height: 64,
                colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
              const SizedBox(height: 12),
              Text(_t('لا توجد تنبيهات محفوظة بعد')),
            ]))
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
                final name = _localizedAlertField(item, 'name', fallback: _t('دواء'));
                final dose = _localizedAlertField(item, 'dose');
                final time = _localizedAlertField(item, 'time');
                final details = [dose, time].where((value) => value.isNotEmpty).join(' • ');
                return Card(child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(.1),
                    child: SvgPicture.asset(AppAssets.medicineIcon, width: 25, height: 25,
                      colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn)),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(details),
                  trailing: SvgPicture.asset(AppAssets.notificationBellIcon, width: 22, height: 22,
                    colorFilter: ColorFilter.mode(item['enabled'] == false ? Colors.grey : AppColors.primary, BlendMode.srcIn)),
                ));
              },
            ),
    );
  }
}