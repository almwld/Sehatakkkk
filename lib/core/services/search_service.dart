import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ البحث الشامل
  Future<Map<String, List<dynamic>>> searchAll(String query) async {
    final results = <String, List<dynamic>>{};

    if (query.isEmpty) return results;

    try {
      final futures = [
        _searchDoctors(query),
        _searchPharmacies(query),
        _searchLabs(query),
        _searchHospitals(query),
        _searchServices(query),
      ];

      final allResults = await Future.wait(futures);

      results['doctors'] = allResults[0];
      results['pharmacies'] = allResults[1];
      results['labs'] = allResults[2];
      results['hospitals'] = allResults[3];
      results['services'] = allResults[4];

    } catch (e) {
      print('Error searching: $e');
    }

    return results;
  }

  // ✅ البحث عن الأطباء
  Future<List<Map<String, dynamic>>> _searchDoctors(String query) async {
    try {
      final snap = await _firestore
          .collection('doctors')
          .where('isAvailable', isEqualTo: true)
          .get();

      final results = snap.docs.where((doc) {
        final data = doc.data();
        final name = data['name']?.toLowerCase() ?? '';
        final specialty = data['specialty']?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return name.contains(search) || specialty.contains(search);
      }).map((doc) => doc.data()).toList();

      return results;
    } catch (e) {
      return [];
    }
  }

  // ✅ البحث عن الصيدليات
  Future<List<Map<String, dynamic>>> _searchPharmacies(String query) async {
    try {
      final snap = await _firestore
          .collection('pharmacies')
          .where('isOpen', isEqualTo: true)
          .get();

      final results = snap.docs.where((doc) {
        final data = doc.data();
        final name = data['name']?.toLowerCase() ?? '';
        final address = data['address']?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return name.contains(search) || address.contains(search);
      }).map((doc) => doc.data()).toList();

      return results;
    } catch (e) {
      return [];
    }
  }

  // ✅ البحث عن المختبرات
  Future<List<Map<String, dynamic>>> _searchLabs(String query) async {
    try {
      final snap = await _firestore
          .collection('labs')
          .where('isAvailable', isEqualTo: true)
          .get();

      final results = snap.docs.where((doc) {
        final data = doc.data();
        final name = data['name']?.toLowerCase() ?? '';
        final location = data['location']?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return name.contains(search) || location.contains(search);
      }).map((doc) => doc.data()).toList();

      return results;
    } catch (e) {
      return [];
    }
  }

  // ✅ البحث عن المستشفيات
  Future<List<Map<String, dynamic>>> _searchHospitals(String query) async {
    try {
      final snap = await _firestore
          .collection('hospitals')
          .where('isActive', isEqualTo: true)
          .get();

      final results = snap.docs.where((doc) {
        final data = doc.data();
        final name = data['name']?.toLowerCase() ?? '';
        final location = data['location']?.toLowerCase() ?? '';
        final search = query.toLowerCase();
        return name.contains(search) || location.contains(search);
      }).map((doc) => doc.data()).toList();

      return results;
    } catch (e) {
      return [];
    }
  }

  // ✅ البحث عن الخدمات
  Future<List<Map<String, dynamic>>> _searchServices(String query) async {
    final services = [
      {'id': 's1', 'name': 'استشارة طبية', 'category': 'استشارات', 'icon': 'medical_services'},
      {'id': 's2', 'name': 'فحص سريري', 'category': 'فحوصات', 'icon': 'health_and_safety'},
      {'id': 's3', 'name': 'توصيل أدوية', 'category': 'توصيل', 'icon': 'delivery_dining'},
      {'id': 's4', 'name': 'تحاليل مختبر', 'category': 'مختبرات', 'icon': 'science'},
      {'id': 's5', 'name': 'أشعة وتشخيص', 'category': 'تشخيص', 'icon': 'radiology'},
      {'id': 's6', 'name': 'علاج طبيعي', 'category': 'علاج', 'icon': 'fitness_center'},
      {'id': 's7', 'name': 'تطعيمات', 'category': 'وقاية', 'icon': 'vaccines'},
      {'id': 's8', 'name': 'رعاية منزلية', 'category': 'رعاية', 'icon': 'home_health'},
      {'id': 's9', 'name': 'استشارة نفسية', 'category': 'استشارات', 'icon': 'psychology'},
      {'id': 's10', 'name': 'فحص نظر', 'category': 'فحوصات', 'icon': 'visibility'},
      {'id': 's11', 'name': 'علاج أسنان', 'category': 'علاج', 'icon': 'dental'},
      {'id': 's12', 'name': 'جراحة عامة', 'category': 'جراحة', 'icon': 'surgical'},
    ];

    final search = query.toLowerCase();
    return services.where((service) {
      final name = service['name']?.toLowerCase() ?? '';
      final category = service['category']?.toLowerCase() ?? '';
      return name.contains(search) || category.contains(search);
    }).toList();
  }

  // ✅ البحث المتقدم مع الفلاتر
  Future<Map<String, List<dynamic>>> advancedSearch({
    required String query,
    String? category,
    String? location,
    double? minRating,
    double? maxPrice,
    bool? isAvailable,
    String? sortBy,
    int? limit,
  }) async {
    final results = <String, List<dynamic>>{};

    try {
      var doctorsQuery = _firestore.collection('doctors').where('isAvailable', isEqualTo: true);

      if (category != null) {
        doctorsQuery = doctorsQuery.where('specialty', isEqualTo: category);
      }

      if (minRating != null) {
        doctorsQuery = doctorsQuery.where('rating', isGreaterThanOrEqualTo: minRating);
      }

      if (limit != null) {
        doctorsQuery = doctorsQuery.limit(limit);
      }

      final snap = await doctorsQuery.get();
      results['doctors'] = snap.docs.map((doc) => doc.data()).toList();

    } catch (e) {
      print('Error in advanced search: $e');
    }

    return results;
  }

  // ✅ البحث السريع (Auto-complete)
  Future<List<String>> getSuggestions(String query) async {
    if (query.isEmpty) return [];

    final suggestions = <String>[];
    final search = query.toLowerCase();

    try {
      final doctors = await _firestore
          .collection('doctors')
          .limit(5)
          .get();
      
      for (final doc in doctors.docs) {
        final name = doc.data()['name'] ?? '';
        if (name.toLowerCase().contains(search)) {
          suggestions.add(name);
        }
      }

      final pharmacies = await _firestore
          .collection('pharmacies')
          .limit(5)
          .get();
      
      for (final doc in pharmacies.docs) {
        final name = doc.data()['name'] ?? '';
        if (name.toLowerCase().contains(search)) {
          suggestions.add(name);
        }
      }

      final specialties = [
        'باطنية', 'قلبية', 'أطفال', 'نساء وولادة', 'أنف وأذن وحنجرة',
        'جلدية', 'عظام ومفاصل', 'جراحة عامة', 'مسالك بولية', 'أعصاب',
        'نفسية', 'أورام', 'غدد صماء', 'طوارئ', 'تخدير'
      ];

      for (final specialty in specialties) {
        if (specialty.contains(search)) {
          suggestions.add(specialty);
        }
      }

    } catch (e) {
      print('Error getting suggestions: $e');
    }

    return suggestions.take(10).toList();
  }

  // ✅ حفظ سجل البحث
  Future<void> saveSearchHistory(String userId, String query) async {
    try {
      await _firestore.collection('search_history').add({
        'userId': userId,
        'query': query,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving search history: $e');
    }
  }

  // ✅ جلب سجل البحث
  Future<List<String>> getSearchHistory(String userId) async {
    try {
      final snap = await _firestore
          .collection('search_history')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      return snap.docs.map((doc) => doc.data()['query'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ✅ حذف سجل البحث
  Future<void> clearSearchHistory(String userId) async {
    try {
      final snap = await _firestore
          .collection('search_history')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error clearing search history: $e');
    }
  }
}
