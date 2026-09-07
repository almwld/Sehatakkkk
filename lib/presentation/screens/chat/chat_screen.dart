import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/ai_chatbot/ai_chatbot_screen.dart';
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
  StreamSubscription? _chatsSubscription;
  List<Map<String, dynamic>> _chats = [];
  List<DoctorModel> _doctors = [];
  bool _loadingChats = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _search = _searchController.text.trim().toLowerCase()));
    _subscribeChats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<DoctorBloc>().add(const LoadDoctors());
    });
  }

  void _subscribeChats() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _loadingChats = false;
      return;
    }
    _chatsSubscription = _chatService.streamUserChats(uid).listen((items) {
      if (!mounted) return;
      setState(() {
        _chats = items;
        _loadingChats = false;
      });
    }, onError: (e) {
      debugPrint('chat list error: $e');
      if (mounted) setState(() => _loadingChats = false);
    });
  }

  @override
  void dispose() {
    _chatsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredChats => _chats.where((chat) {
    if (_search.isEmpty) return true;
    final name = '${chat['doctorName'] ?? chat['participantName'] ?? chat['name'] ?? ''}'.toLowerCase();
    final last = '${chat['lastMessage'] ?? ''}'.toLowerCase();
    return name.contains(_search) || last.contains(_search);
  }).toList();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF7FAFA),
      appBar: AppBar(title: const Text('الدردشة'), centerTitle: true),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'ابحث في محادثاتك...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear),
              filled: true,
              fillColor: isDark ? const Color(0xFF162039) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: _buildAIAssistantCard(isDark),
        ),
        Expanded(child: _buildChatList(isDark)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => _showDoctorsForNewChat(isDark),
        icon: const Icon(Icons.add_comment, color: Colors.white),
        label: const Text('محادثة جديدة', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    if (_loadingChats) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    final chats = _filteredChats;
    if (chats.isEmpty) {
      return _buildInlineEmpty(_search.isEmpty ? 'لا توجد محادثات بعد\nابدأ محادثة مع طبيب موثّق' : 'لا توجد نتائج مطابقة', isDark);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: chats.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _buildChatTile(chats[i], isDark),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, bool isDark) {
    final name = '${chat['doctorName'] ?? chat['participantName'] ?? chat['name'] ?? 'محادثة'}';
    final image = '${chat['doctorImage'] ?? chat['participantImage'] ?? chat['imageUrl'] ?? ''}';
    final last = '${chat['lastMessage'] ?? ''}';
    final unread = (chat['unreadCount'] is num) ? (chat['unreadCount'] as num).toInt() : 0;
    final chatId = '${chat['id'] ?? chat['chatId'] ?? ''}';
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
        subtitle: Text(last.isEmpty ? 'اضغط لفتح المحادثة' : last, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: unread > 0 ? CircleAvatar(radius: 12, backgroundColor: AppColors.primary, child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11))) : const Icon(Icons.chevron_left),
        onTap: chatId.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId, doctorId: '${chat['doctorId'] ?? chat['participantId'] ?? ''}', doctorName: name, doctorImage: image))),
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel d, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.1), backgroundImage: (d.photoUrl ?? '').isNotEmpty ? NetworkImage(d.photoUrl!) : null, child: (d.photoUrl ?? '').isEmpty ? const Icon(Icons.person, color: AppColors.primary) : null),
        title: Text(d.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${d.specialty ?? 'طبيب'} • ⭐ ${(d.rating ?? 0).toStringAsFixed(1)}'),
        trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
        onTap: () => _openChat(d),
      ),
    );
  }

  Future<void> _openChat(DoctorModel doctor) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return ToastService.showError('يرجى تسجيل الدخول أولاً');
    final doctorId = doctor.userId;
    if (doctorId == null || doctorId.isEmpty) return ToastService.showError('حساب الطبيب غير صالح');
    try {
      final chatId = await _chatService.createChat(doctorId: doctorId, doctorName: doctor.name, patientName: FirebaseAuth.instance.currentUser?.displayName ?? 'مستخدم', patientImage: FirebaseAuth.instance.currentUser?.photoURL);
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId, doctorId: doctorId, doctorName: doctor.name, doctorImage: doctor.photoUrl ?? '')));
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
      final chatId = await _chatService.createChat(doctorId: otherId, doctorName: name, patientName: user.displayName ?? 'مستخدم', patientImage: user.photoURL);
      final call = await _callService.initiateCall(receiverId: otherId, receiverName: name, type: isVideo ? CallType.video : CallType.audio, chatId: chatId);
      if (!mounted || call == null) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(chatId: chatId, doctorName: name, doctorId: otherId, isVideo: isVideo, callId: call.id, isOutgoing: true)));
    } catch (e) {
      ToastService.showError('فشل بدء المكالمة');
      debugPrint('call error: $e');
    }
  }

  Widget _buildAIAssistantCard(bool isDark) => Card(
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
    final state = context.read<DoctorBloc>().state;
    if (state is DoctorLoaded) _doctors = state.doctors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      builder: (_) => BlocBuilder<DoctorBloc, DoctorState>(
        builder: (_, state) {
          if (state is DoctorLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (state is DoctorError) return Center(child: Text(state.message));
          final doctors = state is DoctorLoaded ? state.doctors : _doctors;
          if (doctors.isEmpty) return const Center(child: Text('لا يوجد أطباء موثّقون متاحون حالياً'));
          return SizedBox(
            height: MediaQuery.of(context).size.height * .75,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [const Text('اختر طبيباً لبدء محادثة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...doctors.map((d) => _buildDoctorCard(d, isDark))],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInlineEmpty(String text, bool isDark) => Padding(padding: const EdgeInsets.all(28), child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))));
}
