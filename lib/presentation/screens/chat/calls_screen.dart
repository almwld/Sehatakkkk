import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/localization/app_strings.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/call_model.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/core/services/call_service.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/presentation/screens/chat/add_status_screen.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/widgets/status_row.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart' show ChatRoomScreen;

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  String _t(String value) => AppStrings.of(context).translate(value);

  List<CallModel> _lastCalls = const [];
  final StatusService _statusService = StatusService();
  StreamSubscription<List<UserStatusModel>>? _statusSubscription;
  List<UserStatusModel> _statuses = const [];
  bool _loadingStatuses = true;

  @override
  void initState() {
    super.initState();
    _subscribeStatuses();
  }

  void _subscribeStatuses() {
    _statusSubscription = _statusService.streamActiveStatuses().listen(
      (items) {
        if (!mounted) return;
        setState(() {
          _statuses = items;
          _loadingStatuses = false;
        });
      },
      onError: (error) {
        debugPrint('daily statuses error: $error');
        if (mounted) setState(() => _loadingStatuses = false);
      },
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    super.dispose();
  }

  Future<void> _openAddStatus() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddStatusScreen()),
    );
    if (created == true && mounted) {
      _subscribeStatuses();
    }
  }

  Future<void> _openStatus(UserStatusModel status) async {
    if (status.stories.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StoryViewerScreen(status: status)),
    );
  }

  Widget _buildDailyStatuses(bool isDark, String uid) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE7EEEE),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 4),
            child: Text(
              _t('الحالات اليومية'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF263238),
              ),
            ),
          ),
          if (_loadingStatuses)
            const SizedBox(
              height: 104,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
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

  @override
  Widget
(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return _empty(_t('سجّل الدخول لعرض سجل المكالمات'), isDark);
    }

    return Column(
      children: [
        _buildDailyStatuses(isDark, currentUid),
        Expanded(
          child: StreamBuilder<List<CallModel>>(
            stream: CallService().streamCallHistory(limit: 50),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (snapshot.hasError) {
                debugPrint('call history error: ${snapshot.error}');
                if (_lastCalls.isNotEmpty) {
                  return _buildCallsList(context, _lastCalls, currentUid, isDark);
                }
                return _empty(_t('تعذر تحميل سجل المكالمات حالياً\nتحقق من الاتصال وحاول مرة أخرى'), isDark);
              }

              if (snapshot.hasData) {
                _lastCalls = snapshot.data!;
              }
              final calls = snapshot.data ?? _lastCalls;
              if (calls.isEmpty) {
                return _empty(_t('لا توجد مكالمات بعد\nستظهر مكالماتك هنا تلقائياً'), isDark);
              }

              return _buildCallsList(context, calls, currentUid, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallsList(BuildContext context, List<CallModel> calls, String uid, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      itemCount: calls.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) => _callTile(context, calls[index], uid, isDark),
    );
  }

  Widget _callTile(BuildContext context, CallModel call, String uid, bool isDark) {
    final outgoing = call.callerId == uid;
    final name = outgoing ? call.receiverName : call.callerName;
    final photo = outgoing ? call.receiverPhotoUrl : call.callerPhotoUrl;
    final missed = call.status == CallStatus.missed;
    final rejected = call.status == CallStatus.rejected;
    final color = missed || rejected ? AppColors.error : AppColors.primary;
    final statusText = _statusText(call.status, outgoing);
    final typeText = _t(call.isVideoCallType ? 'فيديو' : 'صوت');

    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: AppColors.primary.withOpacity(.12),
          backgroundImage: photo != null && photo.isNotEmpty ? NetworkImage(photo) : null,
          child: photo == null || photo.isEmpty
              ? const Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        title: Text(name.isEmpty ? _t('مستخدم') : name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            Icon(
              outgoing ? Icons.call_made : Icons.call_received,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 5),
            Flexible(child: Text('$statusText • $typeText', overflow: TextOverflow.ellipsis)),
          ],
        ),
        trailing: TextButton(
          onPressed: () async {
            if (call.chatId.isEmpty) return;
            final otherId = outgoing ? call.receiverId : call.callerId;
            final otherName = outgoing ? call.receiverName : call.callerName;
            final otherPhoto = outgoing ? call.receiverPhotoUrl : call.callerPhotoUrl;
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChatRoomScreen(
              chatId: call.chatId,
              otherUserId: otherId,
              otherUserName: otherName,
              otherUserImage: otherPhoto,
            )));
          },
          child: Text(_t('المحادثة')),
        ),
      ),
    );
  }

  String _statusText(CallStatus status, bool outgoing) {
    switch (status) {
      case CallStatus.calling:
      case CallStatus.ringing:
        return outgoing ? _t('جارٍ الاتصال') : _t('واردة');
      case CallStatus.connected:
        return _t('متصلة');
      case CallStatus.ended:
        return _t('منتهية');
      case CallStatus.missed:
        return _t('فائتة');
      case CallStatus.rejected:
        return _t('مرفوضة');
      case CallStatus.busy:
        return _t('مشغول');
      case CallStatus.cancelled:
        return _t('ملغاة');
    }
  }

  Widget _empty(String message, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.6,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
      ),
    );
  }
}
