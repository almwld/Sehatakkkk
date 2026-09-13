import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sehatak/bloc/doctor_bloc/doctor_bloc.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/chat_model.dart';
import 'package:sehatak/core/models/doctor_model.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/ai/ai_chatbot_screen.dart';
import 'package:sehatak/presentation/screens/chat/add_status_screen.dart';
import 'package:sehatak/presentation/screens/chat/calls_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/widgets/status_row.dart';
import 'package:sehatak/presentation/widgets/health_contacts_section.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final StatusService _statusService = StatusService();
  final TextEditingController _searchController = TextEditingController();
  final PageController _tabPageController = PageController();
  StreamSubscription<List<ChatModel>>? _subscription;
  StreamSubscription<List<UserStatusModel>>? _statusSubscription;
  List<ChatModel> _chats = [];
  List<UserStatusModel> _statuses = [];
  String _search = '';
  bool _loadingChats = true;
  bool _openingChat = false;
  bool _loadingStatuses = true;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _subscribeChats();
    _subscribeStatuses();
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

  void _subscribeStatuses() {
    _statusSubscription?.cancel();
    try {
      _statusSubscription = _statusService.streamActiveStatuses().listen(
        (items) {
          if (!mounted) return;
          setState(() {
            _statuses = items;
            _loadingStatuses = false;
          });
        },
        onError: (error) {
          debugPrint('status list error: $error');
          if (mounted) setState(() => _loadingStatuses = false);
        },
      );
    } catch (error) {
      debugPrint('status subscription error: $error');
      _loadingStatuses = false;
    }
  }

  void _selectTab(int index) {
    if (index < 0 || index > 2 || index == _tabIndex) return;
    setState(() => _tabIndex = index);
    if (_tabPageController.hasClients) {
      _tabPageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onTabPageChanged(int index) {
    if (mounted && _tabIndex != index) {
      setState(() => _tabIndex = index);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _statusSubscription?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabPageController.dispose();
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
      appBar: AppBar(
        title: const Text('الدردشة'),
        centerTitle: true,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: _buildTabs(isDark),
        ),
      ),
      body: PageView(
        controller: _tabPageController,
        onPageChanged: _onTabPageChanged,
        children: [
          _buildConversationsTab(isDark),
          const CallsScreen(),
          _buildContactsTab(isDark),
        ],
      ),
      floatingActionButton: (_tabIndex == 0 || _tabIndex == 2)
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: _openingChat ? null : () => _showDoctorsForNewChat(isDark),
              icon: Image.asset(
                'assets/images/chat/attach_file.png',
                width: 21,
                height: 21,
                color: Colors.white,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              label: const Text('محادثة جديدة', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildTabs(bool isDark) {
    const labels = ['المحادثات', 'المكالمات', 'التواصل الصحي'];
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF162039) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE6EEEE)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = _tabIndex == index;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _selectTab(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF526467)),
                    ),
                    child: Text(labels[index]),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildConversationsTab(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: _searchController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: 'ابحث في محادثاتك...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear),
              filled: true,
              fillColor: isDark ? const Color(0xFF162039) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: _buildAIAssistantCard(isDark),
        ),
        Expanded(child: _buildChatList(isDark)),
      ],
    );
  }

  Widget _buildAIAssistantCard(bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF162039) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Image.asset(
          'assets/images/services/ai_assistant.png',
          width: 46,
          height: 46,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 30),
        ),
        title: const Text('المساعد الصحي الذكي', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('اسأل الآن عن صحتك'),
        trailing: const Icon(Icons.chevron_left),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiChatbotScreen())),
      ),
    );
  }

  Widget _buildChatList(bool isDark) {
    if (_loadingChats) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    final chats = _filteredChats;
    if (chats.isEmpty) {
      return Center(
        child: Text(
          _search.isEmpty ? 'لا توجد محادثات بعد\nابدأ محادثة مع طبيب من تبويب جهات الاتصال' : 'لا توجد نتائج مطابقة',
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