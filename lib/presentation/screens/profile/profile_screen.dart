import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/auth/auth_screen.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _userData = {};
  String _userName = '';
  String _userEmail = '';
  String _userPhone = '';
  String _userRole = 'مستخدم';
  String _userImage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          setState(() {
            _userData = data;
            _userName = data['name'] ?? user.displayName ?? 'مستخدم';
            _userEmail = data['email'] ?? user.email ?? '';
            _userPhone = data['phone'] ?? '';
            _userRole = data['role'] ?? 'مستخدم';
            _userImage = data['photoUrl'] ?? '';
            _isLoading = false;
          });
        } else {
          setState(() {
            _userName = user.displayName ?? 'مستخدم';
            _userEmail = user.email ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: 'الملف الشخصي',
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: isDark ? Colors.white : Colors.black87),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ✅ صورة المستخدم
                  _buildUserAvatar(isDark),
                  const SizedBox(height: 16),

                  // ✅ اسم المستخدم
                  Text(
                    _userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _userRole,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ✅ معلومات المستخدم
                  _buildInfoCard(isDark),
                  const SizedBox(height: 16),

                  // ✅ أزرار الإجراءات
                  _buildActionButtons(isDark),
                  const SizedBox(height: 16),

                  // ✅ زر تسجيل الخروج
                  _buildLogoutButton(isDark),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // 🧑 صورة المستخدم
  // ============================================================
  Widget _buildUserAvatar(bool isDark) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: _userImage.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    _userImage,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        _userName.isNotEmpty ? _userName[0].toUpperCase() : 'م',
                        style: TextStyle(
                          fontSize: 40,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                )
              : Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'م',
                  style: TextStyle(
                    fontSize: 40,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? const Color(0xFF0B1121) : Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 📋 بطاقة المعلومات
  // ============================================================
  Widget _buildInfoCard(bool isDark) {
    final List<Map<String, dynamic>> infoItems = [
      {'icon': Icons.person, 'label': 'الاسم', 'value': _userName},
      {'icon': Icons.email, 'label': 'البريد الإلكتروني', 'value': _userEmail},
      {'icon': Icons.phone, 'label': 'رقم الهاتف', 'value': _userPhone.isNotEmpty ? _userPhone : 'غير مضاف'},
      {'icon': Icons.verified_user, 'label': 'الدور', 'value': _userRole},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: infoItems.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        item['value'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (item['label'] == 'الاسم' || item['label'] == 'رقم الهاتف')
                  IconButton(
                    icon: Icon(Icons.edit, color: AppColors.primary, size: 18),
                    onPressed: () {
                      _showEditDialog(item['label'] as String, item['value'] as String);
                    },
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // 🔘 أزرار الإجراءات
  // ============================================================
  Widget _buildActionButtons(bool isDark) {
    final actions = [
      {'icon': Icons.medical_information, 'label': 'السجل الطبي', 'color': Colors.blue},
      {'icon': Icons.calendar_today, 'label': 'مواعيدي', 'color': Colors.green},
      {'icon': Icons.notifications, 'label': 'الإشعارات', 'color': Colors.orange},
      {'icon': Icons.help, 'label': 'المساعدة', 'color': Colors.purple},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return GestureDetector(
          onTap: () {
            ToastService.showSuccess(context, 'جاري فتح ${action['label']}...');
          },
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'] as IconData, color: action['color'] as Color, size: 24),
                const SizedBox(width: 8),
                Text(
                  action['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🚪 زر تسجيل الخروج
  // ============================================================
  Widget _buildLogoutButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'تسجيل الخروج',
          style: TextStyle(color: Colors.red, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 📦 دوال مساعدة
  // ============================================================
  void _showEditDialog(String label, String currentValue) {
    final TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $label'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .update({label == 'الاسم' ? 'name' : 'phone': controller.text});
                    _loadUserData();
                    ToastService.showSuccess(context, '✅ تم التحديث بنجاح');
                  }
                } catch (e) {
                  ToastService.showError(context, '❌ حدث خطأ: $e');
                }
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
