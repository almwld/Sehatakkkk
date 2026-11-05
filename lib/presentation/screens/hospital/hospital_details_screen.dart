import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class HospitalDetailsScreen extends StatefulWidget {
  final String hospitalId;
  final Map<String, dynamic>? hospitalData;

  const HospitalDetailsScreen({
    super.key,
    required this.hospitalId,
    this.hospitalData,
  });

  @override
  State<HospitalDetailsScreen> createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hospital = widget.hospitalData ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text(hospital['name'] ?? _localizedUiText(context, 'تفاصيل المستشفى')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المستشفى
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppImage(
                imageUrl: hospital['image'] ?? '',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // اسم المستشفى
            Text(
              hospital['name'] ?? _localizedUiText(context, 'اسم المستشفى'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // الموقع
            Row(
              children: [
                Icon(Icons.location_on, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  hospital['location'] ?? _localizedUiText(context, 'الموقع غير معروف'),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // التقييم
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${hospital['rating'] ?? 4.5}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (hospital['open'] ?? true)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(hospital['open'] ?? true) ? '🟢 ' : '🔴 '}${_localizedUiText(context, (hospital['open'] ?? true) ? 'مفتوح' : 'مغلق')}',
                    style: TextStyle(
                      color: (hospital['open'] ?? true) ? Colors.green : Colors.red,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 16),

            // معلومات إضافية
            _buildInfoRow('🏥 ${_localizedUiText(context, 'النوع')}', hospital['type'] ?? _localizedUiText(context, 'عام')),
            _buildInfoRow('🛏️ ${_localizedUiText(context, 'عدد الأسرة')}', '${hospital['beds'] ?? 100} ${_localizedUiText(context, 'سرير')}'),
            _buildInfoRow('📞 ${_localizedUiText(context, 'الهاتف')}', hospital['phone'] ?? _localizedUiText(context, 'غير متوفر')),

            const SizedBox(height: 24),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // حجز موعد
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_localizedUiText(context, 'جاري حجز موعد...')),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_localizedUiText(context, 'حجز موعد')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // الاتصال
                      final phone = hospital['phone'] ?? '';
                      if (phone.isNotEmpty) {
                        // فتح تطبيق الهاتف
                      }
                    },
                    icon: const Icon(Icons.phone),
                    label: Text(_localizedUiText(context, 'اتصال')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


String _localizedUiText(BuildContext context, String value) =>
    AppStrings.of(context).translate(value);
