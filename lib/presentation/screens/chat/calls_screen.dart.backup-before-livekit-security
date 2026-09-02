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
  final List<Map<String, dynamic>> _calls = [
    {
      'name': 'د. أحمد المؤيد',
      'subtitle': 'مكالمة واردة',
      'time': 'اليوم، 10:30 ص',
      'type': 'incoming',
      'image': null,
      'duration': '5:23',
    },
    {
      'name': 'د. خالد النخلاني',
      'subtitle': 'مكالمة فائتة',
      'time': 'أمس، 2:15 م',
      'type': 'missed',
      'image': null,
      'duration': '',
    },
    {
      'name': 'د. أسماء الهندي',
      'subtitle': 'مكالمة صادرة',
      'time': 'أمس، 11:45 ص',
      'type': 'outgoing',
      'image': null,
      'duration': '12:30',
    },
    {
      'name': 'د. محمد العلاي',
      'subtitle': 'مكالمة فيديو واردة',
      'time': 'الجمعة، 8:00 م',
      'type': 'incoming',
      'image': null,
      'duration': '8:15',
    },
    {
      'name': 'د. فاطمة صديقي',
      'subtitle': 'مكالمة فائتة (فيديو)',
      'time': 'الجمعة، 7:30 م',
      'type': 'missed',
      'image': null,
      'duration': '',
    },
    {
      'name': 'د. سارة العمري',
      'subtitle': 'مكالمة واردة',
      'time': 'الخميس، 4:20 م',
      'type': 'incoming',
      'image': null,
      'duration': '3:45',
    },
  ];

  String _getInitials(String name) {
    if (name.isEmpty) return 'م';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return name[0];
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.teal,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.indigo,
      Colors.pink,
    ];
    final index = name.hashCode.abs() % colors.length;
    return colors[index];
  }

  IconData _getCallIcon(String type) {
    switch (type) {
      case 'incoming':
        return Icons.call_received;
      case 'missed':
        return Icons.phone_missed;
      case 'outgoing':
        return Icons.call_made;
      default:
        return Icons.phone;
    }
  }

  Color _getCallColor(String type) {
    switch (type) {
      case 'missed':
        return Colors.red;
      case 'incoming':
        return Colors.green;
      case 'outgoing':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0b141a) : const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // ✅ أزرار المكالمات السريعة
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  icon: Icons.favorite,
                  label: 'المفضلة',
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                _buildQuickAction(
                  icon: Icons.person_add,
                  label: 'جهات اتصال',
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                _buildQuickAction(
                  icon: Icons.history,
                  label: 'السجل',
                  onTap: () {
                    HapticFeedback.lightImpact();
                  },
                ),
                _buildQuickAction(
                  icon: Icons.phone,
                  label: 'اتصال',
                  color: AppColors.primary,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CallScreen(
                          chatId: 'new_call',
                          doctorName: 'طبيب',
                          doctorId: 'new',
                          isVideo: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ✅ قائمة المكالمات
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _calls.length,
              itemBuilder: (context, index) {
                final call = _calls[index];
                return _buildCallTile(call, isDark);
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
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallTile(Map<String, dynamic> call, bool isDark) {
    final name = call['name'] as String;
    final subtitle = call['subtitle'] as String;
    final time = call['time'] as String;
    final type = call['type'] as String;
    final duration = call['duration'] as String;
    final icon = _getCallIcon(type);
    final color = _getCallColor(type);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CallScreen(
              chatId: 'call_${DateTime.now().millisecondsSinceEpoch}',
              doctorName: name,
              doctorId: 'doctor_${name.hashCode}',
              isVideo: type == 'incoming' && subtitle.contains('فيديو'),
            ),
          ),
        );
      },
      onLongPress: () {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم الضغط المطول على مكالمة $name'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // ✅ صورة المستخدم
            CircleAvatar(
              radius: 24,
              backgroundColor: _getAvatarColor(name),
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // ✅ معلومات المكالمة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      if (duration.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            duration,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // ✅ الوقت
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
