import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';
import 'package:sehatak/presentation/screens/chat/chat_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final ScrollController? scrollController;

  const ChatScreen({super.key, this.scrollController});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // ... باقي الدوال كما هي مع استخدام widget.scrollController

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverAppBar(
            title: const Text('المحادثات'),
            backgroundColor: isDark ? const Color(0xFF0B1121) : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            elevation: 0,
            floating: true,
            pinned: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: _isLoading
                ? const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                : _chats.isEmpty
                    ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildChatItem(_chats[index], isDark),
                          childCount: _chats.length,
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  // ... باقي الدوال
}
