import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/home/home_bloc.dart';
import 'package:sehatak/bloc/home/home_event.dart';
import 'package:sehatak/bloc/home/home_state.dart';

import 'package:sehatak/presentation/screens/home/widgets/banner_carousel.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_header.dart';
import 'package:sehatak/presentation/screens/home/widgets/home_health_score.dart';

import 'package:sehatak/core/constants/app_colors.dart';

class HomeTab extends StatefulWidget {
  final ScrollController scrollController;

  const HomeTab({
    super.key,
    required this.scrollController,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  Timer? _loadTimer;

  @override
  void initState() {
    super.initState();

    /*
     * Home تظهر فوراً.
     *
     * جلب البيانات يبدأ لاحقاً حتى لا تصبح Firebase شرطاً
     * لظهور الواجهة الأولى.
     */
    _loadTimer = Timer(const Duration(seconds: 20), () {
      if (!mounted) return;

      try {
        context.read<HomeBloc>().add(const HomeStarted());
      } catch (e) {
        debugPrint('Home background loading unavailable: $e');
      }
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            try {
              context.read<HomeBloc>().add(
                    const HomeDataRefreshed(),
                  );
            } catch (e) {
              debugPrint('Home refresh unavailable: $e');
            }
          },
          child: ListView(
            controller: widget.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              top: 8,
              bottom: 32,
            ),
            children: [
              HomeHeader(
                userName: state.userName,
                isLoggedIn: state.isLoggedIn,
              ),

              const SizedBox(height: 8),

              _buildSearch(context, isDark),

              const SizedBox(height: 14),

              _buildBanner(state),

              const SizedBox(height: 18),

              _buildQuickServices(context, isDark),

              const SizedBox(height: 18),

              _buildHealthScore(state, isDark),

              const SizedBox(height: 18),

              _buildHealthStats(state, isDark),

              const SizedBox(height: 22),

              _buildDoctorsSection(state, isDark),

              const SizedBox(height: 22),

              _buildCommunitySection(state, isDark),

              const SizedBox(height: 22),

              _buildTipsSection(state, isDark),

              const SizedBox(height: 22),

              _buildProductsSection(state, isDark),

              const SizedBox(height: 22),

              _buildPlacesSection(
                title: 'المستشفيات',
                icon: Icons.local_hospital_outlined,
                items: state.hospitals,
                isDark: isDark,
              ),

              const SizedBox(height: 22),

              _buildPlacesSection(
                title: 'المختبرات والصيدليات',
                icon: Icons.medical_services_outlined,
                items: [
                  ...state.labs,
                  ...state.pharmacies,
                ],
                isDark: isDark,
              ),

              if (state.isLoading)
                _buildLoadingIndicator(isDark),

              if (state.hasError)
                _buildErrorMessage(
                  state.errorMessage,
                  isDark,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearch(
    BuildContext context,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white10
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(
              Icons.search_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ابحث عن طبيب، خدمة أو دواء',
                style: TextStyle(
                  color: isDark
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(
              Icons.tune_rounded,
              color: isDark
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(HomeState state) {
    if (state.bannerImages.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: BannerCarousel(
        images: state.bannerImages,
        height: 165,
        autoPlay: true,
      ),
    );
  }

  Widget _buildQuickServices(
    BuildContext context,
    bool isDark,
  ) {
    final services = <Map<String, dynamic>>[
      {
        'icon': Icons.medical_services_outlined,
        'title': 'الأطباء',
      },
      {
        'icon': Icons.local_pharmacy_outlined,
        'title': 'الصيدلية',
      },
      {
        'icon': Icons.biotech_outlined,
        'title': 'المختبرات',
      },
      {
        'icon': Icons.local_hospital_outlined,
        'title': 'المستشفيات',
      },
      {
        'icon': Icons.emergency_outlined,
        'title': 'الطوارئ',
      },
      {
        'icon': Icons.bloodtype_outlined,
        'title': 'التبرع بالدم',
      },
      {
        'icon': Icons.calendar_month_outlined,
        'title': 'المواعيد',
      },
      {
        'icon': Icons.health_and_safety_outlined,
        'title': 'صحتي',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'خدمات سريعة',
          isDark,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final service = services[index];

              return Container(
                width: 82,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Icon(
                        service['icon'] as IconData,
                        color: AppColors.primary,
                        size: 25,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      service['title'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHealthScore(
    HomeState state,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HomeHealthScore(
        score: state.isLoaded ? 75 : 0,
        isDark: isDark,
      ),
    );
  }

  Widget _buildHealthStats(
    HomeState state,
    bool isDark,
  ) {
    final stats = <Map<String, dynamic>>[
      {
        'icon': Icons.local_fire_department_outlined,
        'label': 'السعرات',
        'value': state.calories,
        'unit': 'kcal',
      },
      {
        'icon': Icons.directions_walk_outlined,
        'label': 'الخطوات',
        'value': state.steps,
        'unit': 'خطوة',
      },
      {
        'icon': Icons.bedtime_outlined,
        'label': 'النوم',
        'value': state.sleep,
        'unit': 'ساعة',
      },
      {
        'icon': Icons.favorite_outline,
        'label': 'النبض',
        'value': state.heartRate,
        'unit': 'bpm',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'مؤشراتك الصحية',
          isDark,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemBuilder: (context, index) {
              final item = stats[index];

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: AppColors.primary,
                      size: 25,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatNumber(item['value'] as double)} ${item['unit']}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorsSection(
    HomeState state,
    bool isDark,
  ) {
    if (state.doctors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'أفضل الأطباء',
          isDark,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.doctors.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doctor = state.doctors[index];

              final name =
                  _stringValue(doctor, 'name', 'طبيب');
              final specialty =
                  _stringValue(
                    doctor,
                    'specialty',
                    'تخصص طبي',
                  );
              final image =
                  _stringValueNullable(
                    doctor,
                    'image',
                  ) ??
                  _stringValueNullable(
                    doctor,
                    'photoUrl',
                  );

              return Container(
                width: 145,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor:
                          AppColors.primary.withOpacity(0.10),
                      backgroundImage:
                          image != null &&
                                  image.isNotEmpty
                              ? NetworkImage(image)
                              : null,
                      child:
                          image == null || image.isEmpty
                              ? Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 36,
                                )
                              : null,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitySection(
    HomeState state,
    bool isDark,
  ) {
    if (state.communityPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'المجتمع الصحي',
          isDark,
        ),
        const SizedBox(height: 12),
        ...state.communityPosts.take(3).map(
          (post) => _buildPostCard(
            post,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(
    Map<String, dynamic> post,
    bool isDark,
  ) {
    final name = _stringValue(
      post,
      'authorName',
      _stringValue(post, 'name', 'مستخدم'),
    );

    final text = _stringValue(
      post,
      'text',
      _stringValue(
        post,
        'content',
        '',
      ),
    );

    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white10
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor:
                    AppColors.primary.withOpacity(0.10),
                child: Icon(
                  Icons.person_outline,
                  color: AppColors.primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark
                  ? Colors.grey.shade200
                  : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(
    HomeState state,
    bool isDark,
  ) {
    if (state.tips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          'نصائح صحية',
          isDark,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: state.tips.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final tip = state.tips[index];

              final title = _stringValue(
                tip,
                'title',
                'نصيحة صحية',
              );

              final text = _stringValue(
                tip,
                'text',
                _stringValue(
                  tip,
                  'content',
                  '',
                ),
              );

              return Container(
                width: 260,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color:
                      AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        AppColors.primary.withOpacity(0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(
    HomeState state,
    bool isDark,
  ) {
    /*
     * HomeState الحالية لا تحتوي products.
     *
     * لذلك لا نضيف بيانات وهمية هنا.
     * سيظهر القسم تلقائياً عندما يتم ربط ProductRepository
     * الحقيقي بالـ HomeState.
     */
    return const SizedBox.shrink();
  }

  Widget _buildPlacesSection({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required bool isDark,
  }) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title,
          isDark,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 112,
          child: ListView.separated(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              final name = _stringValue(
                item,
                'name',
                title,
              );

              final address = _stringValue(
                item,
                'address',
                _stringValue(
                  item,
                  'location',
                  '',
                ),
              );

              return Container(
                width: 220,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white10
                        : Colors.grey.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                      child: Icon(
                        icon,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              address,
                              maxLines: 2,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(
    String title,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDark
              ? Colors.white
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(bool isDark) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage(
    String? message,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تعذر تحديث بعض بيانات الصفحة. يمكنك متابعة استخدام التطبيق.',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.grey.shade300
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _stringValue(
    Map<String, dynamic> data,
    String key,
    String fallback,
  ) {
    final value = data[key];

    if (value == null) return fallback;

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  String? _stringValueNullable(
    Map<String, dynamic> data,
    String key,
  ) {
    final value = data[key];

    if (value == null) return null;

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  String _formatNumber(double value) {
    if (value == 0) return '—';

    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}
