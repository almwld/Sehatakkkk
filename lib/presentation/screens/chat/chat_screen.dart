import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/chat/calls_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<ChatModel>>? _subscription;
  List<ChatModel> _chats = [];
  String _search = '';
  bool _loadingChats = true;
  bool _openingChat = false;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _subscribeChats();
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

  @override
  void dispose() {
    _subscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildConversationsTab(isDark),
          const CallsScreen(),
          _buildContactsTab(isDark),
        ],
      ),
      floatingActionButton: (_tabIndex == 0 || _tabIndex == 2)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: _openingChat ? null : () => _showDoctorsForNewChat(isDark),
              icon: Image.asset(
                'assets/images/chat/attach_file.png',
                width: 21,
                height: 21,
                color: Colors.white,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              label: const Text('محادثة جديدة', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildTabs(bool isDark) {
    const labels = ['المحادثات', 'المكالمات', 'جهات الاتصال'];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162039) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE6EEEE),
        ),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _tabIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _tabIndex = index),
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
                      color: selected
                          ? Colors.white
                          : (isDark ? Colors.white70 : const Color(0xFF526467)),
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
          child: TextField(
            controller: _searchController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث في محادثاتك...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _searchController.clear,
                    ),
              filled: true,
              fillColor: isDark ? const Color(0xFF162039) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
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
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.smart_toy_outlined, color: Colors.white),
        ),
        title: const Text('المساعد الصحي الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('اسأل الآن عن صحتك'),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AiChatbotScreen()),
        ),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    if (_loadingChats) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final chats = _filteredChats;
    if (chats.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty
              ? 'لا توجد محادثات بعد\nابدأ محادثة مع طبيب من تبويب جهات الاتصال'
              : 'لا توجد نتائج مطابقة',
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
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: AppColors.primary.withOpacity(.12),
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          chat.lastMessage?.isNotEmpty == true ? chat.lastMessage! : 'اضغط لفتح المحادثة',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: unread > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primary,
                child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11)),
              )
            : const Icon(Icons.chevron_left),
        onTap: otherId.isEmpty ? null : () => _openExistingChat(chat.id, otherId, name, image),
      ),
    );
  }

  Widget _buildContactsTab(bool isDark) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading || state is DoctorInitial) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (state is DoctorError) {
          return Center(
            child: Text(
              'تعذر تحميل جهات الاتصال الطبية. حاول مرة أخرى.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          );
        }
        final doctors = state is DoctorLoaded ? state.doctors : <DoctorModel>[];
        if (doctors.isEmpty) {
          return Center(
            child: Text(
              'لا يوجد أطباء موثقون متاحون للمحادثة حالياً.',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          );
        }
        final filtered = _search.isEmpty
            ? doctors
            : doctors.where((doctor) {
                final value = '${doctor.name} ${doctor.specialty}'.toLowerCase();
                return value.contains(_search);
              }).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث عن طبيب أو تخصص...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162039) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) => _doctorContactTile(filtered[index], isDark),
              ),
            ),
          ],
        );
      },
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
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: AppColors.primary.withOpacity(.12),
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
        ),
        title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(doctor.specialty),
        trailing: TextButton(
          onPressed: _openingChat ? null : () => _openChat(doctor),
          child: const Text('محادثة'),
        ),
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
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            otherUserId: otherId,
            otherUserName: name,
            groupImage: image.isEmpty ? null : image,
          ),
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
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            otherUserId: doctorId,
            otherUserName: doctor.name,
            groupImage: doctor.photoUrl,
            isGroup: false,
          ),
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
              child: Align(
                alignment: Alignment.centerRight,
                child: Text('اختر طبيباً لبدء المحادثة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
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
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(.12),
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
        ),
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
