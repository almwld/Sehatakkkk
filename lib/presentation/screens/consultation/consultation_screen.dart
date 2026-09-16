import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/doctor/doctors_list_screen.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});
  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen>
    with SingleTickerProviderStateMixin {
  final ChatService _chat = ChatService();
  final CallService _calls = CallService();
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF7FAFA),
      appBar: AppBar(
        title: const Text('الاستشارات الطبية'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
            controller: _tabs,
            tabs: const [Tab(text: 'المحادثات'), Tab(text: 'سجل المكالمات')]),
      ),
      body: TabBarView(
          controller: _tabs,
          children: [_conversations(dark), _callsHistory(dark)]),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DoctorsListScreen())),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('استشارة جديدة'),
      ),
    );
  }

  Widget _conversations(bool dark) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null)
      return const Center(child: Text('سجّل الدخول لعرض الاستشارات'));
    return StreamBuilder<List<ChatModel>>(
      stream: _chat.streamChats(limit: 100),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final chats = snap.data ?? const <ChatModel>[];
        if (chats.isEmpty)
          return _empty(
              'لا توجد استشارات محفوظة بعد', Icons.chat_bubble_outline);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: chats.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = chats[i];
            final other = c.getOtherParticipant(uid);
            final name = c.getDisplayName(uid);
            final photo = c.getDisplayPhoto(uid);
            return Card(
                elevation: 0,
                color: dark ? const Color(0xFF162039) : Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(.12),
                      backgroundImage:
                          photo.isNotEmpty ? NetworkImage(photo) : null,
                      child: photo.isEmpty
                          ? const Icon(Icons.person, color: AppColors.primary)
                          : null),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      c.lastMessage?.isNotEmpty == true
                          ? c.lastMessage!
                          : 'فتح المحادثة',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: other.isEmpty
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChatRoomScreen(
                                  chatId: c.id,
                                  otherUserId: other,
                                  otherUserName: name,
                                  groupImage: photo.isEmpty ? null : photo))),
                ));
          },
        );
      },
    );
  }

  Widget _callsHistory(bool dark) {
    return StreamBuilder(
      stream: _calls.streamCallHistory(limit: 100),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting && !snap.hasData)
          return const Center(child: CircularProgressIndicator());
        final calls = (snap.data ?? const []).toList();
        if (calls.isEmpty)
          return _empty('لا توجد مكالمات محفوظة بعد', Icons.call_outlined);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: calls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = calls[i];
            final isVideo = c.isVideo.name == 'video';
            final missed = c.status.name == 'missed' ||
                c.status.name == 'rejected' ||
                c.status.name == 'busy';
            return Card(
                elevation: 0,
                color: dark ? const Color(0xFF162039) : Colors.white,
                child: ListTile(
                  leading: CircleAvatar(
                      backgroundColor: (missed ? Colors.red : AppColors.primary)
                          .withOpacity(.12),
                      child: Icon(
                          missed
                              ? Icons.call_missed
                              : (isVideo
                                  ? Icons.videocam_outlined
                                  : Icons.call_outlined),
                          color: missed ? Colors.red : AppColors.primary)),
                  title: Text(isVideo ? 'استشارة فيديو' : 'استشارة صوتية',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      c.status.name == 'connected' || c.status.name == 'ended'
                          ? 'مكالمة مكتملة'
                          : c.status.name),
                  trailing: Text(
                      c.durationSeconds == null ? '' : '${c.durationSeconds}s'),
                ));
          },
        );
      },
    );
  }

  Widget _empty(String text, IconData icon) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 56, color: AppColors.primary.withOpacity(.55)),
        const SizedBox(height: 12),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('سيتم حفظ محادثاتك ومكالماتك هنا تلقائياً.')
      ]));
}
