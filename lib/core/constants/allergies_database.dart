// ============================================================
// 🌿 مسببات الحساسية - Allergies Database
// ============================================================

class AllergiesDatabase {
  static final Map<String, List<String>> allergies = {
    'الطعام': [
      'القمح',
      'الحليب',
      'البيض',
      'المكسرات (اللوز، الجوز، الكاجو)',
      'السمك والمحار',
      'الصويا',
      'الفول السوداني',
      'السمسم',
      'الكرفس',
      'الخردل',
    ],
    'الأدوية': [
      'البنسلين والمضادات الحيوية',
      'الأسبرين',
      'الإيبوبروفين',
      'السلفا',
      'المضادات الحيوية (ماكرولايد)',
      'أدوية الصرع',
      'أدوية التخدير',
    ],
    'البيئة': [
      'غبار المنزل',
      'حبوب اللقاح (الأعشاب، الأشجار)',
      'العفن والفطريات',
      'وبر الحيوانات (القطط، الكلاب)',
      'العطور والمواد الكيميائية',
      'مبيدات الحشرات',
      'دخان السجائر',
      'تلوث الهواء',
    ],
    'الحشرات': [
      'لدغات النحل',
      'لدغات الدبابير',
      'قراد',
      'البعوض',
      'النمل',
      'العناكب',
    ],
    'المواد': [
      'اللاتكس (القفازات، الواقيات)',
      'النيكل (المجوهرات، الإبزيم)',
      'الكوبالت',
      'الصبغات (صبغات الشعر)',
      'العطور والمواد الحافظة',
      'المعادن (الكروم، الزئبق)',
    ],
  };

  static List<String> getCategory(String category) {
    return allergies[category] ?? [];
  }

  static List<String> getAllAllergens() {
    final all = <String>[];
    for (var list in allergies.values) {
      all.addAll(list);
    }
    return all;
  }

  static List<String> searchAllergens(String query) {
    final results = <String>[];
    for (var list in allergies.values) {
      for (var item in list) {
        if (item.contains(query)) {
          results.add(item);
        }
      }
    }
    return results;
  }
}
