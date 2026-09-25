import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = true;
  List<Map<String, dynamic>> _favorites = const [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) {
      if (mounted) setState(() { _loading = false; _favorites = const []; });
      return;
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .orderBy('addedAt', descending: true)
          .get();

      final loaded = <Map<String, dynamic>>[];
      for (final favorite in snapshot.docs) {
        final doctorId = favorite.id;
        final doctor = await _firestore.collection('doctors').doc(doctorId).get();
        if (!doctor.exists || doctor.data() == null) continue;

        final data = doctor.data()!;
        final verified = data['isVerified'] == true ||
            data['verificationStatus'] == 'approved';
        if (!verified) continue;

        loaded.add({
          'id': doctor.id,
          'name': (data['name'] ?? 'طبيب').toString(),
          'specialty': (data['specialty'] ?? 'طبيب عام').toString(),
          'photoUrl': (data['photoUrl'] ?? '').toString(),
        });
      }

      if (mounted) {
        setState(() {
          _favorites = loaded;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load favorite doctors: $e');
      if (mounted) {
        setState(() {
          _favorites = const [];
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(
                  child: Text('لا توجد أطباء في المفضلة'),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final item = _favorites[index];
                      final name = item['name'] as String;
                      final photoUrl = item['photoUrl'] as String;

                      return ListTile(
                        leading: photoUrl.isNotEmpty
                            ? CircleAvatar(backgroundImage: NetworkImage(photoUrl))
                            : CircleAvatar(child: Text(name.characters.first)),
                        title: Text(name),
                        subtitle: Text(item['specialty'] as String),
                        trailing: const Icon(Icons.favorite, color: Colors.red),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DoctorDetailsScreen(
                                doctorId: item['id'] as String,
                              ),
                            ),
                          );
                          _loadFavorites();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
