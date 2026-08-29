import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContactInfoSheet extends StatelessWidget {
  final String? name;
  final String? phone;
  final String? imageUrl;

  const ContactInfoSheet({
    super.key,
    this.name = 'د. أحمد المؤيد',
    this.phone = '+967 777 777 777',
    this.imageUrl = ImageKit.doctor1,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ✅ شريط السحب
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ صورة المستخدم
                Center(
                  child: CircleAvatar(
                    radius: 45,
                    backgroundImage: CachedNetworkImageProvider(imageUrl!),
                    child: const Icon(Icons.person, size: 45, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),

                // ✅ الاسم ورقم الهاتف
                Center(
                  child: Column(
                    children: [
                      Text(
                        name!,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone!,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ أزرار الإجراءات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      Icons.search,
                      'بحث',
                      () => ToastService.showInfo('🔍 جاري البحث...'),
                    ),
                    _buildActionButton(
                      context,
                      Icons.person_add_alt,
                      'حفظ',
                      () => ToastService.showSuccess('✅ تم حفظ الرقم'),
                    ),
                    _buildActionButton(
                      context,
                      Icons.videocam,
                      'فيديو',
                      () => ToastService.showInfo('📹 جاري مكالمة فيديو...'),
                    ),
                    _buildActionButton(
                      context,
                      Icons.call,
                      'مكالمة',
                      () => ToastService.showInfo('📞 جاري الاتصال...'),
                    ),
                  ],
                ),
                const Divider(color: Colors.grey, height: 30),

                // ✅ قائمة الخيارات
                _buildMenuItem(
                  context,
                  Icons.bookmark_add_outlined,
                  'إضافة إلى القوائم',
                ),
                _buildMenuItem(
                  context,
                  Icons.edit_note,
                  'إضافة ملاحظات',
                ),
                _buildMenuItem(
                  context,
                  Icons.notifications_off_outlined,
                  'كتم الإشعارات',
                ),
                _buildMenuItem(
                  context,
                  Icons.photo_library_outlined,
                  'عرض الوسائط',
                ),
                _buildMenuItem(
                  context,
                  Icons.lock_outline,
                  'التشفير',
                  subtitle: 'الرسائل والمكالمات مشفرة تماماً بين الطرفين.',
                ),
                _buildMenuItem(
                  context,
                  Icons.timer_outlined,
                  'الرسائل ذاتية الاختفاء',
                ),
                _buildMenuItem(
                  context,
                  Icons.lock_clock_outlined,
                  'قفل الدردشة',
                  subtitle: 'قم بقفل هذه الدردشة وإخفائها على هذا الجهاز.',
                ),
                _buildMenuItem(
                  context,
                  Icons.shield_outlined,
                  'الخصوصية المتقدمة للدردشة',
                ),
                _buildMenuItem(
                  context,
                  Icons.group_add_outlined,
                  'إنشاء مجموعة',
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? const Color(0xFF2a3942) : Colors.grey[100],
              radius: 25,
              child: Icon(icon, color: isDark ? Colors.white : Colors.black87),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {String? subtitle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDark ? Colors.white54 : Colors.grey[600]),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_left,
        color: isDark ? Colors.white54 : Colors.grey[400],
      ),
      onTap: () {
        Navigator.pop(context);
        ToastService.showInfo('✅ تم تنفيذ: $title');
      },
    );
  }
}
