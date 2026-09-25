import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/article/article_model.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  static const categories = <String>[
    'الكل',
    'صحة عامة',
    'تغذية',
    'صحة نفسية',
    'جلدية',
    'أطفال',
    'رياضة',
  ];

  final _searchController = TextEditingController();
  List<ArticleModel> _articles = <ArticleModel>[];
  String _category = 'الكل';
  String _query = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection('articles')
          .where('isPublished', isEqualTo: true)
          .limit(100)
          .get();

      final list = snap.docs
          .map(ArticleModel.fromFirestore)
          .where((a) => a.title.trim().isNotEmpty)
          .toList();

      list.sort((a, b) {
        final ad = a.publishedAt ?? a.createdAt;
        final bd = b.publishedAt ?? b.createdAt;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });

      if (!mounted) return;
      setState(() {
        _articles = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _articles = <ArticleModel>[];
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<ArticleModel> get _filtered {
    final q = _query.trim().toLowerCase();
    return _articles.where((a) {
      if (_category != 'الكل' && (a.category ?? '') != _category) {
        return false;
      }
      if (q.isEmpty) return true;
      final values = <String>[
        a.title,
        a.subtitle ?? '',
        a.summary ?? '',
        a.category ?? '',
        a.authorName ?? '',
        ...(a.tags ?? const <String>[]),
      ];
      return values.join(' ').toLowerCase().contains(q);
    }).toList();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = 'الكل';
    });
  }

  Future<void> _open(ArticleModel article) async {
    try {
      await FirebaseFirestore.instance
          .collection('articles')
          .doc(article.id)
          .update({'views': FieldValue.increment(1)});
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleReaderScreen(article: article),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final articles = _filtered;

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF081A1A) : const Color(0xFFF6F9F9),
      appBar: CustomAppBar(
        title: 'المقالات الصحية',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                child: UnifiedSearchBar(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () => setState(() {
                    _searchController.clear();
                    _query = '';
                  }),
                  hintText: 'ابحث عن مقال أو موضوع صحي...',
                  isDark: dark,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final selected = _category == categories[i];
                    return ChoiceChip(
                      label: Text(categories[i]),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = categories[i]),
                      selectedColor: AppColors.primary,
                      backgroundColor: dark ? const Color(0xFF102A2A) : Colors.white,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : (dark ? Colors.white24 : const Color(0xFFD9E2E2)),
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? Colors.white
                            : (dark ? Colors.white70 : const Color(0xFF315050)),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _StateMessage(
                  icon: Icons.cloud_off_rounded,
                  title: 'تعذر تحميل المقالات',
                  message: 'تحقق من الاتصال ثم حاول مرة أخرى.',
                  action: 'إعادة المحاولة',
                  onAction: _load,
                ),
              )
            else if (articles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _StateMessage(
                  icon: Icons.article_outlined,
                  title: _query.isEmpty && _category == 'الكل'
                      ? 'لا توجد مقالات منشورة حالياً'
                      : 'لا توجد مقالات مطابقة',
                  message: _query.isEmpty && _category == 'الكل'
                      ? 'ستظهر المقالات الصحية هنا عند نشرها.'
                      : 'جرّب تغيير البحث أو التصنيف.',
                  action: _query.isEmpty && _category == 'الكل' ? null : 'مسح الفلاتر',
                  onAction: _clearFilters,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 28),
                sliver: SliverList.separated(
                  itemCount: articles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _ArticleCard(
                    article: articles[i],
                    dark: dark,
                    onTap: () => _open(articles[i]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final bool dark;
  final VoidCallback onTap;

  const _ArticleCard({
    required this.article,
    required this.dark,
    required this.onTap,
  });

  String? get imageUrl {
    if (article.images != null) {
      for (final image in article.images!) {
        if (image.trim().isNotEmpty) return image;
      }
    }
    final image = article.imageUrl?.trim();
    return image == null || image.isEmpty ? null : image;
  }

  @override
  Widget build(BuildContext context) {
    final text = dark ? Colors.white : const Color(0xFF173131);
    final secondary = dark ? Colors.white60 : const Color(0xFF6B7A7A);

    return Material(
      color: dark ? const Color(0xFF102A2A) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 190,
              child: imageUrl == null
                  ? Container(
                      color: dark ? const Color(0xFF173737) : const Color(0xFFE8F0F0),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.article_outlined,
                        size: 54,
                        color: AppColors.primary.withOpacity(.5),
                      ),
                    )
                  : AppImage(
                      imageUrl: imageUrl!,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if ((article.category ?? '').trim().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            article.category!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const Spacer(),
                      Text(
                        article.timeAgo,
                        style: TextStyle(
                          color: secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: text,
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if ((article.summary ?? article.subtitle ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      (article.summary ?? article.subtitle!).trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 12, height: 1.5),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 16, color: secondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          article.authorName?.trim().isNotEmpty == true
                              ? article.authorName!
                              : 'فريق صحتك',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.visibility_outlined, size: 16, color: secondary),
                      const SizedBox(width: 4),
                      Text(
                        _number(article.views),
                        style: TextStyle(
                          color: secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _number(int value) {
    if (value < 1000) return value.toString();
    if (value < 1000000) return (value / 1000).toStringAsFixed(1) + 'K';
    return (value / 1000000).toStringAsFixed(1) + 'M';
  }
}

class ArticleReaderScreen extends StatelessWidget {
  final ArticleModel article;

  const ArticleReaderScreen({
    super.key,
    required this.article,
  });

  String? get imageUrl {
    if (article.images != null) {
      for (final image in article.images!) {
        if (image.trim().isNotEmpty) return image;
      }
    }
    final image = article.imageUrl?.trim();
    return image == null || image.isEmpty ? null : image;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final text = dark ? Colors.white : const Color(0xFF173131);
    final body = dark ? Colors.white70 : const Color(0xFF263737);

    return Scaffold(
      backgroundColor: dark ? const Color(0xFF081A1A) : const Color(0xFFF6F9F9),
      appBar: CustomAppBar(
        title: 'المقال',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AppImage(
                  imageUrl: imageUrl!,
                  width: double.infinity,
                  height: 230,
                  fit: BoxFit.cover,
                ),
              ),
            if (imageUrl != null) const SizedBox(height: 16),
            if ((article.category ?? '').trim().isNotEmpty)
              Text(
                article.category!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            const SizedBox(height: 7),
            Text(
              article.title,
              style: TextStyle(
                color: text,
                fontSize: 24,
                height: 1.35,
                fontWeight: FontWeight.w900,
              ),
            ),
            if ((article.subtitle ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                article.subtitle!,
                style: TextStyle(color: body.withOpacity(.75), fontSize: 14, height: 1.6),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline_rounded, size: 17, color: body.withOpacity(.65)),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    article.authorName?.trim().isNotEmpty == true
                        ? article.authorName!
                        : 'فريق صحتك',
                    style: TextStyle(color: body.withOpacity(.65), fontSize: 12),
                  ),
                ),
                Text(
                  article.timeAgo,
                  style: TextStyle(color: body.withOpacity(.65), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF102A2A) : Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SelectableText(
                (article.content ?? article.summary ?? '').trim().isEmpty
                    ? 'لا يوجد محتوى متاح لهذا المقال حالياً.'
                    : (article.content ?? article.summary!).trim(),
                style: TextStyle(color: body, fontSize: 15, height: 1.85),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _Stat(icon: Icons.visibility_outlined, value: article.views, dark: dark),
                const SizedBox(width: 16),
                _Stat(icon: Icons.favorite_border_rounded, value: article.likes, dark: dark),
                const SizedBox(width: 16),
                _Stat(icon: Icons.share_outlined, value: article.shares, dark: dark),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final int value;
  final bool dark;

  const _Stat({
    required this.icon,
    required this.value,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: dark ? Colors.white60 : Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? action;
  final VoidCallback onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, height: 1.5),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onAction,
                child: Text(action!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
