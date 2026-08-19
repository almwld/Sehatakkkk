// ============================================================
//   SEHTAK AI v6.0 - البوت الطبي المتكامل
//   Flutter/Dart Version - 2500+ سطر
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

  // ===== الأدوية =====
  final Map<String, Map<String, dynamic>> drugsDb = {
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
      'interactions': 'مميعات دم، ليثيوم، ميثوتريكسيت',
      'contraindications': 'قرحة معدة نشطة، فشل كلوي',
      'notes': 'يؤخذ مع الطعام لتقليل تأثير المعدة',
      'overdose': 'غثيان، نزيف معدي، فشل كلوي',
      'forms': ['أقراص', 'جل', 'شراب', 'تحاميل'],
      'brands': ['نوروفين', 'أدفيل', 'بروفين']
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
    'اوميبرازول': {
      'name_en': 'Omeprazole',
      'category': 'مثبط مضخة بروتون',
      'dose_adult': '20-40mg يومياً',
      'dose_child': 'غير موصى به',
      'max_daily': '40mg',
      'pregnancy': 'باستشارة طبيب',
      'breastfeeding': 'باستشارة طبيب',
      'side_effects': 'صداع، إسهال، غازات',
      'interactions': 'وارفارين، كلوبيدوجريل',
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
  };

  // ===== الأمراض =====
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
  };

  // ===== التخصصات الطبية =====
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

  // ===== النصائح الصحية =====
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
  ];

  // ===== الأسئلة الشائعة =====
  final Map<String, String> faqResponses = {
    'كيف احجز موعد': '📅 لحجز موعد:\n1. اذهب لقسم الأطباء 👨‍⚕️\n2. اختر التخصص والطبيب\n3. اختر التاريخ والوقت\n4. أكد الحجز',
    'كم سعر الاستشارة': '💰 أسعار الاستشارات:\n• طبيب عام: 3,000-10,000 ر.ي\n• استشاري: 10,000-25,000 ر.ي\n• أستاذ: 15,000-45,000 ر.ي',
    'كيف الغي موعد': '❌ لإلغاء موعد:\n1. اذهب للمواعيد 📅\n2. اختر الموعد المطلوب\n3. اضغط إلغاء\n⚠️ يمكن الإلغاء قبل ساعتين فقط',
    'هل التطبيق مجاني': '🆓 التطبيق مجاني مع باقة أساسية.\n💎 الباقات المدفوعة:\n• الذهبية: 99 ر.ي/شهر\n• البلاتينية: 249 ر.ي/شهر',
    'كيف اضيف دواء للتذكير': '💊 لإضافة تذكير دواء:\n1. اذهب لتذكير الأدوية 🔔\n2. اضغط + (إضافة جديدة)\n3. أدخل اسم الدواء والجرعة\n4. حدد الوقت والتكرار',
    'كيف اتواصل مع طبيب': '📞 يمكنك التواصل عبر:\n• الدردشة النصية 💬\n• مكالمة فيديو 📹\n• مكالمة صوتية 📞',
    'اين اجد نتائج تحاليلي': '🔬 نتائج التحاليل في:\n• الملف الصحي > التقارير الطبية 📄\n• قسم التحاليل > نتائجي',
    'كيف اغير كلمة المرور': '🔐 لتغيير كلمة المرور:\nالإعدادات ⚙️ > الحساب > تغيير كلمة المرور',
    'هل بياناتي آمنة': '🔒 نعم! جميع بياناتك مشفرة بأعلى معايير الأمان (AES-256).',
    'ماذا افعل في الطوارئ': '🚨 في الطوارئ:\n1. اتصل على 1122 فوراً\n2. اذهب لأقرب مستشفى 🏥\n3. استخدم زر SOS في التطبيق 🆘',
  };

  // ===== الإسعافات الأولية =====
  final Map<String, String> firstAidDb = {
    'النزيف': '🚑 النزيف:\n1. اضغط بقوة على الجرح بقطعة قماش نظيفة 🩹\n2. ارفع الجزء المصاب فوق مستوى القلب\n3. اتصل بالطوارئ إذا لم يتوقف النزيف بعد 10 دقائق',
    'الحروق': '🚑 الحروق:\n1. ضع المنطقة المصابة تحت ماء بارد جارٍ لمدة 10-15 دقيقة 💧\n2. لا تضع ثلجاً مباشرة على الحرق ❌\n3. غطِ الجرح بضمادة معقمة 🩹',
    'الجروح': '🚑 الجروح:\n1. نظف الجرح بالماء والصابون 🧼\n2. ضع مطهراً 🧴\n3. غطِ بضمادة معقمة 🩹\n4. راقب علامات العدوى',
    'الكدمات': '🚑 الكدمات:\n1. ضع كمادات باردة (ثلج ملفوف بقطعة قماش) لمدة 15-20 دقيقة ❄️\n2. ارفع الجزء المصاب\n3. استخدم مسكنات الألم إذا لزم',
    'التواء الكاحل': '🚑 التواء الكاحل:\n1. راحة (لا تضع وزن على القدم) 🦶\n2. كمادات باردة ❄️\n3. ضغط (ضمادة مرنة) 🩹\n4. رفع القدم فوق مستوى القلب',
    'لدغات الحشرات': '🚑 لدغات الحشرات:\n1. أزل الإبرة إن وجدت (ببطء) 🪡\n2. اغسل المنطقة بالماء والصابون 🧼\n3. ضع كمادات باردة ❄️\n4. استخدم مضاد هستامين للحكة 💊',
    'الحساسية الشديدة': '🚨 حساسية شديدة (صدمة تأقية):\n1. استخدم الإبينفرين (حقنة) إن وجد 💉\n2. اتصل بالطوارئ فوراً 📞\n3. ضع المصاب في وضعية مريحة (استلقاء مع رفع القدمين)\n4. راقب التنفس والنبض',
    'الغصة (الاختناق)': '🚨 الغصة:\n👤 للبالغين:\n1. قف خلف المصاب\n2. لف ذراعيك حول خصره\n3. ادفع بقوة إلى الداخل والأعلى (هيمليخ)\n\n👶 للأطفال <1 سنة:\n1. ضع الطفل على ساعدك\n2. اضرب بين الكتفين 5 مرات\n3. اقلب واضغط على الصدر 5 مرات',
    'الإغماء': '🚑 الإغماء:\n1. ضع المصاب مستلقياً مع رفع القدمين 🦶\n2. تأكد من التنفس والنبض\n3. قم بفك الملابس الضيقة\n4. اتصل بالطوارئ إذا استمر >دقيقة',
    'النوبة الصرعية': '🚑 النوبة الصرعية:\n1. ابعد الأشياء الحادة عن المصاب 🪑\n2. ضع المصاب على جانبه (وضعية الإفاقة)\n3. لا تضع شيئاً في الفم ❌\n4. سجل وقت بداية النوبة ⏱️\n⚠️ اتصل بالطوارئ إذا استمرت >5 دقائق أو تكررت',
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
//   القسم الثالث: بوت المحادثة الذكي (المُحسّن)
// ============================================================

class ChatBot {
  final MedicalKnowledgeBase _kb = MedicalKnowledgeBase();
  final TriageEngine _triageEngine = TriageEngine();
  final List<Map<String, dynamic>> _conversationHistory = [];
  Map<String, dynamic> _userContext = {};
  final Random _random = Random();

  // ============================================================
  // 🎯 الرد الرئيسي
  // ============================================================

  Map<String, dynamic> respond(String message, {Map<String, dynamic>? context}) {
    if (context != null) _userContext = context;
    message = message.trim();
    if (message.isEmpty) {
      return {
        'response': '👋 مرحباً! كيف يمكنني مساعدتك اليوم؟\n\n💡 يمكنك سؤالي عن:\n• الأدوية 💊\n• الأمراض 🩺\n• الإسعافات الأولية 🚑\n• نصائح صحية 💡',
        'type': 'greeting',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    final msgLower = message.toLowerCase();

    // ✅ التحقق من الطوارئ
    if (_isEmergency(msgLower)) {
      return {
        'response': '🚨 حالة طارئة!\n\n• اتصل فوراً على 1122 📞\n• اذهب لأقرب مستشفى 🏥\n• استخدم زر SOS في التطبيق 🆘\n\n⚠️ لا تنتظر! الطوارئ الطبية تحتاج استجابة فورية.',
        'type': 'urgent',
        'create_ticket': true,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    // ✅ التحقق من الدواء
    final drugInfo = _getDrugInfo(msgLower);
    if (drugInfo != null) {
      return {
        'response': drugInfo,
        'type': 'drug_info',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    // ✅ التحقق من المرض
    final diseaseInfo = _getDiseaseInfo(msgLower);
    if (diseaseInfo != null) {
      return {
        'response': diseaseInfo,
        'type': 'disease_info',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    // ✅ التحقق من الإسعافات الأولية
    final firstAidInfo = _getFirstAidInfo(msgLower);
    if (firstAidInfo != null) {
      return {
        'response': firstAidInfo,
        'type': 'first_aid',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    // ✅ التحقق من الأسئلة الشائعة
    final faqAnswer = _getFaqAnswer(msgLower);
    if (faqAnswer != null) {
      return {
        'response': faqAnswer,
        'type': 'faq',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    // ✅ تحليل الأعراض
    if (_isSymptomQuery(msgLower)) {
      final triageResult = _triageEngine.predict(message);
      final conditions = _triageEngine.getPossibleConditions(message);
      String response = '🩺 تحليل الأعراض:\n\n📊 التخصص المقترح: **${triageResult['specialization']}**\n⚡ مستوى الطوارئ: ${triageResult['urgency']}\n🕒 الإطار الزمني: ${triageResult['timeframe']}\n📋 الإجراء الموصى به: ${triageResult['recommended_action']}\n\n📌 الحالات المحتملة:\n';
      for (int i = 0; i < (conditions.length > 3 ? 3 : conditions.length); i++) {
        final c = conditions[i];
        response += '${i + 1}. ${c['name']} (احتمال: ${c['probability']})\n';
      }
      response += '\n⚠️ هذا تحليل أولي فقط - لا يعوض عن الاستشارة الطبية.';
      return {
        'response': response,
        'type': 'triage',
        'create_ticket': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    // ✅ رد افتراضي
    final tip = _kb.healthTips[_random.nextInt(_kb.healthTips.length)];
    return {
      'response': 'شكراً لتواصلك! 🙏\n\nلم أتمكن من فهم سؤالك بشكل كامل.\n\n💡 نصيحة اليوم:\n$tip\n\n👨‍⚕️ للاستشارة الطبية الحقيقية، يرجى حجز موعد مع طبيب متخصص.\n🆘 في الحالات الطارئة، اتصل على 1122 فوراً.',
      'type': 'general',
      'create_ticket': true,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // ============================================================
  // 🛠️ دوال المساعدة
  // ============================================================

  bool _isEmergency(String msg) {
    final emergencyWords = ['طوارئ', 'نزيف', 'اختناق', 'غيبوبة', 'ألم صدر', 'ضيق تنفس'];
    return emergencyWords.any((word) => msg.contains(word));
  }

  bool _isSymptomQuery(String msg) {
    final symptomWords = ['عندي', 'اعاني', 'احس', 'اشعر', 'الم', 'وجع', 'تعبان'];
    return symptomWords.any((word) => msg.contains(word));
  }

  String? _getDrugInfo(String msg) {
    for (var entry in _kb.drugsDb.entries) {
      final drugName = entry.key;
      final info = entry.value;
      if (msg.contains(drugName) || msg.contains((info['name_en'] as String).toLowerCase())) {
        return '''
💊 $drugName (${info['name_en']})

📋 التصنيف: ${info['category']}
💊 الجرعة للبالغين: ${info['dose_adult']}
👶 الجرعة للأطفال: ${info['dose_child']}
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

  String? _getDiseaseInfo(String msg) {
    for (var entry in _kb.diseasesDb.entries) {
      final diseaseName = entry.key;
      final info = entry.value;
      if (msg.contains(diseaseName)) {
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

  String? _getFirstAidInfo(String msg) {
    for (var entry in _kb.firstAidDb.entries) {
      if (msg.contains(entry.key)) {
        return '🚑 ${entry.key}:\n${entry.value}';
      }
    }
    return null;
  }

  String? _getFaqAnswer(String msg) {
    for (var entry in _kb.faqResponses.entries) {
      final key = entry.key;
      if (msg.contains(key)) {
        return entry.value;
      }
    }
    return null;
  }

  String getRandomTip() {
    return _kb.healthTips[_random.nextInt(_kb.healthTips.length)];
  }

  String? getDrugInfoByName(String drugName) {
    final msg = drugName.toLowerCase();
    for (var entry in _kb.drugsDb.entries) {
      if (msg.contains(entry.key) || msg.contains((entry.value['name_en'] as String).toLowerCase())) {
        return '''
💊 ${entry.key} (${entry.value['name_en']})

📋 التصنيف: ${entry.value['category']}
💊 الجرعة: ${entry.value['dose_adult']}
⚠️ الآثار: ${entry.value['side_effects']}
''';
      }
    }
    return null;
  }

  String? getDiseaseInfoByName(String diseaseName) {
    final msg = diseaseName.toLowerCase();
    for (var entry in _kb.diseasesDb.entries) {
      if (msg.contains(entry.key)) {
        return '''
🩺 ${entry.key}

📋 التصنيف: ${entry.value['category']}
🩺 الأعراض: ${entry.value['symptoms']}
🔬 الأسباب: ${entry.value['causes']}
💊 العلاج: ${entry.value['treatment']}
⚠️ المضاعفات: ${entry.value['complications']}
🛡️ الوقاية: ${entry.value['prevention']}
''';
      }
    }
    return null;
  }

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
