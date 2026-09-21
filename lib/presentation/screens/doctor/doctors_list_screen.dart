import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/constants/app_assets.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/presentation/screens/shared/chat_navigation.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedSpecialty = 'الكل';

  final List<String> _specialties = const [
    'الكل',
    'باطنية',
    'قلبية',
    'أطفال',
    'نساء وولادة',
    'جلدية',
    'عظام',
    'نفسية',
    'أنف وأذن وحنجرة',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<DoctorBloc>().add(
        LoadDoctors(
          specialty: _selectedSpecialty,
        ),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startChatWithDoctor(
    DoctorModel doctor,
  ) async {
    await ChatNavigation.openChat(
      context,
      doctorName: doctor.name,
      doctorId: doctor.userId ?? '',
      doctorImage: doctor.photoUrl,
    );
  }

  void _startCallWithDoctor(
    DoctorModel doctor,
    bool isVideo,
  ) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ToastService.showError(
        '❌ يرجى تسجيل الدخول أولاً',
      );
      return;
    }

    final doctorUid = doctor.userId?.trim();

    if (doctorUid == null || doctorUid.isEmpty) {
      ToastService.showError(
        '❌ حساب الطبيب غير مرتبط بحساب المستخدم',
      );
      return;
    }

    if (doctorUid == user.uid) {
      ToastService.showError(
        '❌ لا يمكنك الاتصال بنفسك',
      );
      return;
    }

    final chatId =
        'call_${user.uid}_${doctorUid}_${DateTime.now().millisecondsSinceEpoch}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: chatId,
          doctorName: doctor.name,
          doctorId: doctorUid,
          isVideo: isVideo,
          isOutgoing: true,
        ),
      ),
    );
  }

  void _selectSpecialty(
    String specialty,
  ) {
    setState(() {
      _selectedSpecialty = specialty;
    });

    context.read<DoctorBloc>().add(
      FilterDoctors(
        specialty: specialty,
      ),
    );
  }

  void _searchDoctors(
    String value,
  ) {
    context.read<DoctorBloc>().add(
      SearchDoctors(
        query: value,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();

    context.read<DoctorBloc>().add(
      SearchDoctors(
        query: '',
      ),
    );

    setState(() {});
  }

  Future<void> _reloadDoctors() async {
    final bloc = context.read<DoctorBloc>();

    bloc.add(
      const RefreshDoctors(),
    );

    await bloc.stream.firstWhere(
      (state) =>
          state is DoctorLoaded ||
          state is DoctorError,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0B1121)
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'الأطباء',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(34))),
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildSpecialtiesFilter(isDark),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                if (state is DoctorLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                }

                if (state is DoctorError) {
                  return _buildErrorState(
                    isDark,
                    state.message,
                  );
                }

                if (state is DoctorLoaded) {
                  final doctors = state.doctors;

                  if (doctors.isEmpty) {
                    return _buildEmptyState(
                      isDark,
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: _reloadDoctors,
                    child: ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: doctors.length,
                      itemBuilder: (_, index) {
                        return _buildDoctorCard(
                          doctors[index],
                          isDark,
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: UnifiedSearchBar(
        controller: _searchController,
        onChanged: _searchDoctors,
        onClear: _clearSearch,
        hintText: 'ابحث عن طبيب...',
        isDark: isDark,
      ),
    );
  }

  Widget _buildSpecialtiesFilter(
    bool isDark,
  ) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemCount: _specialties.length,
        itemBuilder: (_, index) {
          final specialty =
              _specialties[index];

          final selected =
              specialty == _selectedSpecialty;

          return GestureDetector(
            onTap: () {
              _selectSpecialty(
                specialty,
              );
            },
            child: Container(
              margin:
                  const EdgeInsets.only(
                right: 8,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : isDark
                        ? const Color(
                            0xFF1A2540,
                          )
                        : Colors.grey.shade100,
                borderRadius:
                    BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                ),
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorCard(
    DoctorModel doctor,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DoctorDetailsScreen(doctorId: doctor.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: doctor.isAvailable ? Colors.green : Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final uid = doctor.userId?.trim();
                          if (uid == null || uid.isEmpty) {
                            ToastService.showError('حساب الطبيب غير مرتبط بملف شخصي');
                            return;
                          }
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(builder: (_) => PatientProfile(userId: uid)),
                          );
                        },
                        child: AppImage(
                          imageUrl: doctor.photoUrl ?? ImageKit.doctor1,
                          height: 52,
                          width: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        doctor.specialty,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 11, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '${doctor.rating ?? 0} (${doctor.reviewsCount ?? 0})',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 7),
                          _availabilityBadge(doctor),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${doctor.consultationFee ?? 0} ر.ي',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      if ((doctor.hospital ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          doctor.hospital!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9, color: isDark ? Colors.white54 : Colors.black45),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            _buildDoctorActions(doctor, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorActions(DoctorModel doctor, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _doctorAction(
            asset: AppAssets.chatBubble,
            label: 'دردشة',
            onTap: () => _startChatWithDoctor(doctor),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _doctorAction(
            asset: AppAssets.chatPhoneCall,
            label: 'اتصال',
            onTap: () => _startCallWithDoctor(doctor, false),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _doctorAction(
            asset: AppAssets.chatVideoCall,
            label: 'فيديو',
            onTap: () => _startCallWithDoctor(doctor, true),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _doctorAction({
    required String asset,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: isDark ? const Color(0xFF243252) : const Color(0xFFF4F7F8),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(asset, width: 18, height: 18, fit: BoxFit.contain),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _availabilityBadge(
    DoctorModel doctor,
  ) {
    final color =
        doctor.isAvailable
            ? Colors.green
            : Colors.red;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Text(
        doctor.isAvailable
            ? 'متاح'
            : 'غير متاح',
        style: TextStyle(
          fontSize: 9,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
  ) {
    final searching =
        _searchController.text
            .trim()
            .isNotEmpty;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              searching
                  ? Icons.search_off
                  : Icons.medical_services_outlined,
              size: 60,
              color: isDark
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              searching
                  ? 'لا توجد نتائج'
                  : 'لا يوجد أطباء متاحون',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              searching
                  ? 'لم يتم العثور على طبيب يطابق البحث'
                  : 'سيظهر الأطباء المعتمدون هنا عند توفرهم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    bool isDark,
    String message,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'تعذر تحميل الأطباء',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
                color: isDark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow:
                  TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _reloadDoctors,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    AppColors.primary,
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
