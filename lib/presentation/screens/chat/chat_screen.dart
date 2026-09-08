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
      appBar: AppBar(title: const Text('الدردشة'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
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
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: _buildAIAssistantCard(isDark),
          ),
          _buildDoctorsSection(isDark),
          const SizedBox(height: 4),
          Expanded(child: _buildChatList(isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: _openingChat ? null : () => _showDoctorsForNewChat(isDark),
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text('محادثة جديدة', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAIAssistantCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
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

  Widget _buildDoctorsSection(bool isDark) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading || state is DoctorInitial) {
          return const SizedBox(
            height: 118,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        if (state is DoctorError) {
          return _sectionMessage('تعذر تحميل الأطباء. حاول مرة أخرى.', isDark);
        }
        final doctors = state is DoctorLoaded ? state.doctors : <DoctorModel>[];
        if (doctors.isEmpty) {
          return _sectionMessage('لا يوجد أطباء موثقون متاحون للمحادثة حالياً.', isDark);
        }
        final visible = doctors.take(5).toList();
        return SizedBox(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text('الأطباء المتاحون للمحادثة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    TextButton(onPressed: () => _showDoctorsForNewChat(isDark), child: const Text('عرض الكل')),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => _doctorMiniCard(visible[i], isDark),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _doctorMiniCard(DoctorModel doctor, bool isDark) {
    final image = doctor.photoUrl ?? '';
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        color: isDark ? const Color(0xFF162039) : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _openingChat ? null : () => _openChat(doctor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppColors.primary.withOpacity(.12),
                  backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
                  child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doctor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(doctor.specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text((doctor.rating ?? 0).toStringAsFixed(1), style: const TextStyle(fontSize: 11)),
                          const Spacer(),
                          const Icon(Icons.chat_bubble_outline, size: 17, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionMessage(String text, bool isDark) => SizedBox(
        height: 74,
        child: Center(
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black54)),
        ),
      );

  Widget _buildChatList(bool isDark) {
    if (_loadingChats) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final chats = _filteredChats;
    if (chats.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'لا توجد محادثات بعد\nاضغط على طبيب أعلاه لبدء محادثة' : 'لا توجد نتائج مطابقة',
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: AppColors.primary.withOpacity(.12),
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
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
