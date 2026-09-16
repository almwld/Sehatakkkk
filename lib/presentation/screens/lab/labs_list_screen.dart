import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/models/lab/lab_booking_model.dart';
import 'package:sehatak/core/models/lab/lab_booking_status.dart';
import 'package:sehatak/core/services/lab_service.dart';
import 'package:sehatak/presentation/screens/lab/lab_detail_screen.dart';
import 'package:sehatak/presentation/screens/lab/lab_results_screen.dart';
import 'package:sehatak/presentation/widgets/common/app_image.dart';

class LabsListScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const LabsListScreen({super.key, this.scrollController});

  @override
  State<LabsListScreen> createState() => _LabsListScreenState();
}

class _LabsListScreenState extends State<LabsListScreen> with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _searchController = TextEditingController();
  final _labService = LabService();
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  bool _isLoading = true;
  List<Map<String, dynamic>> _labs = [];
  late final TabController _tabController;

  final List<String> _categories = const [
    'الكل', 'دم', 'بول', 'هرمونات', 'فيتامينات', 'أشعة',
    'تحاليل عامة', 'ميكروبيولوجي', 'جينية', 'أورام',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_tabChanged);
    _loadLabs();
  }

  void _tabChanged() {
    if (!_tabController.indexIsChanging && mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _string(dynamic value) => value?.toString().trim() ?? '';
  double _number(dynamic value) => value is num ? value.toDouble() : double.tryParse(_string(value)) ?? 0;
  List<dynamic> _list(dynamic value) => value is List ? value : const [];
  bool _bool(dynamic value) => value == true;

  Future<void> _loadLabs() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('labs').get();
      final labs = snapshot.docs
          .map((doc) => <String, dynamic>{'id': doc.id, ...doc.data()})
          .where((lab) => _string(lab['name']).isNotEmpty)
          .toList();
      labs.sort((a, b) => _number(b['rating']).compareTo(_number(a['rating'])));
      if (!mounted) return;
      setState(() { _labs = labs; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _labs = []; _isLoading = false; });
      _showMessage('تعذر تحميل المختبرات. تحقق من الاتصال وحاول مرة أخرى.');
    }
  }

  List<Map<String, dynamic>> _filtered({bool top = false, bool home = false}) {
    Iterable<Map<String, dynamic>> result = _labs;
    if (top) result = result.where((lab) => _number(lab['rating']) >= 4);
    if (home) result = result.where((lab) => _bool(lab['homeService'] ?? lab['homeCollection'] ?? lab['hasHomeService']));
    if (_selectedCategory != 'الكل') {
      result = result.where((lab) {
        final category = _string(lab['category']);
        final specialties = _list(lab['specialties']);
        return category == _selectedCategory || specialties.any((x) => _string(x) == _selectedCategory);
      });
    }
    final query = _searchQuery.toLowerCase().trim();
    if (query.isNotEmpty) {
      result = result.where((lab) {
        final name = _string(lab['name']).toLowerCase();
        final address = _string(lab['address'] ?? lab['location']).toLowerCase();
        final specialties = _list(lab['specialties']);
        final tests = _list(lab['tests']);
        return name.contains(query) || address.contains(query) ||
            specialties.any((x) => _string(x).toLowerCase().contains(query)) ||
            tests.any((x) => _string(x is Map ? x['name'] : x).toLowerCase().contains(query));
      });
    }
    final list = result.toList();
    list.sort((a, b) => _number(b['rating']).compareTo(_number(a['rating'])));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bookingsSelected = _tabController.index == 3;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1121) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('مختبرات صحتك'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [Tab(text: 'المختبرات'), Tab(text: 'الأفضل'), Tab(text: 'سحب منزلي'), Tab(text: 'حجوزاتي')],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: bookingsSelected
          ? _bookingsView(dark)
          : Column(
              children: [
                _searchBar(dark),
                _categoriesBar(dark),
                Expanded(child: TabBarView(controller: _tabController, children: [
                  _labsView(_filtered(), dark),
                  _labsView(_filtered(top: true), dark),
                  _labsView(_filtered(home: true), dark),
                  _bookingsView(dark),
                ])),
              ],
            ),
    );
  }

  Widget _searchBar(bool dark) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          style: TextStyle(color: dark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'ابحث عن مختبر، تخصص، أو فحص...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }),
            filled: true,
            fillColor: dark ? const Color(0xFF1A2540) : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
          ),
        ),
      );

  Widget _categoriesBar(bool dark) => SizedBox(
        height: 56,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: _categories.length,
          itemBuilder: (_, index) {
            final category = _categories[index];
            final selected = _selectedCategory == category;
            return ChoiceChip(label: Text(category), selected: selected, onSelected: (_) => setState(() => _selectedCategory = category), selectedColor: AppColors.primary, labelStyle: TextStyle(color: selected ? Colors.white : (dark ? Colors.white : Colors.black87)));
          },
          separatorBuilder: (_, __) => const SizedBox(width: 8),
        ),
      );

  Widget _labsView(List<Map<String, dynamic>> labs, bool dark) {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    if (labs.isEmpty) {
      return RefreshIndicator(onRefresh: _loadLabs, child: ListView(children: [const SizedBox(height: 220), Center(child: Text(_labs.isEmpty ? 'لا توجد مختبرات مسجلة حاليًا.' : 'لا توجد نتائج مطابقة للبحث.', style: TextStyle(color: Colors.grey)))]));
    }
    return RefreshIndicator(onRefresh: _loadLabs, child: ListView.builder(controller: widget.scrollController, padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), itemCount: labs.length, itemBuilder: (_, index) => _labCard(labs[index], dark)));
  }

  Widget _labCard(Map<String, dynamic> lab, bool dark) {
    final image = _string(lab['imageUrl'] ?? lab['image']);
    final tests = _list(lab['tests']);
    final home = _bool(lab['homeService'] ?? lab['homeCollection'] ?? lab['hasHomeService']);
    final open = _bool(lab['isOpen'] ?? lab['openNow']);
    return Card(
      color: dark ? const Color(0xFF1A2540) : Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LabDetailScreen(labId: _string(lab['id'])))),
        child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
          SizedBox(width: 82, height: 82, child: ClipRRect(borderRadius: BorderRadius.circular(14), child: image.isNotEmpty ? AppImage(imageUrl: image, fit: BoxFit.cover) : Container(color: AppColors.primary.withOpacity(.1), child: const Icon(Icons.science, color: AppColors.primary, size: 36)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(_string(lab['name']), maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87))), if (lab['isVerified'] == true) const Icon(Icons.verified, size: 19, color: AppColors.primary)]),
            const SizedBox(height: 4),
            Text(_string(lab['address'] ?? lab['location'] ?? 'العنوان غير متوفر'), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: dark ? Colors.grey[400] : Colors.grey[600])),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: [_badge('${_number(lab['rating']).toStringAsFixed(1)} ★', AppColors.primary), _badge(open ? 'مفتوح' : 'مغلق', open ? Colors.green : Colors.grey), if (home) _badge('سحب منزلي', AppColors.primary), if (tests.isNotEmpty) _badge('${tests.length} فحص', AppColors.primary)]),
          ])),
        ])),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(.1), borderRadius: BorderRadius.circular(20)), child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)));

  Widget _bookingsView(bool dark) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text('سجّل الدخول لمتابعة حجوزاتك ونتائجك.'));
    return StreamBuilder<List<LabBookingModel>>(
      stream: _labService.getPatientBookings(user.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('تعذر تحميل الحجوزات الحالية.', style: TextStyle(color: dark ? Colors.white : Colors.black87)));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        final bookings = snapshot.data!;
        if (bookings.isEmpty) return Center(child: Text('لا توجد حجوزات مختبرات حتى الآن.', style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700])));
        return ListView.separated(padding: const EdgeInsets.all(12), itemCount: bookings.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (_, index) => _bookingCard(bookings[index], dark));
      },
    );
  }

  Widget _bookingCard(LabBookingModel booking, bool dark) {
    final completed = booking.status == LabBookingStatus.completed;
    return Card(
      color: dark ? const Color(0xFF1A2540) : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(.1), child: Icon(completed ? Icons.assignment_turned_in : Icons.science, color: AppColors.primary)),
        title: Text(booking.labName, style: TextStyle(fontWeight: FontWeight.bold, color: dark ? Colors.white : Colors.black87)),
        subtitle: Padding(padding: const EdgeInsets.only(top: 6), child: Text('${_statusLabel(booking.status)} • ${booking.tests.length} فحص • ${booking.totalPrice.toStringAsFixed(0)} ر.ي', style: TextStyle(color: dark ? Colors.grey[300] : Colors.grey[700]))),
        trailing: completed && booking.results != null ? TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => LabResultsScreen(bookingId: booking.id))), child: const Text('النتائج')) : const Icon(Icons.chevron_left),
      ),
    );
  }

  String _statusLabel(LabBookingStatus status) {
    switch (status) {
      case LabBookingStatus.pending: return 'قيد الانتظار';
      case LabBookingStatus.sampleTaken: return 'تم أخذ العينة';
      case LabBookingStatus.processing: return 'قيد التحليل';
      case LabBookingStatus.completed: return 'مكتمل';
      case LabBookingStatus.cancelled: return 'ملغي';
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.primary));
}
