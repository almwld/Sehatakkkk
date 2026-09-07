import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<List<ChatModel>>? _chatsSubscription;
  List<ChatModel> _chats = [];
  String _search = '';
  bool _loadingChats = true;
  bool _creatingDefaultChats = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _search = _searchController.text.trim().toLowerCase());
      }
    });
    _subscribeChats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DoctorBloc>().add(const LoadDoctors());
    });
  }

  void _subscribeChats() {
    try {
      _chatsSubscription = _chatService.streamChats().listen((items) {
        if (!mounted) return;
        setState(() {
          _chats = items;
          _loadingChats = false;
        });
      }, onError: (e) {
        debugPrint('chat list error: $e');
        if (mounted) setState(() => _loadingChats = false);
      });
    } catch (e) {
      debugPrint('chat subscription error: $e');
      _loadingChats = false;
    }
  }

  Future<void> _ensureDefaultDoctorChats(List<DoctorModel> doctors) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || doctors.isEmpty || _creatingDefaultChats) return;

    _creatingDefaultChats = true;
    try {
      for (final doctor in doctors) {
        final doctorId = doctor.userId?.trim();
        if (doctorId == null || doctorId.isEmpty || doctorId == user.uid) continue;
        try {
          await _chatService.createChat(
            doctorId: doctorId,
            doctorName: doctor.name,
            doctorImage: doctor.photoUrl,
            patientName: user.displayName ?? 'مستخدم',
            patientImage: user.photoURL,
          );
        } catch (e) {
          debugPrint('default doctor chat skipped for $doctorId: $e');
        }
      }
    } finally {
      _creatingDefaultChats = false;
    }
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<ChatModel> get _filteredChats => _chats.where((chat) {
    if (_search.isEmpty) return true;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return chat.getDisplayName(uid).toLowerCase().contains(_search) ||
        (chat.lastMessage ?? '').toLowerCase().contains(_search);
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<DoctorBloc, DoctorState>(
      listener: (context, state) {
        if (state is DoctorLoaded) {
          unawaited(_ensureDefaultDoctorChats(state.doctors));
        }
      },
      child: Scaffold(
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
                      : IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF162039) : Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: _buildAIAssistantCard()),
            Expanded(child: _buildChatList(isDark)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: () => _showDoctorsForNewChat(isDark),
          icon: const Icon(Icons.add_comment, color: Colors.white),
          label: const Text('محادثة جديدة', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    if (_loadingChats) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    final chats = _filteredChats;
    if (chats.isEmpty) {
      return _buildInlineEmpty(
        _search.isEmpty ? 'لا توجد محادثات بعد\nسيتم تجهيز أطباء المنصة تلقائياً هنا' : 'لا توجد نتائج مطابقة',
        isDark,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _buildChatTile(chats[i], isDark),
    );
  }

  Widget _buildChatTile(ChatModel chat, bool isDark) {
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
    if (!mounted) return;
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
  }

  Widget _buildDoctorCard(DoctorModel d, bool isDark) => Card(
        elevation: 0,
        color: isDark ? const Color(0xFF162039) : Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(.1),
            backgroundImage: (d.photoUrl ?? '').isNotEmpty ? NetworkImage(d.photoUrl!) : null,
            child: (d.photoUrl ?? '').isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null,
          ),
          title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${d.specialty} • ⭐ ${(d.rating ?? 0).toStringAsFixed(1)}'),
          trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
          onTap: () => _openChat(d),
        ),
      );

  Future<void> _openChat(DoctorModel doctor) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return ToastService.showError('يرجى تسجيل الدخول أولاً');
    final doctorId = doctor.userId;
    if (doctorId == null || doctorId.isEmpty) return ToastService.showError('حساب الطبيب غير صالح');
    try {
      final chatId = await _chatService.createChat(
        doctorId: doctorId,
        doctorName: doctor.name,
        doctorImage: doctor.photoUrl,
        patientName: user.displayName ?? 'مستخدم',
        patientImage: user.photoURL,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            otherUserId: doctorId,
            otherUserName: doctor.name,
            groupImage: doctor.photoUrl,
          ),
        ),
      );
    } catch (e) {
      ToastService.showError('تعذر فتح المحادثة');
      debugPrint('open chat error: $e');
    }
  }

  Future<void> _startCall(String otherId, String name, bool isVideo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return ToastService.showError('يرجى تسجيل الدخول أولاً');
    if (otherId.isEmpty || otherId == user.uid) return ToastService.showError('حساب الطرف الآخر غير صالح');
    try {
      final chatId = await _chatService.createChat(
        doctorId: otherId,
        doctorName: name,
        patientName: user.displayName ?? 'مستخدم',
        patientImage: user.photoURL,
      );
      final call = await _callService.initiateCall(
        receiverId: otherId,
        receiverName: name,
        type: isVideo ? CallType.video : CallType.audio,
        chatId: chatId,
      );
      if (!mounted || call == null) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CallScreen(
            chatId: chatId,
            doctorName: name,
            doctorId: otherId,
            isVideo: isVideo,
            callId: call.id,
            isOutgoing: true,
          ),
        ),
      );
    } catch (e) {
      ToastService.showError('فشل بدء المكالمة');
      debugPrint('call error: $e');
    }
  }

  Widget _buildAIAssistantCard() => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: AppColors.primary,
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.psychology, color: Colors.white)),
          title: const Text('المساعد الذكي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: const Text('استشارات ومعلومات صحية', style: TextStyle(color: Colors.white70)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen())),
        ),
      );

  void _showDoctorsForNewChat(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * .75,
        child: BlocBuilder<DoctorBloc, DoctorState>(
          builder: (_, state) {
            if (state is DoctorLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            if (state is DoctorError) return Center(child: Text(state.message));
            final doctors = state is DoctorLoaded ? state.doctors : <DoctorModel>[];
            if (doctors.isEmpty) return const Center(child: Text('لا يوجد أطباء موثّقون متاحون حالياً'));
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('اختر طبيباً لبدء محادثة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...doctors.map((d) => _buildDoctorCard(d, isDark)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInlineEmpty(String text, bool isDark) => Padding(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))),
      );
}
