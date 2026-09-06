import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/bloc/chat/chat_bloc.dart';
import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/presentation/screens/chat/widgets/chat_shimmer.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  final CallService _callService = CallService();
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChatBloc>().add(LoadChats());
      context.read<DoctorBloc>().add(const LoadDoctors());
    });
  }

  @override
  void dispose() { _tabController.dispose(); _searchController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(isDark),
      body: Column(children: [
        _buildSearchBar(isDark),
        _buildTabBar(isDark),
        Expanded(child: TabBarView(controller: _tabController, children: [
          _buildChatList(isDark), _buildCallsList(isDark), _buildAIAssistant(isDark),
        ])),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _showDoctorsForNewChat(isDark),
        child: const Icon(Icons.chat_bubble_outline),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName?.trim();
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
      foregroundColor: isDark ? Colors.white : Colors.black87,
      elevation: 0,
      title: Row(children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary.withOpacity(.1),
          backgroundImage: user?.photoURL != null ? CachedNetworkImageProvider(user!.photoURL!) : null,
          child: user?.photoURL == null ? Text(name?.isNotEmpty == true ? name![0].toUpperCase() : 'م', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) : null,
        ),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('المحادثات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('تواصل مع أطبائك بأمان', style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ]),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () => setState(() => _isSearching = !_isSearching)),
        IconButton(icon: const Icon(Icons.notifications_none), onPressed: () => ToastService.showInfo('الإشعارات الجديدة تظهر تلقائياً عند وصول رسالة')),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    if (!_isSearching) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (value) { setState(() => _searchQuery = value.trim()); context.read<ChatBloc>().add(SearchChatsEvent(query: value)); },
        decoration: InputDecoration(
          hintText: 'ابحث في المحادثات والأطباء...', prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() { _searchQuery = ''; _isSearching = false; }); context.read<ChatBloc>().add(SearchChatsEvent(query: '')); }),
          filled: true, fillColor: isDark ? const Color(0xFF1A2540) : Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildTabBar(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: TabBar(controller: _tabController, indicator: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(9)), indicatorSize: TabBarIndicatorSize.tab, labelColor: Colors.white, unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600], tabs: const [Tab(text: 'المحادثات'), Tab(text: 'المكالمات'), Tab(text: 'المساعد')]),
  );

  Widget _buildChatList(bool isDark) => BlocBuilder<ChatBloc, ChatState>(
    builder: (context, chatState) {
      if (chatState is ChatLoading) return const ChatShimmer();
      if (chatState is ChatError) return _buildErrorState(isDark, chatState.message, () => context.read<ChatBloc>().add(LoadChats()));
      return BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, doctorState) {
          final chats = chatState is ChatLoaded ? chatState.chats.where((c) => !c.isArchived).toList() : <ChatModel>[];
          final doctors = doctorState is DoctorLoaded ? doctorState.doctors.where(_matchesDoctorSearch).toList() : <DoctorModel>[];
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async { context.read<ChatBloc>().add(RefreshChats()); context.read<DoctorBloc>().add(const RefreshDoctors()); },
            child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(12, 8, 12, 90), children: [
              _buildAIAssistantCard(isDark), const SizedBox(height: 14),
              _sectionTitle('الأطباء', 'من Firestore', isDark),
              if (doctorState is DoctorLoading) const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
              else if (doctorState is DoctorError) _buildInlineError(doctorState.message)
              else if (doctors.isEmpty) _buildInlineEmpty('لا يوجد أطباء مطابقون للبحث', isDark)
              else ...doctors.map((doctor) => _buildDoctorCard(doctor, isDark)),
              const SizedBox(height: 10),
              if (chats.isNotEmpty) ...[_sectionTitle('محادثاتك', '${chats.length} محادثة', isDark), ...chats.map((chat) => _buildChatCard(chat, isDark))]
              else _buildInlineEmpty('لا توجد محادثات بعد', isDark),
            ]),
          );
        },
      );
    },
  );

  bool _matchesDoctorSearch(DoctorModel doctor) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();
    return doctor.name.toLowerCase().contains(q) || doctor.specialty.toLowerCase().contains(q) || (doctor.subspecialty ?? '').toLowerCase().contains(q) || (doctor.hospital ?? '').toLowerCase().contains(q);
  }

  Widget _sectionTitle(String title, String subtitle, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
    child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87))), Text(subtitle, style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]))]),
  );

  Widget _buildDoctorCard(DoctorModel doctor, bool isDark) {
    final canChat = doctor.userId?.trim().isNotEmpty == true;
    final photo = doctor.photoUrl?.trim().isNotEmpty == true ? doctor.photoUrl!.trim() : ImageKit.doctor1;
    return Card(elevation: 0, color: isDark ? const Color(0xFF1A2540) : Colors.white, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      Stack(children: [CircleAvatar(radius: 28, backgroundImage: CachedNetworkImageProvider(photo), backgroundColor: AppColors.primary.withOpacity(.1)), if (doctor.isOnline) Positioned(bottom: 0, right: 0, child: Container(width: 13, height: 13, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF1A2540) : Colors.white, width: 2))))]),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doctor.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 3), Text(doctor.specialty, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])), const SizedBox(height: 5), Row(children: [const Icon(Icons.star, size: 13, color: Colors.amber), const SizedBox(width: 3), Text('${doctor.rating ?? 0}', style: const TextStyle(fontSize: 11)), const SizedBox(width: 7), Text('(${doctor.reviewsCount ?? 0})', style: TextStyle(fontSize: 10, color: isDark ? Colors.grey[400] : Colors.grey[600])), const Spacer(), Text(doctor.isOnline ? 'متصل' : (doctor.isAvailable ? 'متاح' : 'غير متاح'), style: TextStyle(fontSize: 10, color: doctor.isOnline || doctor.isAvailable ? Colors.green : Colors.grey))])])),
      IconButton(onPressed: canChat ? () => _startChatWithDoctor(doctor) : null, icon: Icon(Icons.chat_bubble_outline, color: canChat ? AppColors.primary : Colors.grey), tooltip: canChat ? 'بدء المحادثة' : 'غير مرتبط بحساب'),
    ])));
  }

  Future<void> _startChatWithDoctor(DoctorModel doctor) async {
    final user = FirebaseAuth.instance.currentUser;
    final doctorUid = doctor.userId?.trim();
    if (user == null) return ToastService.showError('يرجى تسجيل الدخول أولاً');
    if (doctorUid == null || doctorUid.isEmpty) return ToastService.showError('الطبيب موجود في الدليل لكنه غير مرتبط بحساب مستخدم للدردشة بعد');
    if (doctorUid == user.uid) return ToastService.showError('لا يمكنك بدء محادثة مع حسابك');
    try {
      final chatId = await _chatService.createChat(doctorId: doctorUid, doctorName: doctor.name, patientName: user.displayName ?? 'مستخدم', doctorImage: doctor.photoUrl, patientImage: user.photoURL);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId, otherUserId: doctorUid, otherUserName: doctor.name)));
    } catch (e) { ToastService.showError('فشل إنشاء المحادثة'); debugPrint('start chat error: $e'); }
  }

  Widget _buildChatCard(ChatModel chat, bool isDark) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = chat.getDisplayName(userId); final photo = chat.getDisplayPhoto(userId); final unread = chat.getTotalUnreadCount();
    final last = chat.lastMessage?.trim().isNotEmpty == true ? chat.lastMessage! : 'ابدأ المحادثة'; final time = chat.lastMessageTime?.toDate();
    return Card(elevation: 0, color: isDark ? const Color(0xFF1A2540) : Colors.white, margin: const EdgeInsets.only(bottom: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(radius: 27, backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null, child: photo.isEmpty ? Text(name.isNotEmpty ? name[0] : 'م') : null),
      title: Text(name.isNotEmpty ? name : 'محادثة', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(last, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [if (time != null) Text(_formatTime(time), style: const TextStyle(fontSize: 9, color: Colors.grey)), if (unread > 0) Container(margin: const EdgeInsets.only(top: 5), padding: const EdgeInsets.all(5), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10)))]),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chat.id, otherUserId: chat.getOtherParticipant(userId), otherUserName: name, isGroup: chat.isGroup))),
    ));
  }

  Widget _buildCallsList(bool isDark) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return _buildInlineEmpty('سجّل الدخول لعرض المكالمات', isDark);
    return StreamBuilder<List<CallModel>>(stream: _callService.streamCallHistory(), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      if (snapshot.hasError) return _buildErrorState(isDark, 'تعذر تحميل سجل المكالمات', () => setState(() {}));
      final calls = snapshot.data ?? [];
      if (calls.isEmpty) return _buildInlineEmpty('لا توجد مكالمات بعد', isDark);
      return ListView.builder(padding: const EdgeInsets.fromLTRB(12, 8, 12, 90), itemCount: calls.length, itemBuilder: (_, index) => _buildCallCard(calls[index], isDark));
    });
  }

  Widget _buildCallCard(CallModel call, bool isDark) {
    final me = FirebaseAuth.instance.currentUser?.uid; final isCaller = call.callerId == me; final name = isCaller ? call.receiverName : call.callerName; final otherId = isCaller ? call.receiverId : call.callerId; final video = call.callType == CallType.video; final missed = call.status == CallStatus.missed || call.status == CallStatus.rejected;
    return Card(elevation: 0, color: isDark ? const Color(0xFF1A2540) : Colors.white, margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: missed ? Colors.red.withOpacity(.1) : AppColors.primary.withOpacity(.1), child: Icon(video ? Icons.videocam_outlined : Icons.phone_outlined, color: missed ? Colors.red : AppColors.primary)), title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(missed ? 'مكالمة فائتة' : call.status == CallStatus.ended ? 'مكالمة منتهية' : 'مكالمة'), trailing: IconButton(icon: Icon(video ? Icons.videocam_outlined : Icons.phone_outlined, color: AppColors.primary), onPressed: () => _startCall(otherId, name, video))));
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
    } catch (e) { ToastService.showError('فشل بدء المكالمة'); debugPrint('call error: $e'); }
  }

  Widget _buildAIAssistantCard(bool isDark) => Card(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), color: AppColors.primary, child: ListTile(leading: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.psychology, color: Colors.white)), title: const Text('المساعد الذكي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: const Text('استشارات ومعلومات صحية', style: TextStyle(color: Colors.white70)), trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen())));

  Widget _buildAIAssistant(bool isDark) => Padding(padding: const EdgeInsets.all(16), child: Column(children: [Card(elevation: 0, color: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [const Icon(Icons.psychology, color: Colors.white, size: 64), const SizedBox(height: 12), const Text('المساعد الذكي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('اسأل عن الأعراض والأدوية والنصائح الصحية', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)), const SizedBox(height: 18), ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen())), child: const Text('بدء المحادثة'))]))), const SizedBox(height: 16), const Text('يمكنك العودة للدردشة مع طبيب في أي وقت', style: TextStyle(color: Colors.grey))]));

  Widget _buildInlineEmpty(String text, bool isDark) => Padding(padding: const EdgeInsets.all(28), child: Center(child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]))));
  Widget _buildInlineError(String text) => Padding(padding: const EdgeInsets.all(16), child: Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)));
  Widget _buildErrorState(bool isDark, String text, VoidCallback retry) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_off, size: 58, color: Colors.red[300]), const SizedBox(height: 12), Text(text, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white : Colors.black87)), const SizedBox(height: 12), ElevatedButton(onPressed: retry, child: const Text('إعادة المحاولة'))]));

  void _showDoctorsForNewChat(bool isDark) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white, builder: (_) => SizedBox(height: MediaQuery.of(context).size.height * .75, child: BlocBuilder<DoctorBloc, DoctorState>(builder: (_, state) {
      if (state is DoctorLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      if (state is DoctorError) return Center(child: Text(state.message));
      final doctors = state is DoctorLoaded ? state.doctors : <DoctorModel>[];
      return ListView(padding: const EdgeInsets.all(16), children: [const Text('اختر طبيباً لبدء محادثة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 12), ...doctors.map((d) => _buildDoctorCard(d, isDark))]);
    })));
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 7) return '${time.day}/${time.month}';
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    if (diff.inMinutes > 0) return 'منذ ${diff.inMinutes} دقيقة';
    return 'الآن';
  }
}
