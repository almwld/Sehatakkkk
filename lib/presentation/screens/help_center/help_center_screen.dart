import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faqs = [
    {
      'id': '1',
      'question': 'كيف يمكنني حجز موعد مع طبيب؟',
      'answer': 'يمكنك حجز موعد من خلال التوجه إلى شاشة الأطباء، اختيار الطبيب المناسب، ثم الضغط على زر "حجز موعد" واختيار التاريخ والوقت المناسبين.',
      'category': 'المواعيد',
      'icon': Icons.calendar_month_rounded,
    },
    {
      'id': '2',
      'question': 'كيف يمكنني إجراء مكالمة فيديو مع الطبيب؟',
      'answer': 'بعد حجز الموعد، ستظهر لك أيقونة "مكالمة فيديو" في شاشة تفاصيل الموعد. اضغط عليها لبدء المكالمة مع طبيبك في الوقت المحدد.',
      'category': 'المكالمات',
      'icon': Icons.videocam_rounded,
    },
    {
      'id': '3',
      'question': 'كيف يمكنني طلب الأدوية من الصيدلية؟',
      'answer': 'اذهب إلى شاشة الصيدلية، ابحث عن الدواء المطلوب، أضفه إلى السلة، ثم اتبع خطوات الدفع لتأكيد الطلب. سيتم توصيل الدواء إلى عنوانك.',
      'category': 'الصيدلية',
      'icon': Icons.local_pharmacy_rounded,
    },
    {
      'id': '4',
      'question': 'ماذا أفعل إذا نسيت كلمة المرور؟',
      'answer': 'في شاشة تسجيل الدخول، اضغط على "نسيت كلمة المرور" واتبع التعليمات لإعادة تعيينها عبر بريدك الإلكتروني المسجل.',
      'category': 'الحساب',
      'icon': Icons.lock_outline_rounded,
    },
    {
      'id': '5',
      'question': 'كيف يمكنني تحديث بيانات ملفي الشخصي؟',
      'answer': 'اذهب إلى شاشة "ملفي" (التي تظهر عند الضغط على أيقونة الشخص في أعلى الشاشة)، ثم اضغط على زر "تعديل" لتحديث بياناتك.',
      'category': 'الحساب',
      'icon': Icons.person_outline_rounded,
    },
    {
      'id': '6',
      'question': 'هل يمكنني إلغاء الموعد بعد تأكيده؟',
      'answer': 'نعم، يمكنك إلغاء الموعد من خلال شاشة "مواعيدي"، اختر الموعد الذي تريد إلغاءه واضغط على زر "إلغاء الموعد".',
      'category': 'المواعيد',
      'icon': Icons.cancel_rounded,
    },
    {
      'id': '7',
      'question': 'كيف يمكنني التواصل مع الدعم الفني؟',
      'answer': 'يمكنك التواصل معنا عبر البريد الإلكتروني support@sehatak.com، أو من خلال نموذج الاتصال في شاشة "تواصل معنا".',
      'category': 'الدعم',
      'icon': Icons.support_agent_rounded,
    },
    {
      'id': '8',
      'question': 'هل التطبيق مجاني؟',
      'answer': 'نعم، تطبيق "صحتك" مجاني للتحميل والاستخدام الأساسي. تتوفر باقات اشتراك مميزة لخدمات إضافية.',
      'category': 'الاشتراكات',
      'icon': Icons.subscriptions_rounded,
    },
  ];

  List<Map<String, dynamic>> get _filteredFaqs {
    if (_searchQuery.isEmpty) return _faqs;
    return _faqs.where((faq) =>
      faq['question'].contains(_searchQuery) ||
      faq['answer'].contains(_searchQuery) ||
      faq['category'].contains(_searchQuery)
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredFaqs;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'المساعدة والدعم',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.contact_support_rounded),
            onPressed: () => _showContactDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط البحث
          _buildSearchBar(),
          // ✅ قائمة الأسئلة
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final faq = filtered[index];
                      return _buildFaqItem(context, faq, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'ابحث عن سؤال...',
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 60,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'لم نجد إجابة لبحثك',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, Map<String, dynamic> faq, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            faq['icon'] as IconData,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          faq['question'],
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            faq['category'],
            style: TextStyle(
              fontSize: 9,
              color: AppColors.info,
            ),
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            const Text('تواصل معنا'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يسعدنا مساعدتك! تواصل معنا عبر:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _contactItem(
              icon: Icons.email_rounded,
              label: 'البريد الإلكتروني',
              value: 'support@sehatak.com',
              onTap: () => _launchUrl('mailto:support@sehatak.com'),
            ),
            const SizedBox(height: 8),
            _contactItem(
              icon: Icons.phone_rounded,
              label: 'الهاتف',
              value: '+967 123 456 789',
              onTap: () => _launchUrl('tel:+967123456789'),
            ),
            const SizedBox(height: 8),
            _contactItem(
              icon: Icons.web_rounded,
              label: 'الموقع',
              value: 'sehatak.com',
              onTap: () => _launchUrl('https://sehatak.com'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _contactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح الرابط'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
        ),
      );
    }
  }
}
