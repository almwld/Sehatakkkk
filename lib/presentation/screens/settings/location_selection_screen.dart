import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sehatak/core/constants/app_colors.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({super.key});

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  static const _prefKey = 'delivery_area';
  static const _areas = <String>[
    'صنعاء',
    'عدن',
    'تعز',
    'الحديدة',
    'إب',
    'حضرموت',
    'ذمار',
    'عمران',
    'حجة',
    'المحويت',
    'ريمة',
    'البيضاء',
    'مأرب',
    'شبوة',
    'أبين',
    'لحج',
    'الضالع',
    'صعدة',
    'الجوف',
    'المهرة',
    'سقطرى',
  ];

  String? _selectedArea;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadArea();
  }

  Future<void> _loadArea() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _selectedArea = prefs.getString(_prefKey);
      _loading = false;
    });
  }

  Future<void> _selectArea(String area) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, area);
    if (!mounted) return;
    setState(() => _selectedArea = area);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم تحديد منطقتك: $area')),
    );
  }

  Future<void> _clearArea() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    if (!mounted) return;
    setState(() => _selectedArea = null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إلغاء تحديد المنطقة')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد منطقتك'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  elevation: 0,
                  color: dark ? const Color(0xFF1A2540) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('منطقتك الحالية', style: TextStyle(fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                              const SizedBox(height: 4),
                              Text(
                                _selectedArea ?? 'لم يتم تحديد المنطقة بعد',
                                style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedArea != null)
                          IconButton(
                            tooltip: 'إلغاء التحديد',
                            onPressed: _clearArea,
                            icon: const Icon(Icons.close, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('اختر محافظتك/منطقتك', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
                const SizedBox(height: 8),
                ..._areas.map((area) => Card(
                      elevation: 0,
                      color: dark ? const Color(0xFF1A2540) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: RadioListTile<String>(
                        value: area,
                        groupValue: _selectedArea,
                        activeColor: AppColors.primary,
                        title: Text(area, style: TextStyle(color: dark ? Colors.white : Colors.black87)),
                        onChanged: (value) {
                          if (value != null) _selectArea(value);
                        },
                      ),
                    )),
              ],
            ),
    );
  }
}
