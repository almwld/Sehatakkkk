import 'package:sehatak/core/services/cache_service.dart';

class PreloadService {
  static final PreloadService _instance = PreloadService._internal();
  factory PreloadService() => _instance;
  PreloadService._internal();

  final CacheService _cache = CacheService();

  Future<void> preloadEssentialData() async {
    try {
      await Future.wait([
        _preloadDoctors(),
        _preloadPharmacies(),
        _preloadLabs(),
        _preloadHospitals(),
        _preloadMedicines(),
      ]);
      print('✅ Essential data preloaded successfully');
    } catch (e) {
      print('❌ Error preloading data: $e');
    }
  }

  Future<void> _preloadDoctors() async {
    final data = await Future.delayed(
      const Duration(milliseconds: 200),
      () => [
        {'id': '1', 'name': 'د. أحمد المؤيد', 'specialty': 'باطنية', 'image': ImageKit.doctor1},
        {'id': '2', 'name': 'د. خالد النخلاني', 'specialty': 'قلبية', 'image': ImageKit.doctor2},
        {'id': '3', 'name': 'د. أسماء الهندي', 'specialty': 'أطفال', 'image': ImageKit.doctor3},
      ],
    );
    await _cache.saveList('preloaded_doctors', data);
  }

  Future<void> _preloadPharmacies() async {
    final data = await Future.delayed(
      const Duration(milliseconds: 150),
      () => [
        {'id': '1', 'name': 'صيدلية ابن حيان', 'location': 'صنعاء'},
        {'id': '2', 'name': 'صيدلية الشفاء', 'location': 'صنعاء'},
        {'id': '3', 'name': 'صيدلية الأمانة', 'location': 'صنعاء'},
      ],
    );
    await _cache.saveList('preloaded_pharmacies', data);
  }

  Future<void> _preloadLabs() async {
    final data = await Future.delayed(
      const Duration(milliseconds: 150),
      () => [
        {'id': '1', 'name': 'مختبر الرازي', 'location': 'صنعاء'},
        {'id': '2', 'name': 'مختبر العولقي', 'location': 'صنعاء'},
        {'id': '3', 'name': 'مختبر المأمون', 'location': 'صنعاء'},
      ],
    );
    await _cache.saveList('preloaded_labs', data);
  }

  Future<void> _preloadHospitals() async {
    final data = await Future.delayed(
      const Duration(milliseconds: 200),
      () => [
        {'id': '1', 'name': 'مستشفى 22 مايو', 'location': 'صنعاء'},
        {'id': '2', 'name': 'مستشفى الجمهورية', 'location': 'صنعاء'},
        {'id': '3', 'name': 'مستشفى الكويت', 'location': 'صنعاء'},
      ],
    );
    await _cache.saveList('preloaded_hospitals', data);
  }

  Future<void> _preloadMedicines() async {
    final data = await Future.delayed(
      const Duration(milliseconds: 150),
      () => [
        {'id': '1', 'name': 'باراسيتامول 500mg', 'price': 500},
        {'id': '2', 'name': 'فيتامين د 1000IU', 'price': 1200},
        {'id': '3', 'name': 'أموكسيسيلين 500mg', 'price': 1500},
      ],
    );
    await _cache.saveList('preloaded_medicines', data);
  }
}
