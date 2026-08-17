import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/utils/image_utils.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen> {
  List<Map<String, dynamic>> _medicines = [];
  bool _isLoading = true;
  String _selectedCategory = 'الكل';
  
  final List<String> _categories = ['الكل', 'مسكنات', 'مضادات حيوية', 'فيتامينات', 'أجهزة طبية', 'مضادات التهابية'];

  // ✅ البيانات التجريبية (موجودة مسبقاً)
  final List<Map<String, dynamic>> _mockMedicines = [
    {'id': '1', 'name': 'باراسيتامول 500mg', 'category': 'مسكنات', 'price': 500.0, 'image': ImageService.medicine1, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 50, 'unit': 'قرص', 'rating': 4.8},
    {'id': '2', 'name': 'فيتامين د 1000IU', 'category': 'فيتامينات', 'price': 1200.0, 'image': ImageService.medicine2, 'pharmacyName': 'عالم الصيدلة', 'stock': 30, 'unit': 'كبسولة', 'rating': 4.7},
    {'id': '3', 'name': 'جهاز قياس ضغط', 'category': 'أجهزة طبية', 'price': 8500.0, 'image': ImageService.medicine3, 'pharmacyName': 'صيدلية النهضة', 'stock': 10, 'unit': 'جهاز', 'rating': 4.9},
    {'id': '4', 'name': 'أموكسيسيلين 500mg', 'category': 'مضادات حيوية', 'price': 1500.0, 'image': ImageService.medicine4, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 20, 'unit': 'كبسولة', 'rating': 4.5},
    {'id': '5', 'name': 'ديكلوفيناك 50mg', 'category': 'مسكنات', 'price': 650.0, 'image': ImageService.medicine1, 'pharmacyName': 'صيدلية النهضة', 'stock': 40, 'unit': 'قرص', 'rating': 4.6},
    {'id': '6', 'name': 'نابروكسين 250mg', 'category': 'مضادات التهابية', 'price': 550.0, 'image': ImageService.medicine2, 'pharmacyName': 'عالم الصيدلة', 'stock': 35, 'unit': 'قرص', 'rating': 4.4},
    {'id': '7', 'name': 'أسبرين 100mg', 'category': 'مسكنات', 'price': 300.0, 'image': ImageService.medicine3, 'pharmacyName': 'صيدلية ابن حيان', 'stock': 60, 'unit': 'قرص', 'rating': 4.3},
    {'id': '8', 'name': 'إيبوبروفين 400mg', 'category': 'مضادات التهابية', 'price': 750.0, 'image': ImageService.medicine4, 'pharmacyName': 'صيدلية النهضة', 'stock': 25, 'unit': 'قرص', 'rating': 4.7},
  ];

  @override
  void initState() {
    super.initState();
    _loadMedicines();
  }

  Future<void> _loadMedicines() async {
    setState(() => _isLoading = true);
    try {
      // ✅ محاولة جلب من Firebase
      final snapshot = await FirebaseFirestore.instance
          .collection('medicines')
          .limit(20)
          .get();
      
      if (snapshot.docs.isNotEmpty) {
        _medicines = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? '',
            'category': data['category'] ?? '',
            'price': data['price']?.toDouble() ?? 0.0,
            'image': data['image'] ?? ImageService.medicine1,
            'pharmacyName': data['pharmacyName'] ?? '',
            'stock': data['stock'] ?? 0,
            'unit': data['unit'] ?? '',
            'rating': data['rating']?.toDouble() ?? 0.0,
          };
        }).toList();
      } else {
        // ✅ استخدام البيانات التجريبية
        _medicines = _mockMedicines;
      }
    } catch (e) {
      // ✅ في حالة الخطأ، استخدام البيانات التجريبية
      _medicines = _mockMedicines;
    }
    setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filteredMedicines {
    if (_selectedCategory == 'الكل') return _medicines;
    return _medicines.where((m) => m['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الصيدلية'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط التصنيفات
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
                    selectedColor: primaryColor.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isSelected ? primaryColor : (isDark ? Colors.white : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          // ✅ قائمة الأدوية
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMedicines.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medication, size: 64, color: isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'لا توجد أدوية',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredMedicines.length,
                        itemBuilder: (context, index) {
                          final medicine = _filteredMedicines[index];
                          return _buildMedicineCard(medicine, isDark);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Map<String, dynamic> medicine, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ صورة الدواء
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              medicine['image'] as String,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: Colors.grey.shade200,
                child: const Icon(Icons.medication, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ✅ معلومات الدواء
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        medicine['category'] as String,
                        style: TextStyle(fontSize: 10, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '${medicine['rating'] ?? 0}',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white : Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      medicine['pharmacyName'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${medicine['price']} ر.ي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
