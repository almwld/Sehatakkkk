import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/chat/chat_bloc.dart';
import '../../../bloc/chat/chat_event.dart';
import '../../../bloc/chat/chat_state.dart';
import '../../../core/models/chat_model.dart';
import 'chat_detail_screen.dart';
import 'widgets/chat_shimmer.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatBloc()..add(const LoadChats()),
      child: const _ChatScreenView(),
    );
  }
}

class _ChatScreenView extends StatelessWidget {
  const _ChatScreenView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        actions: [
          IconButton(
            tooltip: 'بحث',
            onPressed: () {},
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'المزيد',
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state.status == ChatStatus.loading &&
              state.chats.isEmpty) {
            return const ChatShimmer();
          }

          if (state.status == ChatStatus.failure &&
              state.chats.isEmpty) {
            return _ErrorView(
              message:
                  state.errorMessage ?? 'تعذر تحميل المحادثات',
              onRetry: () {
                context
                    .read<ChatBloc>()
                    .add(const LoadChats());
              },
            );
          }

          if (state.chats.isEmpty) {
            return const _EmptyChats();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<ChatBloc>()
                  .add(const RefreshChats());

              await Future<void>.delayed(
                const Duration(milliseconds: 400),
              );
            },
            child: ListView.separated(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              itemCount: state.chats.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (_, index) {
                final chat = state.chats[index];

                return _ChatTile(
                  chat: chat,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<ChatBloc>(),
                          child: ChatDetailScreen(
                            chatId: chat.id,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final title = chat.isGroup
        ? chat.doctorName.isNotEmpty
            ? chat.doctorName
            : 'مجموعة'
        : chat.doctorName.isNotEmpty
            ? chat.doctorName
            : chat.patientName;

    final image =
        chat.doctorImage.isNotEmpty
            ? chat.doctorImage
            : chat.patientImage;

    return ListTile(
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor:
                colors.primaryContainer,
            backgroundImage:
                image.isNotEmpty
                    ? NetworkImage(image)
                    : null,
            child: image.isEmpty
                ? Icon(
                    chat.isGroup
                        ? Icons.groups_rounded
                        : Icons.person_rounded,
                    color: colors.primary,
                  )
                : null,
          ),
          if (chat.isOnline)
            Positioned(
              right: 0,
              bottom: 1,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        theme.scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          chat.lastMessage.isEmpty
              ? 'لا توجد رسائل بعد'
              : chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.end,
        children: [
          if (chat.lastMessageTime != null)
            Text(
              _formatDate(chat.lastMessageTime!),
              style: theme.textTheme.labelSmall,
            ),
          if (chat.unreadCount > 0) ...[
            const SizedBox(height: 5),
            Container(
              constraints: const BoxConstraints(
                minWidth: 22,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: Text(
                chat.unreadCount > 99
                    ? '99+'
                    : '${chat.unreadCount}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();

    if (now.year == local.year &&
        now.month == local.month &&
        now.day == local.day) {
      return '${local.hour.toString().padLeft(2, '0')}:'
          '${local.minute.toString().padLeft(2, '0')}';
    }

    return '${local.day}/${local.month}';
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    final colors =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 72,
              color: colors.primary,
            ),
            const SizedBox(height: 20),
            Text(
              'لا توجد محادثات',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ستظهر محادثاتك هنا عند بدء محادثة حقيقية.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
