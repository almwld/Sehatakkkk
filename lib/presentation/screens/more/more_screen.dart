import 'package:flutter/material.dart';
import 'package:sehatak/core/theme/app_theme.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'رعاية عائلية', 'أدوات تشخيصية', 'لوجستيات'];

  // بيانات المؤشرات الحيوية (من قاعدة بيانات محلية)
  final List<Map<String, dynamic>> _vitalsData = [
    {'title': 'عداد الخطوات', 'value': '5,230', 'unit': 'خطوة', 'icon': Icons.directions_walk, 'color': Colors.orange, 'status': 'طبيعي'},
    {'title': 'ضغط الدم', 'value': '120/80', 'unit': 'ملم زئبق', 'icon': Icons.favorite, 'color': Colors.red, 'status': 'طبيعي'},
    {'title': 'معدل القلب', 'value': '72', 'unit': 'نبضة/د', 'icon': Icons.pulse_tracker, 'color': Colors.pink, 'status': 'طبيعي'},
    {'title': 'نسبة السكر', 'value': '95', 'unit': 'مغ/دسل', 'icon': Icons.water_drop, 'color': Colors.blue, 'status': 'طبيعي'},
  ];

  // بيانات الخدمات
  final List<Map<String, dynamic>> _services = [
    {'title': 'صحة المرأة ومتابعة الحمل', 'subtitle': 'تتبع الدورة الشهرية وأسابيع الحمل بدقة', 'icon': Icons.woman, 'category': 'رعاية عائلية'},
    {'title': 'نمو الطفل وسجل التطعيمات', 'subtitle': 'متابعة مراحل التطور والجرعات كاملة', 'icon': Icons.child_care, 'category': 'رعاية عائلية'},
    {'title': 'طبيب العائلة والرعاية المنزلية', 'subtitle': 'جدولة زيارات الفحص المنزلي للأقارب', 'icon': Icons.house_rounded, 'category': 'رعاية عائلية'},
    {'title': 'العيادة الذكية للذكاء الاصطناعي', 'subtitle': 'فحص الأعراض وتحليل الحالة فورياً', 'icon': Icons.psychology, 'category': 'أدوات تشخيصية'},
    {'title': 'مقياس التوتر النفسي', 'subtitle': 'تقييم الحالة النفسية وتقديم تمارين الاسترخاء', 'icon': Icons.self_improvement, 'category': 'أدوات تشخيصية'},
    {'title': 'خدمات التوصيل الطبي', 'subtitle': 'توصيل الأدوية والمستلزمات إلى منزلك', 'icon': Icons.delivery_dining, 'category': 'لوجستيات'},
  ];

  List<Map<String, dynamic>> get _filteredServices {
    if (_selectedCategory == 'الكل') return _services;
    return _services.where((s) => s['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = AppTheme.primaryColor;
    final accentColor = AppTheme.accentColor;
    final bgColor = isDark ? const Color(0xFF0B1121) : AppTheme.backgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================================
            // 1. شريط الهوية العلوي الذكي
            // ============================================================
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: bgColor,
              elevation: 0,
              expandedHeight: 80,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      Text(
                        'لوحة التحكم الشاملة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.settings_outlined, color: primaryColor),
                  onPressed: () {},
                ),
              ],
            ),

            // ============================================================
            // 2. جناح العيادة الذكية للذكاء الاصطناعي
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.85)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
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
                                Icon(Icons.psychology, color: accentColor, size: 18),
                                const SizedBox(width: 6),
                                const Text(
                                  'عيادة الذكاء الاصطناعي',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
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
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'ابدأ فحصاً فورياً مدعوماً بالذكاء الاصطناعي لتحليل حالتك وتوجيهك للطبيب المناسب.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontFamily: 'Tajawal',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          elevation: 0,
                        ),
                        onPressed: () {},
                        child: const Text(
                          'ابدأ الفحص الذكي الآن',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================================
            // 3. عنوان المؤشرات الحيوية
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'المؤشرات الحيوية والتتبع اليومي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),

            // ============================================================
            // 4. شبكة المؤشرات الحيوية
            // ============================================================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final data = _vitalsData[index];
                    return _buildVitalsCard(
                      title: data['title'] as String,
                      value: data['value'] as String,
                      unit: data['unit'] as String,
                      icon: data['icon'] as IconData,
                      iconColor: data['color'] as Color,
                      status: data['status'] as String,
                    );
                  },
                  childCount: _vitalsData.length,
                ),
              ),
            ),

            // ============================================================
            // 5. كبسولات التصفح الأفقي
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: _buildFilterChips(),
              ),
            ),

            // ============================================================
            // 6. قائمة الخدمات الديناميكية
            // ============================================================
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final service = _filteredServices[index];
                    return _buildServiceRowCard(
                      title: service['title'] as String,
                      subtitle: service['subtitle'] as String,
                      icon: service['icon'] as IconData,
                    );
                  },
                  childCount: _filteredServices.length,
                ),
              ),
            ),

            // ============================================================
            // 7. خزنة البيانات المشفرة (Privacy Vault)
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A2540) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : AppTheme.cardBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock_outline, color: AppTheme.primaryColor),
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
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.sensors, size: 16),
                              label: const Text('إدارة أذونات الحساسات'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.picture_as_pdf, size: 16),
                              label: const Text('تصدير التقرير المشفر'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: BorderSide(color: AppTheme.primaryColor),
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
              ),
            ),

            // ============================================================
            // 8. التذييل المؤسسي
            // ============================================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red.shade300,
                      ),
                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'صحتك لخدمات الرعاية الطبية - v1.0.0 (Build 240)',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🧩 ميثود بناء كروت المؤشرات الحيوية
  // ============================================================
  Widget _buildVitalsCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
    required String status,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = status == 'طبيعي' ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : AppTheme.cardBorderColor,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 13,
                  fontFamily: 'Tajawal',
                ),
              ),
              Icon(icon, color: iconColor, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                  fontFamily: 'Tajawal',
                ),
              ),
              Row(
                children: [
                  Text(
                    unit,
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                      fontSize: 11,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 ميثود بناء كبسولات التصفح
  // ============================================================
  Widget _buildFilterChips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: EdgeInsets.only(
              right: index == 0 ? 0 : 8.0,
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
              selectedColor: AppTheme.primaryColor,
              backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.primaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: 'Tajawal',
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              elevation: 0,
              pressElevation: 0,
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 🧩 ميثود بناء كروت الخدمات
  // ============================================================
  Widget _buildServiceRowCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : AppTheme.cardBorderColor,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 12,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
