import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/localization/dynamic_localization.dart';
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
  Map<String, dynamic>? _hospitalData;
  bool _loading = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _hospitalData = widget.hospitalData;
    if (_hospitalData == null) _loadHospital();
  }

  Future<void> _loadHospital() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(widget.hospitalId)
          .get();
      if (!snapshot.exists) {
        throw StateError('Hospital document was not found');
      }
      if (!mounted) return;
      setState(() => _hospitalData = {
        'id': snapshot.id,
        ...?snapshot.data(),
      });
    } catch (error, stack) {
      debugPrint('Hospital details load failed: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hospital = _hospitalData ?? <String, dynamic>{};
    final locale = AppStrings.of(context).locale;
    final hospitalName = localizedField(hospital, 'name', locale, fallback: _localizedUiText(context, 'اسم المستشفى'));
    final hospitalLocation = localizedField(
      hospital,
      'location',
      locale,
      fallback: localizedField(hospital, 'address', locale, fallback: _localizedUiText(context, 'الموقع غير معروف')),
    );
    final hospitalType = localizedField(hospital, 'type', locale, fallback: _localizedUiText(context, 'عام'));

    return Scaffold(
      appBar: AppBar(
        title: Text(hospitalName),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 42, color: Colors.redAccent),
                        const SizedBox(height: 12),
                        Text(_localizedUiText(context, 'تعذر تحميل بيانات المستشفى')),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _loadHospital,
                          icon: const Icon(Icons.refresh),
                          label: Text(_localizedUiText(context, 'إعادة المحاولة')),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المستشفى
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AppImage(
                imageUrl: (hospital['imageUrl'] ?? hospital['image'] ?? hospital['photoUrl'] ?? '').toString(),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),

            // اسم المستشفى
            Text(
              hospitalName,
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
                  hospitalLocation,
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
                    color: _isOpen(hospital)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ' ${_isOpen(hospital) ? '🟢 ' : '🔴 '}${_localizedUiText(context, _isOpen(hospital) ? 'مفتوح' : 'مغلق')}',
                    style: TextStyle(
                      color: _isOpen(hospital) ? Colors.green : Colors.red,
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
            _buildInfoRow('🏥 ${_localizedUiText(context, 'النوع')}', hospitalType),
            _buildInfoRow('🛏️ ${_localizedUiText(context, 'عدد الأسرة')}', '${hospital['beds'] ?? 100} ${_localizedUiText(context, 'سرير')}'),
            _buildInfoRow('📞 ${_localizedUiText(context, 'الهاتف')}', (hospital['phone'] ?? hospital['phoneNumber'] ?? _localizedUiText(context, 'غير متوفر')).toString()),

            const SizedBox(height: 24),

            _publicStaffDirectory(),
            const SizedBox(height: 20),

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
                      final phone = (hospital['phone'] ?? hospital['phoneNumber'] ?? '').toString();
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


  Widget _publicStaffDirectory() {
    final hospitalId = widget.hospitalId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedUiText(context, 'الأقسام الطبية'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('hospital_departments')
              .where('hospitalId', isEqualTo: hospitalId)
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(_localizedUiText(context, 'تعذر تحميل الأقسام حالياً'));
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            final departments = snapshot.data!.docs;
            if (departments.isEmpty) {
              return Text(_localizedUiText(context, 'لم تُنشر أقسام طبية لهذا المستشفى بعد'));
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: departments.map((doc) {
                final name = doc.data()['name']?.toString().trim() ?? '';
                if (name.isEmpty) return const SizedBox.shrink();
                return Chip(
                  avatar: const Icon(Icons.medical_services_outlined, size: 16),
                  label: Text(name),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 18),
        Text(
          _localizedUiText(context, 'الكادر الصحي'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('hospital_staff')
              .where('hospitalId', isEqualTo: hospitalId)
              .where('isPublic', isEqualTo: true)
              .where('status', isEqualTo: 'active')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(_localizedUiText(context, 'تعذر تحميل بيانات الكادر الصحي'));
            }
            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            final staff = snapshot.data!.docs;
            if (staff.isEmpty) {
              return Text(_localizedUiText(context, 'لم تُنشر ملفات الكادر الصحي لهذا المستشفى بعد'));
            }
            return Column(
              children: staff.map((doc) {
                final data = doc.data();
                final name = (data['displayName'] ?? '').toString().trim();
                final title = (data['jobTitle'] ?? '').toString().trim();
                final department = (data['departmentName'] ?? '').toString().trim();
                final details = [title, department]
                    .where((value) => value.isNotEmpty)
                    .join(' • ');
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medical_services_outlined),
                    ),
                    title: Text(name.isEmpty
                        ? _localizedUiText(context, 'عضو الكادر الصحي')
                        : name),
                    subtitle: details.isEmpty ? null : Text(details),
                    trailing: data['isVerified'] == true
                        ? const Icon(Icons.verified, color: AppColors.primary)
                        : null,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }


  bool _isOpen(Map<String, dynamic> hospital) {
    final value = hospital['open'] ?? hospital['isOpen'];
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) return ['true', '1', 'yes', 'open'].contains(value.toLowerCase().trim());
    return true;
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
