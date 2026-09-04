import '../../../core/models/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../bloc/chat/chat_bloc.dart';
import 'widgets/chat_shimmer.dart';
import '../../../core/models/doctor_model.dart';
import '../../../core/services/chat_service.dart';
import '../../bloc/doctor_bloc/doctor_bloc.dart';
import '../ai/ai_chatbot_screen.dart';
import 'chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadChats());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('المحادثات'),
        backgroundColor: isDark ? AppColors.backgroundDark : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => context.read<ChatBloc>().add(RefreshChats()),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'new_chat_fab',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _showNewChatSheet,
        child: const Icon(
          Icons.add_comment_rounded,
        ),
      ),

      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const ChatShimmer();
          }
          if (state is ChatError) {
            return Center(child: Text(state.message));
          }
          if (state is ChatLoaded) {
            if (state.chats.isEmpty) {
              return _buildEmptyState(isDark);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.chats.length,
              itemBuilder: (context, index) {
                final chat = state.chats[index];
                return _buildChatTile(chat, isDark);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }


  // ==========================================================
  // ➕ محادثة جديدة
  // ==========================================================

  void _showNewChatSheet() {
    context.read<DoctorBloc>().add(
      LoadDoctors(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final isDark =
            Theme.of(sheetContext).brightness ==
                Brightness.dark;

        return SafeArea(
          child: Container(
            height:
                MediaQuery.of(sheetContext).size.height * 0.78,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.backgroundDark
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.chat_rounded,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'محادثة جديدة',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            Text(
                              'اختر المساعد الذكي أو طبيبًا',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                ),

                // ==================================================
                // 🤖 AI
                // ==================================================

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    8,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.pop(sheetContext);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AiChatbotScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primary.withOpacity(0.07),
                          borderRadius:
                              BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary
                                .withOpacity(0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.psychology_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المساعد الذكي',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'مساعدة فورية واستفسارات صحية',
                                    maxLines: 1,
                                    overflow:
                                        TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // 👨‍⚕️ Doctors
                // ==================================================

                Expanded(
                  child: BlocBuilder<DoctorBloc, DoctorState>(
                    builder: (context, state) {
                      if (state is DoctorLoading ||
                          state is DoctorInitial) {
                        return _buildDoctorShimmer(
                          isDark,
                        );
                      }

                      if (state is DoctorError) {
                        return Center(
                          child: Padding(
                            padding:
                                const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons
                                      .medical_services_outlined,
                                  size: 46,
                                  color: isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<DoctorBloc>()
                                        .add(LoadDoctors());
                                  },
                                  icon: const Icon(
                                    Icons.refresh,
                                  ),
                                  label: const Text(
                                    'إعادة المحاولة',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is DoctorLoaded) {
                        if (state.doctors.isEmpty) {
                          return Center(
                            child: Text(
                              'لا يوجد أطباء متاحون حاليًا',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          );
                        }

                        return RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () async {
                            context
                                .read<DoctorBloc>()
                                .add(RefreshDoctors());

                            await Future<void>.delayed(
                              const Duration(
                                milliseconds: 300,
                              ),
                            );
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              12,
                              4,
                              12,
                              24,
                            ),
                            itemCount: state.doctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorItem(
                                state.doctors[index],
                                isDark,
                                sheetContext,
                              );
                            },
                          ),
                        );
                      }

                      return _buildDoctorShimmer(
                        isDark,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // ✨ Doctor Shimmer
  // ==========================================================

  Widget _buildDoctorShimmer(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        12,
        4,
        12,
        24,
      ),
      itemCount: 6,
      itemBuilder: (_, index) {
        return Container(
          height: 78,
          margin: const EdgeInsets.only(
            bottom: 8,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[850]
                : Colors.grey[200],
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 100,
                      height: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // 👨‍⚕️ Doctor Item
  // ==========================================================

  Widget _buildDoctorItem(
    DoctorModel doctor,
    bool isDark,
    BuildContext sheetContext,
  ) {
    final photo =
        doctor.photoUrl?.trim() ?? '';

    return InkWell(
      borderRadius:
          BorderRadius.circular(14),
      onTap: () {
        Navigator.pop(sheetContext);
        _startChatWithDoctor(doctor);
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 8,
        ),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[850]
              : Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.grey[800]!
                : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor:
                  AppColors.primary.withOpacity(0.10),
              backgroundImage:
                  photo.isNotEmpty
                      ? CachedNetworkImageProvider(photo)
                      : null,
              child: photo.isEmpty
                  ? Text(
                      doctor.name.isNotEmpty
                          ? doctor.name[0]
                          : 'ط',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          doctor.name.isNotEmpty
                              ? doctor.name
                              : 'طبيب',
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                      if (doctor.isVerified)
                        const Padding(
                          padding:
                              EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.verified,
                            size: 15,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    doctor.specialty.isNotEmpty
                        ? doctor.specialty
                        : 'تخصص طبي',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),

                  if (doctor.rating != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          doctor.rating!
                              .toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            const Icon(
              Icons.chat_outlined,
              size: 22,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 💬 Start Doctor Chat
  // ==========================================================

  Future<void> _startChatWithDoctor(
    DoctorModel doctor,
  ) async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى تسجيل الدخول أولًا',
          ),
        ),
      );

      return;
    }

    try {
      final chatId =
          await _chatService.createChat(
        doctorId: doctor.id,
        doctorName: doctor.name,
        patientName:
            user.displayName ?? 'مريض',
        doctorImage:
            doctor.photoUrl,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(
            chatId: chatId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل إنشاء المحادثة: $e',
          ),
        ),
      );
    }
  }

  Widget _buildChatTile(ChatModel chat, bool isDark) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final name = chat.getDisplayName(userId);
    final photo = chat.getDisplayPhoto(userId);
    final unread = chat.getTotalUnreadCount();

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: photo.isNotEmpty ? CachedNetworkImageProvider(photo) : null,
        child: photo.isEmpty ? Text(name.isNotEmpty ? name[0] : 'م') : null,
      ),
      title: Text(name),
      subtitle: Text(chat.lastMessage ?? 'ابدأ المحادثة'),
      trailing: unread > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unread',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatDetailScreen(chatId: chat.id),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 60, color: isDark ? Colors.grey[600] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text('لا توجد محادثات', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }
}
