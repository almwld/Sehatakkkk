import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/messages/messages_bloc.dart';
import '../../../core/constants/app_colors.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';

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
  final TextEditingController
      _textController =
      TextEditingController();

  final ScrollController
      _scrollController =
      ScrollController();

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();

    context.read<MessagesBloc>().add(
          LoadMessages(
            chatId: widget.chatId,
            limit: 30,
          ),
        );

    _scrollController.addListener(
      _onScroll,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // مراقبة التمرير
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position =
        _scrollController.position;

    if (position.maxScrollExtent <= 0) {
      return;
    }

    if (position.pixels >=
        position.maxScrollExtent * 0.8) {
      _loadMoreMessages();
    }
  }

  // ============================================================
  // تحميل المزيد
  // ============================================================

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) {
      return;
    }

    final messagesBloc =
        context.read<MessagesBloc>();

    final state =
        messagesBloc.state;

    if (state is! MessagesLoaded) {
      return;
    }

    if (!state.hasMore) {
      return;
    }

    if (state.isLoadingMore) {
      return;
    }

    _isLoadingMore = true;

    messagesBloc.add(
      LoadMoreMessages(
        chatId: widget.chatId,
        limit: 30,
      ),
    );

    await Future<void>.delayed(
      const Duration(
        milliseconds: 300,
      ),
    );

    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // ============================================================
  // واجهة الشاشة
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'الدردشة',
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : Colors.white,
        foregroundColor: isDark
            ? Colors.white
            : Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<
                MessagesBloc,
                MessagesState>(
              builder:
                  (context, state) {
                if (state
                    is MessagesLoading) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (state
                    is MessagesError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      child: Text(
                        state.message,
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                if (state
                    is MessagesLoaded) {
                  if (state.messages
                      .isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد رسائل',
                      ),
                    );
                  }

                  final currentUserId =
                      FirebaseAuth
                          .instance
                          .currentUser
                          ?.uid;

                  return ListView.builder(
                    controller:
                        _scrollController,
                    reverse: true,
                    padding:
                        const EdgeInsets.all(
                      12,
                    ),
                    itemCount:
                        state.messages.length +
                            (state.isLoadingMore
                                ? 1
                                : 0),
                    itemBuilder:
                        (context, index) {
                      if (index ==
                          state.messages
                              .length) {
                        return const Padding(
                          padding:
                              EdgeInsets.all(8),
                          child: Center(
                            child:
                                CircularProgressIndicator(),
                          ),
                        );
                      }

                      final message =
                          state.messages[index];

                      final isMe =
                          message.senderId ==
                              currentUserId;

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // ======================================================
          // شريط الكتابة
          // ======================================================

          ChatInputBar(
            textController:
                _textController,
            onSend: (text) {
              final value =
                  text.trim();

              if (value.isEmpty) {
                return;
              }

              context
                  .read<MessagesBloc>()
                  .add(
                    SendMessage(
                      chatId:
                          widget.chatId,
                      text: value,
                    ),
                  );

              _textController.clear();
            },
            onImagePick: () {},
            onVoiceRecord: () {},
            onFilePick: () {},
            onLocationShare: () {},
            isSending: false,
          ),
        ],
      ),
    );
  }
}
