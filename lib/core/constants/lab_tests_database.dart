// 🔬 الفحوصات المخبرية - Lab Tests Database
class LabTestsDatabase {
  static final Map<String, Map<String, dynamic>> labTests = {
    'CBC': {'full_name':'تعداد دم كامل','purpose':'تقييم صحة الدم والخلايا','normal':{'WBC':'4.5-11 x10^3','RBC':'4.5-5.5 x10^6','Hgb':'13-17 g/dL (رجال)، 12-16 (نساء)','Hct':'38-50%','Plt':'150-400 x10^3'},'interpretation':'انخفاض: فقر دم، نزيف. ارتفاع: جفاف، كثرة الحمر','fasting':'لا يحتاج','time':'ساعة','price_range':'50-150 ر.س'},
    'HbA1c': {'full_name':'السكر التراكمي','purpose':'متوسط السكر في 3 أشهر','normal':{'HbA1c':'<5.7% (طبيعي)، 5.7-6.4% (مقدم)، ≥6.5% (سكري)'},'interpretation':'مؤشر لمتوسط سكر الدم','fasting':'لا يحتاج','time':'ساعة','price_range':'80-200 ر.س'},
    'Lipid Profile': {'full_name':'مستوى الدهون','purpose':'الكوليسترول والدهون الثلاثية','normal':{'Total Cholesterol':'<200 mg/dL','LDL':'<100 mg/dL','HDL':'>40 (رجال)، >50 (نساء)','Triglycerides':'<150 mg/dL'},'interpretation':'تقييم خطر أمراض القلب','fasting':'حسب المختبر','time':'2-4 ساعات','price_range':'100-250 ر.س'},
    'Liver Function': {'full_name':'وظائف الكبد','purpose':'صحة الكبد والقناة الصفراوية','normal':{'ALT':'<40 U/L','AST':'<40 U/L','ALP':'<120 U/L','Bilirubin':'0.2-1.2 mg/dL','Albumin':'3.5-5.0 g/dL'},'interpretation':'تقييم وظائف الكبد','fasting':'8 ساعات','time':'2-4 ساعات','price_range':'100-200 ر.س'},
    'Kidney Function': {'full_name':'وظائف الكلى','purpose':'تقييم صحة الكلى','normal':{'Creatinine':'0.6-1.2 mg/dL','BUN':'7-20 mg/dL','eGFR':'>90 mL/min'},'interpretation':'تقييم وظائف الكلى','fasting':'8 ساعات','time':'2-4 ساعات','price_range':'100-200 ر.س'},
    'TSH': {'full_name':'هرمون الغدة الدرقية المحفز','purpose':'وظيفة الغدة الدرقية','normal':{'TSH':'0.4-4.0 mIU/L','T4':'4.5-12.5 mcg/dL'},'interpretation':'تقييم وظيفة الغدة الدرقية','fasting':'لا يحتاج','time':'2-4 ساعات','price_range':'80-180 ر.س'},
    'Vitamin D': {'full_name':'فيتامين د','purpose':'مستوى فيتامين د','normal':{'Vitamin D':'30-50 ng/mL تقريباً'},'interpretation':'تقييم مستوى فيتامين د','fasting':'لا يحتاج','time':'24 ساعة','price_range':'150-300 ر.س'},
    'Vitamin B12': {'full_name':'فيتامين ب12','purpose':'تقييم مستوى ب12','normal':{'B12':'200-900 pg/mL'},'interpretation':'تقييم مستوى ب12','fasting':'حسب المختبر','time':'24 ساعة','price_range':'100-200 ر.س'},
    'Ferritin': {'full_name':'فيريتين','purpose':'مخزون الحديد','normal':{'Ferritin':'يختلف حسب العمر والجنس والمختبر'},'interpretation':'تقييم مخزون الحديد','fasting':'لا يحتاج','time':'2-4 ساعات','price_range':'80-150 ر.س'},
    'Urine Analysis': {'full_name':'تحليل بول كامل','purpose':'صحة الكلى والمسالك البولية','normal':{'Protein':'سلبي','Glucose':'سلبي','RBC':'0-2 /HPF','WBC':'0-5 /HPF'},'interpretation':'فحص عام للبول','fasting':'لا يحتاج','time':'ساعة','price_range':'30-80 ر.س'},
    'ECG': {'full_name':'تخطيط القلب الكهربائي','purpose':'نشاط القلب الكهربائي','normal':{'Rate':'60-100 bpm','Rhythm':'جيبية'},'interpretation':'تقييم النشاط الكهربائي للقلب','fasting':'لا يحتاج','time':'10 دقائق','price_range':'100-300 ر.س'},
    'Chest X-Ray': {'full_name':'أشعة صدر','purpose':'الرئتين والقلب والعظام الصدرية','normal':{'Lungs':'شفافة','Heart':'حجم طبيعي'},'interpretation':'تصوير الصدر','fasting':'لا يحتاج','time':'15 دقيقة','price_range':'100-250 ر.س'},
  };

  static Map<String, dynamic>? getLabTest(String name) => labTests[name];

  static List<Map<String, dynamic>> searchLabTests(String query) {
    final q = query.trim().toLowerCase();
    return labTests.entries.where((e) {
      final name = e.value['full_name']?.toString().toLowerCase() ?? '';
      return e.key.toLowerCase().contains(q) || name.contains(q);
    }).map((e) => {'name': e.key, ...e.value}).toList();
  }
}
