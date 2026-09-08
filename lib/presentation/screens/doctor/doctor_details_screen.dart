import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/booking/booking_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;

  const DoctorDetailsScreen({super.key, required this.doctorId});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();

  DoctorModel? _doctor;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _busy = false;
  int _selectedTab = 0;

  static const _tabs = ['المعلومات', 'المواعيد', 'التقييمات'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (Firebase.apps.isEmpty) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastService.showError('❌ خدمة Firebase غير جاهزة');
      }
      return;
    }

    try {
      final results = await Future.wait([
        _firestore.collection('doctors').doc(widget.doctorId).get(),
        _loadFavoriteState(),
      ]);

      final doctorDoc = results.first as DocumentSnapshot<Map<String, dynamic>>;
      if (!mounted) return;

      if (!doctorDoc.exists || doctorDoc.data() == null) {
        setState(() => _isLoading = false);
        ToastService.showError('❌ الطبيب غير موجود');
        return;
      }

      final doctor = DoctorModel.fromFirestore(doctorDoc.id, doctorDoc.data()!);
      if (doctor.isVerified != true) {
        setState(() => _isLoading = false);
        ToastService.showError('❌ الطبيب غير متاح');
        return;
      }

      setState(() {
        _doctor = doctor;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ToastService.showError('❌ فشل تحميل بيانات الطبيب');
    }
  }

  Future<void> _loadFavoriteState() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .doc(widget.doctorId)
          .get();
      if (mounted) setState(() => _isFavorite = doc.exists);
    } catch (_) {}
  }

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return;
    }

    final ref = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(widget.doctorId);

    try {
      if (_isFavorite) {
        await ref.delete();
        if (mounted) setState(() => _isFavorite = false);
        ToastService.showInfo('تمت إزالة الطبيب من المفضلة');
      } else {
        await ref.set({
          'doctorId': widget.doctorId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) setState(() => _isFavorite = true);
        ToastService.showSuccess('تمت إضافة الطبيب إلى المفضلة');
      }
    } catch (_) {
      ToastService.showError('❌ تعذر تحديث المفضلة');
    }
  }

  Future<String?> _ensureChat() async {
    final user = _auth.currentUser;
    final doctor = _doctor;
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return null;
    }
    if (doctor == null) return null;

    final doctorUid = doctor.userId?.trim();
    if (doctorUid == null || doctorUid.isEmpty) {
      ToastService.showError('❌ حساب الطبيب غير مرتبط بحساب المستخدم');
      return null;
    }
    if (doctorUid == user.uid) {
      ToastService.showError('❌ لا يمكنك التواصل مع حسابك');
      return null;
    }

    return _chatService.createChat(
      doctorId: doctorUid,
      doctorName: doctor.name,
      patientName: user.displayName ?? 'مريض',
      doctorImage: doctor.photoUrl,
    );
  }

  Future<void> _openChat() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final chatId = await _ensureChat();
      final doctor = _doctor;
      if (!mounted || chatId == null || chatId.isEmpty || doctor == null) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            otherUserId: doctor.userId!,
            otherUserName: doctor.name,
            isGroup: false,
          ),
        ),
      );
    } catch (e) {
      if (mounted) ToastService.showError('❌ تعذر فتح الدردشة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startCall({required bool video}) async {
    if (_busy) return;
    final doctor = _doctor;
    if (doctor == null) return;

    final user = _auth.currentUser;
    final doctorUid = doctor.userId?.trim();
    if (user == null) {
      ToastService.showError('❌ يرجى تسجيل الدخول أولاً');
      return;
    }
    if (doctorUid == null || doctorUid.isEmpty) {
      ToastService.showError('❌ حساب الطبيب غير مرتبط بحساب المستخدم');
      return;
    }
    if (doctorUid == user.uid) {
      ToastService.showError('❌ لا يمكنك الاتصال بنفسك');
      return;
    }

    setState(() => _busy = true);
    try {
      final chatId = await _ensureChat();
      if (chatId == null || chatId.isEmpty) return;

      final call = await _callService.initiateCall(
        receiverId: doctorUid,
        receiverName: doctor.name,
        receiverPhotoUrl: doctor.photoUrl,
        type: video ? CallType.video : CallType.audio,
        chatId: chatId,
      );

      if (!mounted || call == null || call.id.isEmpty) {
        if (mounted) ToastService.showError('❌ تعذر إنشاء المكالمة');
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: doctor.name,
            doctorId: doctorUid,
            isVideo: video,
            callId: call.id,
            isOutgoing: true,
          ),
        ),
      );
    } catch (e) {
      if (mounted) ToastService.showError('❌ تعذر بدء المكالمة');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _bookAppointment() {
    final doctor = _doctor;
    if (doctor == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen(doctorId: doctor.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? const Color(0xFF0B1121) : const Color(0xFFF6F9FA);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: bg,
        appBar: _appBar(dark),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final doctor = _doctor;
    if (doctor == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: _appBar(dark, title: 'غير موجود'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_off_outlined, size: 64, color: dark ? Colors.white54 : Colors.black26),
                const SizedBox(height: 12),
                Text('تعذر العثور على الطبيب', style: TextStyle(color: dark ? Colors.white : Colors.black87, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: _appBar(dark),
      body: RefreshIndicator(
        onRefresh: _load,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            children: [
              _buildProfileCard(doctor, dark),
              const SizedBox(height: 14),
              _buildQuickActions(dark),
              const SizedBox(height: 18),
              _buildTabs(dark),
              const SizedBox(height: 14),
              _buildTabContent(doctor, dark),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(bool dark, {String title = 'تفاصيل الطبيب'}) {
    return AppBar(
      backgroundColor: dark ? const Color(0xFF0B1121) : Colors.white,
      foregroundColor: dark ? Colors.white : const Color(0xFF263238),
      elevation: 0,
      centerTitle: true,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      actions: [
        IconButton(
          tooltip: _isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
          onPressed: _doctor == null ? null : _toggleFavorite,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(_isFavorite),
              color: _isFavorite ? Colors.red : (dark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(DoctorModel doctor, bool dark) {
    final image = (doctor.photoUrl ?? '').trim().isNotEmpty ? doctor.photoUrl! : ImageKit.doctor1;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF162039) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withOpacity(.10)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 18, offset: const Offset(0, 7))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
            child: ClipOval(child: AppImage(imageUrl: image, width: 82, height: 82, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(doctor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: dark ? Colors.white : const Color(0xFF263238)))),
                    if (doctor.isVerified == true) const Padding(padding: EdgeInsetsDirectional.only(start: 5), child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 19)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(doctor.specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, color: dark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.w600)),
                const SizedBox(height: 9),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _badge(Icons.star_rounded, '${doctor.rating ?? 0}', Colors.amber, dark),
                    _badge(Icons.work_history_outlined, '${doctor.experienceYears ?? 0} سنة', AppColors.primary, dark),
                    _badge(doctor.isAvailable ? Icons.circle : Icons.remove_circle_outline, doctor.isAvailable ? 'متاح' : 'غير متاح', doctor.isAvailable ? Colors.green : Colors.grey, dark),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text, Color color, bool dark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: dark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _action(icon: Icons.chat_bubble_rounded, label: 'دردشة', hint: 'محادثة مباشرة', color: AppColors.primary, onTap: _openChat, dark: dark),
          _action(icon: Icons.call_rounded, label: 'اتصال', hint: 'مكالمة صوتية', color: const Color(0xFF2E9B5F), onTap: () => _startCall(video: false), dark: dark),
          _action(icon: Icons.videocam_rounded, label: 'فيديو', hint: 'استشارة مرئية', color: const Color(0xFF3976D8), onTap: () => _startCall(video: true), dark: dark),
          _action(icon: Icons.calendar_month_rounded, label: 'حجز', hint: 'موعد الطبيب', color: const Color(0xFFE58A22), onTap: _bookAppointment, dark: dark),
        ],
      ),
    );
  }

  Widget _action({required IconData icon, required String label, required String hint, required Color color, required VoidCallback onTap, required bool dark}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _busy ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF162039) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(.17)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(color: color.withOpacity(.10), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 23),
                  ),
                  const SizedBox(height: 7),
                  Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87)),
                  const SizedBox(height: 2),
                  Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 8, color: dark ? Colors.white54 : Colors.black45)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs(bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: dark ? const Color(0xFF162039) : const Color(0xFFEFF3F4), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final selected = index == _selectedTab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(color: selected ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(_tabs[index], style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: selected ? Colors.white : (dark ? Colors.white60 : Colors.black54)))),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabContent(DoctorModel doctor, bool dark) {
    switch (_selectedTab) {
      case 1:
        return _appointmentsTab(dark);
      case 2:
        return _reviewsTab(doctor, dark);
      default:
        return _infoTab(doctor, dark);
    }
  }

  Widget _infoTab(DoctorModel doctor, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((doctor.about ?? '').trim().isNotEmpty) ...[
            _sectionTitle('نبذة عن الطبيب', Icons.person_outline_rounded, dark),
            _card(dark, Padding(padding: const EdgeInsets.all(16), child: Text(doctor.about!, style: TextStyle(height: 1.65, fontSize: 13, color: dark ? Colors.white70 : Colors.black54)))),
            const SizedBox(height: 14),
          ],
          _sectionTitle('المعلومات المهنية', Icons.badge_outlined, dark),
          _card(dark, Column(children: [
            _infoRow(Icons.medical_services_outlined, 'التخصص', doctor.specialty, dark),
            _infoRow(Icons.workspace_premium_outlined, 'الخبرة', '${doctor.experienceYears ?? 0} سنة', dark),
            _infoRow(Icons.payments_outlined, 'رسوم الكشف', '${doctor.consultationFee ?? 0} ر.ي', dark),
            if ((doctor.hospital ?? '').isNotEmpty) _infoRow(Icons.local_hospital_outlined, 'المستشفى', doctor.hospital!, dark),
            if ((doctor.clinicAddress ?? '').isNotEmpty) _infoRow(Icons.location_on_outlined, 'العنوان', doctor.clinicAddress!, dark),
          ])),
          const SizedBox(height: 14),
          _sectionTitle('إجراءات سريعة', Icons.flash_on_rounded, dark),
          _card(dark, Column(children: [
            _listAction(Icons.chat_bubble_outline_rounded, 'فتح الدردشة', 'تواصل مباشرة مع الطبيب', _openChat, dark),
            _listAction(Icons.calendar_month_outlined, 'حجز موعد', 'اختر الموعد المناسب لك', _bookAppointment, dark),
            _listAction(Icons.call_outlined, 'مكالمة صوتية', 'بدء استشارة صوتية', () => _startCall(video: false), dark),
            _listAction(Icons.videocam_outlined, 'مكالمة مرئية', 'بدء استشارة بالفيديو', () => _startCall(video: true), dark),
          ])),
        ],
      ),
    );
  }

  Widget _appointmentsTab(bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _card(dark, Column(children: [
        const SizedBox(height: 4),
        Icon(Icons.calendar_month_rounded, size: 48, color: AppColors.primary.withOpacity(.75)),
        const SizedBox(height: 10),
        Text('احجز موعدك مع الطبيب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87)),
        const SizedBox(height: 6),
        Text('انتقل إلى شاشة الحجز لاختيار التاريخ والوقت والخدمة.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54)),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _bookAppointment, icon: const Icon(Icons.event_available_rounded), label: const Text('حجز موعد الآن'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
      ])),
    );
  }

  Widget _reviewsTab(DoctorModel doctor, bool dark) {
    final rating = (doctor.rating ?? 0).toDouble();
    final count = doctor.reviewsCount ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _card(dark, Column(children: [
        Row(children: [
          Container(width: 76, height: 76, decoration: BoxDecoration(color: Colors.amber.withOpacity(.10), shape: BoxShape.circle), child: Center(child: Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.amber)))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('التقييم العام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87)),
            const SizedBox(height: 5),
            Row(children: List.generate(5, (i) => Icon(i < rating.round() ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 18))),
            const SizedBox(height: 4),
            Text('$count تقييم', style: TextStyle(fontSize: 12, color: dark ? Colors.white60 : Colors.black54)),
          ])),
        ]),
        const SizedBox(height: 18),
        Container(width: double.infinity, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: dark ? Colors.white.withOpacity(.035) : const Color(0xFFF7F9FA), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text('ستظهر التقييمات المكتملة من المرضى هنا عند توفرها.', style: TextStyle(fontSize: 11, color: dark ? Colors.white60 : Colors.black54)))])),
      ])),
    );
  }

  Widget _sectionTitle(String title, IconData icon, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [Icon(icon, size: 19, color: AppColors.primary), const SizedBox(width: 7), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: dark ? Colors.white : Colors.black87))]),
    );
  }

  Widget _card(bool dark, Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: dark ? const Color(0xFF162039) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: dark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035))),
      child: child,
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool dark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.primary)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 10, color: dark ? Colors.white45 : Colors.black45)), const SizedBox(height: 2), Text(value, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dark ? Colors.white : Colors.black87))]))]),
    );
  }

  Widget _listAction(IconData icon, String title, String subtitle, VoidCallback onTap, bool dark) {
    return InkWell(
      onTap: _busy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(11)), child: Icon(icon, color: AppColors.primary, size: 20)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: dark ? Colors.white : Colors.black87)), const SizedBox(height: 2), Text(subtitle, style: TextStyle(fontSize: 10, color: dark ? Colors.white45 : Colors.black45))])), const Icon(Icons.chevron_left_rounded, size: 20, color: Colors.grey)]),
      ),
    );
  }
}
