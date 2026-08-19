// ============================================================
// 🔬 الفحوصات المخبرية - Lab Tests Database
// ============================================================

class LabTestsDatabase {
  static final Map<String, Map<String, dynamic>> labTests = {
    'CBC': {
      'full_name': 'تعداد دم كامل',
      'purpose': 'تقييم صحة الدم والخلايا',
      'normal': {
        'WBC': '4.5-11 x10^3',
        'RBC': '4.5-5.5 x10^6',
        'Hgb': '13-17 g/dL (رجال)، 12-16 (نساء)',
        'Hct': '38-50%',
        'Plt': '150-400 x10^3',
      },
      'interpretation': 'انخفاض: فقر دم، نزيف. ارتفاع: جفاف، كثرة الحمر',
      'fasting': 'لا يحتاج',
      'time': 'ساعة',
      'price_range': '50-150 ر.س',
    },
    'HbA1c': {
      'full_name': 'السكر التراكمي',
      'purpose': 'متوسط السكر في 3 أشهر',
      'normal': {
        'HbA1c': '<5.7% (طبيعي)، 5.7-6.4% (مقدم)، ≥6.5% (سكري)',
      },
      'interpretation': 'كل 1% زيادة تزيد خطر المضاعفات 20%',
      'fasting': 'لا يحتاج',
      'time': 'ساعة',
      'price_range': '80-200 ر.س',
    },
    'Lipid Profile': {
      'full_name': 'مستوى الدهون',
      'purpose': 'الكوليسترول والدهون الثلاثية',
      'normal': {
        'Total Cholesterol': '<200 mg/dL',
        'LDL (الضار)': '<100 mg/dL',
        'HDL (النافع)': '>40 (رجال)، >50 (نساء)',
        'Triglycerides': '<150 mg/dL',
      },
      'interpretation': 'LDL مرتفع + HDL منخفض = خطر قلبي عالٍ',
      'fasting': '12 ساعة',
      'time': '2-4 ساعات',
      'price_range': '100-250 ر.س',
    },
    'Liver Function': {
      'full_name': 'وظائف الكبد',
      'purpose': 'صحة الكبد والقناة الصفراوية',
      'normal': {
        'ALT': '<40 U/L',
        'AST': '<40 U/L',
        'ALP': '<120 U/L',
        'Bilirubin': '0.2-1.2 mg/dL',
        'Albumin': '3.5-5.0 g/dL',
      },
      'interpretation': 'ALT/AST مرتفع: تلف كبدي',
      'fasting': '8 ساعات',
      'time': '2-4 ساعات',
      'price_range': '100-200 ر.س',
    },
    'Kidney Function': {
      'full_name': 'وظائف الكلى',
      'purpose': 'تقييم صحة الكلى',
      'normal': {
        'Creatinine': '0.6-1.2 mg/dL',
        'BUN': '7-20 mg/dL',
        'eGFR': '>90 mL/min',
        'Uric Acid': '3.5-7.2 mg/dL (رجال)، 2.6-6.0 (نساء)',
      },
      'interpretation': 'كرياتينين مرتفع: فشل كلوي',
      'fasting': '8 ساعات',
      'time': '2-4 ساعات',
      'price_range': '100-200 ر.س',
    },
    'TSH': {
      'full_name': 'هرمون الغدة الدرقية المحفز',
      'purpose': 'وظيفة الغدة الدرقية',
      'normal': {
        'TSH': '0.4-4.0 mIU/L',
        'T4': '4.5-12.5 mcg/dL',
        'T3': '2.3-4.2 pg/mL',
      },
      'interpretation': 'TSH مرتفع = قصور درق، TSH منخفض = فرط درق',
      'fasting': 'لا يحتاج',
      'time': '2-4 ساعات',
      'price_range': '80-180 ر.س',
    },
    'Vitamin D': {
      'full_name': 'فيتامين د',
      'purpose': 'مستوى فيتامين د',
      'normal': {
        'Vitamin D': '<20 (نقص شديد)، 20-30 (نقص)، 30-50 (كافٍ)، >50 (مثالي)',
      },
      'interpretation': 'نقص فيتامين د شائع جداً في الشرق الأوسط',
      'fasting': 'لا يحتاج',
      'time': '24 ساعة',
      'price_range': '150-300 ر.س',
    },
    'Vitamin B12': {
      'full_name': 'فيتامين ب12',
      'purpose': 'تقييم مستوى ب12',
      'normal': {
        'B12': '200-900 pg/mL',
      },
      'interpretation': 'نقص ب12 يسبب فقر دم وتنميل أطراف',
      'fasting': '8 ساعات',
      'time': '24 ساعة',
      'price_range': '100-200 ر.س',
    },
    'Ferritin': {
      'full_name': 'فيريتين',
      'purpose': 'مخزون الحديد',
      'normal': {
        'Ferritin': '20-200 ng/mL',
      },
      'interpretation': 'منخفض = نقص حديد، مرتفع = ترسب حديد',
      'fasting': 'لا يحتاج',
      'time': '2-4 ساعات',
      'price_range': '80-150 ر.س',
    },
    'Urine Analysis': {
      'full_name': 'تحليل بول كامل',
      'purpose': 'صحة الكلى والمسالك البولية',
      'normal': {
        'Color': 'أصفر شاحب',
        'pH': '4.5-8.0',
        'Protein': 'سلبي',
        'Glucose': 'سلبي',
        'RBC': '0-2 /HPF',
        'WBC': '0-5 /HPF',
      },
      'interpretation': 'بروتين +: مرض كبيبات الكلى',
      'fasting': 'لا يحتاج',
      'time': 'ساعة',
      'price_range': '30-80 ر.س',
    },
    'ECG': {
      'full_name': 'تخطيط القلب الكهربائي',
      'purpose': 'نشاط القلب الكهربائي',
      'normal': {
        'Rate': '60-100 bpm',
        'Rhythm': 'جيبية',
        'PR Interval': '0.12-0.20 ثانية',
        'QRS Complex': '<0.12 ثانية',
      },
      'interpretation': 'ST ارتفاع/هبوط: نقص تروية',
      'fasting': 'لا يحتاج',
      'time': '10 دقائق',
      'price_range': '100-300 ر.س',
    },
    'Chest X-Ray': {
      'full_name': 'أشعة صدر',
      'purpose': 'الرئتين والقلب والعظام الصدرية',
      'normal': {
        'Lungs': 'شفافة',
        'Heart': 'حجم طبيعي',
        'Bones': 'سليمة',
      },
      'interpretation': 'ظلال بيضاء: التهاب رئوي',
      'fasting': 'لا يحتاج',
      'time': '15 دقيقة',
      'price_range': '100-250 ر.س',
    },
  };

