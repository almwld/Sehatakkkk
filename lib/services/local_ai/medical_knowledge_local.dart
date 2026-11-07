import 'package:sehatak/core/services/local_storage_service.dart';

class MedicalKnowledgeLocal {
  static final MedicalKnowledgeLocal _instance = MedicalKnowledgeLocal._internal();
  factory MedicalKnowledgeLocal() => _instance;
  MedicalKnowledgeLocal._internal();

  final LocalStorageService _storage = LocalStorageService();

  // ============================================================
  // 🚀 تهيئة البيانات في وضع عدم الاتصال
  // ============================================================

  Future<void> initializeOfflineData() async {
    await _storage.initialize();

    final stats = await _storage.getStats();
    if ((stats['drugs'] ?? 0) == 0) {
      await _storage.insertDrugs(_getInitialDrugs());
    }
    if ((stats['diseases'] ?? 0) == 0) {
      await _storage.insertDiseases(_getInitialDiseases());
    }
    if ((stats['first_aid'] ?? 0) == 0) {
      await _storage.insertFirstAid(_getInitialFirstAid());
    }
    if ((stats['health_tips'] ?? 0) == 0) {
      await _storage.insertHealthTips(_getInitialTips());
    }
  }

  // ============================================================
  // 📥 تحميل البيانات الأولية
  // ============================================================

  // ============================================================
  // 🔍 البحث والاستعلام
  // ============================================================

  Future<Map<String, dynamic>?> searchDrug(String query) async {
    return await _storage.getDrug(query);
  }

  Future<List<Map<String, dynamic>>> searchAllDrugs(String query) async {
    return await _storage.searchDrugs(query);
  }

  Future<Map<String, dynamic>?> getDisease(String name) async {
    return await _storage.getDisease(name);
  }

  Future<Map<String, dynamic>?> getFirstAid(String name) async {
    return await _storage.getFirstAid(name);
  }

  Future<List<String>> getRandomTips(int count) async {
    return await _storage.getRandomTips(count);
  }

  // ============================================================
  // 💬 المحادثات
  // ============================================================

  Future<void> saveMessage({
    required String sessionId,
    required String message,
    required bool isUser,
    String? type,
  }) async {
    await _storage.saveMessage(
      sessionId: sessionId,
      message: message,
      isUser: isUser,
      type: type,
    );
  }

  Future<List<Map<String, dynamic>>> getConversation(String sessionId) async {
    return await _storage.getConversation(sessionId);
  }

  Future<void> clearConversation(String sessionId) async {
    await _storage.clearConversation(sessionId);
  }

  // ============================================================
  // 📊 البيانات الأولية
  // ============================================================

  List<Map<String, dynamic>> _getInitialDrugs() {
    // Keep names for offline lookup only. No unreviewed dose or safety claims
    // are seeded; medication decisions must use an approved leaflet or clinician.
    return [
      {'name': 'باراسيتامول', 'name_en': 'Paracetamol', 'category': 'مسكن وخافض حرارة', 'notes': 'راجع النشرة المعتمدة أو الطبيب/الصيدلي قبل الاستخدام.'},
      {'name': 'ايبوبروفين', 'name_en': 'Ibuprofen', 'category': 'مضاد التهاب غير ستيرويدي', 'notes': 'راجع النشرة المعتمدة أو الطبيب/الصيدلي قبل الاستخدام.'},
      {'name': 'اموكسيسيلين', 'name_en': 'Amoxicillin', 'category': 'مضاد حيوي', 'notes': 'لا تستخدم المضادات الحيوية دون وصفة ومتابعة طبية.'},
    ];
  }

  List<Map<String, dynamic>> _getInitialDiseases() => [];

  List<Map<String, String>> _getInitialFirstAid() => [];

  List<String> _getInitialTips() => [];

  // ============================================================
  // 🗑️ تنظيف
  // ============================================================

  void dispose() {
    _storage.dispose();
  }
}
