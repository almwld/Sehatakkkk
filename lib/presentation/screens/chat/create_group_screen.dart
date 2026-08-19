import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/constants/imagekit.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedMembers = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _searchUsers('');
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      setState(() {
        _searchResults = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'مستخدم',
            'image': data['image'] ?? '',
            'isSelected': _selectedMembers.contains(doc.id),
          };
        }).toList();
      });
    } catch (e) {
      print('❌ Search error: $e');
    }
  }

  void _toggleMember(String userId) {
    setState(() {
      if (_selectedMembers.contains(userId)) {
        _selectedMembers.remove(userId);
      } else {
        _selectedMembers.add(userId);
      }
    });
    _searchUsers(_searchController.text);
  }

  Future<void> _createGroup() async {
    final name = _groupNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المجموعة')),
      );
      return;
    }

    if (_selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عضو واحد على الأقل')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final members = [user.uid, ..._selectedMembers];

      final docRef = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .add({
        'name': name,
        'isGroup': true,
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'image': _selectedImage ?? ImageKit.doctor1,
        'members': members,
        'lastMessage': 'تم إنشاء المجموعة',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      // ✅ إضافة الأعضاء كمجموعة فرعية
      for (final memberId in members) {
        await FirebaseFirestore.instance
            .collection('chat_rooms')
            .doc(docRef.id)
            .collection('members')
            .doc(memberId)
            .set({
          'userId': memberId,
          'joinedAt': FieldValue.serverTimestamp(),
          'isAdmin': memberId == user.uid,
        });
      }

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إنشاء المجموعة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل إنشاء المجموعة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء مجموعة جديدة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _selectedMembers.isNotEmpty ? _createGroup : null,
              child: const Text(
                'إنشاء',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ✅ اسم المجموعة
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _groupNameController,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة',
                hintText: 'أدخل اسم المجموعة',
                prefixIcon: Icon(Icons.group),
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // ✅ البحث عن أعضاء
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: _searchUsers,
              decoration: const InputDecoration(
                hintText: '🔍 ابحث عن أعضاء...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ),

          // ✅ الأعضاء المختارين
          if (_selectedMembers.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedMembers.length,
                itemBuilder: (context, index) {
                  final memberId = _selectedMembers[index];
                  final member = _searchResults.firstWhere(
                    (m) => m['id'] == memberId,
                    orElse: () => {'name': 'مستخدم', 'image': ''},
                  );
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(member['name'] ?? 'مستخدم'),
                      onDeleted: () => _toggleMember(memberId),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  );
                },
              ),
            ),

          // ✅ نتائج البحث
          Expanded(
            child: _searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text('لا توجد نتائج'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      final isSelected = user['isSelected'] as bool;

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            user['image'] ?? ImageKit.doctor1,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => CircleAvatar(
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                (user['name'] ?? 'م')[0],
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ),
                          ),
                        ),
                        title: Text(user['name'] ?? 'مستخدم'),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.check_circle_outline, color: Colors.grey),
                        onTap: () => _toggleMember(user['id'] as String),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
