import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/presentation/screens/call/call_screen.dart';

class CallsScreen extends StatefulWidget {
  const CallsScreen({super.key});

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  // بيانات تجريبية للواجهة فقط.
  //
  // ملاحظة أمنية:
  // لا يتم إنشاء chatId أو doctorId وهميين هنا.
  // المكالمة الحقيقية يجب أن تكون مرتبطة بمحادثة حقيقية
  // تم إنشاؤها من خلال ChatService / Backend.
  final List<Map<String, dynamic>> _calls = [
    {
      'name': 'د. أحمد المؤيد',
      'subtitle': 'مكالمة واردة',
      'time': 'اليوم، 10:30 ص',
      'type': 'incoming',
      'image': null,
      'duration': '5:23',
      'chatId': null,
      'doctorId': null,
      'isVideo': false,
    },
    {
      'name': 'د. محمد القاسمي',
      'subtitle': 'مكالمة صادرة',
      'time': 'أمس، 08:45 م',
      'type': 'outgoing',
      'image': null,
      'duration': '12:41',
      'chatId': null,
      'doctorId': null,
      'isVideo': false,
    },
    {
      'name': 'د. سارة عبدالله',
      'subtitle': 'مكالمة فائتة',
      'time': 'أمس، 03:20 م',
      'type': 'missed',
      'image': null,
      'duration': null,
      'chatId': null,
      'doctorId': null,
      'isVideo': false,
    },
    {
      'name': 'د. خالد العريقي',
      'subtitle': 'مكالمة واردة',
      'time': '30 أغسطس، 11:15 ص',
      'type': 'incoming',
      'image': null,
      'duration': '8:17',
      'chatId': null,
      'doctorId': null,
      'isVideo': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF111B21),
        foregroundColor: Colors.white,
        title: const Text(
          'المكالمات',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _calls.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      24,
                    ),
                    itemCount: _calls.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      return _buildCallTile(_calls[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF111B21),
            Color(0xFF0B141A),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickAction(
              icon: Icons.phone_outlined,
              label: 'اتصال',
              color: AppColors.primary,
              onTap: () {
                HapticFeedback.mediumImpact();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'لإجراء مكالمة، افتح محادثة الطبيب أولاً.',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickAction(
              icon: Icons.videocam_outlined,
              label: 'فيديو',
              color: AppColors.info,
              onTap: () {
                HapticFeedback.mediumImpact();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'لإجراء مكالمة فيديو، افتح محادثة الطبيب أولاً.',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFF1F2C34),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: 25,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallTile(Map<String, dynamic> call) {
    final name = call['name']?.toString() ?? 'طبيب';
    final subtitle = call['subtitle']?.toString() ?? '';
    final time = call['time']?.toString() ?? '';
    final type = call['type']?.toString() ?? '';
    final duration = call['duration']?.toString();
    final image = call['image']?.toString();
    final isVideo = call['isVideo'] == true;

    final isMissed = type == 'missed';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _buildCallScreenForRecord(call),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111B21),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              _buildAvatar(
                name: name,
                image: image,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          _getCallTypeIcon(type),
                          size: 16,
                          color: isMissed
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isMissed
                                  ? AppColors.error
                                  : Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (isVideo) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.videocam_outlined,
                            size: 16,
                            color: Colors.white54,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (duration != null && duration.isNotEmpty)
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isVideo
                          ? Icons.videocam_outlined
                          : Icons.phone_outlined,
                      color: AppColors.primary,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar({
    required String name,
    String? image,
  }) {
    if (image != null && image.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          image,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildDefaultAvatar(name);
          },
        ),
      );
    }

    return _buildDefaultAvatar(name);
  }

  Widget _buildDefaultAvatar(String name) {
    final firstLetter = name.trim().isNotEmpty
        ? name.trim().substring(0, 1)
        : 'ط';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        firstLetter,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getCallTypeIcon(String type) {
    switch (type) {
      case 'incoming':
        return Icons.call_received_rounded;
      case 'outgoing':
        return Icons.call_made_rounded;
      case 'missed':
        return Icons.call_missed_rounded;
      default:
        return Icons.phone_rounded;
    }
  }

  Widget _buildCallScreenForRecord(
    Map<String, dynamic> call,
  ) {
    final chatId = call['chatId']?.toString();

    if (chatId == null || chatId.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B141A),
        appBar: AppBar(
          title: const Text('المكالمة'),
          backgroundColor: const Color(0xFF111B21),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone_disabled_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'هذه المكالمة التجريبية غير مرتبطة بمحادثة حقيقية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'افتح المحادثة المرتبطة بالطبيب لبدء مكالمة آمنة.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('العودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CallScreen(
      chatId: chatId,
      doctorName: call['name']?.toString() ?? 'طبيب',
      doctorId: call['doctorId']?.toString() ?? '',
      isVideo: call['isVideo'] == true,
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.phone_disabled_outlined,
              color: Colors.white38,
              size: 64,
            ),
            SizedBox(height: 18),
            Text(
              'لا توجد مكالمات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'ستظهر مكالماتك هنا عند إجراء مكالمة مع طبيب.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
