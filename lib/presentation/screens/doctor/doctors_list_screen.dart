import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  String _selectedSpecialty = 'الكل';
  bool _isGridView = false;
  bool _showOnlyAvailable = false;

  final List<String> _specialties = [
    'الكل',
    'باطنية',
    'قلبية',
    'أطفال',
    'نساء وولادة',
    'جلدية',
    'عظام',
    'نفسية',
    'أنف وأذن وحنجرة',
    'أسنان',
    'عيون',
    'جراحة عامة',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DoctorBloc>().add(LoadDoctors());
  }

  // ✅ بدء محادثة مع الطبيب
  Future<void> _startChatWithDoctor(DoctorModel doctor) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
        return;
      }

      final chatId = await _chatService.createChat(
        doctorId: doctor.id,
        doctorName: doctor.name,
        patientName: user.displayName ?? 'مريض',
      );

      if (chatId.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              chatId: chatId,
              otherUserId: doctor.id,
              otherUserName: doctor.name,
              isGroup: false,
            ),
          ),
        );
      }
    } catch (e) {
      ToastService.showError('❌ فشل بدء المحادثة: $e');
    }
  }

  // ✅ بدء مكالمة مع الطبيب
  void _startCallWithDoctor(DoctorModel doctor, bool isVideo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
          doctorName: doctor.name,
          doctorId: doctor.id,
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('الأطباء'),
        backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showOnlyAvailable ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showOnlyAvailable = !_showOnlyAvailable),
            tooltip: _showOnlyAvailable ? 'عرض الكل' : 'عرض المتاحين فقط',
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          _buildSpecialtiesFilter(isDark),
          Expanded(
            child: BlocBuilder<DoctorBloc, DoctorState>(
              builder: (context, state) {
                if (state is DoctorLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (state is DoctorError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<DoctorBloc>().add(LoadDoctors());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DoctorLoaded) {
                  final doctors = state.doctors;
                  if (doctors.isEmpty) {
                    return _buildEmptyState(isDark);
                  }
                  return _isGridView
                      ? _buildGridView(doctors, isDark)
                      : _buildListView(doctors, isDark);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧩 ويدجت البحث
  // ============================================================
  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A2540) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن طبيب...',
                border: InputBorder.none,
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              onChanged: (value) {
                context.read<DoctorBloc>().add(SearchDoctors(query: value));
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              onPressed: () {
                _searchController.clear();
                context.read<DoctorBloc>().add(SearchDoctors(query: ''));
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏷️ فلتر التخصصات
  // ============================================================
  Widget _buildSpecialtiesFilter(bool isDark) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _specialties.length,
        itemBuilder: (context, index) {
          final specialty = _specialties[index];
          final isSelected = _selectedSpecialty == specialty;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSpecialty = specialty);
              context.read<DoctorBloc>().add(
                // DoctorEventFilter(specialty: specialty),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFF1A2540) : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                ),
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // 📋 عرض القائمة
  // ============================================================
  Widget _buildListView(List<DoctorModel> doctors, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildDoctorCard(doctor, isDark);
      },
    );
  }

  // ============================================================
  // 📊 عرض الشبكة
  // ============================================================
  Widget _buildGridView(List<DoctorModel> doctors, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildDoctorGridCard(doctor, isDark);
      },
    );
  }

  // ============================================================
  // 🃏 بطاقة الطبيب (قائمة) - مع أزرار الدردشة والمكالمات
  // ============================================================
  Widget _buildDoctorCard(DoctorModel doctor, bool isDark) {
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ✅ صورة الطبيب
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: doctor.isAvailable ? Colors.green : Colors.grey,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: AppImage(
                  imageUrl: doctor.photoUrl ?? ImageKit.doctor1,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ المعلومات
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.rating ?? 0}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${doctor.reviewsCount ?? 0})',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: doctor.isAvailable
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          doctor.isAvailable ? 'متاح' : 'غير متاح',
                          style: TextStyle(
                            fontSize: 9,
                            color: doctor.isAvailable ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.consultationFee ?? 0} ر.ي',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (doctor.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'متصل',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // ✅ أزرار الدردشة والمكالمات
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chat, color: AppColors.primary),
                  onPressed: () => _startChatWithDoctor(doctor),
                  tooltip: 'دردشة',
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.phone, color: AppColors.primary),
                  onPressed: () => _startCallWithDoctor(doctor, false),
                  tooltip: 'مكالمة صوتية',
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: AppColors.primary),
                  onPressed: () => _startCallWithDoctor(doctor, true),
                  tooltip: 'مكالمة فيديو',
                  iconSize: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🃏 بطاقة الطبيب (شبكة)
  // ============================================================
  Widget _buildDoctorGridCard(DoctorModel doctor, bool isDark) {
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
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2540) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صورة الطبيب
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AppImage(
                    imageUrl: doctor.photoUrl ?? ImageKit.doctor1,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 10),
                        const SizedBox(width: 2),
                        Text(
                          '${doctor.rating ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: doctor.isAvailable
                          ? Colors.green.withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doctor.isAvailable ? 'متاح' : 'غير متاح',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ),
                if (doctor.isOnline)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'متصل',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.specialty,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.payments, size: 12, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.consultationFee ?? 0} ر.ي',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _startChatWithDoctor(doctor),
                          icon: const Icon(Icons.chat, size: 14),
                          label: const Text('دردشة', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _startCallWithDoctor(doctor, false),
                          icon: const Icon(Icons.phone, size: 14),
                          label: const Text('اتصال', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            minimumSize: const Size(0, 28),
                          ),
                        ),
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

  // ============================================================
  // 📭 حالة فارغة
  // ============================================================
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على أطباء تطابق بحثك',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
