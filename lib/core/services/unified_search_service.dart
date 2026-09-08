import 'package:cloud_firestore/cloud_firestore.dart';

class UnifiedSearchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<UnifiedSearchResult>> search(String rawQuery, {int perCollectionLimit = 150}) async {
    final query = normalize(rawQuery);
    if (query.isEmpty) return const [];
    final futures = <Future<List<UnifiedSearchResult>>>[
      _collection('doctors', 'doctor', perCollectionLimit, query, fields: ['name', 'specialty', 'bio', 'city'], verifiedOnly: true),
      _collection('pharmacies', 'pharmacy', perCollectionLimit, query, fields: ['name', 'address', 'city']),
      _collection('labs', 'lab', perCollectionLimit, query, fields: ['name', 'location', 'city', 'specialties']),
      _collection('hospitals', 'hospital', perCollectionLimit, query, fields: ['name', 'location', 'city', 'specialties']),
      _collection('products', 'product', perCollectionLimit, query, fields: ['name', 'category', 'description', 'brand'], publishedOnly: true),
      _collection('drug_catalog', 'drug', perCollectionLimit, query, fields: ['name', 'genericName', 'brandName', 'category', 'uses']),
      _collection('articles', 'article', perCollectionLimit, query, fields: ['title', 'category', 'content', 'tags'], publishedOnly: true),
      _collection('community_posts', 'post', perCollectionLimit, query, fields: ['title', 'content', 'category', 'tags', 'userName'], publishedOnly: true),
    ];
    final batches = await Future.wait(futures);
    final results = batches.expand((e) => e).toList()..addAll(_healthTopics(query))..addAll(_serviceTopics(query));
    results.sort((a, b) => b.score.compareTo(a.score));
    final seen = <String>{};
    return results.where((r) => seen.add('${r.type}:${r.id}')).take(120).toList();
  }

  Future<List<UnifiedSearchResult>> _collection(String collection, String type, int limit, String query, {required List<String> fields, bool verifiedOnly = false, bool publishedOnly = false}) async {
    try {
      Query<Map<String, dynamic>> request = _db.collection(collection).limit(limit);
      if (publishedOnly) request = request.where('isPublished', isEqualTo: true);
      if (verifiedOnly) request = request.where('isVerified', isEqualTo: true);
      final snapshot = await request.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final searchable = fields.map((f) => _value(data[f])).join(' ');
        final normalized = normalize(searchable);
        final title = _title(data, type);
        final subtitle = _subtitle(data, type);
        final score = _score(query, normalized, normalize(title), normalize(subtitle));
        return UnifiedSearchResult(id: doc.id, type: type, title: title, subtitle: subtitle, imageUrl: (data['imageUrl'] ?? data['photoUrl'] ?? data['image'] ?? data['avatar'] ?? '').toString(), data: data, score: score);
      }).where((r) => r.score > 0).toList();
    } catch (_) {
      return const [];
    }
  }

  int _score(String query, String searchable, String title, String subtitle) {
    if (!searchable.contains(query) && !query.split(' ').any((t) => t.length > 1 && searchable.contains(t))) return 0;
    var score = 2;
    if (title == query) score += 30;
    if (title.startsWith(query)) score += 18;
    if (title.contains(query)) score += 12;
    if (subtitle.contains(query)) score += 7;
    for (final token in query.split(' ')) {
      if (token.length > 1 && searchable.contains(token)) score += 3;
    }
    return score;
  }

  List<UnifiedSearchResult> _healthTopics(String query) {
    const topics = [
      ('blood_pressure', 'ضغط الدم', 'المؤشرات الحيوية والصحة', '/dashboard'), ('blood_sugar', 'سكر الدم', 'متابعة الجلوكوز', '/dashboard'), ('weight', 'الوزن', 'متابعة الوزن', '/dashboard'), ('mental_health', 'الصحة النفسية', 'الدعم والصحة النفسية', '/dashboard'), ('nutrition', 'التغذية', 'التغذية الصحية', '/dashboard'), ('sleep', 'النوم', 'متابعة النوم', '/dashboard'), ('fitness', 'اللياقة', 'النشاط واللياقة', '/dashboard'),
    ];
    return topics.where((t) => normalize('${t.$2} ${t.$3}').contains(query) || query.contains(normalize(t.$2))).map((t) => UnifiedSearchResult(id: t.$1, type: 'health', title: t.$2, subtitle: t.$3, route: t.$4, score: 20)).toList();
  }

  List<UnifiedSearchResult> _serviceTopics(String query) {
    const services = [
      ('pharmacy', 'الصيدلية', 'الأدوية والمنتجات', '/pharmacy'), ('emergency', 'الطوارئ', 'أرقام وخدمات الطوارئ', '/emergency'), ('doctors', 'الأطباء', 'حجز واستشارات الأطباء', '/doctors'), ('labs', 'المختبرات', 'الفحوصات والحجوزات', '/labs'), ('consultation', 'استشارة', 'استشارة طبية', '/consultation'), ('blood_donation', 'التبرع بالدم', 'خدمة التبرع بالدم', '/blood-donation'), ('map', 'بالقرب منك', 'المنشآت الصحية القريبة', '/map'), ('wallet', 'المحفظة', 'الدفع والمحفظة', '/wallet'),
    ];
    return services.where((s) => normalize('${s.$2} ${s.$3}').contains(query) || normalize(s.$2).contains(query)).map((s) => UnifiedSearchResult(id: s.$1, type: 'service', title: s.$2, subtitle: s.$3, route: s.$4, score: 18)).toList();
  }

  String normalize(String value) {
    var s = value.toLowerCase().trim();
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '').replaceAll('ـ', '');
    s = s.replaceAll(RegExp('[إأآٱ]'), 'ا').replaceAll('ى', 'ي').replaceAll('ة', 'ه').replaceAll('ؤ', 'و').replaceAll('ئ', 'ي');
    const digits = {'٠':'0','١':'1','٢':'2','٣':'3','٤':'4','٥':'5','٦':'6','٧':'7','٨':'8','٩':'9'};
    digits.forEach((a, b) => s = s.replaceAll(a, b));
    return s.replaceAll(RegExp(r'\s+'), ' ');
  }

  String _value(dynamic value) {
    if (value is Iterable) return value.map(_value).join(' ');
    if (value is Map) return value.values.map(_value).join(' ');
    return value?.toString() ?? '';
  }

  String _title(Map<String, dynamic> data, String type) {
    switch (type) {
      case 'article': return (data['title'] ?? data['name'] ?? 'مقال صحي').toString();
      case 'drug': return (data['name'] ?? data['genericName'] ?? data['brandName'] ?? 'دواء').toString();
      case 'product': return (data['name'] ?? 'منتج صحي').toString();
      case 'post': return (data['title'] ?? data['content'] ?? 'منشور').toString();
      default: return (data['name'] ?? 'نتيجة').toString();
    }
  }

  String _subtitle(Map<String, dynamic> data, String type) {
    switch (type) {
      case 'doctor': return (data['specialty'] ?? data['city'] ?? '').toString();
      case 'product': return (data['category'] ?? data['brand'] ?? '').toString();
      case 'drug': return (data['genericName'] ?? data['brandName'] ?? data['category'] ?? '').toString();
      case 'article': return (data['category'] ?? '').toString();
      case 'post': return (data['userName'] ?? data['category'] ?? '').toString();
      default: return (data['address'] ?? data['location'] ?? data['city'] ?? '').toString();
    }
  }
}

class UnifiedSearchResult {
  final String id;
  final String type;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? route;
  final Map<String, dynamic>? data;
  final int score;
  const UnifiedSearchResult({required this.id, required this.type, required this.title, required this.subtitle, this.imageUrl = '', this.route, this.data, this.score = 0});
}
