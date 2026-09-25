import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:sehatak/core/constants/app_colors.dart';
import 'package:sehatak/core/services/toast_service.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';
import 'package:sehatak/presentation/widgets/common/custom_app_bar.dart';

class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({super.key});

  @override
  State<FavoriteDoctorsScreen> createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
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
        final doctor = await _firestore.collection('doctors').doc(favorite.id).get();
        if (!doctor.exists || doctor.data() == null) continue;

        final data = doctor.data()!;
        final verified = data['isVerified'] == true ||
            data['verificationStatus'] == 'approved';
        if (!verified) continue;

        loaded.add({
          'id': doctor.id,
          'name': (data['name'] ?? 'طبيب').toString(),
          'specialty': (data['specialty'] ?? 'طبيب عام').toString(),
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
      if (mounted) setState(() { _favorites = const []; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الأطباء المفضلين',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text('لا يوجد أطباء مضافون إلى المفضلة'))
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _favorites.length,
                    itemBuilder: (context, index) {
                      final doctor = _favorites[index];
                      final name = doctor['name'] as String;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            child: Text(
                              name.characters.first,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(doctor['specialty'] as String),
                          trailing: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorDetailsScreen(
                                  doctorId: doctor['id'] as String,
                                ),
                              ),
                            );
                            _loadFavorites();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
