import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/image_service.dart';
import 'package:sehatak/presentation/screens/auth/login_screen.dart';
import 'package:sehatak/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/screens/settings/settings_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _selectedCategory = 'الكل';
  final ScrollController _scrollController = ScrollController();
  double _appBarOpacity = 1.0;

  // ✅ كبسولات التصفح
  final List<String> _categories = [
    'الكل',
    'رعاية عائلية',
    'أدوات تشخيصية',
    'لوجستيات وتأمين',
  ];

  // ✅ المؤشرات الحيوية
  final List<Map<String, dynamic>> _vitals = [
    {'title': 'عداد الخطوات', 'value': '5,230', 'unit': 'خطوة', 'icon': Icons.directions_walk, 'color': Colors.orange, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'ضغط الدم', 'value': '120/80', 'unit': 'ملم زئبق', 'icon': Icons.favorite, 'color': Colors.red, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'معدل القلب', 'value': '72', 'unit': 'نبضة/د', 'icon': Icons.favorite, 'color': Colors.pink, 'status': 'طبيعي', 'statusColor': Colors.green},
    {'title': 'نسبة السكر', 'value': '95', 'unit': 'مغ/دسل', 'icon': Icons.water_drop, 'color': Colors.blue, 'status': 'مرتفع', 'statusColor': Colors.red},
  ];

  // ✅ الخدمات (حسب الفلتر)
  List<Map<String, dynamic>> get _filteredServices {
    switch (_selectedCategory) {
      case 'رعاية عائلية':
        return [
          {'icon': Icons.woman, 'title': 'صحة المرأة', 'subtitle': 'متابعة الدورة والحمل'},
          {'icon': Icons.child_care, 'title': 'نمو الطفل', 'subtitle': 'مراحل التطور والتطعيمات'},
          {'icon': Icons.house_rounded, 'title': 'طبيب العائلة', 'subtitle': 'رعاية منزلية متكاملة'},
          {'icon': Icons.pregnant_woman, 'title': 'متابعة الحمل', 'subtitle': 'أسابيع الحمل بدقة'},
        ];
      case 'أدوات تشخيصية':
        return [
          {'icon': Icons.psychology, 'title': 'العيادة الذكية', 'subtitle': 'فحص الأعراض بالذكاء الاصطناعي'},
          {'icon': Icons.medical_services, 'title': 'حاسبة خطر الأمراض', 'subtitle': 'تقييم المخاطر الصحية'},
          {'icon': Icons.healing, 'title': 'مقياس التوتر', 'subtitle': 'قياس مستوى التوتر النفسي'},
          {'icon': Icons.search, 'title': 'قاموس الأدوية', 'subtitle': 'البحث عن الأدوية وتفاصيلها'},
        ];
      case 'لوجستيات وتأمين':
        return [
          {'icon': Icons.local_pharmacy, 'title': 'صيدلية', 'subtitle': 'طلب الأدوية وتوصيلها'},
          {'icon': Icons.science, 'title': 'مختبرات', 'subtitle': 'حجز التحاليل والفحوصات'},
          {'icon': Icons.shield, 'title': 'تأمين صحي', 'subtitle': 'خطط التأمين والاشتراك'},
          {'icon': Icons.map, 'title': 'خرائط المرافق', 'subtitle': 'أقرب المستشفيات والصيدليات'},
        ];
      default:
        return [
          {'icon': Icons.woman, 'title': 'صحة المرأة', 'subtitle': 'متابعة الدورة والحمل'},
          {'icon': Icons.child_care, 'title': 'نمو الطفل', 'subtitle': 'مراحل التطور والتطعيمات'},
          {'icon': Icons.psychology, 'title': 'العيادة الذكية', 'subtitle': 'فحص الأعراض بالذكاء الاصطناعي'},
          {'icon': Icons.local_pharmacy, 'title': 'صيدلية', 'subtitle': 'طلب الأدوية وتوصيلها'},
          {'icon': Icons.science, 'title': 'مختبرات', 'subtitle': 'حجز التحاليل والفحوصات'},
          {'icon': Icons.shield, 'title': 'تأمين صحي', 'subtitle': 'خطط التأمين والاشتراك'},
          {'icon': Icons.healing, 'title': 'مقياس التوتر', 'subtitle': 'قياس مستوى التوتر النفسي'},
          {'icon': Icons.house_rounded, 'title': 'طبيب العائلة', 'subtitle': 'رعاية منزلية متكاملة'},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      setState(() {
        _appBarOpacity = 1.0 - (currentScroll / maxScroll).clamp(0.0, 1.0);
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0D5257);
    final user = FirebaseAuth.instance.currentUser;
    final logged = user != null;
    final name = user?.displayName ?? user?.email?.split('@')[0] ?? 'مستخدم';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ✅ AppBar يختفي تدريجياً
          SliverAppBar(
            expandedHeight: 100,
            floating: true,
            pinned: true,
            backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
            foregroundColor: primaryColor,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Opacity(
                opacity: _appBarOpacity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      // ✅ صورة الملف الشخصي
                      GestureDetector(
                        onTap: () {
                          if (logged) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PatientProfile()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => AuthBloc(),
                                  child: const LoginScreen(),
                                ),
                              ),
                            );
                          }
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: user?.photoURL ?? '',
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _shimmerPlaceholder(45, 45, 14),
                            errorWidget: (_, __, ___) => Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.person, color: primaryColor, size: 24),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              logged ? name : 'زائر',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              logged ? 'رقم الملف: #${user?.uid.substring(0, 8) ?? '00000000'}' : 'تسجيل الدخول للمزيد',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ✅ زر الإعدادات
                      IconButton(
                        icon: Icon(Icons.settings_outlined, color: primaryColor),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ المحتوى الرئيسي
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1️⃣ جناح العيادة الذكية (AI Smart Suite)
                _buildAISmartSuite(primaryColor),
                const SizedBox(height: 20),

                // 2️⃣ المؤشرات الحيوية
                _sectionTitle('المؤشرات الحيوية', isDark),
                const SizedBox(height: 10),
                _buildVitalsGrid(),
                const SizedBox(height: 20),

                // 3️⃣ كبسولات التصفح
                _buildFilterChips(primaryColor),
                const SizedBox(height: 16),

                // 4️⃣ الخدمات حسب الفلتر
                ..._filteredServices.map((service) => _buildServiceCard(service, isDark, primaryColor)),
                const SizedBox(height: 16),

                // 5️⃣ خزنة البيانات المشفرة (Privacy Vault)
                _buildPrivacyVault(isDark, primaryColor),
                const SizedBox(height: 16),

                // 6️⃣ تذييل فخم (Premium Footer)
                _buildPremiumFooter(isDark, primaryColor),
                const SizedBox(height: 30),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Shimmer
  Widget _shimmerPlaceholder(double width, double height, double radius) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }

  // ✅ جناح العيادة الذكية
  Widget _buildAISmartSuite(Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.psychology, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'عيادة الذكاء الاصطناعي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.blur_on, color: Colors.white54),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'هل تشعر بأي أعراض صحية حالياً؟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ابدأ فحصاً فورياً مدعوماً بالذكاء الاصطناعي لتحليل حالتك وتوجيهك للطبيب المناسب.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: () {},
              child: const Text(
                'ابدأ الفحص الذكي الآن',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ شبكة المؤشرات الحيوية
  Widget _buildVitalsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: _vitals.length,
      itemBuilder: (context, index) {
        final vital = _vitals[index];
        final color = vital['color'] as Color;
        final statusColor = vital['statusColor'] as Color;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vital['title'] as String,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Icon(vital['icon'] as IconData, color: color, size: 20),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vital['value'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D5257),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vital['status'] as String,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vital['unit'] as String,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ كبسولات التصفح
  Widget _buildFilterChips(Color primaryColor) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(
              right: index == 0 ? 0 : 8,
              left: index == _categories.length - 1 ? 0 : 0,
            ),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (val) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : primaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : primaryColor.withOpacity(0.2),
                ),
              ),
              elevation: 0,
            ),
          );
        },
      ),
    );
  }

  // ✅ بطاقة الخدمة
  Widget _buildServiceCard(Map<String, dynamic> service, bool isDark, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            service['icon'] as IconData,
            color: primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          service['title'] as String,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          service['subtitle'] as String,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDark ? Colors.grey[500] : Colors.grey[400],
        ),
        onTap: () {},
      ),
    );
  }

  // ✅ خزنة البيانات المشفرة (Privacy Vault)
  Widget _buildPrivacyVault(bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'مركز الخصوصية والتحكم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.08),
                    foregroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.sensors, size: 16),
                  label: const Text(
                    'إدارة الأذونات',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.file_download, size: 16),
                  label: const Text(
                    'تصدير التقرير',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ تذييل فخم (Premium Footer)
  Widget _buildPremiumFooter(bool isDark, Color primaryColor) {
    return Column(
      children: [
        // ✅ زر تسجيل الخروج
        GestureDetector(
          onTap: () {
            _showLogoutDialog();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.red.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ✅ رقم الإصدار
        Text(
          'صحتك - v1.0.0 (Build 240)',
          style: TextStyle(
            color: isDark ? Colors.grey[600] : Colors.grey[400],
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '© 2026 Sehatak Platform. All rights reserved.',
          style: TextStyle(
            color: isDark ? Colors.grey[700] : Colors.grey[300],
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  // ✅ حوار تسجيل الخروج
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthBloc>().add(Logout());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}
