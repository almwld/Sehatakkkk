import 'package:sehatak/core/models/doctor_model.dart';
import '../../bloc/doctor_bloc/doctor_bloc.dart';
import 'package:flutter/material.dart';
import '../doctor/doctor_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, dynamic>> _favorites = [
    {'id': '1', 'name': 'د. أحمد محمد', 'specialty': 'طبيب عام'},
    {'id': '2', 'name': 'د. سارة علي', 'specialty': 'أمراض القلب'},
    {'id': '3', 'name': 'د. خالد حسن', 'specialty': 'جراحة العظام'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final item = _favorites[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Text(
                  item['name']?.isNotEmpty == true ? item['name'][0] : 'ط',
                  style: const TextStyle(color: Colors.teal),
                ),
              ),
              title: Text(item['name'] ?? 'طبيب'),
              subtitle: Text(item['specialty'] ?? 'طبيب عام'),
              trailing: const Icon(Icons.favorite, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DoctorDetailsScreen(
                      doctorId: "
                        id: item['id'] ?? '',
                        name: item['name'] ?? '',
                        specialty: item['specialty'] ?? '',
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
