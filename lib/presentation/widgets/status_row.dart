import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/status_model.dart';

class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.statuses,
    required this.onAddStatus,
    required this.onOpenStatus,
    this.currentUserId,
  });

  final List<UserStatusModel> statuses;
  final VoidCallback onAddStatus;
  final ValueChanged<UserStatusModel> onOpenStatus;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final mine = currentUserId == null
        ? null
        : statuses.cast<UserStatusModel?>().firstWhere(
            (status) => status?.userId == currentUserId,
            orElse: () => null,
          );
    final others = statuses.where((status) => status.userId != currentUserId).toList();

    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: others.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          if (index == 0) {
            if (mine != null) {
              return _StatusCircle(
                status: mine,
                isMine: true,
                onTap: () => onOpenStatus(mine),
                onAddStatus: onAddStatus,
              );
            }
            return _AddStatusButton(onTap: onAddStatus);
          }
          final status = others[index - 1];
          return _StatusCircle(
            status: status,
            isMine: false,
            onTap: () => onOpenStatus(status),
          );
        },
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({
    required this.status,
    required this.onTap,
    required this.isMine,
    this.onAddStatus,
  });
  final UserStatusModel status;
  final VoidCallback onTap;
  final bool isMine;
  final VoidCallback? onAddStatus;

  @override
  Widget build(BuildContext context) {
    final ringColors = isMine
        ? [Colors.green.shade600, Colors.green.shade400]
        : status.isViewed
            ? [Colors.grey.shade400, Colors.grey.shade600]
            : [Colors.purple, Colors.pink, Colors.orange];
    final story = status.stories.firstWhere(
      (item) => item.type == 'image' && item.url.isNotEmpty,
      orElse: () => status.stories.first,
    );

    Widget content;
    if (story.type == 'image' && story.url.isNotEmpty) {
      content = Image.network(story.url, fit: BoxFit.cover, width: double.infinity, height: double.infinity, errorBuilder: (_, __, ___) => _fallback(story));
    } else {
      content = _fallback(story);
    }

    return Semantics(
      button: true,
      label: 'حالة ' + status.userName,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 70,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: ringColors),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(child: content),
                    ),
                  ),
                  if (isMine && onAddStatus != null)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: GestureDetector(
                        onTap: onAddStatus,
                        child: Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 15),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              Text(isMine ? 'حالتك' : status.userName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback(StoryItem story) {
    if (story.type == 'video') {
      return Container(color: Colors.black87, alignment: Alignment.center, child: const Icon(Icons.play_circle_fill, color: Colors.white, size: 30));
    }
    final text = story.text?.trim();
    return Container(
      color: AppColors.primary.withOpacity(.14),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Text(text != null && text.isNotEmpty ? text : 'حالتك', maxLines: 3, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 10)),
    );
  }
}
class _AddStatusButton extends StatelessWidget {
  const _AddStatusButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'إضافة حالة',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 70,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFE9F6F4),
                      child: Icon(Icons.person_outline, color: AppColors.primary, size: 30),
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.add, color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text('إضافة حالة', maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
