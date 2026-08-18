import 'dart:convert';
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

    // ✅ التحقق من وجود بيانات
    final stats = await _storage.getStats();
    if (stats['drugs'] == 0) {
      print('📦 Loading offline data...');
      await _loadInitialData();
    }
  }

  // ============================================================
  // 📥 تحميل البيانات الأولية
  // ============================================================

  Future<void> _loadInitialData() async {
    // ✅ تحميل الأدوية
    await _storage.insertDrugs(_getInitialDrugs());

    // ✅ تحميل الأمراض
    await _storage.insertDiseases(_getInitialDiseases());

    // ✅ تحميل الإسعافات الأولية
    await _storage.insertFirstAid(_getInitialFirstAid());

    // ✅ تحميل النصائح الصحية
    await _storage.insertHealthTips(_getInitialTips());

    print('✅ Offline data loaded successfully');
  }

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
    return [
      {
        'name': 'باراسيتامول',
        'name_en': 'Paracetamol',
        'category': 'مسكن ألم وخافض حرارة',
        'dose_adult': '500-1000mg كل 6-8 ساعات',
        'dose_child': '15mg/kg كل 6 ساعات',
        'max_daily': '4g',
        'pregnancy': 'آمن',
        'breastfeeding': 'آمن',
        'side_effects': 'نادر: حساسية جلدية',
        'interactions': 'وارفارين (زيادة تأثير)',
        'contraindications': 'أمراض كبد حادة',
        'notes': 'لا يتعارض مع المعدة',
        'overdose': 'تلف كبدي حاد - طوارئ',
        'forms': jsonEncode(['أقراص', 'شراب', 'تحاميل', 'حقن']),
        'brands': jsonEncode(['بانادول', 'تايلينول', 'أدول']),
      },
      {
        'name': 'ايبوبروفين',
        'name_en': 'Ibuprofen',
        'category': 'مضاد التهاب غير ستيرويدي',
        'dose_adult': '200-400mg كل 6-8 ساعات',
        'dose_child': '10mg/kg كل 8 ساعات',
        'max_daily': '1200mg',
        'pregnancy': 'غير آمن (الثلث الثالث)',
        'breastfeeding': 'باستشارة طبيب',
        'side_effects': 'حرقة معدة، قرحة، تأثير كلوي',
        'interactions': 'مميعات دم، ليثيوم، ميثوتريكسيت',
        'contraindications': 'قرحة معدة نشطة، فشل كلوي',
        'notes': 'يؤخذ مع الطعام لتقليل تأثير المعدة',
        'overdose': 'غثيان، نزيف معدي، فشل كلوي',
        'forms': jsonEncode(['أقراص', 'جل', 'شراب', 'تحاميل']),
        'brands': jsonEncode(['نوروفين', 'أدفيل', 'بروفين']),
      },
      {
        'name': 'اموكسيسيلين',
        'name_en': 'Amoxicillin',
        'category': 'مضاد حيوي - بنسلين',
        'dose_adult': '500mg كل 8 ساعات',
        'dose_child': '50mg/kg/يوم مقسمة',
        'max_daily': '1500mg',
        'pregnancy': 'آمن نسبياً',
        'breastfeeding': 'آمن',
        'side_effects': 'إسهال، حساسية، طفح',
        'interactions': 'ألوبيورينول (زيادة طفح)',
        'contraindications': 'حساسية البنسلين',
        'notes': 'أكمل الكورس كاملاً',
        'overdose': 'غثيان، إقياء، إسهال',
        'forms': jsonEncode(['أقراص', 'كبسولات', 'شراب', 'حقن']),
        'brands': jsonEncode(['أموكسيل', 'هيكسيل']),
      },
      // ... المزيد من الأدوية
    ];
  }

  List<Map<String, dynamic>> _getInitialDiseases() {
    return [
      {
        'name': 'ارتفاع ضغط الدم',
        'category': 'قلب وأوعية دموية',
        'symptoms': 'صداع خلفي، دوخة، نزيف أنف، زغللة عين، ضيق تنفس',
        'causes': 'وراثة، ملح زائد، سمنة، توتر نفسي، قلة حركة',
        'treatment': 'أدوية خافضة، تقليل ملح، رياضة، وزن مثالي',
        'complications': 'جلطة دماغية، فشل كلوي، فشل قلبي، عمى',
        'prevention': 'غذاء صحي قليل الملح، رياضة 150 دقيقة/أسبوع',
        'normal_range': 'أقل من 120/80 mmHg',
        'when_to_see_doctor': 'قراءة متكررة ≥140/90 أو أعراض شديدة',
        'emergency_warning': 'صداع شديد مفاجئ، ضيق تنفس، ألم صدر',
      },
      {
        'name': 'السكري نوع 2',
        'category': 'غدد صماء وسكري',
        'symptoms': 'عطش مفرط، تبول كثير، جوع مستمر، فقدان وزن، تعب',
        'causes': 'وراثة، سمنة، قلة حركة، مقاومة إنسولين',
        'treatment': 'ميتفورمين، أنسولين، حمية، رياضة، مراقبة سكر',
        'complications': 'عمى، فشل كلوي، بتر، أمراض قلبية',
        'prevention': 'وزن صحي، رياضة منتظمة، تغذية متوازنة، فحص سنوي',
        'normal_range': 'سكر صائم <100 mg/dL، تراكمي <5.7%',
        'when_to_see_doctor': 'سكر صائم ≥126 أو تراكمي ≥6.5%',
        'emergency_warning': 'غيبوبة، تنفس كيتوني، عطش شديد',
      },
      // ... المزيد من الأمراض
    ];
  }

  List<Map<String, String>> _getInitialFirstAid() {
    return [
      {
        'name': 'النزيف',
        'steps': '1. اضغط بقوة على الجرح بقطعة قماش نظيفة\n2. ارفع الجزء المصاب فوق مستوى القلب\n3. اتصل بالطوارئ إذا لم يتوقف النزيف بعد 10 دقائق',
        'warnings': '⚠️ لا ترفع الضغط حتى وصول المساعدة',
      },
      {
        'name': 'الحروق',
        'steps': '1. ضع المنطقة المصابة تحت ماء بارد جارٍ لمدة 10-15 دقيقة\n2. لا تضع ثلجاً مباشرة على الحرق\n3. غطِ الجرح بضمادة معقمة\n4. لا تفرقع الفقاعات',
        'warnings': '⚠️ للحروق الكبيرة أو في الوجه - اتصل بالطوارئ فوراً',
      },
      // ... المزيد من الإسعافات
    ];
  }

  List<String> _getInitialTips() {
    return [
      'اشرب 8-10 أكواب ماء يومياً 💧',
      'تناول 5 حصص من الخضار والفواكه يومياً 🥗',
      'قلل استهلاك الملح إلى أقل من 5 غرامات يومياً 🧂',
      'مارس المشي 30 دقيقة يومياً 🚶',
      'نم 7-8 ساعات ليلاً 😴',
      'مارس تمارين التنفس العميق 🧘',
      'تناول الأسماك الدهنية مرتين أسبوعياً 🐟',
      'تجنب التدخين والكحول 🚭',
      'افحص ضغط الدم شهرياً 🩺',
      'افحص السكر سنوياً 🧪',
      // ... المزيد من النصائح
    ];
  }

  // ============================================================
  // 🗑️ تنظيف
  // ============================================================

  void dispose() {
    _storage.dispose();
  }
}
