import '../../core/models/doctor_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/hospital/hospital_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _favorites = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'أطباء', 'مستشفيات', 'صيدليات', 'مختبرات'];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        setState(() {
          _favorites = [];
          _isLoading = false;
        });
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      setState(() {
        _favorites = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('⚠️ Error loading favorites: $e');
      setState(() => _isLoading = false);
      ToastService.showError('❌ فشل تحميل المفضلة');
    }
  }

  Future<void> _removeFavorite(String id) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(id)
          .delete();

      setState(() {
        _favorites.removeWhere((item) => item['id'] == id);
      });
      ToastService.showSuccess('✅ تم إزالة من المفضلة');
    } catch (e) {
      ToastService.showError('❌ فشل إزالة من المفضلة');
    }
  }

  List<Map<String, dynamic>> get _filteredFavorites {
    if (_selectedFilter == 'الكل') return _favorites;
    return _favorites.where((item) => item['type'] == _selectedFilter).toList();
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    if (item['type'] == 'أطباء') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorDetailsScreen(
            doctor: DoctorModel(id: item['doctorId'] ?? item['id'], name: item['name'] ?? "", specialty: item['specialty'] ?? "")['doctorId'] ?? item['id'],
          ),
        ),
      );
    } else if (item['type'] == 'مستشفيات') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HospitalDetailsScreen(
            hospitalId: item['hospitalId'] ?? item['id'],
            hospitalData: {},
          ),
        ),
      );
    } else {
      ToastService.showInfo('📋 عرض تفاصيل ${item['name']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'المفضلة ⭐ (${_favorites.length})',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showClearDialog(),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState(isDark)
              : Column(
                  children: [
                    // ✅ الفلاتر
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = _selectedFilter == filter;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedFilter = filter),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isDark
                                          ? const Color(0xFF1A2540)
                                          : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isDark
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade700,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // ✅ قائمة المفضلة
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredFavorites.length,
                        itemBuilder: (context, index) {
                          final item = _filteredFavorites[index];
                          return _buildFavoriteCard(item, isDark);
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/ui/favorites.png',
            width: 80,
            height: 80,
            errorBuilder: (_, __, ___) => Icon(
              Icons.favorite_border,
              size: 80,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد مفضلات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف الأطباء والمستشفيات إلى مفضلاتك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('العودة للرئيسية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(Map<String, dynamic> item, bool isDark) {
    final type = item['type'] ?? 'أخرى';
    final name = item['name'] ?? 'غير معروف';
    final subtitle = item['subtitle'] ?? item['specialty'] ?? item['location'] ?? '';
    final rating = item['rating'] ?? 4.5;

    // ✅ أيقونة محلية حسب النوع
    String getIconPath(String type) {
      switch (type) {
        case 'أطباء':
          return 'assets/images/services/consultation.png';
        case 'مستشفيات':
          return 'assets/images/services/hospital.png';
        case 'صيدليات':
          return 'assets/images/services/pharmacy.png';
        case 'مختبرات':
          return 'assets/images/services/laboratory.png';
        default:
          return 'assets/images/ui/favorites.png';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // ✅ أيقونة محلية
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getTypeColor(type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                getIconPath(type),
                width: 28,
                height: 28,
                errorBuilder: (_, __, ___) => Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ✅ المعلومات
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      '$rating',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: _getTypeColor(type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 9,
                          color: _getTypeColor(type),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ✅ أزرار الإجراءات
          Column(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 18),
                color: AppColors.primary,
                onPressed: () => _navigateToDetail(item),
              ),
              IconButton(
                icon: const Icon(Icons.favorite, size: 18, color: Colors.red),
                onPressed: () => _removeFavorite(item['id']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'أطباء':
        return Colors.blue;
      case 'مستشفيات':
        return Colors.red;
      case 'صيدليات':
        return Colors.green;
      case 'مختبرات':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'أطباء':
        return Icons.medical_services;
      case 'مستشفيات':
        return Icons.local_hospital;
      case 'صيدليات':
        return Icons.local_pharmacy;
      case 'مختبرات':
        return Icons.science;
      default:
        return Icons.favorite;
    }
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع المفضلة'),
        content: const Text('هل أنت متأكد من حذف جميع المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllFavorites();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllFavorites() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      setState(() {
        _favorites.clear();
      });
      ToastService.showSuccess('✅ تم حذف جميع المفضلة');
    } catch (e) {
      ToastService.showError('❌ فشل حذف المفضلة');
    }
  }
}
