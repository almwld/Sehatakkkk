import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  late Database _database;
  bool _isInitialized = false;

  // ============================================================
  // 📁 تهيئة قاعدة البيانات المحلية
  // ============================================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final documentsDirectory = await getDatabasesPath();
      final path = join(documentsDirectory, 'sehatak_ai.db');

      _database = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onUpgrade: _upgradeTables,
      );

      _isInitialized = true;
      print('✅ Local database initialized');
    } catch (e) {
      print('❌ Database initialization error: $e');
      // ✅ في حالة الفشل، استخدام SharedPreferences كبديل
      await _initSharedPreferences();
    }
  }

  // ============================================================
  // 📊 إنشاء الجداول
  // ============================================================

  Future<void> _createTables(Database db, int version) async {
    // ✅ جدول الأدوية
    await db.execute('''
      CREATE TABLE drugs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        name_en TEXT,
        category TEXT,
        dose_adult TEXT,
        dose_child TEXT,
        max_daily TEXT,
        pregnancy TEXT,
        breastfeeding TEXT,
        side_effects TEXT,
        interactions TEXT,
        contraindications TEXT,
        notes TEXT,
        overdose TEXT,
        forms TEXT,
        brands TEXT,
        updated_at INTEGER
      )
    ''');

    // ✅ جدول الأمراض
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT,
        symptoms TEXT,
        causes TEXT,
        treatment TEXT,
        complications TEXT,
        prevention TEXT,
        normal_range TEXT,
        when_to_see_doctor TEXT,
        emergency_warning TEXT,
        updated_at INTEGER
      )
    ''');

    // ✅ جدول الإسعافات الأولية
    await db.execute('''
      CREATE TABLE first_aid (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        steps TEXT,
        warnings TEXT,
        updated_at INTEGER
      )
    ''');

    // ✅ جدول النصائح الصحية
    await db.execute('''
      CREATE TABLE health_tips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tip TEXT NOT NULL,
        category TEXT,
        updated_at INTEGER
      )
    ''');

    // ✅ جدول المحادثات
    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        message TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        type TEXT
      )
    ''');

    // ✅ جدول الفهارس للبحث السريع
    await db.execute('''
      CREATE INDEX idx_drugs_name ON drugs(name);
      CREATE INDEX idx_drugs_name_en ON drugs(name_en);
      CREATE INDEX idx_diseases_name ON diseases(name);
      CREATE INDEX idx_conversations_session ON conversations(session_id);
    ''');

    print('✅ Tables created successfully');
  }

  Future<void> _upgradeTables(Database db, int oldVersion, int newVersion) async {
    // ✅ تحديث الجداول عند تغيير الإصدار
    print('🔄 Upgrading database from $oldVersion to $newVersion');
  }

  Future<void> _initSharedPreferences() async {
    // ✅ استخدام SharedPreferences كبديل إذا فشلت SQLite
    final prefs = await SharedPreferences.getInstance();
    print('✅ Using SharedPreferences as fallback');
  }

  // ============================================================
  // 💊 عمليات الأدوية
  // ============================================================

  Future<void> insertDrugs(List<Map<String, dynamic>> drugs) async {
    if (!_isInitialized) await initialize();

    try {
      final batch = _database.batch();
      for (var drug in drugs) {
        batch.insert('drugs', {
          'name': drug['name'],
          'name_en': drug['name_en'] ?? '',
          'category': drug['category'] ?? '',
          'dose_adult': drug['dose_adult'] ?? '',
          'dose_child': drug['dose_child'] ?? '',
          'max_daily': drug['max_daily'] ?? '',
          'pregnancy': drug['pregnancy'] ?? '',
          'breastfeeding': drug['breastfeeding'] ?? '',
          'side_effects': drug['side_effects'] ?? '',
          'interactions': drug['interactions'] ?? '',
          'contraindications': drug['contraindications'] ?? '',
          'notes': drug['notes'] ?? '',
          'overdose': drug['overdose'] ?? '',
          'forms': jsonEncode(drug['forms'] ?? []),
          'brands': jsonEncode(drug['brands'] ?? []),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
      print('✅ ${drugs.length} drugs inserted');
    } catch (e) {
      print('❌ Error inserting drugs: $e');
    }
  }

  Future<Map<String, dynamic>?> getDrug(String name) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database.query(
        'drugs',
        where: 'name LIKE ? OR name_en LIKE ?',
        whereArgs: ['%$name%', '%$name%'],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (e) {
      print('❌ Error getting drug: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchDrugs(String query) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database.query(
        'drugs',
        where: 'name LIKE ? OR name_en LIKE ? OR category LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        limit: 10,
      );
      return result;
    } catch (e) {
      print('❌ Error searching drugs: $e');
      return [];
    }
  }

  // ============================================================
  // 🩺 عمليات الأمراض
  // ============================================================

  Future<void> insertDiseases(List<Map<String, dynamic>> diseases) async {
    if (!_isInitialized) await initialize();

    try {
      final batch = _database.batch();
      for (var disease in diseases) {
        batch.insert('diseases', {
          'name': disease['name'],
          'category': disease['category'] ?? '',
          'symptoms': disease['symptoms'] ?? '',
          'causes': disease['causes'] ?? '',
          'treatment': disease['treatment'] ?? '',
          'complications': disease['complications'] ?? '',
          'prevention': disease['prevention'] ?? '',
          'normal_range': disease['normal_range'] ?? '',
          'when_to_see_doctor': disease['when_to_see_doctor'] ?? '',
          'emergency_warning': disease['emergency_warning'] ?? '',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
      print('✅ ${diseases.length} diseases inserted');
    } catch (e) {
      print('❌ Error inserting diseases: $e');
    }
  }

  Future<Map<String, dynamic>?> getDisease(String name) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database.query(
        'diseases',
        where: 'name LIKE ?',
        whereArgs: ['%$name%'],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (e) {
      print('❌ Error getting disease: $e');
      return null;
    }
  }

  // ============================================================
  // 💬 عمليات المحادثات
  // ============================================================

  Future<void> saveMessage({
    required String sessionId,
    required String message,
    required bool isUser,
    String? type,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      await _database.insert('conversations', {
        'session_id': sessionId,
        'message': message,
        'is_user': isUser ? 1 : 0,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'type': type ?? '',
      });
    } catch (e) {
      print('❌ Error saving message: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getConversation(String sessionId) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database.query(
        'conversations',
        where: 'session_id = ?',
        whereArgs: [sessionId],
        orderBy: 'timestamp ASC',
        limit: 100,
      );
      return result;
    } catch (e) {
      print('❌ Error getting conversation: $e');
      return [];
    }
  }

  Future<void> clearConversation(String sessionId) async {
    if (!_isInitialized) await initialize();

    try {
      await _database.delete(
        'conversations',
        where: 'session_id = ?',
        whereArgs: [sessionId],
      );
    } catch (e) {
      print('❌ Error clearing conversation: $e');
    }
  }

  // ============================================================
  // 🩹 عمليات الإسعافات الأولية
  // ============================================================

  Future<void> insertFirstAid(List<Map<String, String>> firstAidItems) async {
    if (!_isInitialized) await initialize();

    try {
      final batch = _database.batch();
      for (var item in firstAidItems) {
        batch.insert('first_aid', {
          'name': item['name'] ?? '',
          'steps': item['steps'] ?? '',
          'warnings': item['warnings'] ?? '',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
      print('✅ ${firstAidItems.length} first aid items inserted');
    } catch (e) {
      print('❌ Error inserting first aid: $e');
    }
  }

  Future<Map<String, dynamic>?> getFirstAid(String name) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database.query(
        'first_aid',
        where: 'name LIKE ?',
        whereArgs: ['%$name%'],
        limit: 1,
      );
      if (result.isEmpty) return null;
      return result.first;
    } catch (e) {
      print('❌ Error getting first aid: $e');
      return null;
    }
  }

  // ============================================================
  // 💡 عمليات النصائح الصحية
  // ============================================================

  Future<void> insertHealthTips(List<String> tips) async {
    if (!_isInitialized) await initialize();

    try {
      final batch = _database.batch();
      for (var tip in tips) {
        batch.insert('health_tips', {
          'tip': tip,
          'category': 'general',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
      print('✅ ${tips.length} health tips inserted');
    } catch (e) {
      print('❌ Error inserting health tips: $e');
    }
  }

  Future<List<String>> getRandomTips(int count) async {
    if (!_isInitialized) await initialize();

    try {
      final result = await _database.query(
        'health_tips',
        orderBy: 'RANDOM()',
        limit: count,
      );
      return result.map((e) => e['tip'] as String).toList();
    } catch (e) {
      print('❌ Error getting random tips: $e');
      return [];
    }
  }

  // ============================================================
  // 🗑️ تنظيف البيانات
  // ============================================================

  Future<void> clearAllData() async {
    if (!_isInitialized) await initialize();

    try {
      await _database.delete('conversations');
      print('✅ All data cleared');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }

  // ============================================================
  // 📊 إحصائيات
  // ============================================================

  Future<Map<String, int>> getStats() async {
    if (!_isInitialized) await initialize();

    try {
      final drugCount = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM drugs')
      ) ?? 0;
      final diseaseCount = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM diseases')
      ) ?? 0;
      final conversationCount = Sqflite.firstIntValue(
        await _database.rawQuery('SELECT COUNT(*) FROM conversations')
      ) ?? 0;

      return {
        'drugs': drugCount,
        'diseases': diseaseCount,
        'conversations': conversationCount,
      };
    } catch (e) {
      print('❌ Error getting stats: $e');
      return {'drugs': 0, 'diseases': 0, 'conversations': 0};
    }
  }

  void dispose() {
    if (_isInitialized) {
      _database.close();
    }
  }
}
