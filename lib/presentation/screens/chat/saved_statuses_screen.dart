import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/localization/app_strings.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';

class SavedStatusesScreen extends StatelessWidget {
  const SavedStatusesScreen({super.key});

  String _t(BuildContext context, String value) =>
      AppStrings.of(context).translate(value);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = StatusService();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(_t(context, 'الحالات المحفوظة'))),
        body: Center(child: Text(_t(context, 'يرجى تسجيل الدخول'))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, 'الحالات المحفوظة')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<UserStatusModel>>(
        stream: service.streamSavedStatuses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(_t(context, 'تعذر تحميل الحالات المحفوظة')));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final statuses = snapshot.data!;
          if (statuses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 52, color: Colors.grey.shade500),
                  const SizedBox(height: 12),
                  Text(_t(context, 'لا توجد حالات محفوظة بعد')),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: statuses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final status = statuses[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(.12),
                    backgroundImage: status.userImage?.isNotEmpty == true
                        ? NetworkImage(status.userImage!)
                        : null,
                    child: status.userImage?.isNotEmpty == true
                        ? null
                        : Text(status.userName.characters.first),
                  ),
                  title: Text(status.userName),
                  subtitle: Text('${status.stories.length} ${_t(context, 'عنصر محفوظ')}'),
                  trailing: IconButton(
                    tooltip: _t(context, 'إزالة من المحفوظات'),
                    icon: const Icon(Icons.bookmark_remove_outlined),
                    onPressed: () => service.removeSavedStatus(status.id),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => StoryViewerScreen(status: status),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
