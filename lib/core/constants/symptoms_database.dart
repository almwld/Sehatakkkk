// ============================================================
// 📊 قاعدة الأعراض - Symptoms Database
// ============================================================

class SymptomsDatabase {
  static final Map<String, Map<String, dynamic>> symptoms = {
    'صداع': {
      'category': 'عصبي',
      'possible': ['صداع توتري', 'صداع نصفي', 'الجيوب الأنفية'],
      'severity': 'متوسط',
      'action': 'مسكن، راحة، استشارة إذا استمر',
      'when_to_see_doctor': 'إذا استمر >3 أيام أو كان شديداً',
    },
    'حمى': {
      'category': 'عام',
      'possible': ['عدوى فيروسية', 'عدوى بكتيرية', 'التهابات'],
      'severity': 'متوسط',
      'action': 'خافض حرارة، سوائل، راحة',
      'when_to_see_doctor': 'إذا استمرت >3 أيام أو تجاوزت 39°C',
    },
    'سعال': {
      'category': 'تنفسي',
      'possible': ['نزلة برد', 'انفلونزا', 'التهاب شعب', 'ربو'],
      'severity': 'خفيف',
      'action': 'سوائل دافئة، عسل، بخاخات',
      'when_to_see_doctor': 'إذا استمر >أسبوع أو كان مصحوباً بدم',
    },
    'ضيق تنفس': {
      'category': 'تنفسي',
      'possible': ['ربو', 'التهاب رئوي', 'قصور قلب', 'قلق'],
      'severity': 'شديد',
      'action': '🚨 طوارئ - اتصل 1122 فوراً',
      'when_to_see_doctor': 'فوري - حالة طارئة',
    },
    'ألم بطن': {
      'category': 'هضمي',
      'possible': ['التهاب معدة', 'قرحة', 'قولون عصبي', 'تسمم غذائي'],
      'severity': 'متوسط',
      'action': 'راحة، سوائل، تجنب الأكل الثقيل',
      'when_to_see_doctor': 'إذا استمر >يومين أو كان شديداً',
    },
    'إسهال': {
      'category': 'هضمي',
      'possible': ['عدوى فيروسية', 'تسمم غذائي', 'قولون عصبي'],
      'severity': 'خفيف',
      'action': 'سوائل (ORS)، راحة، بروبيوتيك',
      'when_to_see_doctor': 'إذا استمر >3 أيام أو كان دموياً',
    },
    'غثيان': {
      'category': 'هضمي',
      'possible': ['التهاب معدة', 'تسمم غذائي', 'حمل', 'قلق'],
      'severity': 'خفيف',
      'action': 'سوائل، راحة، زنجبيل',
      'when_to_see_doctor': 'إذا استمر >يومين أو مع قيء شديد',
    },
    'طفح جلدي': {
      'category': 'جلدي',
      'possible': ['حساسية', 'إكزيما', 'صدفية', 'عدوى فطرية'],
      'severity': 'خفيف',
      'action': 'مضاد هستامين، مرطب، كورتيزون موضعي',
      'when_to_see_doctor': 'إذا انتشر بسرعة أو مع حمى',
    },
    'ألم مفاصل': {
      'category': 'عضلي',
      'possible': ['التهاب مفاصل', 'نقرس', 'شد عضلي', 'هشاشة'],
      'severity': 'متوسط',
      'action': 'راحة، كمادات، مسكن',
      'when_to_see_doctor': 'إذا استمر >أسبوع أو مع تورم',
    },
    'تعب': {
      'category': 'عام',
      'possible': ['فقر دم', 'قصور درق', 'اكتئاب', 'عدوى مزمنة'],
      'severity': 'خفيف',
      'action': 'راحة، نوم كاف، تغذية جيدة',
      'when_to_see_doctor': 'إذا استمر >أسبوعين أو مع أعراض أخرى',
    },
    'دوخة': {
      'category': 'عصبي',
      'possible': ['انخفاض ضغط', 'فقر دم', 'مشاكل الأذن', 'صداع نصفي'],
      'severity': 'متوسط',
      'action': 'راحة، سوائل، جلوس',
      'when_to_see_doctor': 'إذا تكررت أو مع إغماء',
    },
    'خفقان قلب': {
      'category': 'قلب',
      'possible': ['قلق', 'فرط درق', 'فقر دم', 'اضطراب نظم'],
      'severity': 'شديد',
      'action': 'راحة، تنفس عميق',
      'when_to_see_doctor': 'استشارة قلبية فورية',
    },
    'ألم صدر': {
      'category': 'قلب',
      'possible': ['ذبحة صدرية', 'التهاب رئوي', 'ارتجاع مريئي'],
      'severity': 'شديد',
      'action': '🚨 طوارئ - اتصل 1122 فوراً',
      'when_to_see_doctor': 'فوري - حالة طارئة',
    },
    'حرقة': {
      'category': 'هضمي',
      'possible': ['ارتجاع مريئي', 'قرحة', 'التهاب معدة'],
      'severity': 'خفيف',
      'action': 'مضادات حموضة، تجنب الأكل الدسم',
      'when_to_see_doctor': 'إذا استمر >أسبوع أو مع صعوبة بلع',
    },
    'أرق': {
      'category': 'نفسي',
      'possible': ['قلق', 'اكتئاب', 'الكافيين', 'قلة نشاط'],
      'severity': 'خفيف',
      'action': 'نمط نوم منتظم، تجنب الشاشات قبل النوم',
      'when_to_see_doctor': 'إذا استمر >شهر أو يؤثر على الحياة',
    },
    'تساقط شعر': {
      'category': 'جلدي',
      'possible': ['نقص حديد', 'قصور درق', 'توتر', 'ثعلبة'],
      'severity': 'خفيف',
      'action': 'تحليل فيتامينات، تغذية جيدة',
      'when_to_see_doctor': 'إذا كان مفاجئاً أو مع بقع صلعاء',
    },
    'جفاف الفم': {
      'category': 'عام',
      'possible': ['جفاف', 'أدوية', 'سكري', 'متلازمة سجوجرن'],
      'severity': 'خفيف',
      'action': 'شرب ماء، فحص سكر',
      'when_to_see_doctor': 'إذا استمر مع أعراض أخرى',
    },
    'تنميل': {
      'category': 'عصبي',
      'possible': ['سكري', 'نقص فيتامين ب12', 'انزلاق غضروفي'],
      'severity': 'متوسط',
      'action': 'فحص سكر وفيتامينات',
      'when_to_see_doctor': 'إذا كان مفاجئاً أو مع ضعف',
    },
    'التهاب حلق': {
      'category': 'أنف وأذن وحنجرة',
      'possible': ['فيروسي', 'بكتيري', 'حساسية'],
      'severity': 'خفيف',
      'action': 'غرغرة ماء وملح، مسكن',
      'when_to_see_doctor': 'إذا استمر >3 أيام أو مع حمى',
    },
    'احمرار عين': {
      'category': 'عيون',
      'possible': ['التهاب ملتحمة', 'حساسية', 'جفاف'],
      'severity': 'خفيف',
      'action': 'قطرات مرطبة، مضاد هستامين',
      'when_to_see_doctor': 'إذا كان مؤلماً أو مع تغير الرؤية',
    },
  };

  static Map<String, dynamic>? getSymptom(String symptom) {
    return symptoms[symptom];
  }

  static List<Map<String, dynamic>> searchSymptoms(String query) {
    final results = <Map<String, dynamic>>[];
    for (var entry in symptoms.entries) {
      if (entry.key.contains(query) || entry.value['category'].contains(query)) {
        results.add({'name': entry.key, ...entry.value});
      }
    }
    return results;
  }

  static List<String> getCategories() {
    return symptoms.values.map((e) => e['category'] as String).toSet().toList();
  }
}
