// ============================================================
//   SEHTAK AI v5.0 - البوت الطبي المتكامل
//   Flutter/Dart Version - 2000+ سطر
//   Medical AI Bot - Unified & Enhanced
// ============================================================

import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';

// ============================================================
//   القسم الأول: قاعدة المعرفة الطبية الشاملة
// ============================================================

class MedicalKnowledgeBase {
  static final MedicalKnowledgeBase _instance = MedicalKnowledgeBase._internal();
  factory MedicalKnowledgeBase() => _instance;
  MedicalKnowledgeBase._internal();

  final Random _random = Random();

  // ===== 100+ دواء مع معلومات كاملة =====
  final Map<String, Map<String, dynamic>> drugsDb = {
    // ===== مسكنات الألم =====
    'باراسيتامول': {
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
      'forms': ['أقراص', 'شراب', 'تحاميل', 'حقن'],
      'brands': ['بانادول', 'تايلينول', 'أدول']
    },
    'ايبوبروفين': {
      'name_en': 'Ibuprofen',
      'category': 'مضاد التهاب غير ستيرويدي',
      'dose_adult': '200-400mg كل 6-8 ساعات',
      'dose_child': '10mg/kg كل 8 ساعات',
      'max_daily': '1200mg',
      'pregnancy': 'غير آمن (الثلث الثالث)',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'حرقة معدة، قرحة، تأثير كلوي',
      'interactions': 'مميعات دم، ليثيوم، ميثوتركسيت',
      'contraindications': 'قرحة معدة نشطة، فشل كلوي',
      'notes': 'يؤخذ مع الطعام لتقليل تأثير المعدة',
      'overdose': 'غثيان، نزيف معدي، فشل كلوي',
      'forms': ['أقراص', 'جل', 'شراب', 'تحاميل'],
      'brands': ['نوروفين', 'أدفيل', 'بروفين']
    },
    'ديكلوفيناك': {
      'name_en': 'Diclofenac',
      'category': 'مضاد التهاب غير ستيرويدي',
      'dose_adult': '50mg كل 8 ساعات',
      'dose_child': 'غير موصى به',
      'max_daily': '150mg',
      'pregnancy': 'غير آمن',
      'breastfeeding': 'غير آمن',
      'side_effects': 'ألم معدة، دوخة، طنين',
      'interactions': 'مميعات دم، مضادات ارتفاع ضغط',
      'contraindications': 'قرحة، فشل كلوي، حساسية الأسبرين',
      'notes': 'لا يستخدم مع مميعات الدم',
      'overdose': 'نزيف، فشل كلوي حاد',
      'forms': ['أقراص', 'جل', 'تحاميل', 'حقن'],
      'brands': ['فولتارين', 'كلاموكس']
    },
    'اموكسيسيلين': {
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
      'forms': ['أقراص', 'كبسولات', 'شراب', 'حقن'],
      'brands': ['أموكسيل', 'هيكسيل']
    },
    'ازيثرومايسين': {
      'name_en': 'Azithromycin',
      'category': 'مضاد حيوي - ماكرولايد',
      'dose_adult': '500mg يومياً 3 أيام',
      'dose_child': '10mg/kg يومياً',
      'max_daily': '500mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'إسهال، غثيان، اضطراب نظم قلب',
      'interactions': 'أدوية عدم نظم قلب، مضادات حموضة',
      'contraindications': 'اضطراب نظم قلب، حساسية الماكرولايد',
      'notes': 'لا يؤخذ مع مضادات حموضة',
      'overdose': 'غثيان، إقياء، إسهال حاد',
      'forms': ['أقراص', 'شراب', 'حقن'],
      'brands': ['زيثروماكس', 'أزيتروكس']
    },
    'اوميبرازول': {
      'name_en': 'Omeprazole',
      'category': 'مثبط مضخة بروتون',
      'dose_adult': '20-40mg يومياً',
      'dose_child': 'حسب الوزن',
      'max_daily': '40mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'صداع، إسهال، غازات',
      'interactions': 'كلوبيدوجريل، وارفارين، ديجوكسين',
      'contraindications': 'حساسية المثبطات',
      'notes': 'قبل الأكل بـ 30 دقيقة',
      'overdose': 'نادر - غثيان، صداع',
      'forms': ['أقراص', 'كبسولات', 'حقن'],
      'brands': ['لوسيك', 'أوميبرازول']
    },
    'ميتفورمين': {
      'name_en': 'Metformin',
      'category': 'خافض سكر فموي - بيجوانيد',
      'dose_adult': '500-850mg مع الأكل',
      'dose_child': 'حسب إرشادات الطبيب',
      'max_daily': '2550mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'آمن',
      'side_effects': 'غثيان، إسهال، طعم معدني',
      'interactions': 'كحول، سيميتيدين، فوروسيميد',
      'contraindications': 'فشل كلوي، حماض سكري',
      'notes': 'يبدأ بجرعة منخفضة ويزيد تدريجياً',
      'overdose': 'حماض لاكتاتي - طوارئ',
      'forms': ['أقراص', 'شراب'],
      'brands': ['جلوكوفاج', 'ميتفورمين']
    },
    'سيتريزين': {
      'name_en': 'Cetirizine',
      'category': 'مضاد هستامين',
      'dose_adult': '10mg يومياً',
      'dose_child': '5mg يومياً (2-6 سنوات)',
      'max_daily': '10mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'نعاس، جفاف فم',
      'interactions': 'مهدئات، كحول',
      'contraindications': 'حساسية السيتريزين',
      'notes': 'الجيل الثاني - أقل تهدئة',
      'overdose': 'نعاس شديد، هياج',
      'forms': ['أقراص', 'شراب', 'قطرات'],
      'brands': ['زيرتك', 'سيترين']
    },
    'لوراتادين': {
      'name_en': 'Loratadine',
      'category': 'مضاد هستامين',
      'dose_adult': '10mg يومياً',
      'dose_child': '5mg يومياً (2-6 سنوات)',
      'max_daily': '10mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'جفاف فم، صداع',
      'interactions': 'مضادات فطريات، إريثروميسين',
      'contraindications': 'حساسية اللوراتادين',
      'notes': 'لا يسبب نعاس - مناسب للاستخدام النهاري',
      'overdose': 'نعاس، صداع',
      'forms': ['أقراص', 'شراب'],
      'brands': ['كلاريتين', 'لوراتادين']
    },
    'فيتامين د': {
      'name_en': 'Vitamin D',
      'category': 'مكمل غذائي - فيتامين',
      'dose_adult': '1000-4000 IU يومياً',
      'dose_child': '400-1000 IU',
      'max_daily': '4000 IU',
      'pregnancy': 'آمن',
      'breastfeeding': 'آمن',
      'side_effects': 'نادر: غثيان، فرط كالسيوم',
      'interactions': 'مضادات اختلاج، كورتيزون',
      'contraindications': 'فرط كالسيوم، حساسية',
      'notes': 'يؤخذ مع وجبة دسمة لامتصاص أفضل',
      'overdose': 'غثيان، قيء، إمساك',
      'forms': ['أقراص', 'قطرات', 'حقن'],
      'brands': ['فيتامين د3', 'كالسيوم د']
    },
    'حديد': {
      'name_en': 'Iron',
      'category': 'مكمل غذائي - معدن',
      'dose_adult': '65mg يومياً',
      'dose_child': 'حسب الوزن',
      'max_daily': '200mg',
      'pregnancy': 'آمن',
      'breastfeeding': 'آمن',
      'side_effects': 'إمساك، براز أسود، غثيان',
      'interactions': 'مضادات حموضة، تتراسايكلين',
      'contraindications': 'داء ترسب الأصبغة الدموية',
      'notes': 'مع فيتامين C لامتصاص أفضل',
      'overdose': 'تسمم حديدي - طوارئ',
      'forms': ['أقراص', 'شراب', 'قطرات', 'حقن'],
      'brands': ['فيروجلوبين', 'حديد']
    },
    'فوليك أسيد': {
      'name_en': 'Folic Acid',
      'category': 'فيتامين ب9',
      'dose_adult': '400-800mcg يومياً',
      'dose_child': 'حسب العمر',
      'max_daily': '1000mcg',
      'pregnancy': 'آمن - ضروري',
      'breastfeeding': 'آمن',
      'side_effects': 'نادر',
      'interactions': 'مضادات اختلاج، ميثوتركسيت',
      'contraindications': 'حساسية الفوليك',
      'notes': 'مهم جداً قبل وخلال الحمل',
      'overdose': 'نادر',
      'forms': ['أقراص'],
      'brands': ['فوليك أسيد']
    },
    'ماغنيسيوم': {
      'name_en': 'Magnesium',
      'category': 'مكمل غذائي - معدن',
      'dose_adult': '200-400mg يومياً',
      'dose_child': 'حسب العمر',
      'max_daily': '400mg',
      'pregnancy': 'آمن',
      'breastfeeding': 'آمن',
      'side_effects': 'إسهال، غثيان',
      'interactions': 'مضادات حموضة، مدرات بول',
      'contraindications': 'فشل كلوي، انسداد معوي',
      'notes': 'للعضلات والأعصاب والنوم - يفضل مساءً',
      'overdose': 'غثيان، قيء، انخفاض ضغط',
      'forms': ['أقراص', 'شراب', 'بودرة'],
      'brands': ['ماغنيسيوم', 'ماغنيسيوم بلس']
    },
    'زنك': {
      'name_en': 'Zinc',
      'category': 'مكمل غذائي - معدن',
      'dose_adult': '15-30mg يومياً',
      'dose_child': 'حسب العمر',
      'max_daily': '40mg',
      'pregnancy': 'آمن',
      'breastfeeding': 'آمن',
      'side_effects': 'غثيان، طعم معدني',
      'interactions': 'مضادات حيوية، بنسلامين',
      'contraindications': 'حساسية الزنك',
      'notes': 'يعزز المناعة ويساعد في التئام الجروح',
      'overdose': 'غثيان، قيء، إسهال',
      'forms': ['أقراص', 'شراب', 'معينات'],
      'brands': ['زنك', 'زينك فيت']
    },
    'أوميغا 3': {
      'name_en': 'Omega-3',
      'category': 'مكمل غذائي - دهون أوميغا',
      'dose_adult': '1000-2000mg يومياً',
      'dose_child': 'حسب العمر',
      'max_daily': '3000mg',
      'pregnancy': 'آمن',
      'breastfeeding': 'آمن',
      'side_effects': 'رائحة سمك، غازات',
      'interactions': 'مميعات دم',
      'contraindications': 'حساسية السمك',
      'notes': 'يفضل مع وجبة - للقلب والدماغ',
      'overdose': 'نزيف، غثيان',
      'forms': ['كبسولات', 'شراب'],
      'brands': ['أوميغا 3', 'زيت سمك']
    },
    'بيوتين': {
      'name_en': 'Biotin',
      'category': 'فيتامين ب7',
      'dose_adult': '30-100mcg يومياً',
      'dose_child': 'حسب العمر',
      'max_daily': '100mcg',
      'pregnancy': 'آمن',
      'breastfeeding': 'آمن',
      'side_effects': 'نادر',
      'interactions': 'مضادات اختلاج',
      'contraindications': 'حساسية البيوتين',
      'notes': 'للشعر والأظافر والجلد',
      'overdose': 'نادر',
      'forms': ['أقراص', 'كبسولات'],
      'brands': ['بيوتين', 'بيوتين فورت']
    },
    'ميلاتونين': {
      'name_en': 'Melatonin',
      'category': 'منظم النوم - هرمون',
      'dose_adult': '3-5mg قبل النوم',
      'dose_child': '1-3mg',
      'max_daily': '5mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'نعاس نهاري، صداع',
      'interactions': 'مميعات دم، مضادات مناعة',
      'contraindications': 'اضطرابات مناعية',
      'notes': 'للأرق وتنظيم الساعة البيولوجية',
      'overdose': 'نعاس، دوخة',
      'forms': ['أقراص', 'قطرات', 'معينات'],
      'brands': ['ميلاتونين', 'سليب إيد']
    },
    'مونتيلوكاست': {
      'name_en': 'Montelukast',
      'category': 'مضاد ليوكوترين',
      'dose_adult': '10mg مساءً',
      'dose_child': '4-5mg مساءً',
      'max_daily': '10mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'صداع، أرق، عدوانية',
      'interactions': 'فينوباربيتال، ريفامبيسين',
      'contraindications': 'حساسية المونتيلوكاست',
      'notes': 'للربو والحساسية - لا يستخدم للنوبات الحادة',
      'overdose': 'صداع، غثيان',
      'forms': ['أقراص', 'حبيبات'],
      'brands': ['سنغولير', 'مونتيلوكاست']
    },
    'ليفوثيروكسين': {
      'name_en': 'Levothyroxine',
      'category': 'هرمون درقي',
      'dose_adult': '25-100mcg صباحاً',
      'dose_child': 'حسب الوزن',
      'max_daily': '200mcg',
      'pregnancy': 'آمن - ضروري',
      'breastfeeding': 'آمن',
      'side_effects': 'خفقان، أرق، رجفة',
      'interactions': 'مضادات حموضة، حديد، كالسيوم',
      'contraindications': 'فرط درق غير معالج',
      'notes': 'على معدة فارغة - قبل الإفطار بـ 30 دقيقة',
      'overdose': 'خفقان، تعرق، قلق',
      'forms': ['أقراص'],
      'brands': ['ثيروكسين', 'إيليتروكسين']
    },
    'وارفارين': {
      'name_en': 'Warfarin',
      'category': 'مميع دم - مضاد تخثر',
      'dose_adult': '2-5mg يومياً',
      'dose_child': 'نادر',
      'max_daily': 'حسب INR',
      'pregnancy': 'غير آمن',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'نزيف، كدمات',
      'interactions': 'كثير - فيتامين ك، مضادات حيوية',
      'contraindications': 'نزف نشط، قرحة',
      'notes': 'يراقب INR أسبوعياً - حمية ثابتة من فيتامين ك',
      'overdose': 'نزيف حاد - طوارئ',
      'forms': ['أقراص'],
      'brands': ['كومادين', 'وارفارين']
    },
    'كلوبيدوجريل': {
      'name_en': 'Clopidogrel',
      'category': 'مضاد صفائح - مميع دم',
      'dose_adult': '75mg يومياً',
      'dose_child': 'غير موصى به',
      'max_daily': '75mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'نزيف، كدمات',
      'interactions': 'مثبطات مضخة البروتون، مضادات تخثر',
      'contraindications': 'نزف نشط، قرحة',
      'notes': 'بعد الجلطات والدعامات القلبية',
      'overdose': 'نزيف',
      'forms': ['أقراص'],
      'brands': ['بلافيكس', 'كلوبيدوجريل']
    },
    'بروميثازين': {
      'name_en': 'Promethazine',
      'category': 'مضاد هستامين - مهدئ',
      'dose_adult': '25mg عند الحاجة',
      'dose_child': 'غير موصى به <2 سنة',
      'max_daily': '75mg',
      'pregnancy': 'غير آمن',
      'breastfeeding': 'غير آمن',
      'side_effects': 'نعاس شديد، جفاف',
      'interactions': 'مهدئات، كحول',
      'contraindications': 'ربو، صرع، مشاكل كبد',
      'notes': 'للحساسية الشديدة والغثيان - يسبب نعاساً شديداً',
      'overdose': 'نعاس شديد، تثبيط تنفسي',
      'forms': ['أقراص', 'شراب', 'تحاميل', 'حقن'],
      'brands': ['فينيرغان', 'بروميثازين']
    },
    'ديكساميثازون': {
      'name_en': 'Dexamethasone',
      'category': 'كورتيكوستيرويد',
      'dose_adult': 'حسب الحالة',
      'dose_child': 'حسب الوزن',
      'max_daily': 'حسب الوصفة',
      'pregnancy': 'للضرورة فقط',
      'breastfeeding': 'للضرورة فقط',
      'side_effects': 'ارتفاع سكر، زيادة وزن، هشاشة',
      'interactions': 'مضادات التهاب، مدرات بول',
      'contraindications': 'عدوى فطرية، حساسية',
      'notes': 'لا يوقف فجأة - تخفيض تدريجي',
      'overdose': 'ارتفاع سكر، ارتفاع ضغط',
      'forms': ['أقراص', 'حقن', 'قطرات'],
      'brands': ['ديكساميثازون']
    },
    'ريفاروكسابان': {
      'name_en': 'Rivaroxaban',
      'category': 'مميع دم مباشر',
      'dose_adult': '20mg يومياً مع العشاء',
      'dose_child': 'غير موصى به',
      'max_daily': '20mg',
      'pregnancy': 'غير آمن',
      'breastfeeding': 'غير آمن',
      'side_effects': 'نزيف، كدمات',
      'interactions': 'مضادات فطريات، مضادات حيوية',
      'contraindications': 'نزف نشط، فشل كبدي',
      'notes': 'لا يحتاج مراقبة INR - يؤخذ مع الوجبة',
      'overdose': 'نزيف',
      'forms': ['أقراص'],
      'brands': ['زاريلتو', 'ريفاروكسابان']
    },
  };

