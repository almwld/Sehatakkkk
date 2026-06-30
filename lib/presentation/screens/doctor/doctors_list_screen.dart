import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/presentation/bloc/doctor_bloc/doctor_bloc.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedSpecialty = 'الكل';
  String _sortBy = 'التقييم';
  bool _showAvailableOnly = false;

  final List<Map<String, String>> _specialties = const [
    {'icon': '🫀', 'name': 'الكل'},
    {'icon': '👨‍⚕️', 'name': 'عام'},
    {'icon': '🫀', 'name': 'قلب'},
    {'icon': '🫁', 'name': 'صدرية'},
    {'icon': '🧠', 'name': 'أعصاب'},
    {'icon': '🦴', 'name': 'عظام'},
    {'icon': '👶', 'name': 'أطفال'},
    {'icon': '👩‍🦰', 'name': 'جلدية'},
    {'icon': '👁️', 'name': 'عيون'},
    {'icon': '🦷', 'name': 'أسنان'},
    {'icon': '🧘', 'name': 'نفسية'},
    {'icon': '🤰', 'name': 'نسائية'},
    {'icon': '🩺', 'name': 'أنف وأذن'},
    {'icon': '📊', 'name': 'أشعة'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<DoctorBloc>().add(LoadDoctors());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'الأطباء',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _showSortSheet(context),
          ),
          IconButton(
            icon: Icon(
              _showAvailableOnly ? Icons.filter_alt_rounded : Icons.filter_alt_outlined,
              color: _showAvailableOnly ? AppColors.primary : Colors.white,
            ),
            onPressed: () => setState(() => _showAvailableOnly = !_showAvailableOnly),
          ),
        ],
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DoctorErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 60, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<DoctorBloc>().add(LoadDoctors()),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is DoctorLoadedState) {
            final doctors = _filterDoctors(state.doctors);
            return Column(
              children: [
                _buildSearchBar(isDark),
                _buildSpecialties(isDark),
                _buildStats(doctors.length),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: doctors.length,
                    itemBuilder: (_, i) => _buildDoctorCard(doctors[i], isDark, context),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterDoctors(List<Map<String, dynamic>> doctors) {
    var list = doctors;
    if (_selectedSpecialty != 'الكل') {
      list = list.where((d) => d['specialty'] == _selectedSpecialty).toList();
    }
    if (_showAvailableOnly) {
      list = list.where((d) => d['available'] == true).toList();
    }
    if (_searchCtrl.text.isNotEmpty) {
      final q = _searchCtrl.text.toLowerCase();
      list = list.where((d) => d['name'].toLowerCase().contains(q) || d['specialty'].toLowerCase().contains(q)).toList();
    }
    if (_sortBy == 'التقييم') {
      list.sort((a, b) => (b['rating'] as double).compareTo(a['rating']));
    }
    if (_sortBy == 'السعر') {
      list.sort((a, b) => int.parse(a['fee'].toString()).compareTo(int.parse(b['fee'].toString())));
    }
    return list;
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (_) => setState(() {}),
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن طبيب...',
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.grey),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () {
                      _searchCtrl.clear();
                      setState(() {});
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialties(bool isDark) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _specialties.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (c, i) {
          final s = _specialties[i];
          final sel = _selectedSpecialty == s['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedSpecialty = s['name']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: sel ? Border.all(color: AppColors.primary) : Border.all(color: Colors.grey.shade200),
                boxShadow: sel ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8)] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s['icon']!, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    s['name']!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Text('$count طبيب', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Row(
              children: [
                Text('ترتيب: $_sortBy', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                const SizedBox(width: 4),
                const Icon(Icons.swap_vert_rounded, size: 16, color: AppColors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> d, bool isDark, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
        border: Border.all(color: isDark ? const Color(0xFF2D3A54) : Colors.transparent),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: d['photoUrl'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(d['name'])}&background=00796B&color=fff',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.8), AppColors.primaryDark.withOpacity(0.9)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        d['name'][0] + d['name'][d['name'].length - 2],
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              if (d['online'] == true)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(d['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    if (d['available'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('متاح', style: TextStyle(fontSize: 9, color: AppColors.success)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${d['subspecialty'] ?? d['specialty']} • ${d['experience'] ?? '0'}+ سنة', style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _starRow((d['rating'] ?? 0).toDouble()),
                    const SizedBox(width: 4),
                    Text('${d['reviews'] ?? 0} تقييم', style: const TextStyle(fontSize: 10, color: AppColors.darkGrey)),
                    const SizedBox(width: 10),
                    const Icon(Icons.people_rounded, size: 12, color: AppColors.grey),
                    const SizedBox(width: 2),
                    Text(d['patients'] ?? '0', style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                    const Spacer(),
                    Text('${d['fee'] ?? 0} ر.ي', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: () => ChatNavigation.openChat(context, doctorName: d['name'], doctorId: d['id']),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.chat_rounded, color: AppColors.info, size: 18),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DoctorDetailsScreen(doctorId: d['id']))),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating.floor() ? Icons.star_rounded : (rating - i > 0 ? Icons.star_half_rounded : Icons.star_border_rounded),
        color: AppColors.amber,
        size: 14,
      )),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('ترتيب حسب', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('التقييم (الأعلى)'),
              leading: const Icon(Icons.star_rounded, color: AppColors.amber),
              trailing: _sortBy == 'التقييم' ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _sortBy = 'التقييم');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('السعر (الأقل)'),
              leading: const Icon(Icons.attach_money_rounded, color: AppColors.success),
              trailing: _sortBy == 'السعر' ? const Icon(Icons.check_rounded, color: AppColors.primary) : null,
              onTap: () {
                setState(() => _sortBy = 'السعر');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
