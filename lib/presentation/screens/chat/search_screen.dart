import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/chat/chat_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_model.dart';
import 'chat_room_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<ChatModel> _results = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final state = context.read<ChatBloc>().state;
    if (state is ChatLoaded) {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final filtered = state.chats.where((chat) {
        final name = chat.getDisplayName(uid).toLowerCase();
        return name.contains(query) ||
            (chat.lastMessage?.toLowerCase().contains(query) ?? false) ||
            (chat.groupName?.toLowerCase().contains(query) ?? false);
      }).toList();
      if (!mounted) return;
      setState(() {
        _results = filtered;
        _isSearching = false;
      });
    } else if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  void _openChat(ChatModel chat) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final otherId = chat.getOtherParticipant(uid);
    if (otherId.isEmpty && !chat.isGroup) return;
    final name = chat.getDisplayName(uid);
    final photo = chat.getDisplayPhoto(uid);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatId: chat.id,
          otherUserId: otherId,
          otherUserName: name,
          otherUserImage: photo.isEmpty ? null : photo,
          isGroup: chat.isGroup,
          groupImage: chat.groupPhoto,
          lastMessage: chat.lastMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _controller.text.isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('بحث'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'ابحث عن محادثة...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: _controller.clear,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : !hasQuery
              ? _buildInitialState()
              : _results.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final chat = _results[index];
                        final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                        final name = chat.getDisplayName(uid);
                        final photo = chat.getDisplayPhoto(uid);
                        final lastMessage = chat.lastMessage ?? '';
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                photo.isNotEmpty ? NetworkImage(photo) : null,
                            child: photo.isEmpty
                                ? Text(name.isEmpty ? 'م' : name[0])
                                : null,
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openChat(chat),
                        );
                      },
                    ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('ابحث عن محادثات', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('ابحث عن الأشخاص أو الرسائل', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('لا توجد نتائج', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('حاول البحث بكلمات مختلفة', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
        ],
      ),
    );
  }
}