  static Map<String, dynamic>? getLabTest(String name) {
    return labTests[name];
  }

  static List<Map<String, dynamic>> searchLabTests(String query) {
    final results = <Map<String, dynamic>>[];
    for (var entry in labTests.entries) {
      if (entry.key.contains(query) || entry.value['full_name'].contains(query)) {
        results.add({'name': entry.key, ...entry.value});
      }
    }
    return results;
  }
}
// ============================================================
// 🔬 الفحوصات المخبرية - Lab Tests Database
// ============================================================

class LabTestsDatabase {
  static final Map<String, Map<String, dynamic>> labTests = {
    'CBC': {
      'full_name': 'تعداد دم كامل',
      'purpose': 'تقييم صحة الدم والخلايا',
      'normal': {
        'WBC': '4.5-11 x10^3',
        'RBC': '4.5-5.5 x10^6',
        'Hgb': '13-17 g/dL (رجال)، 12-16 (نساء)',
        'Hct': '38-50%',
        'Plt': '150-400 x10^3',
      },
      'interpretation': 'انخفاض: فقر دم، نزيف. ارتفاع: جفاف، كثرة الحمر',
      'fasting': 'لا يحتاج',
      'time': 'ساعة',
      'price_range': '50-150 ر.س',
    },
    'HbA1c': {
      'full_name': 'السكر التراكمي',
      'purpose': 'متوسط السكر في 3 أشهر',
      'normal': {
        'HbA1c': '<5.7% (طبيعي)، 5.7-6.4% (مقدم)، ≥6.5% (سكري)',
      },
      'interpretation': 'كل 1% زيادة تزيد خطر المضاعفات 20%',
      'fasting': 'لا يحتاج',
      'time': 'ساعة',
      'price_range': '80-200 ر.س',
    },
    'Lipid Profile': {
      'full_name': 'مستوى الدهون',
      'purpose': 'الكوليسترول والدهون الثلاثية',
      'normal': {
        'Total Cholesterol': '<200 mg/dL',
        'LDL (الضار)': '<100 mg/dL',
        'HDL (النافع)': '>40 (رجال)، >50 (نساء)',
        'Triglycerides': '<150 mg/dL',
      },
      'interpretation': 'LDL مرتفع + HDL منخفض = خطر قلبي عالٍ',
      'fasting': '12 ساعة',
      'time': '2-4 ساعات',
      'price_range': '100-250 ر.س',
    },
    'Liver Function': {
      'full_name': 'وظائف الكبد',
      'purpose': 'صحة الكبد والقناة الصفراوية',
      'normal': {
        'ALT': '<40 U/L',
        'AST': '<40 U/L',
        'ALP': '<120 U/L',
        'Bilirubin': '0.2-1.2 mg/dL',
        'Albumin': '3.5-5.0 g/dL',
      },
      'interpretation': 'ALT/AST مرتفع: تلف كبدي',
      'fasting': '8 ساعات',
      'time': '2-4 ساعات',
      'price_range': '100-200 ر.س',
    },
    'Kidney Function': {
      'full_name': 'وظائف الكلى',
      'purpose': 'تقييم صحة الكلى',
      'normal': {
        'Creatinine': '0.6-1.2 mg/dL',
        'BUN': '7-20 mg/dL',
        'eGFR': '>90 mL/min',
        'Uric Acid': '3.5-7.2 mg/dL (رجال)، 2.6-6.0 (نساء)',
      },
      'interpretation': 'كرياتينين مرتفع: فشل كلوي',
      'fasting': '8 ساعات',
      'time': '2-4 ساعات',
      'price_range': '100-200 ر.س',
    },
    'TSH': {
      'full_name': 'هرمون الغدة الدرقية المحفز',
      'purpose': 'وظيفة الغدة الدرقية',
      'normal': {
        'TSH': '0.4-4.0 mIU/L',
        'T4': '4.5-12.5 mcg/dL',
        'T3': '2.3-4.2 pg/mL',
      },
      'interpretation': 'TSH مرتفع = قصور درق، TSH منخفض = فرط درق',
      'fasting': 'لا يحتاج',
      'time': '2-4 ساعات',
      'price_range': '80-180 ر.س',
    },
    'Vitamin D': {
      'full_name': 'فيتامين د',
      'purpose': 'مستوى فيتامين د',
      'normal': {
        'Vitamin D': '<20 (نقص شديد)، 20-30 (نقص)، 30-50 (كافٍ)، >50 (مثالي)',
      },
      'interpretation': 'نقص فيتامين د شائع جداً في الشرق الأوسط',
      'fasting': 'لا يحتاج',
      'time': '24 ساعة',
      'price_range': '150-300 ر.س',
    },
    'Vitamin B12': {
      'full_name': 'فيتامين ب12',
      'purpose': 'تقييم مستوى ب12',
      'normal': {
        'B12': '200-900 pg/mL',
      },
      'interpretation': 'نقص ب12 يسبب فقر دم وتنميل أطراف',
      'fasting': '8 ساعات',
      'time': '24 ساعة',
      'price_range': '100-200 ر.س',
    },
    'Ferritin': {
      'full_name': 'فيريتين',
      'purpose': 'مخزون الحديد',
      'normal': {
        'Ferritin': '20-200 ng/mL',
      },
      'interpretation': 'منخفض = نقص حديد، مرتفع = ترسب حديد',
      'fasting': 'لا يحتاج',
      'time': '2-4 ساعات',
      'price_range': '80-150 ر.س',
    },
    'Urine Analysis': {
      'full_name': 'تحليل بول كامل',
      'purpose': 'صحة الكلى والمسالك البولية',
      'normal': {
        'Color': 'أصفر شاحب',
        'pH': '4.5-8.0',
        'Protein': 'سلبي',
        'Glucose': 'سلبي',
        'RBC': '0-2 /HPF',
        'WBC': '0-5 /HPF',
      },
      'interpretation': 'بروتين +: مرض كبيبات الكلى',
      'fasting': 'لا يحتاج',
      'time': 'ساعة',
      'price_range': '30-80 ر.س',
    },
    'ECG': {
      'full_name': 'تخطيط القلب الكهربائي',
      'purpose': 'نشاط القلب الكهربائي',
      'normal': {
        'Rate': '60-100 bpm',
        'Rhythm': 'جيبية',
        'PR Interval': '0.12-0.20 ثانية',
        'QRS Complex': '<0.12 ثانية',
      },
      'interpretation': 'ST ارتفاع/هبوط: نقص تروية',
      'fasting': 'لا يحتاج',
      'time': '10 دقائق',
      'price_range': '100-300 ر.س',
    },
    'Chest X-Ray': {
      'full_name': 'أشعة صدر',
      'purpose': 'الرئتين والقلب والعظام الصدرية',
      'normal': {
        'Lungs': 'شفافة',
        'Heart': 'حجم طبيعي',
        'Bones': 'سليمة',
      },
      'interpretation': 'ظلال بيضاء: التهاب رئوي',
      'fasting': 'لا يحتاج',
      'time': '15 دقيقة',
      'price_range': '100-250 ر.س',
    },
  };

  static Map<String, dynamic>? getLabTest(String name) {
    return labTests[name];
  }

  static List<Map<String, dynamic>> searchLabTests(String query) {
    final results = <Map<String, dynamic>>[];
    for (var entry in labTests.entries) {
      if (entry.key.contains(query) || entry.value['full_name'].contains(query)) {
        results.add({'name': entry.key, ...entry.value});
      }
    }
    return results;
  }
}
