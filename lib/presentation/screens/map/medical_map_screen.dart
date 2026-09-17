import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/theme/app_theme.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class MedicalMapScreen extends StatefulWidget {
  const MedicalMapScreen({super.key});

  @override
  State<MedicalMapScreen> createState() => _MedicalMapScreenState();
}

class _MedicalMapScreenState extends State<MedicalMapScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _facilities = [
    {'name': 'مستشفى النقيب', 'address': 'شارع حدة، أمام الخطوط الجوية', 'phone': '01-222222', 'rating': 4.8},
    {'name': 'مستشفى اليمن الألماني', 'address': 'شارع الستين، منطقة الحصبة', 'phone': '01-333333', 'rating': 4.6},
    {'name': 'مستشفى الثورة العام', 'address': 'شارع الزبيري، باب اليمن', 'phone': '01-444444', 'rating': 4.9},
    {'name': 'صيدلية الشفاء', 'address': 'شارع التحرير، بجانب البنك المركزي', 'phone': '01-555555', 'rating': 4.5},
    {'name': 'مختبر الوطنية', 'address': 'شارع الخمسين، الحصبة', 'phone': '01-666666', 'rating': 4.7},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFacilities {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _facilities;
    return _facilities.where((facility) {
      final text = '${facility['name']} ${facility['address']}'.toLowerCase();
      return text.contains(query);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryColor;
    final bgColor = isDark ? const Color(0xFF0B1121) : AppTheme.backgroundColor;
    final facilities = _filteredFacilities;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: CustomAppBar(
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        elevation: 0.5,
        title: const Text('المرافق الصحية', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
        actions: [IconButton(icon: Icon(Icons.filter_list, color: primaryColor), onPressed: () {})],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
              image: const DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?w=600'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
            child: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.map_rounded, size: 64, color: AppTheme.primaryColor.withOpacity(0.3)),
                const SizedBox(height: 8),
                Text('خريطة صنعاء', style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey[600], fontFamily: 'Tajawal')),
                Text('اضغط للتفاعل مع الخريطة', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey[400], fontFamily: 'Tajawal')),
              ]),
            ),
          ),
          Positioned(
            bottom: 240,
            left: 16,
            child: Column(children: [
              FloatingActionButton(mini: true, backgroundColor: Colors.white, child: const Icon(Icons.my_location, color: AppTheme.primaryColor), onPressed: () {}),
              const SizedBox(height: 8),
              FloatingActionButton(mini: true, backgroundColor: Colors.white, child: const Icon(Icons.add, color: AppTheme.primaryColor), onPressed: () {}),
              const SizedBox(height: 8),
              FloatingActionButton(mini: true, backgroundColor: Colors.white, child: const Icon(Icons.remove, color: AppTheme.primaryColor), onPressed: () {}),
            ]),
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: UnifiedSearchBar(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              onClear: _clearSearch,
              hintText: 'ابحث عن منشأة صحية (مستشفى، مختبر، صيدلية)...',
              isDark: isDark,
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 200,
              child: facilities.isEmpty
                  ? Center(child: Text('لا توجد منشآت مطابقة للبحث', style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontFamily: 'Tajawal')))
                  : PageView.builder(
                      controller: PageController(viewportFraction: 0.88),
                      itemCount: facilities.length,
                      itemBuilder: (context, index) => _buildFacilityCard(facilities[index], isDark),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(Map<String, dynamic> facility, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        border: isDark ? Border.all(color: Colors.grey[800]!, width: 0.5) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.local_hospital_outlined, color: AppTheme.primaryColor, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(facility['name'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppTheme.primaryColor, fontSize: 16, fontFamily: 'Tajawal')),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.star, color: Colors.amber, size: 14), const SizedBox(width: 4), Text('${facility['rating']}', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[500], fontFamily: 'Tajawal')), const SizedBox(width: 8), Expanded(child: Text(facility['address'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[500], fontFamily: 'Tajawal')))]),
          ])),
        ]),
        const Spacer(),
        const Divider(height: 1),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [Icon(Icons.phone_in_talk_outlined, color: AppTheme.primaryColor, size: 16), const SizedBox(width: 6), Text(facility['phone'] as String, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Tajawal'))]),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)), onPressed: () {}, child: const Text('حجز موعد', style: TextStyle(fontFamily: 'Tajawal', color: Colors.white, fontSize: 12))),
        ]),
      ]),
    );
  }
}
