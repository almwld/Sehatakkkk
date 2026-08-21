import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/chat/status_view_screen.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  final ImagePicker _picker = ImagePicker();
  
  List<Map<String, dynamic>> _statuses = [
    {
      'name': 'د. أحمد المؤيد',
      'text': 'مرحباً! كيف يمكنني مساعدتك؟',
      'image': null,
      'color': Colors.teal,
      'time': 'منذ 5 دقائق',
    },
    {
      'name': 'د. خالد النخلاني',
      'text': 'سأتصل بك غداً',
      'image': null,
      'color': Colors.blue,
      'time': 'منذ ساعتين',
    },
    {
      'name': 'د. أسماء الهندي',
      'text': 'تم تأكيد موعدك',
      'image': null,
      'color': Colors.purple,
      'time': 'منذ 5 ساعات',
    },
    {
      'name': 'د. محمد العلاي',
      'text': 'نحتاج إلى تحليل جديد',
      'image': null,
      'color': Colors.orange,
      'time': 'منذ يوم',
    },
  ];

  Future<void> _pickAndUploadStatus(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (image != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _statuses.insert(0, {
            'name': 'أنت',
            'text': 'حالة جديدة',
            'image': File(image.path),
            'color': Colors.green,
            'time': 'الآن',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم رفع الحالة بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddStatusOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF202c33),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('اختر من المعرض', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadStatus(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('التقط صورة', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickAndUploadStatus(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0b141a) : const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ زر إضافة حالة
          GestureDetector(
            onTap: _showAddStatusOptions,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202c33) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أضف حالة جديدة',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          'شارك حالتك مع الآخرين',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // ✅ الحالات
          if (_statuses.isNotEmpty) ...[
            const Text(
              'الحالات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._statuses.map((status) => _buildStatusItem(status, isDark)),
          ],
          
          const SizedBox(height: 20),
          
          // ✅ القنوات
          const Text(
            'القنوات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildChannelItem('صحتك الطبية', 'أحدث النصائح الطبية', 'منذ ساعة', 'ص', Colors.teal),
          _buildChannelItem('الأخبار الصحية', 'آخر المستجدات الصحية', 'منذ يوم', 'أ', Colors.blue),
          _buildChannelItem('التغذية السليمة', 'نصائح غذائية يومية', 'منذ يومين', 'ت', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatusItem(Map<String, dynamic> status, bool isDark) {
    final name = status['name'] as String;
    final text = status['text'] as String;
    final color = status['color'] as Color;
    final time = status['time'] as String;
    final image = status['image'] as File?;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StatusViewScreen(
              name: name,
              statusText: text,
              imageFile: image,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF202c33) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ✅ صورة الحالة
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.file(
                        image,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Center(
                      child: Text(
                        name.isNotEmpty ? name[0] : 'م',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // ✅ معلومات الحالة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // ✅ الوقت
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelItem(String name, String subtitle, String time, String letter, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF202c33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'جديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
