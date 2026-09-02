import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../core/models/chat_model.dart';
import '../../../core/models/message_model.dart';
import '../../../core/services/call_service.dart';
import 'widgets/chat_background.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/typing_indicator.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatDetailScreen> createState() =>
      _ChatDetailScreenState();
}

class _ChatDetailScreenState
    extends State<ChatDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<ChatBloc>()
          .add(OpenChat(widget.chatId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatBloc, ChatState>(
      listenWhen: (previous, current) =>
          previous.actionError !=
          current.actionError &&
          current.actionError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.actionError!,
            ),
          ),
        );
      },
      child: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          final chat = state.activeChat;

          return Scaffold(
            appBar: _buildAppBar(
              context,
              chat,
            ),
            body: ChatBackground(
              child: Column(
                children: [
                  Expanded(
                    child: _MessageList(
                      messages: state.messages,
                      isLoading:
                          state.isLoadingMessages,
                      chat: chat,
                    ),
                  ),
                  const TypingIndicator(),
                  ChatInputBar(
                    onSend: (text) {
                      context.read<ChatBloc>().add(
                            SendChatMessage(
                              chatId: widget.chatId,
                              text: text,
                            ),
                          );
                    },
                    onAttachment: () {
                      _showUnavailable(
                        context,
                        'رفع الملفات سيتم ربطه بخدمة Nextcloud.',
                      );
                    },
                    onVoice: () {
                      _showUnavailable(
                        context,
                        'تسجيل الصوت سيتم ربطه بخدمة الوسائط.',
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ChatModel? chat,
  ) {
    final title = chat == null
        ? 'المحادثة'
        : chat.isGroup
            ? chat.doctorName.isNotEmpty
                ? chat.doctorName
                : 'مجموعة'
            : chat.doctorName.isNotEmpty
                ? chat.doctorName
                : chat.patientName;

    final image = chat?.doctorImage.isNotEmpty == true
        ? chat!.doctorImage
        : chat?.patientImage ?? '';

    return AppBar(
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundImage: image.isNotEmpty
                ? NetworkImage(image)
                : null,
            child: image.isEmpty
                ? const Icon(
                    Icons.person_rounded,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (chat?.isOnline == true)
                  const Text(
                    'متصل الآن',
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'مكالمة صوتية',
          onPressed: () {
            _showUnavailable(
              context,
              'المكالمة الصوتية تستخدم LiveKit.',
            );
          },
          icon: const Icon(
            Icons.call_rounded,
          ),
        ),
        IconButton(
          tooltip: 'مكالمة فيديو',
          onPressed: () {
            _showUnavailable(
              context,
              'مكالمة الفيديو تستخدم LiveKit.',
            );
          },
          icon: const Icon(
            Icons.videocam_rounded,
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              context.read<ChatBloc>().add(
                    DeleteChat(widget.chatId),
                  );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'delete',
              child: Text('حذف المحادثة'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _startCall(
    BuildContext context, {
    required bool isVideo,
    required ChatModel? chat,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showUnavailable(
        context,
        'يرجى تسجيل الدخول أولاً.',
      );
      return;
    }

    if (chat == null || chat.id.trim().isEmpty) {
      _showUnavailable(
        context,
        'المحادثة غير متاحة.',
      );
      return;
    }

    final receiverId = chat.doctorId == currentUser.uid
        ? chat.patientId
        : chat.doctorId;

    if (receiverId.trim().isEmpty) {
      _showUnavailable(
        context,
        'تعذر تحديد الطرف الآخر للمكالمة.',
      );
      return;
    }

    final callerName = currentUser.displayName?.trim().isNotEmpty == true
        ? currentUser.displayName!.trim()
        : 'مستخدم';

    await CallService().startCall(
      receiverId: receiverId,
      callerName: callerName,
      isVideo: isVideo,
      chatId: chat.id,
      context: context,
    );
  }

  void _showUnavailable(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

class _MessageList extends StatefulWidget {
  final List<MessageModel> messages;
  final bool isLoading;
  final ChatModel? chat;

  const _MessageList({
    required this.messages,
    required this.isLoading,
    required this.chat,
  });

  @override
  State<_MessageList> createState() =>
      _MessageListState();
}

class _MessageListState
    extends State<_MessageList> {
  final _controller = ScrollController();

  @override
  void didUpdateWidget(
    covariant _MessageList oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.length >
        oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (!_controller.hasClients) return;

          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration:
                const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading &&
        widget.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.messages.isEmpty) {
      return const Center(
        child: Text(
          'ابدأ المحادثة بإرسال أول رسالة.',
        ),
      );
    }

    return ListView.builder(
      controller: _controller,
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      itemCount: widget.messages.length,
      itemBuilder: (_, index) {
        final message = widget.messages[index];

        final currentUid = context
            .read<ChatBloc>()
            .state
            .activeChat;

        final isMe =
            currentUid != null &&
            message.senderId ==
                (currentUid.participants.isNotEmpty
                    ? currentUid.participants.first
                    : '');

        return MessageBubble(
          message: message,
          isMe: isMe,
        );
      },
    );
  }
}
