import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/status_model.dart';
import 'package:sehatak/core/services/chat_service.dart';
import 'package:sehatak/core/services/status_service.dart';
import 'package:sehatak/presentation/screens/chat/add_status_screen.dart';
import 'package:sehatak/presentation/screens/chat/chat_room_screen.dart';
import 'package:sehatak/presentation/screens/chat/story_viewer_screen.dart';
import 'package:sehatak/presentation/widgets/status_row.dart';

class HealthContactsSection extends StatefulWidget {
  final bool isDark;
  const HealthContactsSection({super.key, required this.isDark});

  @override
  State<HealthContactsSection> createState() => _HealthContactsSectionState();
}

class _HealthContactsSectionState extends State<HealthContactsSection> {
  final StatusService _statusService = StatusService();
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  Stream<List<UserStatusModel>>? _statusStream;
  Future<List<_DirectoryRecord>>? _directoryFuture;
  String _search = '';
  bool _opening = false;

  @override
  void initState() {
    super.initState();
    _statusStream = _statusService.streamActiveStatuses();
    _directoryFuture = _loadDirectory();
    _searchController.addListener(() {
      if (mounted) setState(() => _search = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserStatusModel>>(
      stream: _statusStream,
      builder: (context, statusSnapshot) {
        final statuses = statusSnapshot.data ?? const <UserStatusModel>[];
        return FutureBuilder<List<_DirectoryRecord>>(
          future: _directoryFuture,
          builder: (context, directorySnapshot) {
            if (directorySnapshot.connectionState == ConnectionState.waiting && !directorySnapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            final records = directorySnapshot.data ?? const <_DirectoryRecord>[];
            return Column(
              children: [
                _buildStatuses(statuses),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'ابحث في التواصل الصحي...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _search.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: _searchController.clear),
                      filled: true,
                      fillColor: widget.isDark ? const Color(0xFF162039) : Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                Expanded(child: _buildDirectory(records)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatuses(List<UserStatusModel> statuses) {
    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(bottom: BorderSide(color: widget.isDark ? Colors.white10 : const Color(0xFFE7EEEE))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text('الحالات اليومية', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
          SizedBox(
            height: 112,
            child: statuses.isEmpty
                ? Center(child: Text('لا توجد حالات يومية حالياً', style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black45)))
                : StatusRow(
                    statuses: statuses,
                    currentUserId: FirebaseAuth.instance.currentUser?.uid,
                    onAddStatus: _openAddStatus,
                    onOpenStatus: _openStatus,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectory(List<_DirectoryRecord> all) {
    final grouped = <String, List<_DirectoryRecord>>{};
    for (final record in all) {
      if (_search.isNotEmpty && !record.searchText.contains(_search)) continue;
      grouped.putIfAbsent(record.category, () => <_DirectoryRecord>[]).add(record);
    }

    const order = <String>[
      'أطباء',
      'صيدليات',
      'مرافق صحية',
      'مستشفيات',
      'مختبرات',
      'مندوب توصيل',
      'مسعف ميداني',
      'عينة مخبر منزلي',
    ];
    final visible = order.where((title) => grouped[title]?.isNotEmpty ?? false).toList();
    if (visible.isEmpty) {
      return Center(child: Text(_search.isEmpty ? 'لا توجد حسابات صحية متاحة للتواصل حالياً.' : 'لا توجد نتائج مطابقة.', style: TextStyle(color: widget.isDark ? Colors.white70 : Colors.black54)));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
      itemCount: visible.length,
      itemBuilder: (_, index) => _buildCategory(visible[index], grouped[visible[index]]!),
    );
  }

  Widget _buildCategory(String title, List<_DirectoryRecord> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 12, 2, 7),
          child: Row(
            children: [
              Container(width: 4, height: 22, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text('${items.length}', style: TextStyle(color: widget.isDark ? Colors.white54 : Colors.black45, fontSize: 12)),
            ],
          ),
        ),
        ...items.map(_buildContactCard),
      ],
    );
  }

  Widget _buildContactCard(_DirectoryRecord item) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: widget.isDark ? const Color(0xFF162039) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppColors.primary.withOpacity(.12),
          backgroundImage: item.image.isNotEmpty ? NetworkImage(item.image) : null,
          child: item.image.isEmpty ? Icon(item.icon, color: AppColors.primary) : null,
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(item.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
        onTap: item.userId.isEmpty ? null : () => _openChat(item),
      ),
    );
  }

  Future<List<_DirectoryRecord>> _loadDirectory() async {
    final records = <_DirectoryRecord>[];
    final self = FirebaseAuth.instance.currentUser?.uid;

    void add(String category, String id, Map<String, dynamic> data, IconData icon) {
      final userId = (data['userId'] ?? data['uid'] ?? data['ownerId'] ?? id).toString();
      if (userId.isEmpty || userId == self) return;
      final name = (data['name'] ?? data['displayName'] ?? data['title'] ?? 'حساب صحي').toString().trim();
      final image = (data['photoUrl'] ?? data['imageUrl'] ?? data['logoUrl'] ?? data['photo'] ?? '').toString();
      final subtitle = (data['specialty'] ?? data['description'] ?? data['address'] ?? data['location'] ?? category).toString().trim();
      records.add(_DirectoryRecord(category: category, userId: userId, name: name.isEmpty ? 'حساب صحي' : name, image: image, subtitle: subtitle.isEmpty ? category : subtitle, icon: icon, data: data));
    }

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> collection(String name) async {
      try {
        return (await FirebaseFirestore.instance.collection(name).limit(100).get()).docs;
      } catch (e) {
        debugPrint('health directory $name error: $e');
        return const [];
      }
    }

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> healthRole(String role) async {
      try {
        return (await FirebaseFirestore.instance.collection('health_contacts').where('role', isEqualTo: role).limit(100).get()).docs;
      } catch (e) {
        debugPrint('health directory role $role error: $e');
        return const [];
      }
    }

    final results = await Future.wait([
      collection('doctors'),
      collection('pharmacies'),
      collection('hospitals'),
      collection('labs'),
      healthRole('delivery'),
      healthRole('paramedic'),
      healthRole('service'),
    ]);

    for (final d in results[0]) add('أطباء', d.id, d.data(), Icons.medical_services_outlined);
    for (final d in results[1]) add('صيدليات', d.id, d.data(), Icons.local_pharmacy_outlined);
    for (final d in results[2]) add('مستشفيات', d.id, d.data(), Icons.local_hospital_outlined);
    for (final d in results[3]) {
      add('مختبرات', d.id, d.data(), Icons.science_outlined);
      if (_isHomeSample(d.data())) add('عينة مخبر منزلي', d.id, d.data(), Icons.home_work_outlined);
    }
    for (final d in results[4]) add('مندوب توصيل', d.id, d.data(), Icons.delivery_dining);
    for (final d in results[5]) add('مسعف ميداني', d.id, d.data(), Icons.emergency);
    for (final d in results[6]) add(_isHospital(d.data()) ? 'مستشفيات' : 'مرافق صحية', d.id, d.data(), Icons.health_and_safety_outlined);
    return records;
  }

  bool _isHospital(Map<String, dynamic> data) {
    final value = '${data['type'] ?? ''} ${data['facilityType'] ?? ''} ${data['category'] ?? ''} ${data['name'] ?? ''}'.toLowerCase();
    return value.contains('hospital') || value.contains('مستشفى');
  }

  bool _isHomeSample(Map<String, dynamic> data) {
    final value = '${data['homeSample'] ?? ''} ${data['homeCollection'] ?? ''} ${data['serviceType'] ?? ''} ${data['services'] ?? ''} ${data['name'] ?? ''}'.toLowerCase();
    return value.contains('true') || value.contains('home') || value.contains('منزلي') || value.contains('منزل');
  }

  Future<void> _openAddStatus() async {
    if (!mounted) return;
    final created = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => const AddStatusScreen()));
    if (created == true && mounted) setState(() => _statusStream = _statusService.streamActiveStatuses());
  }

  Future<void> _openStatus(UserStatusModel status) async {
    if (!mounted || status.stories.isEmpty) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => StoryViewerScreen(status: status)));
  }

  Future<void> _openChat(_DirectoryRecord item) async {
    if (_opening) return;
    final current = FirebaseAuth.instance.currentUser;
    if (current == null || item.userId.isEmpty) return;
    setState(() => _opening = true);
    try {
      final me = await FirebaseFirestore.instance.collection('users').doc(current.uid).get();
      final data = me.data() ?? const <String, dynamic>{};
      final chatId = await _chatService.createChat(
        doctorId: item.userId,
        doctorName: item.name,
        patientName: (data['name'] ?? current.displayName ?? 'مستخدم').toString(),
        doctorImage: item.image.isEmpty ? null : item.image,
        patientImage: (data['photoUrl'] ?? current.photoURL)?.toString(),
      );
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(chatId: chatId, otherUserId: item.userId, otherUserName: item.name, otherUserImage: item.image.isEmpty ? null : item.image, isGroup: false)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تعذر فتح المحادثة: $e')));
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }
}

class _DirectoryRecord {
  final String category, userId, name, image, subtitle;
  final IconData icon;
  final Map<String, dynamic> data;
  const _DirectoryRecord({required this.category, required this.userId, required this.name, required this.image, required this.subtitle, required this.icon, required this.data});
  String get searchText => '$category $name $subtitle ${data['specialty'] ?? ''} ${data['location'] ?? ''}'.toLowerCase();
}
