import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/search_service.dart';
import 'package:sehatak/core/services/unified_search_service.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class AdvancedSearchScreen extends StatefulWidget {
  final String? initialQuery;
  const AdvancedSearchScreen({super.key, this.initialQuery});

  @override
  State<AdvancedSearchScreen> createState() => _UnifiedSearchScreenState();
}

class _UnifiedSearchScreenState extends State<AdvancedSearchScreen> {
  final _controller = TextEditingController();
  final _service = UnifiedSearchService();
  final _history = SearchService();
  List<UnifiedSearchResult> _results = const [];
  List<String> _suggestions = const [];
  bool _loading = false;
  String _type = 'الكل';

  static const _types = <String, String>{
    'الكل': 'all', 'أطباء': 'doctor', 'صيدليات': 'pharmacy', 'مختبرات': 'lab', 'مستشفيات': 'hospital', 'منتجات': 'product', 'أدوية': 'drug', 'مقالات': 'article', 'منشورات': 'post', 'صحتي': 'health', 'خدمات': 'service',
  };

  @override
  void initState() {
    super.initState();
    if ((widget.initialQuery ?? '').trim().isNotEmpty) {
      _controller.text = widget.initialQuery!.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) => _search());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    setState(() => _loading = true);
    try {
      final results = await _service.search(q);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) await _history.saveSearchHistory(uid, q);
      if (!mounted) return;
      setState(() { _results = results; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _suggest(String value) async {
    if (value.trim().length < 2) {
      setState(() => _suggestions = const []);
      return;
    }
    final suggestions = await _history.getSuggestions(value.trim());
    if (mounted) setState(() => _suggestions = suggestions);
  }

  List<UnifiedSearchResult> get _filtered => _type == 'all' ? _results : _results.where((r) => r.type == _type).toList();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('البحث الذكي'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: Column(children: [
        Padding(padding: const EdgeInsets.fromLTRB(14, 14, 14, 8), child: Container(height: 52, padding: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [
          const Text('⌕', style: TextStyle(fontSize: 26, color: AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: TextField(controller: _controller, textInputAction: TextInputAction.search, onSubmitted: (_) => _search(), onChanged: _suggest, decoration: const InputDecoration(hintText: 'طبيب، دواء، خدمة، مستشفى، مقال...', border: InputBorder.none))),
          if (_loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ]))),
        if (_suggestions.isNotEmpty && _results.isEmpty) _suggestionsView(dark),
        SizedBox(height: 44, child: ListView.separated(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 14), itemCount: _types.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) { final entry = _types.entries.elementAt(i); final selected = _type == entry.key; return ChoiceChip(label: Text(entry.key, style: TextStyle(fontSize: 10, color: selected ? Colors.white : (dark ? Colors.white70 : Colors.black87))), selected: selected, selectedColor: AppColors.primary, onSelected: (_) => setState(() => _type = entry.key)); })),
        Expanded(child: _loading ? const Center(child: CircularProgressIndicator()) : _filtered.isEmpty ? _empty(dark) : ListView.builder(padding: const EdgeInsets.fromLTRB(14, 8, 14, 24), itemCount: _filtered.length, itemBuilder: (_, i) => _resultCard(_filtered[i], dark))),
      ]),
    );
  }

  Widget _suggestionsView(bool dark) => Container(color: dark ? const Color(0xFF1A2540) : Colors.white, constraints: const BoxConstraints(maxHeight: 180), child: ListView.builder(itemCount: _suggestions.length, itemBuilder: (_, i) => ListTile(title: Text(_suggestions[i]), onTap: () { _controller.text = _suggestions[i]; _suggestions = const []; _search(); setState(() {}); })));

  Widget _resultCard(UnifiedSearchResult result, bool dark) => InkWell(onTap: () => _open(result), borderRadius: BorderRadius.circular(16), child: Container(margin: const EdgeInsets.only(bottom: 9), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: dark ? const Color(0xFF1A2540) : Colors.white, borderRadius: BorderRadius.circular(16)), child: Row(children: [
    if (result.imageUrl.isNotEmpty) ClipRRect(borderRadius: BorderRadius.circular(12), child: AppImage(imageUrl: result.imageUrl, width: 58, height: 58, fit: BoxFit.cover)) else Container(width: 58, height: 58, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(12)), child: Text(_label(result.type), style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w900))),
    const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131))), if (result.subtitle.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(result.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: dark ? Colors.white60 : Colors.grey[600]))), Text(_label(result.type), style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w800))]))
  ])));

  String _label(String type) => const {'doctor':'طبيب','pharmacy':'صيدلية','lab':'مختبر','hospital':'مستشفى','product':'منتج','drug':'دواء','article':'مقال','post':'منشور','health':'صحتي','service':'خدمة'}[type] ?? 'نتيجة';

  void _open(UnifiedSearchResult result) {
    switch (result.type) {
      case 'doctor':
        _go('/doctor/${result.id}');
        break;
      case 'health':
      case 'service':
        if (result.route != null) _go(result.route!);
        break;
      case 'product':
      case 'drug':
        _go('/pharmacy');
        break;
      case 'pharmacy':
      case 'lab':
      case 'hospital':
        _go(result.type == 'lab' ? '/labs' : result.type == 'pharmacy' ? '/pharmacy' : '/services');
        break;
      case 'article':
      case 'post':
        _go('/more');
        break;
    }
  }

  void _go(String route) => context.push(route);

  Widget _empty(bool dark) => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_controller.text.isEmpty ? 'ابحث في منصة صحتك' : 'لا توجد نتائج مطابقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: dark ? Colors.white : const Color(0xFF173131))), const SizedBox(height: 8), Text('يشمل الأطباء والأدوية والمنتجات والمنشآت والخدمات والمقالات والمجتمع وبيانات صحتي.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : Colors.grey[600]))])));
}
