import 'package:flutter/material.dart';
import '../../core/models/doctor_model.dart';
import '../screens/doctor/doctor_details_screen.dart';

class AppSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text('نتائج البحث عن: $query'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorDetailsScreen(
                    doctor: DoctorModel(id: '1', name: 'د. أحمد', specialty: 'طبيب عام'),
                  ),
                ),
              );
            },
            child: const Text('عرض طبيب'),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('ابحث عن أطباء، محادثات، أو ملفات'),
          const SizedBox(height: 8),
          Text('ابحث عن: $query', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
