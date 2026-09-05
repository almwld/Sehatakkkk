import 'package:flutter/material.dart';
import 'package:sehatak/presentation/screens/doctor/doctor_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = [
      {'id': '1', 'name': 'د. أحمد المولد', 'specialty': 'باطنية'},
      {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: favorites.isEmpty
          ? const Center(
              child: Text('لا توجد أطباء في المفضلة'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final item = favorites[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(item['name']![0]),
                  ),
                  title: Text(item['name']!),
                  subtitle: Text(item['specialty']!),
                  trailing: const Icon(Icons.favorite, color: Colors.red),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DoctorDetailsScreen(
                          doctorId: item['id']!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}