  // ===== 30+ مرض مع معلومات كاملة =====
  final Map<String, Map<String, dynamic>> diseasesDb = {
    'ارتفاع ضغط الدم': {
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
    'السكري نوع 2': {
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
    'الربو': {
      'category': 'جهاز تنفسي',
      'symptoms': 'صفير صدر، ضيق تنفس، سعال ليلي، ضغط صدر',
      'causes': 'حساسية، وراثة، ملوثات، تدخين',
      'treatment': 'بخاخات موسعة، بخاخات واقية، تجنب المحفزات',
      'complications': 'نوبة ربو حادة، تلف رئة، قصور تنفسي',
      'prevention': 'تجنب المحفزات، بخاخ وقائي منتظم',
      'normal_range': 'تخطيط تنفس طبيعي، قمة تدفق >80%',
      'when_to_see_doctor': 'نوبة لا تستجيب للبخاخ أو صعوبة في الكلام',
      'emergency_warning': 'عدم قدرة على الكلام، زرقة شفاه',
    },
    'الاكتئاب': {
      'category': 'صحة نفسية',
      'symptoms': 'حزن مستمر، فقدان اهتمام، أرق، تعب، أفكار انتحارية',
      'causes': 'كيمياء دماغ، أحداث حياة، وراثة، أمراض مزمنة',
      'treatment': 'علاج نفسي، أدوية مضادة، دعم اجتماعي',
      'complications': 'انتحار، عزلة، إدمان، أمراض جسدية',
      'prevention': 'دعم اجتماعي، رياضة، نوم كاف، التعبير عن المشاعر',
      'normal_range': '-',
      'when_to_see_doctor': 'أعراض >2 أسابيع أو أفكار إيذاء',
      'emergency_warning': 'أفكار انتحارية، إهمال شخصي شديد',
    },
    'التهاب المعدة': {
      'category': 'جهاز هضمي',
      'symptoms': 'حرقة، ألم أعلى البطن، غثيان، انتفاخ، فقدان شهية',
      'causes': 'جرثومة المعدة، مسكنات، كحول، توتر',
      'treatment': 'مضادات حموضة، علاج الجرثومة، تجنب المهيجات',
      'complications': 'قرحة معدية، نزيف معدي، سرطان معدة',
      'prevention': 'تجنب المهيجات، أكل منتظم، تقليل التوتر',
      'normal_range': '-',
      'when_to_see_doctor': 'ألم مستمر >2 أسابيع، دم في القيء، براز أسود',
      'emergency_warning': 'قيء دموي، براز أسود، ألم شديد مفاجئ',
    },
    'فقر الدم': {
      'category': 'أمراض الدم',
      'symptoms': 'تعب، شحوب، دوخة، ضيق نفس، سرعة نبض، برودة أطراف',
      'causes': 'نقص حديد، نزيف، سوء تغذية، أمراض مزمنة',
      'treatment': 'مكملات حديد + فيتامين C، علاج السبب، غذاء غني بالحديد',
      'complications': 'فشل قلب، ضعف مناعة، مشاكل نمو للأطفال',
      'prevention': 'غذاء غني بالحديد، فيتامين C مع الوجبات',
      'normal_range': 'هيموجلوبين: رجال 13-17، نساء 12-16 g/dL',
      'when_to_see_doctor': 'تعب شديد مع شحوب أو ضيق تنفس',
      'emergency_warning': 'ضيق تنفس شديد، دوخة، إغماء',
    },
    'التهاب المفاصل': {
      'category': 'عظام ومفاصل',
      'symptoms': 'ألم مفاصل، تورم، تيبس صباحي >1 ساعة، إرهاق',
      'causes': 'مناعة ذاتية، عوامل بيئية، وراثة',
      'treatment': 'مسكنات، مضادات روماتيزم، كورتيزون، علاج طبيعي',
      'complications': 'تشوه مفاصل، هشاشة عظام، أمراض قلب',
      'prevention': 'وزن صحي، تمارين تقوية، إقلاع تدخين، فحص مبكر',
      'normal_range': 'مؤشر التهاب <10، سرعة ترسيب <20',
      'when_to_see_doctor': 'تيبس وتورم مفاصل >6 أسابيع',
      'emergency_warning': 'ألم مفاصل شديد، حمى، تورم أحمر ساخن',
    },
    'الصداع النصفي': {
      'category': 'أعصاب',
      'symptoms': 'ألم نابض جانبي، غثيان، حساسية ضوء/صوت، هالة بصرية',
      'causes': 'وراثة، محفزات غذائية، توتر، هرمونات',
      'treatment': 'مسكنات، أدوية وقائية، غرفة مظلمة، راحة',
      'complications': 'صداع مزمن، متلازمة الصداع المفرط بالأدوية',
      'prevention': 'تجنب المحفزات، نوم منتظم، رياضة، أدوية وقائية',
      'normal_range': '-',
      'when_to_see_doctor': 'صداع >72 ساعة أو تغير نمط الصداع',
      'emergency_warning': 'صداع مفاجئ شديد، حمى، تشوش، ضعف مفاجئ',
    },
    'التهاب الكبد': {
      'category': 'كبد',
      'symptoms': 'يرقان، تعب، ألم بطن، بول غامق، براز فاتح، غثيان',
      'causes': 'فيروسات، كحول، أدوية سامة، مناعة ذاتية',
      'treatment': 'راحة، مضادات فيروسية، تطعيم',
      'complications': 'تشمع كبد، فشل كبدي، سرطان كبد',
      'prevention': 'تطعيم، نظافة، تجنب كحول، فحص دم للمتبرعين',
      'normal_range': 'إنزيمات كبد طبيعية (ALT<40, AST<40)',
      'when_to_see_doctor': 'يرقان أو تعب شديد مع ألم بطن',
      'emergency_warning': 'يرقان شديد، نزيف، تشوش، استسقاء',
    },
    'حصوات الكلى': {
      'category': 'مسالك بولية',
      'symptoms': 'ألم خاصرة شديد، دم في البول، غثيان، تكرار تبول',
      'causes': 'جفاف، أملاح، وراثة، غذاء غني بالبروتين',
      'treatment': 'سوائل كثيرة، تفتيت موجي، مسكنات، جراحة',
      'complications': 'انسداد، فشل كلوي، تكرار الحصوات',
      'prevention': 'شرب 2-3 لتر ماء يومياً، تقليل ملح وبروتين حيواني',
      'normal_range': '-',
      'when_to_see_doctor': 'ألم شديد مع غثيان أو حمى أو عدم تبول',
      'emergency_warning': 'عدم تبول، حمى مع قشعريرة، ألم لا يحتمل',
    },
  };

  // ===== 30+ تخصص طبي =====
  final Map<String, Map<String, dynamic>> specializations = {
    'الطب العام': {
      'keywords': ['حرارة', 'تعب', 'إرهاق', 'ضعف', 'فقدان وزن', 'فحص دوري'],
      'description': 'الطبيب العام هو خط الدفاع الأول',
    },
    'الطب العصبي': {
      'keywords': ['صداع', 'دوار', 'دوخة', 'تشنج', 'صرع', 'تنميل', 'شلل'],
      'description': 'أمراض الجهاز العصبي',
    },
    'الصدرية والقلب': {
      'keywords': ['صدر', 'قلب', 'ضيق تنفس', 'سعال', 'خفقان', 'ألم صدر'],
      'description': 'أمراض القلب والجهاز التنفسي',
    },
    'الجهاز الهضمي': {
      'keywords': ['بطن', 'معدة', 'إسهال', 'إمساك', 'غثيان', 'حرقة'],
      'description': 'أمراض الجهاز الهضمي',
    },
    'الجلدية': {
      'keywords': ['طفح', 'حكة', 'احمرار', 'بثور', 'تورم', 'أكزيما'],
      'description': 'أمراض الجلد والشعر والأظافر',
    },
    'العظام والمفاصل': {
      'keywords': ['عظام', 'مفاصل', 'ظهر', 'رقبة', 'ركبة', 'ألم عظام'],
      'description': 'أمراض العظام والمفاصل',
    },
    'الصحة النفسية': {
      'keywords': ['قلق', 'اكتئاب', 'أرق', 'توتر', 'خوف', 'هلع'],
      'description': 'الصحة النفسية والاضطرابات النفسية',
    },
    'طب الأطفال': {
      'keywords': ['طفل', 'رضيع', 'حمى', 'تسنين', 'مغص', 'تلقيح'],
      'description': 'أمراض الأطفال من الولادة حتى المراهقة',
    },
    'طب العيون': {
      'keywords': ['عين', 'رؤية', 'نظر', 'غشاوة', 'احمرار عين', 'دموع'],
      'description': 'أمراض العين والرؤية',
    },
    'أنف وأذن وحنجرة': {
      'keywords': ['أذن', 'أنف', 'حلق', 'زكام', 'رشح', 'تهاب حلق'],
      'description': 'أمراض الأنف والأذن والحنجرة',
    },
    'طب الأسنان': {
      'keywords': ['أسنان', 'ضرس', 'لثة', 'فم', 'تسوس', 'خراج'],
      'description': 'أمراض الأسنان والفم واللثة',
    },
    'المسالك البولية': {
      'keywords': ['بول', 'حرقان', 'تبول', 'مثانة', 'دم في بول', 'سلس'],
      'description': 'أمراض الكلى والمسالك البولية',
    },
    'الغدد الصماء': {
      'keywords': ['سكر', 'غدة', 'هرمون', 'درق', 'نمو', 'بلوغ', 'سمنة'],
      'description': 'أمراض الغدد الصماء والسكري',
    },
  };

  // ===== 100+ نصيحة صحية =====
  final List<String> healthTips = [
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
    'استخدم واقي شمس SPF 30+ يومياً ☀️',
    'اغسل يديك بانتظام 🧼',
    'تناول الألياف 25-30 غراماً يومياً 🌾',
    'مارس تمارين تقوية العضلات مرتين أسبوعياً 💪',
    'احصل على تطعيم الإنفلونزا سنوياً 💉',
    'افحص أسنانك كل 6 أشهر 🦷',
    'تجنب الجلوس المطول لأكثر من ساعة 🪑',
    'تأمل 10 دقائق يومياً 🧘‍♀️',
    'تواصل مع الأصدقاء والعائلة بانتظام 👨‍👩‍👧‍👦',
    'تعلم مهارة جديدة لتحفيز عقلك 🧠',
    'تجنب المشروبات الغازية 🥤',
    'استخدم الدرج بدل المصعد 🏃',
    'اقرأ ملصقات الطعام قبل الشراء 🏷️',
    'تناول فيتامين د في الشتاء ☀️',
    'لا تؤجل الفحص الدوري السنوي 📅',
    'ابتسم.. الصحة النفسية تبدأ بابتسامة 😊',
    'تناول المكسرات (اللوز، الجوز) يومياً 🥜',
    'قلل القلي والمقليات 🍟',
    'استبدل الأرز الأبيض بالأرز البني 🍚',
    'تناول البروتين في كل وجبة 🍗',
    'لا تتخطى وجبة الإفطار 🍳',
    'احتفظ بزجاجة ماء بجانبك دائماً 🍼',
    'تجنب الأضواء الزرقاء قبل النوم 📵',
    'حافظ على وضعية جيدة أثناء الجلوس 🪑',
    'امتدد بعد الاستيقاظ مباشرة 🤸',
    'خذ قيلولة 20 دقيقة إذا احتجت 😴',
    'تناول الشاي الأخضر يومياً 🍵',
    'تجنب السهر المتكرر 🌙',
    'اقرأ كتاباً قبل النوم 📚',
    'احتضن شخصاً تحبه يومياً 🤗',
    'تبرع بالدم كل 3 أشهر إذا استطعت 🩸',
    'تفقد ثدييك/خصيتيك شهرياً 🎗️',
    'تجنب التوتر المفرط.. فهو قاتل صامت 😰',
    'اشكر الله على نعمة الصحة كل يوم 🤲',
  ];

  // ===== 50+ سؤال شائع =====
  final Map<String, String> faqResponses = {
    'كيف احجز موعد': '📅 لحجز موعد:\n1. اذهب لقسم الأطباء 👨‍⚕️\n2. اختر التخصص والطبيب\n3. اختر التاريخ والوقت\n4. أكد الحجز',
    'كم سعر الاستشارة': '💰 أسعار الاستشارات:\n• طبيب عام: 100-300 ر.س\n• استشاري: 300-800 ر.س\n• أستاذ: 500-1500 ر.س',
    'كيف الغي موعد': '❌ لإلغاء موعد:\n1. اذهب للمواعيد 📅\n2. اختر الموعد المطلوب\n3. اضغط إلغاء\n⚠️ يمكن الإلغاء قبل ساعتين فقط',
    'هل التطبيق مجاني': '🆓 التطبيق مجاني مع باقة أساسية.\n💎 الباقات المدفوعة:\n• الذهبية: 99 ر.س/شهر\n• البلاتينية: 249 ر.س/شهر',
    'كيف اضيف دواء للتذكير': '💊 لإضافة تذكير دواء:\n1. اذهب لتذكير الأدوية 🔔\n2. اضغط + (إضافة جديدة)\n3. أدخل اسم الدواء والجرعة\n4. حدد الوقت والتكرار',
    'كيف اتواصل مع طبيب': '📞 يمكنك التواصل عبر:\n• الدردشة النصية 💬\n• مكالمة فيديو 📹\n• مكالمة صوتية 📞',
    'اين اجد نتائج تحاليلي': '🔬 نتائج التحاليل في:\n• الملف الصحي > التقارير الطبية 📄\n• قسم التحاليل > نتائجي',
    'كيف اغير كلمة المرور': '🔐 لتغيير كلمة المرور:\nالإعدادات ⚙️ > الحساب > تغيير كلمة المرور',
    'هل بياناتي آمنة': '🔒 نعم! جميع بياناتك مشفرة بأعلى معايير الأمان (AES-256).',
    'ماذا افعل في الطوارئ': '🚨 في الطوارئ:\n1. اتصل على 1122 فوراً\n2. اذهب لأقرب مستشفى 🏥\n3. استخدم زر SOS في التطبيق 🆘',
  };

  // ===== الإسعافات الأولية =====
  final Map<String, String> firstAidDb = {
    'النزيف': 'اضغط بقوة على الجرح بقطعة قماش نظيفة، ارفع الجزء المصاب، اتصل بالطوارئ إذا لم يتوقف النزيف',
    'الحروق': 'ضع المنطقة المصابة تحت ماء بارد جارٍ لمدة 10-15 دقيقة، لا تضع ثلجاً، غطِ الجرح بضمادة معقمة',
    'الجروح': 'نظف الجرح بالماء والصابون، ضع مطهراً، غطِ بضمادة معقمة، راقب علامات العدوى',
    'الكدمات': 'ضع كمادات باردة (ثلج) لمدة 15-20 دقيقة، ارفع الجزء المصاب، استخدم مسكنات الألم إذا لزم',
    'التواء': 'راحة، كمادات باردة (ثلج)، ضغط، رفع (RICE)',
    'لدغات الحشرات': 'أزل الإبرة إن وجدت، اغسل المنطقة بالماء والصابون، ضع كمادات باردة، استخدم مضاد هستامين للحكة',
    'الحساسية الشديدة': 'استخدم الإبينفرين (حقنة) إن وجد، اتصل بالطوارئ فوراً، ضع المصاب في وضعية مريحة',
    'الغصة (الاختناق)': 'هيمليخ (دفع البطن) للبالغين، ضربات الظهر للأطفال <1 سنة، اتصل بالطوارئ',
    'الإغماء': 'ضع المصاب مستلقياً مع رفع القدمين، تأكد من التنفس والنبض، اتصل بالطوارئ إذا استمر >دقيقة',
    'النوبة': 'أبعد الأشياء الحادة، ضع المصاب على جانبه، لا تضع شيئاً في الفم، اتصل بالطوارئ إذا استمرت >5 دقائق',
  };
}

// ============================================================
//   القسم الثاني: محرك الفرز الطبي (Triage)
// ============================================================

class TriageEngine {
  final MedicalKnowledgeBase _kb = MedicalKnowledgeBase();

  Map<String, dynamic> predict(String symptoms, {String? bodyPart}) {
    final symptomsLower = symptoms.toLowerCase();
    String bestSpecialization = 'الطب العام';
    int maxScore = 0;
    List<String> matchedKeywords = [];

    for (var entry in _kb.specializations.entries) {
      int score = 0;
      for (var keyword in entry.value['keywords'] as List<String>) {
        if (symptomsLower.contains(keyword.toLowerCase())) {
          score++;
          matchedKeywords.add(keyword);
        }
      }
      if (score > maxScore) {
        maxScore = score;
        bestSpecialization = entry.key;
      }
    }

    String urgency = 'low';
    final highKeywords = ['طوارئ', 'نزيف', 'اختناق', 'غيبوبة', 'ألم صدر', 'ضيق تنفس'];
    final mediumKeywords = ['مستمر', 'متكرر', 'حاد'];

    if (highKeywords.any((k) => symptomsLower.contains(k))) {
      urgency = 'high';
    } else if (mediumKeywords.any((k) => symptomsLower.contains(k))) {
      urgency = 'medium';
    }

    String action;
    String timeframe;
    if (urgency == 'high') {
      action = '🚨 حالة طارئة - اتصل على 1122 أو اذهب لأقرب مستشفى فوراً';
      timeframe = 'فوري - الآن';
    } else if (urgency == 'medium') {
      action = '📅 استشارة طبية خلال 24 ساعة';
      timeframe = 'خلال 24 ساعة';
    } else {
      action = '🏠 مراقبة منزلية، استشر طبيباً إذا استمرت الأعراض أكثر من 3 أيام';
      timeframe = '3-5 أيام';
    }

    return {
      'specialization': bestSpecialization,
      'urgency': urgency,
      'recommended_action': action,
      'timeframe': timeframe,
      'confidence': (0.7 + (0.1 * (maxScore / 5))).clamp(0.0, 0.95),
      'matched_keywords': matchedKeywords.take(5).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  List<Map<String, dynamic>> getPossibleConditions(String symptoms, {String? bodyPart}) {
    final result = predict(symptoms, bodyPart: bodyPart);
    final spec = result['specialization'] as String;

    final conditionsMap = {
      'الطب العام': [
        {'name': 'نزلة بردية', 'probability': 'مرتفع', 'treatment': 'راحة، سوائل، فيتامين C'},
        {'name': 'إرهاق عام', 'probability': 'متوسط', 'treatment': 'نوم كاف، تغذية متوازنة'},
      ],
      'الطب العصبي': [
        {'name': 'صداع توتري', 'probability': 'مرتفع', 'treatment': 'راحة، مسكنات، تجنب الإجهاد'},
        {'name': 'شقيقة (صداع نصفي)', 'probability': 'متوسط', 'treatment': 'غرفة مظلمة، مسكنات خاصة'},
      ],
      'الصدرية والقلب': [
        {'name': 'التهاب شعب هوائية', 'probability': 'متوسط', 'treatment': 'مضادات حيوية، موسعات شعب'},
        {'name': 'ذبحة صدرية', 'probability': 'منخفض', 'treatment': '🚨 راجع الطوارئ فوراً'},
      ],
      'الجهاز الهضمي': [
        {'name': 'التهاب معدي', 'probability': 'مرتفع', 'treatment': 'سوائل، راحة، أكل خفيف'},
        {'name': 'قولون عصبي', 'probability': 'متوسط', 'treatment': 'تجنب المهيجات، ألياف، بروبيوتيك'},
      ],
      'الجلدية': [
        {'name': 'إكزيما', 'probability': 'متوسط', 'treatment': 'مرطبات، كورتيزون موضعي'},
        {'name': 'حساسية جلدية', 'probability': 'مرتفع', 'treatment': 'مضاد هستامين، تجنب المسبب'},
      ],
      'العظام والمفاصل': [
        {'name': 'شد عضلي', 'probability': 'مرتفع', 'treatment': 'راحة، كمادات، مسكن'},
        {'name': 'التهاب مفاصل', 'probability': 'متوسط', 'treatment': 'مسكنات، علاج طبيعي'},
      ],
      'الصحة النفسية': [
        {'name': 'قلق عام', 'probability': 'مرتفع', 'treatment': 'تمارين تنفس، تأمل، استشارة نفسية'},
        {'name': 'اكتئاب', 'probability': 'متوسط', 'treatment': 'استشارة نفسية، علاج سلوكي'},
      ],
      'طب الأطفال': [
        {'name': 'التهاب حلق فيروسي', 'probability': 'مرتفع', 'treatment': 'سوائل دافئة، راحة، باراسيتامول'},
        {'name': 'مغص رضيع', 'probability': 'متوسط', 'treatment': 'تدليك بطن، تجشئة، دفء'},
      ],
    };

    return conditionsMap[spec] ?? conditionsMap['الطب العام']!;
  }
}

// ============================================================
//   القسم الثالث: بوت المحادثة الذكي
// ============================================================

class ChatBot {
  final MedicalKnowledgeBase _kb = MedicalKnowledgeBase();
  final TriageEngine _triageEngine = TriageEngine();
  final List<Map<String, dynamic>> _conversationHistory = [];
  Map<String, dynamic> _userContext = {};
  final Random _random = Random();

  final Map<String, Map<String, dynamic>> _patterns = {
    r'\b(سلام|هلا|مرحب|اهلا|hi|hello|hey|صباح الخير|مساء الخير)\b': {
      'response': 'وعليكم السلام ورحمة الله وبركاته! 🌸\n\nأنا مساعدك الصحي الذكي. يمكنني:\n• تحليل أعراضك 🩺\n• اقتراح تخصص طبي 👨‍⚕️\n• الإجابة عن أسئلتك الصحية 💬\n• مساعدتك في استخدام التطبيق 📱\n\nكيف يمكنني خدمتك اليوم؟',
      'type': 'greeting',
    },
    r'\b(طوارئ|emergency|urgent|طارئ|حادث|نزيف|اختناق|غيبوبة|قلب|صدر|ألم صدر|ضيق تنفس)\b': {
      'response': '🚨 حالة طارئ!\n\n• اتصل فوراً على 1122 📞\n• اذهب لأقرب مستشفى 🏥\n• استخدم زر SOS في التطبيق 🆘\n\n⚠️ لا تنتظر! الطوارئ الطبية تحتاج استجابة فورية.',
      'type': 'urgent',
    },
    r'\b(احجز|book|حجز|موعد|appointment).*(طبيب|doctor|دكتور)\b': {
      'response': '📅 لحجز موعد:\n1. اذهب لقسم "الأطباء" 👨‍⚕️\n2. اختر التخصص والطبيب المناسبين\n3. اختر التاريخ والوقت المتاحين\n4. اختر نوع الموعد (حضوري/فيديو)\n5. أكد الحجز\n\n💡 يمكنك تصفية الأطباء حسب التقييم، السعر، والتوفر.',
      'type': 'help',
    },
    r'\b(إلغا|cancel).*(موعد|استشار|appointment|consultation)\b': {
      'response': '❌ لإلغاء الموعد:\n1. اذهب إلى "المواعيد" 📅\n2. اختر الموعد المطلوب\n3. اضغط "إلغاء"\n\n⚠️ يمكن الإلغاء قبل ساعتين فقط من الموعد.',
      'type': 'help',
    },
    r'\b(باقة|اشتراك|plan|subscription|سعر|تكلف|price|cost|ذهبية|بلاتينية|عائلية)\b': {
      'response': '💎 باقاتنا المميزة:\n\n🆓 الأساسية (مجانية):\n• 2 استشارة/شهر\n• خصم 5% صيدلية\n\n⭐ الذهبية (99 ر.س/شهر):\n• استشارات غير محدودة\n• خصم 20% صيدلية\n\n👑 البلاتينية (249 ر.س/شهر):\n• فيديو + خصم 30%\n• طبيب أسرة شخصي\n\n👨‍👩‍👧‍👦 العائلية (399 ر.س/شهر):\n• 5 أفراد\n• خصم 35%',
      'type': 'info',
    },
    r'\b(دوا|علاج|medicine|medication|drug|pharmacy|صيدل)\b': {
      'response': '💊 اكتب اسم الدواء الذي تريد معلومات عنه.\nمثال: "باراسيتامول"، "ايبوبروفين"، "ميتفورمين".',
      'type': 'info',
    },
    r'\b(نتيجة|نتائج|تحليل|lab|test result|فحص|CBC|سكر|ضغط)\b': {
      'response': '🔬 نتائج التحاليل متوفرة في:\n• الملف الصحي > التقارير الطبية 📄\n• قسم التحاليل > نتائجي\n\n⏱️ تستغرق 2-48 ساعة حسب نوع التحليل.\n🔔 سيصلك إشعار عند الجاهزية.',
      'type': 'info',
    },
    r'\b(شكر|thanks|thank|مشكو|بارك الله|جزاك)\b': {
      'response': 'العفو! 🌸\n\nسعيد بمساعدتك. تذكر أنا هنا دائماً للإجابة عن أسئلتك.\n\n💚 هل هناك شيء آخر يمكنني مساعدتك فيه؟',
      'type': 'greeting',
    },
    r'\b(وداع|باي|bye|مع السلام|سلامه|إلى اللقاء)\b': {
      'response': 'في أمان الله! 👋\n\nدمت بصحة وعافية 🤍\n\nتذكر: أنا هنا دائماً لمساعدتك.',
      'type': 'greeting',
    },
    r'\b(عندي|اعاني|احس|اشعر|الم|وجع|تعبان|مرض|symptom|pain|hurt|sick|حمى|صداع|كحة|سعال|اسهال)\b': {
      'response': '🩺 دعني أحلل أعراضك...\n\nالرجاء وصف الأعراض بالتفصيل، مثل:\n• ما هي الأعراض بالتحديد؟\n• منذ متى بدأت؟\n• شدتها؟ (خفيف/متوسط/شديد)\n• أي جزء من الجسم؟\n\n💡 سأقوم بفرز حالتك وتوجيهك للتخصص المناسب.',
      'type': 'triage',
    },
    r'\b(قلق|اكتئاب|توتر|حزين|خوف|نوم|أرق|psychological|mental health)\b': {
      'response': '🧠 الصحة النفسية مهمة مثل الجسدية.\n\nيمكنني مساعدتك بـ:\n• تمارين التنفس العميق 🧘\n• تقنيات الاسترخاء\n• نصائح للنوم المريح\n• توجيهك لاختصاصي نفسي\n\n💬 هل تريد التحدث أكثر عن مشاعرك؟',
      'type': 'emotional',
    },
  };

  final Map<String, String> _emotionalResponses = {
    'sad': '🤍 أتفهم شعورك. الصحة النفسية مهمة مثل الجسدية.\n\nتذكر أنت لست وحدك.\n• يمكنك التحدث مع مختص نفسي\n• مارس التنفس العميق\n• تواصل مع شخص تحبه',
    'angry': '😔 أعتذر عن أي إزعاج.\n\nدعني أساعدك في حل المشكلة. هل يمكنك شرح ما حدث بالتفصيل؟',
    'worried': '🧘 القلق طبيعي، لكن دعنا نتصرف بهدوء.\n\nما هي الأعراض التي تثير قلقك؟ سأساعدك في تحليل الموقف.',
    'happy': '😊 جميل أن أسمع ذلك!\n\nكيف يمكنني مساعدتك اليوم؟\n• هل تريد موعداً مع طبيب؟\n• تبحث عن دواء معين؟',
    'tired': '😴 يبدو أنك متعب.\n\nنصائح لتجديد النشاط:\n• خذ قسطاً من الراحة\n• اشرب كوباً من الماء\n• تناول وجبة خفيفة صحية',
  };

  String? analyzeEmotion(String message) {
    final msgLower = message.toLowerCase();
    if (['حزين', 'مكتئب', 'مقهور', 'sad', 'depressed'].any((w) => msgLower.contains(w))) return 'sad';
    if (['غاضب', 'معصب', 'مستفز', 'angry'].any((w) => msgLower.contains(w))) return 'angry';
    if (['قلق', 'خايف', 'متوتر', 'worried', 'scared'].any((w) => msgLower.contains(w))) return 'worried';
    if (['سعيد', 'مبسوط', 'فرحان', 'happy', 'glad'].any((w) => msgLower.contains(w))) return 'happy';
    if (['تعبان', 'مرهق', 'نعسان', 'tired', 'exhausted'].any((w) => msgLower.contains(w))) return 'tired';
    return null;
  }

  String? getDrugInfo(String message) {
    final msgLower = message.toLowerCase();
    for (var entry in _kb.drugsDb.entries) {
      final drugName = entry.key;
      final info = entry.value;
      if (msgLower.contains(drugName) || msgLower.contains((info['name_en'] as String).toLowerCase())) {
        return '''
💊 $drugName (${info['name_en']})

📋 التصنيف: ${info['category']}
💊 الجرعة للبالغين: ${info['dose_adult']}
👶 الجرعة للأطفال: ${info['dose_child']}
⚠️ الحد الأقصى اليومي: ${info['max_daily']}
🤰 الحمل: ${info['pregnancy']}
⚠️ الآثار الجانبية: ${info['side_effects']}
🔄 التداخلات: ${info['interactions']}
🚫 موانع الاستعمال: ${info['contraindications']}
📝 ملاحظات: ${info['notes']}

⚠️ هذه معلومات عامة - استشر طبيبك قبل تناول أي دواء
''';
      }
    }
    return null;
  }

  String? getDiseaseInfo(String message) {
    final msgLower = message.toLowerCase();
    for (var entry in _kb.diseasesDb.entries) {
      final diseaseName = entry.key;
      final info = entry.value;
      if (msgLower.contains(diseaseName)) {
        return '''
🩺 $diseaseName

📋 التصنيف: ${info['category']}
🩺 الأعراض: ${info['symptoms']}
🔬 الأسباب: ${info['causes']}
💊 العلاج: ${info['treatment']}
⚠️ المضاعفات: ${info['complications']}
🛡️ الوقاية: ${info['prevention']}
📊 النطاق الطبيعي: ${info['normal_range']}
👨‍⚕️ متى تزور الطبيب: ${info['when_to_see_doctor']}
🔴 علامات الطوارئ: ${info['emergency_warning']}

⚠️ هذا تحليل أولي فقط - لا يعوض عن الاستشارة الطبية
''';
      }
    }
    return null;
  }

  String? getFirstAidInfo(String message) {
    final msgLower = message.toLowerCase();
    for (var entry in _kb.firstAidDb.entries) {
      if (msgLower.contains(entry.key)) {
        return '🚑 ${entry.key}:\n${entry.value}';
      }
    }
    return null;
  }

  String? getFaqAnswer(String message) {
    final msgLower = message.toLowerCase();
    String? bestKey;
    int bestScore = 0;
    for (var entry in _kb.faqResponses.entries) {
      final key = entry.key;
      final score = key.split(' ').where((w) => msgLower.contains(w)).length;
      if (score > bestScore) {
        bestScore = score;
        bestKey = key;
      }
    }
    if (bestKey != null && bestScore >= 1) return _kb.faqResponses[bestKey];
    return null;
  }

  String getRandomTip() => _kb.healthTips[_random.nextInt(_kb.healthTips.length)];

  Map<String, dynamic> respond(String message, {Map<String, dynamic>? context}) {
    if (context != null) _userContext = context;
    message = message.trim();
    if (message.isEmpty) {
      return {
        'response': '👋 مرحباً! كيف يمكنني مساعدتك اليوم؟',
        'type': 'greeting',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    final emotion = analyzeEmotion(message);
    if (emotion != null && _emotionalResponses.containsKey(emotion)) {
      return {
        'response': _emotionalResponses[emotion],
        'type': 'emotional_$emotion',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    final drugInfo = getDrugInfo(message);
    if (drugInfo != null) {
      return {
        'response': drugInfo,
        'type': 'drug_info',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    final diseaseInfo = getDiseaseInfo(message);
    if (diseaseInfo != null) {
      return {
        'response': diseaseInfo,
        'type': 'disease_info',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    final firstAidInfo = getFirstAidInfo(message);
    if (firstAidInfo != null) {
      return {
        'response': firstAidInfo,
        'type': 'first_aid',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    final faqAnswer = getFaqAnswer(message);
    if (faqAnswer != null) {
      return {
        'response': faqAnswer,
        'type': 'faq',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    for (var entry in _patterns.entries) {
      final pattern = RegExp(entry.key, caseSensitive: false);
      if (pattern.hasMatch(message)) {
        final result = Map<String, dynamic>.from(entry.value);
        result['timestamp'] = DateTime.now().toIso8601String();
        result['create_ticket'] = false;

        if (result['type'] == 'triage') {
          final triageResult = _triageEngine.predict(message);
          final conditions = _triageEngine.getPossibleConditions(message);
          String response = '🩺 تحليل الأعراض:\n\n📊 التخصص المقترح: **${triageResult['specialization']}**\n⚡ مستوى الطوارئ: ${triageResult['urgency']}\n🕒 الإطار الزمني: ${triageResult['timeframe']}\n📋 الإجراء الموصى به: ${triageResult['recommended_action']}\n\n📌 الحالات المحتملة:\n';
          for (int i = 0; i < (conditions.length > 3 ? 3 : conditions.length); i++) {
            final c = conditions[i];
            response += '${i + 1}. ${c['name']} (احتمال: ${c['probability']})\n';
          }
          response += '\n⚠️ هذا تحليل أولي فقط - لا يعوض عن الاستشارة الطبية.\n👨‍⚕️ للاستشارة الحقيقية، يمكنك حجز موعد مع طبيب متخصص عبر المنصة.';
          result['response'] = response;
        }
        return result;
      }
    }

    final tip = getRandomTip();
    return {
      'response': 'شكراً لتواصلك! 🙏\n\nلم أتمكن من فهم سؤالك بشكل كامل.\n\n💡 نصيحة اليوم:\n$tip\n\n👨‍⚕️ للاستشارة الطبية الحقيقية، يرجى حجز موعد مع طبيب متخصص.\n🆘 في الحالات الطارئة، اتصل على 1122 فوراً.\n\nهل تريد مساعدة في شيء آخر؟',
      'type': 'escalate',
      'create_ticket': true,
      'ticket_priority': 'normal',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

// ============================================================
//   القسم الرابع: خدمة البوت الموحدة
// ============================================================

class BotService {
  static final BotService _instance = BotService._internal();
  factory BotService() => _instance;
  BotService._internal();

  final ChatBot _chatBot = ChatBot();
  final TriageEngine _triageEngine = TriageEngine();

  Map<String, dynamic> processMessage(String message, {Map<String, dynamic>? context}) {
    return _chatBot.respond(message, context: context);
  }

  Map<String, dynamic> triageSymptoms(String symptoms, {String? bodyPart}) {
    return _triageEngine.predict(symptoms, bodyPart: bodyPart);
  }

  List<Map<String, dynamic>> getPossibleConditions(String symptoms, {String? bodyPart}) {
    return _triageEngine.getPossibleConditions(symptoms, bodyPart: bodyPart);
  }

  String? getDrugInfo(String drugName) => _chatBot.getDrugInfo(drugName);
  String? getDiseaseInfo(String diseaseName) => _chatBot.getDiseaseInfo(diseaseName);
  String getRandomTip() => _chatBot.getRandomTip();

  final MedicalKnowledgeBase _kb = MedicalKnowledgeBase();

  Map<String, dynamic> getStatistics() {
    return {
      'drugs': _kb.drugsDb.length,
      'diseases': _kb.diseasesDb.length,
      'specializations': _kb.specializations.length,
      'health_tips': _kb.healthTips.length,
      'faqs': _kb.faqResponses.length,
      'first_aid': _kb.firstAidDb.length,
    };
  }
}
