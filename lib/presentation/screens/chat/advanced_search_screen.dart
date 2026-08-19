import 'package:flutter/material.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class AdvancedSearchScreen extends StatefulWidget {
  final List<Map<String, dynamic>> chats;
  final Function(List<Map<String, dynamic>>) onResults;

  const AdvancedSearchScreen({
    super.key,
    required this.chats,
    required this.onResults,
  });

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'الكل';
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _results = [];

  final List<String> _filters = [
    'الكل',
    'رسائل',
    'مكالمات',
    'صور',
    'فيديو',
    'ملفات',
  ];

  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty && _startDate == null && _endDate == null) {
      setState(() => _results = []);
      return;
    }

    setState(() {
      _results = widget.chats.where((chat) {
        // ✅ البحث بالاسم
        final name = (chat['doctorName'] as String? ?? chat['patientName'] as String? ?? '').toLowerCase();
        final message = (chat['lastMessage'] as String? ?? '').toLowerCase();

        bool matchesQuery = query.isEmpty ||
            name.contains(query) ||
            message.contains(query);

        // ✅ تصفية حسب النوع
        bool matchesFilter = _selectedFilter == 'الكل' ||
            chat['type'] == _selectedFilter;

        // ✅ تصفية حسب التاريخ
        bool matchesDate = true;
        if (_startDate != null) {
          final date = chat['date'] as DateTime?;
          if (date != null && date.isBefore(_startDate!)) {
            matchesDate = false;
          }
        }
        if (_endDate != null) {
          final date = chat['date'] as DateTime?;
          if (date != null && date.isAfter(_endDate!)) {
            matchesDate = false;
          }
        }

        return matchesQuery && matchesFilter && matchesDate;
      }).toList();
    });

    widget.onResults(_results);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث متقدم'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ✅ حقل البحث
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '🔍 ابحث بالاسم أو الكلمات المفتاحية...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
            const SizedBox(height: 16),

            // ✅ فلتر النوع
            Container(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = selected ? filter : 'الكل');
                      },
                      backgroundColor: isDark ? const Color(0xFF1A2540) : Colors.grey[200],
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // ✅ اختيار التاريخ
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(
                    label: 'من',
                    date: _startDate,
                    onChanged: (date) => setState(() => _startDate = date),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker(
                    label: 'إلى',
                    date: _endDate,
                    onChanged: (date) => setState(() => _endDate = date),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ✅ زر البحث
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'بحث',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ✅ النتائج
            Expanded(
              child: _results.isEmpty
                  ? const Center(child: Text('لا توجد نتائج'))
                  : ListView.builder(
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          leading: const Icon(Icons.chat, color: AppColors.primary),
                          title: Text(result['doctorName'] ?? result['patientName'] ?? 'مستخدم'),
                          subtitle: Text(result['lastMessage'] ?? ''),
                          trailing: Text(
                            _formatDate(result['date'] as DateTime?),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required Function(DateTime?) onChanged,
  }) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          locale: const Locale('ar', 'YE'),
        );
        if (picked != null) {
          onChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : label,
              style: TextStyle(
                color: date != null ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
}
