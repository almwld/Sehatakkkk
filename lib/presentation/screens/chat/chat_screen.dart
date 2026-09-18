import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/chat/add_status_screen.dart';
import 'package:sehatak/presentation/screens/chat/calls_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/screens/patient/patient_profile.dart';
import 'package:sehatak/presentation/widgets/status_row.dart';
import 'package:sehatak/presentation/widgets/health_contacts_section.dart';
import 'package:sehatak/presentation/widgets/common/unified_search_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final StatusService _statusService = StatusService();
  final TextEditingController _searchController = TextEditingController();
  final PageController _tabPageController = PageController();
  StreamSubscription<List<ChatModel>>? _subscription;
  StreamSubscription<List<UserStatusModel>>? _statusSubscription;
  List<ChatModel> _chats = [];
  List<UserStatusModel> _statuses = [];
  String _search = '';
  bool _loadingChats = true;
  bool _openingChat = false;
  bool _loadingStatuses = true;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _subscribeChats();
    _subscribeStatuses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DoctorBloc>().add(const LoadDoctors());
    });
  }

  void _onSearchChanged() {
    if (mounted) {
      setState(() => _search = _searchController.text.trim().toLowerCase());
    }
  }

  void _subscribeChats() {
    try {
      _subscription = _chatService.streamChats().listen(
        (items) {
          if (!mounted) return;
          setState(() {
            _chats = items;
            _loadingChats = false;
          });
        },
        onError: (error) {
          debugPrint('chat list error: $error');
          if (mounted) setState(() => _loadingChats = false);
        },
      );
    } catch (error) {
      debugPrint('chat subscription error: $error');
      _loadingChats = false;
    }
  }

  void _subscribeStatuses() {
    try {
      _statusSubscription = _statusService.streamActiveStatuses().listen(
        (items) {
          if (!mounted) return;
          setState(() {
            _statuses = items;
            _loadingStatuses = false;
          });
        },
        onError: (error) {
          debugPrint('status list error: $error');
          if (mounted) setState(() => _loadingStatuses = false);
        },
      );
    } catch (error) {
      debugPrint('status subscription error: $error');
      _loadingStatuses = false;
    }
  }

  void _selectTab(int index) {
    if (index < 0 || index > 2 || index == _tabIndex) return;
    setState(() => _tabIndex = index);
    if (_tabPageController.hasClients) {
      _tabPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onTabPageChanged(int index) {
    if (mounted && _tabIndex != index) {
      setState(() => _tabIndex = index);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _statusSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabPageController.dispose();
    super.dispose();
  }

  List<ChatModel> get _filteredChats {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (_search.isEmpty) return _chats;
    return _chats.where((chat) {
      return chat.getDisplayName(uid).toLowerCase().contains(_search) ||
          (chat.lastMessage ?? '').toLowerCase().contains(_search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text('الدردشة'),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: _buildTabs(isDark),
        ),
      ),
      body: PageView(
        controller: _tabPageController,
        onPageChanged: _onTabPageChanged,
        children: [
          _buildConversationsTab(isDark),
          const CallsScreen(),
          _buildContactsTab(isDark),
        ],
      ),
    );
  }

  Widget _buildTabs(bool isDark) {
    const labels = ['المحادثات', 'المكالمات', 'تواصل صحي'];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162039) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE6EEEE)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _tabIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _selectTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF526467)),
                    ),
                    child: Text(labels[index]),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConversationsTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: UnifiedSearchBar(controller: _searchController, hintText: 'ابحث في محادثاتك...'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: _buildAIAssistantCard(isDark),
        ),
        Expanded(child: _buildChatList(isDark)),
      ],
    );
  }

  Widget _buildAIAssistantCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Padding(padding: const EdgeInsetsDirectional.only(start: 4), child: Image.asset('assets/images/services/ai_assistant.png', width: 42, height: 42, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 30))),
        title: const Text('المساعد الصحي الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('اسأل الآن عن صحتك'),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen())),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    if (_loadingChats) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    final chats = _filteredChats;
    if (chats.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'لا توجد محادثات بعد\nابدأ محادثة مع طبيب من تبويب تواصل صحي' : 'لا توجد نتائج مطابقة',
          textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _chatTile(chats[i], isDark),
    );
  }

  Widget _chatTile(ChatModel chat, bool isDark) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = chat.getDisplayName(uid);
    final image = chat.getDisplayPhoto(uid);
    final otherId = chat.getOtherParticipant(uid);
    final unread = chat.unreadCount[uid] ?? 0;
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: _conversationAvatar(
          userId: otherId,
          name: name,
          image: image,
          isDark: isDark,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(chat.lastMessage?.isNotEmpty == true ? chat.lastMessage! : 'اضغط لفتح المحادثة', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: unread > 0
            ? CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11)))
            : const Icon(Icons.chevron_left),
        onTap: otherId.isEmpty ? null : () => _openExistingChat(chat.id, otherId, name, image),
      ),
    );
  }

  Widget _conversationAvatar({
    required String userId,
    required String name,
    required String image,
    required bool isDark,
  }) {
    if (userId.isEmpty) {
      return _profileAvatar(name, image, false, null);
    }
    return StreamBuilder<UserStatusModel?>(
      stream: _statusService.streamUserStatus(userId),
      builder: (context, snapshot) {
        final status = snapshot.data;
        final hasStatus = status?.isValid == true && status!.stories.isNotEmpty;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (hasStatus) {
              _openStatus(status!);
            } else {
              _openPublicProfile(userId);
            }
          },
          child: _profileAvatar(name, image, hasStatus, status),
        );
      },
    );
  }

  Widget _profileAvatar(
    String name,
    String image,
    bool hasStatus,
    UserStatusModel? status,
  ) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: hasStatus ? AppColors.primary : Colors.transparent,
          width: 3,
        ),
      ),
      child: CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primary.withOpacity(.12),
        backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
        child: image.isEmpty
            ? const Icon(Icons.person, color: AppColors.primary)
            : null,
      ),
    );
  }

  Future<void> _openPublicProfile(String userId) async {
    if (!mounted || userId.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PatientProfile(userId: userId)),
    );
  }

  Widget _buildContactsTab(bool isDark) {
    return HealthContactsSection(isDark: isDark);
  }

  Widget _buildStatusSection(bool isDark) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 6, 0, 2),
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE7EEEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Text('الحالات اليومية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          if (_loadingStatuses)
            const SizedBox(height: 112, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
          else
            StatusRow(
              statuses: _statuses,
              currentUserId: uid,
              onAddStatus: _openAddStatus,
              onOpenStatus: _openStatus,
            ),
        ],
      ),
    );
  }

  Future<void> _openAddStatus() async {
    if (!mounted) return;
    final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddStatusScreen()));
    if (created == true && mounted) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final mine = await _statusService.getUserStatus(uid);
          if (mounted && mine != null) {
            setState(() {
              _statuses = [mine, ..._statuses.where((status) => status.userId != uid)];
              _loadingStatuses = false;
            });
          }
        } catch (error) {
          debugPrint('reload own status error: ' + error.toString());
        }
      }
      _subscribeStatuses();
    }
  }

  Future<void> _openStatus(UserStatusModel status) async {
    if (!mounted || status.stories.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoryViewerScreen(status: status)),
    );
  }

  Widget _doctorContactTile(DoctorModel doctor, bool isDark) {
    final image = doctor.photoUrl ?? '';
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(radius: 27, backgroundColor: AppColors.primary.withOpacity(.12), backgroundImage: image.isNotEmpty ? NetworkImage(image) : null, child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null),
        title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(doctor.specialty),
        trailing: TextButton(onPressed: _openingChat ? null : () => _openChat(doctor), child: const Text('محادثة')),
        onTap: _openingChat ? null : () => _openChat(doctor),
      ),
    );
  }

  Future<void> _openExistingChat(String chatId, String otherId, String name, String image) async {
    if (!mounted || _openingChat) return;
    setState(() => _openingChat = true);
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(chatId: chatId, otherUserId: otherId, otherUserName: name, groupImage: image.isEmpty ? null : image),
        ),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  Future<void> _openChat(DoctorModel doctor) async {
    if (_openingChat) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ToastService.showError('يرجى تسجيل الدخول أولاً');
      return;
    }
    final doctorId = doctor.userId?.trim();
    if (doctorId == null || doctorId.isEmpty) {
      ToastService.showError('حساب الطبيب غير صالح');
      return;
    }
    if (doctorId == user.uid) {
      ToastService.showError('لا يمكنك بدء محادثة مع حسابك');
      return;
    }
    setState(() => _openingChat = true);
    try {
      final chatId = await _chatService.createChat(
        doctorId: doctorId,
        doctorName: doctor.name,
        doctorImage: doctor.photoUrl,
        patientName: user.displayName ?? 'مستخدم',
        patientImage: user.photoURL,
      );
      if (!mounted || chatId.trim().isEmpty) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(chatId: chatId, otherUserId: doctorId, otherUserName: doctor.name, groupImage: doctor.photoUrl, isGroup: false),
        ),
      );
    } catch (e) {
      debugPrint('open chat error: $e');
      if (mounted) ToastService.showError('تعذر فتح المحادثة: $e');
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  Future<void> _showDoctorsForNewChat(bool isDark) async {
    if (_openingChat || !mounted) return;
    final state = context.read<DoctorBloc>().state;
    final doctors = state is DoctorLoaded ? state.doctors : <DoctorModel>[];
    if (doctors.isEmpty) {
      ToastService.showError('لا يوجد أطباء موثقون متاحون للمحادثة حالياً');
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * .72,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(4))),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Align(alignment: Alignment.centerRight, child: Text('اختر طبيباً لبدء المحادثة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _buildDoctorPickerTile(doctors[i], isDark, sheetContext),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoctorPickerTile(DoctorModel doctor, bool isDark, BuildContext sheetContext) {
    final image = doctor.photoUrl ?? '';
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : const Color(0xFFF7FAFA),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.12), backgroundImage: image.isNotEmpty ? NetworkImage(image) : null, child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null),
        title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(doctor.specialty),
        trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
        onTap: () {
          Navigator.pop(sheetContext);
          _openChat(doctor);
        },
      ),
    );
  }
}
