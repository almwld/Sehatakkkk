import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatak/core/constants/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _contacts = [
    {'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'image': null},
    {'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'image': null},
    {'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'image': null},
    {'name': 'د. محمد العلاي', 'specialty': 'أنف وأذن وحنجرة', 'image': null},
    {'name': 'د. فاطمة صديقي', 'specialty': 'نساء وولادة', 'image': null},
    {'name': 'د. سارة العمري', 'specialty': 'جلدية', 'image': null},
    {'name': 'د. يوسف الحضرمي', 'specialty': 'عظام', 'image': null},
    {'name': 'د. مريم الشيباني', 'specialty': 'نفسية', 'image': null},
  ];

  void _search(String query) {
    setState(() {
      _isLoading = true;
      if (query.isEmpty) {
        _results = [];
        _isLoading = false;
        return;
      }

      final lowerQuery = query.toLowerCase();
      _results = _contacts.where((contact) {
        return contact['name'].toLowerCase().contains(lowerQuery) ||
            contact['specialty'].toLowerCase().contains(lowerQuery);
      }).toList();
      _isLoading = false;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'م';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return parts[0][0] + parts[1][0];
    }
    return name[0];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0b141a) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0b141a) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _search,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'ابحث عن طبيب، تخصص...',
            hintStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black87),
              onPressed: () {
                HapticFeedback.lightImpact();
                _controller.clear();
                setState(() => _results = []);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty && _controller.text.isNotEmpty
              ? _buildEmptyState(isDark)
              : _results.isEmpty
                  ? _buildRecentSearches(isDark)
                  : _buildResults(isDark),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'حاول البحث بكلمات مختلفة',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 60,
            color: isDark ? Colors.grey[600] : Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث عن طبيب',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب اسم الطبيب أو التخصص',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'باطنية',
              'قلبية',
              'أطفال',
              'نساء وولادة',
              'جلدية',
              'عظام',
            ].map((specialty) {
              return GestureDetector(
                onTap: () {
                  _controller.text = specialty;
                  _search(specialty);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF202c33) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    specialty,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final contact = _results[index];
        return ListTile(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('بدء محادثة مع ${contact['name']}'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              _getInitials(contact['name']),
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            contact['name'],
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            contact['specialty'],
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'استشارة',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
