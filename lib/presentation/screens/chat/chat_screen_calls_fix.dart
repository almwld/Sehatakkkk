  // ============================================================
  // 📞 قائمة المكالمات
  // ============================================================
  Widget _buildCallsList(bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state is ChatLoading) {
          return const ChatShimmer();
        }
        if (state is ChatError) {
          return _buildErrorState(isDark);
        }

        final calls = _sampleCalls;
        
        if (calls.isEmpty) {
          return _buildEmptyState(
            isDark,
            'لا توجد مكالمات',
            'سجل المكالمات فارغ',
            'assets/images/ui/phone_call.png',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return _buildCallCard(call, isDark);
          },
        );
      },
    );
  }
