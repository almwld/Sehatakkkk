import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/status_model.dart';

class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.statuses,
    required this.onAddStatus,
    required this.onOpenStatus,
  });

  final List<UserStatusModel> statuses;
  final VoidCallback onAddStatus;
  final ValueChanged<UserStatusModel> onOpenStatus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        itemCount: statuses.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          if (index == 0) return _AddStatusButton(onTap: onAddStatus);
          final status = statuses[index - 1];
          return _StatusCircle(status: status, onTap: () => onOpenStatus(status));
        },
      ),
    );
  }
}

class _StatusCircle extends StatelessWidget {
  const _StatusCircle({required this.status, required this.onTap});

  final UserStatusModel status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ringColors = status.isViewed
        ? [Colors.grey.shade400, Colors.grey.shade600]
        : [Colors.purple, Colors.pink, Colors.orange];

    return Semantics(
      button: true,
      label: 'حالة ${status.userName}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 70,
          child: Column(
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
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(.14),
                    backgroundImage: status.userImage?.isNotEmpty == true
                        ? NetworkImage(status.userImage!)
                        : null,
                    child: status.userImage?.isNotEmpty == true
                        ? null
                        : Text(
                            status.userName.isEmpty ? 'م' : status.userName.characters.first,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                status.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
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
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
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
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                'إضافة حالة',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
