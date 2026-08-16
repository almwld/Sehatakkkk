import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/ad_model.dart';

class AdManagementScreen extends StatefulWidget {
  final String? providerId;
  final String? providerName;
  final AdType? providerType; // ✅ تحديد نوع المقدم
  const AdManagementScreen({
    super.key,
    this.providerId,
    this.providerName,
    this.providerType,
  });

  @override
  State<AdManagementScreen> createState() => _AdManagementScreenState();
}

class _AdManagementScreenState extends State<AdManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedStatus = 'all';
  AdType? _selectedType;

  final List<String> _statusFilters = ['الكل', 'قيد المراجعة', 'نشط', 'مرفوض', 'منتهي'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedType = widget.providerType;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email?.contains('admin') ?? false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateAdDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: isDark ? const Color(0xFF0B1121) : Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.grey,
              tabs: [
                Tab(text: _getMyAdsTabTitle()),
                if (isAdmin) const Tab(text: 'مراجعة المنصة'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _statusFilters.length,
              itemBuilder: (context, index) {
                final filter = _statusFilters[index];
                final isSelected = _selectedStatus == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedStatus = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyAdsTab(),
                if (isAdmin) _buildPlatformReviewTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (widget.providerType) {
      case AdType.doctor:
        return 'عروضي الطبية';
      case AdType.pharmacy:
        return 'منتجاتي';
      case AdType.lab:
        return 'خدمات مختبري';
      case AdType.hospital:
        return 'خدماتي الطبية';
      default:
        return 'إدارة الإعلانات';
    }
  }

  String _getMyAdsTabTitle() {
    switch (widget.providerType) {
      case AdType.doctor:
        return 'عروضي';
      case AdType.pharmacy:
        return 'منتجاتي';
      case AdType.lab:
        return 'خدماتي';
      case AdType.hospital:
        return 'خدماتي';
      default:
        return 'إعلاناتي';
    }
  }

  String _getAdTypeDisplay(AdModel ad) {
    // ✅ استخدام التسمية المناسبة من الـ AdModel
    return ad.displayName;
  }

  IconData _getAdTypeIcon(AdModel ad) {
    return ad.displayIcon;
  }

  Color _getAdTypeColor(AdModel ad) {
    return ad.displayColor;
  }

  Widget _buildMyAdsTab() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('يرجى تسجيل الدخول'));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('advertisements')
          .where('providerId', isEqualTo: widget.providerId ?? user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('خطأ: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ads = snapshot.data?.docs.map((doc) {
          return AdModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList() ?? [];

        final filteredAds = _selectedStatus == 'الكل'
            ? ads
            : ads.where((ad) => ad.statusText == _selectedStatus).toList();

        if (filteredAds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getEmptyIcon(), size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(_getEmptyMessage()),
                const SizedBox(height: 8),
                Text(
                  'انقر على + لإضافة ${_getAddButtonText()}',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredAds.length,
          itemBuilder: (context, index) {
            final ad = filteredAds[index];
            return _buildAdCard(ad);
          },
        );
      },
    );
  }

  Widget _buildAdCard(AdModel ad) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeColor = _getAdTypeColor(ad);
    final typeIcon = _getAdTypeIcon(ad);
    final typeName = _getAdTypeDisplay(ad);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        border: Border.all(color: ad.statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ بطاقة النوع
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(typeIcon, size: 14, color: typeColor),
                const SizedBox(width: 4),
                Text(
                  typeName,
                  style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ✅ صورة الإعلان
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ad.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: Colors.grey[200],
                child: Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  ad.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ad.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ad.statusText,
                  style: TextStyle(fontSize: 10, color: ad.statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            ad.description,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.visibility, '${ad.views} مشاهدة'),
              _buildInfoChip(Icons.touch_app, '${ad.clicks} نقرة'),
              _buildInfoChip(Icons.calendar_today, '${ad.startDate.day}/${ad.startDate.month}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'الميزانية: ${ad.budget} ريال',
                  style: const TextStyle(fontSize: 12, color: AppColors.primary),
                ),
              ),
              Text(
                'المصروف: ${ad.spent} ريال',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          if (ad.status == AdStatus.pending)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.hourglass_empty, color: Colors.orange, size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '⏳ قيد المراجعة من قبل المنصة',
                        style: TextStyle(fontSize: 11, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (ad.status == AdStatus.rejected && ad.reviewNotes != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سبب الرفض: ${ad.reviewNotes}',
                        style: const TextStyle(fontSize: 11, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getEmptyMessage() {
    switch (widget.providerType) {
      case AdType.doctor:
        return 'لا توجد عروض طبية';
      case AdType.pharmacy:
        return 'لا توجد منتجات';
      case AdType.lab:
        return 'لا توجد خدمات مخبرية';
      default:
        return 'لا توجد إعلانات';
    }
  }

  IconData _getEmptyIcon() {
    switch (widget.providerType) {
      case AdType.doctor:
        return Icons.local_hospital_outlined;
      case AdType.pharmacy:
        return Icons.local_pharmacy_outlined;
      case AdType.lab:
        return Icons.science_outlined;
      default:
        return Icons.ad_off;
    }
  }

  String _getAddButtonText() {
    switch (widget.providerType) {
      case AdType.doctor:
        return 'عرض طبي';
      case AdType.pharmacy:
        return 'منتج';
      case AdType.lab:
        return 'خدمة مخبرية';
      default:
        return 'إعلان';
    }
  }

  void _showCreateAdDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final budgetController = TextEditingController();
    String? imagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: 'إضافة ${_getAddButtonText()} جديد',
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => imagePath = image.path);
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      image: imagePath != null
                          ? DecorationImage(
                              image: FileImage(File(imagePath!)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: imagePath == null
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('اضغط لإضافة صورة', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'عنوان ${_getAddButtonText()}'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: 'وصف ${_getAddButtonText()}'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'الميزانية (ريال)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ToastService.showError(context, '✅ تم إرسال ${_getAddButtonText();
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final ads = snapshot.data?.docs.map((doc) {
          return AdModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
        }).toList() ?? [];

        if (ads.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('لا توجد إعلانات في انتظار المراجعة'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: ads.length,
          itemBuilder: (context, index) {
            final ad = ads[index];
            return _buildReviewCard(ad);
          },
        );
      },
    );
  }

  Widget _buildReviewCard(AdModel ad) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typeName = _getAdTypeDisplay(ad);
    final typeColor = _getAdTypeColor(ad);
    final typeIcon = _getAdTypeIcon(ad);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4)],
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '🔄 قيد المراجعة',
                  style: TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(typeIcon, size: 12, color: typeColor),
                    const SizedBox(width: 4),
                    Text(
                      typeName,
                      style: TextStyle(fontSize: 10, color: typeColor, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '📢 ${ad.title}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            ad.description,
            style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoChip(Icons.business, ad.providerName),
              _buildInfoChip(Icons.people, ad.targetText),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _reviewAd(ad, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('✅ قبول'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _reviewAd(ad, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('❌ رفض'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _reviewAd(AdModel ad, bool approve) async {
    final notesController = TextEditingController();

    if (!approve) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: 'سبب الرفض',
          content: TextField(
            controller: notesController,
            decoration: const InputDecoration(hintText: 'اكتب سبب الرفض...'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _submitReview(ad, approve, notesController.text);
              },
              child: const Text('تأكيد الرفض'),
            ),
          ],
        ),
      );
    } else {
      _submitReview(ad, approve, '');
    }
  }

  Future<void> _submitReview(AdModel ad, bool approve, String notes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('advertisements')
          .doc(ad.id)
          .update({
        'status': approve ? 'approved' : 'rejected',
        'reviewedAt': DateTime.now().toIso8601String(),
        'reviewNotes': notes,
        'reviewerId': user.uid,
      });

      if (mounted) {
        ToastService.showError(context, approve ? '✅ تمت الموافقة على ${_getAddButtonText();
      }
    } catch (e) {
      if (mounted) {
        ToastService.showError(context, '❌ حدث خطأ: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
