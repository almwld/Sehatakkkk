import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_dimensions.dart';
import 'pharmacy_products_screen.dart';

class PharmaciesListScreen extends StatelessWidget {
  const PharmaciesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('pharmacies').where('isActive', isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text('تعذر تحميل الصيدليات حالياً')));
        if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final pharmacies = snapshot.data!.docs;

        return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.pharmacies),
        actions: [IconButton(icon: const Icon(Icons.filter_list), onPressed: () {})],
      ),
      body: pharmacies.isEmpty
          ? const Center(child: Text('لا توجد صيدليات متاحة حالياً'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              itemCount: pharmacies.length,
              itemBuilder: (context, index) {
                final doc = pharmacies[index];
                final pharmacy = doc.data();
                final name = pharmacy['name']?.toString() ?? 'صيدلية';
                final address = pharmacy['address']?.toString() ?? pharmacy['location']?.toString() ?? '';
                final isOpen = pharmacy['isOpen'] == true || pharmacy['openNow'] == true;
                final rating = pharmacy['rating'];
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PharmacyProductsScreen(pharmacyId: doc.id))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(AppDimensions.paddingL),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                    ),
                    child: Row(children: [
                      Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.local_pharmacy, color: AppColors.primary, size: 32)),
                      const SizedBox(width: 16),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (address.isNotEmpty) ...[const SizedBox(height: 4), Text(address, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey))],
                        const SizedBox(height: 8),
                        Row(children: [
                          if (rating != null) ...[const Icon(Icons.star, color: AppColors.amber, size: 16), const SizedBox(width: 4), Text('$rating'), const SizedBox(width: 16)],
                          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isOpen ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(isOpen ? 'مفتوح' : 'مغلق', style: TextStyle(fontSize: 11, color: isOpen ? AppColors.success : AppColors.error))),
                        ]),
                      ])),
                      const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ]),
                  ),
                );
              },
            ),
    );
      },
    );
  }
}
