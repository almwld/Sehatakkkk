import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _faqs = <_Faq>[
    _Faq('كيف أحجز موعداً مع طبيب؟', 'افتح قسم الأطباء، اختر الطبيب المناسب، ثم اختر الموعد المتاح واضغط تأكيد الحجز.', Icons.calendar_month_rounded),
    _Faq('كيف أستخدم الاستشارة الفورية؟', 'من خدمة الاستشارة الفورية يمكنك بدء محادثة أو مكالمة مع مقدم الرعاية المتاح.', Icons.video_call_rounded),
    _Faq('أين أجد طلبات الصيدلية؟', 'افتح الصيدلية ثم قسم طلباتي لمراجعة حالة الطلب والتوصيل وتفاصيل الشراء.', Icons.local_pharmacy_rounded),
    _Faq('كيف أضيف أفراد العائلة؟', 'من الملف الصحي يمكنك إضافة أفراد العائلة وإدارة بياناتهم الصحية كلٌ على حدة.', Icons.family_restroom_rounded),
    _Faq('لماذا لم تصلني الإشعارات؟', 'تأكد من اتصال الإنترنت ومن السماح للتطبيق بالإشعارات من إعدادات الهاتف، ثم أعد فتح التطبيق.', Icons.notifications_active_rounded),
    _Faq('كيف أتواصل مع الدعم؟', 'استخدم البريد الإلكتروني أو الاتصال الهاتفي من قسم تواصل مع الدعم أدناه.', Icons.support_agent_rounded),
  ];

  List<_Faq> get _filteredFaqs {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _faqs;
    return _faqs.where((faq) => (faq.question + ' ' + faq.answer).toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _open(String value) async {
    final uri = Uri.parse(value);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح وسيلة التواصل')));
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح وسيلة التواصل')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final faqs = _filteredFaqs;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF081A1A) : const Color(0xFFF6F9F9),
      appBar: CustomAppBar(
        title: 'المساعدة والدعم',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
        children: [
          _HeroCard(dark: dark),
          const SizedBox(height: 14),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث في الأسئلة الشائعة...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear_rounded),
                    ),
              filled: true,
              fillColor: dark ? const Color(0xFF102A2A) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 18),
          const Text('الأسئلة الشائعة', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (faqs.isEmpty)
            _EmptyFaq(dark: dark)
          else
            ...faqs.map((faq) => _FaqTile(faq: faq, dark: dark)),
          const SizedBox(height: 10),
          _SupportCard(
            dark: dark,
            onEmail: () => _open('mailto:support@sehatak.com'),
            onPhone: () => _open('tel:+9671234567'),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final bool dark;
  const _HeroCard({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(22)),
      child: const Row(
        children: [
          CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 32)),
          SizedBox(width: 14),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('كيف يمكننا مساعدتك؟', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                  SizedBox(height: 5),
                  Text('ابحث عن إجابة أو تواصل مباشرة مع فريق الدعم.', style: TextStyle(color: Colors.white70, height: 1.45)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final _Faq faq;
  final bool dark;
  const _FaqTile({required this.faq, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF102A2A) : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE2EAEA)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: AppColors.primary,
        collapsedIconColor: dark ? Colors.white60 : Colors.black45,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withOpacity(.10),
          child: Icon(faq.icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          faq.question,
          textDirection: TextDirection.rtl,
          style: TextStyle(color: dark ? Colors.white : const Color(0xFF173131), fontSize: 14, fontWeight: FontWeight.w800),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              faq.answer,
              textDirection: TextDirection.rtl,
              style: TextStyle(color: dark ? Colors.white70 : const Color(0xFF647474), fontSize: 13, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  final bool dark;
  final VoidCallback onEmail;
  final VoidCallback onPhone;

  const _SupportCard({required this.dark, required this.onEmail, required this.onPhone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF102A2A) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: dark ? Colors.white10 : const Color(0xFFE2EAEA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('تواصل مع الدعم', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text('اختر الطريقة المناسبة وسنساعدك في أقرب وقت.', textDirection: TextDirection.rtl, style: TextStyle(color: dark ? Colors.white60 : Colors.black54, fontSize: 12)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _ContactButton(icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: 'support@sehatak.com', onTap: onEmail)),
              const SizedBox(width: 10),
              Expanded(child: _ContactButton(icon: Icons.phone_outlined, label: 'الهاتف', value: '+967 1 234 567', onTap: onPhone)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _ContactButton({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EmptyFaq extends StatelessWidget {
  final bool dark;
  const _EmptyFaq({required this.dark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: dark ? Colors.white24 : Colors.black26),
          const SizedBox(height: 8),
          Text('لا توجد نتائج مطابقة', style: TextStyle(color: dark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Faq {
  final String question;
  final String answer;
  final IconData icon;
  const _Faq(this.question, this.answer, this.icon);
}
