import 'dart:math';

/// Conservative natural-language symptom interpreter. It identifies symptoms and urgency; it does not diagnose.
class SymptomInterpreter {
  static const Map<String, List<String>> _lexicon = {
    'حمى / حرارة': ['حمى','حراره','حرارة','سخونه','سخونة','حار جسمي','جسمي حار','في حرارة','عندي حرارة','حرارتي مرتفعه','حرارتي مرتفعة'],
    'غثيان': ['غثيان','غثيانه','احس بغثيان','احس بالغثيان','قلبي يموج','نفسي تقلب','نفسي مقلوبه','نفسي مقلوبة','اشعر بالغثيان'],
    'قيء': ['استفراغ','استفرغ','ترجيع','ارجع','تقيؤ','قيء','اقياء'],
    'صداع': ['صداع','راسي يوجعني','راسي يوجع','راسي يؤلمني','وجع راس','الم راس','ألم رأس'],
    'سعال / كحة': ['سعال','كحه','كحة','اكح','اكح كثير','كحة تاعبني'],
    'التهاب الحلق': ['حلقي يوجع','حلقي يؤلمني','الم حلق','ألم حلق','حلق ناشف','حلقي ملتهب'],
    'ضيق التنفس': ['ضيق نفس','ضيق تنفس','نفسي ضيق','ما اقدر اتنفس','ما اقدر أتنفس','اختناق','مخنوق'],
    'ألم الصدر': ['الم صدر','ألم صدر','صدري يوجعني','صدري يوجع','وجع صدر','ضغط في صدري'],
    'دوخة': ['دوخه','دوخة','دايخ','دايخه','احس بدوخه','احس اني بدوخ'],
    'تعب / إرهاق': ['تعبان','تعبانه','تعب','مرهق','مرهقه','ارهاق','إرهاق','مالي خلق','ضعف'],
    'ألم البطن': ['بطني يوجعني','بطني يوجع','الم بطن','ألم بطن','وجع بطن','معدتي توجعني','معدتي يوجعني'],
    'إسهال': ['اسهال','إسهال','بطني يلعب','بطن يلعب معاي','براز مائي'],
    'إمساك': ['امساك','إمساك','ما اقدر ادخل الحمام','ما اخرج'],
    'ألم عضلي / مفاصل': ['عضلاتي توجعني','عضلاتي تؤلمني','مفاصلي توجعني','مفاصلي تؤلمني','الم مفاصل','ألم مفاصل','وجع جسم'],
    'ألم الظهر': ['ظهري يوجعني','ظهري يؤلمني','الم ظهر','ألم ظهر','وجع ظهر'],
    'طفح / حكة': ['طفح','حكه','حكة','جلدي يحكني','جلدي يحك','احمرار في الجلد'],
    'خفقان': ['خفقان','قلبي يدق بسرعة','قلبي سريع','دقات قلبي سريعه','دقات قلبي سريعة'],
    'رشح / احتقان': ['رشح','زكام','انفي مسدود','أنفي مسدود','احتقان','سيلان الانف','سيلان الأنف','اعطس','عطس'],
  };
  static const Map<String, String> _specialties = {
    'ضيق التنفس': 'الطوارئ / طبيب صدرية','ألم الصدر': 'الطوارئ / طبيب قلب','خفقان': 'طبيب قلب',
    'ألم البطن': 'طبيب باطنية / جهاز هضمي','غثيان': 'طبيب باطنية / جهاز هضمي','قيء': 'طبيب باطنية / جهاز هضمي',
    'طفح / حكة': 'طبيب جلدية','ألم عضلي / مفاصل': 'طبيب عظام ومفاصل','ألم الظهر': 'طبيب عظام ومفاصل',
    'رشح / احتقان': 'طبيب عام / أنف وأذن وحنجرة','صداع': 'طبيب عام / أعصاب','حمى / حرارة': 'طبيب عام',
  };
  static Map<String, dynamic>? analyze(String input) {
    final text = _normalize(input); if (text.isEmpty) return null;
    final found = <String>[];
    for (final entry in _lexicon.entries) { if (entry.value.any((p) => text.contains(_normalize(p)))) found.add(entry.key); }
    if (found.isEmpty) return null;
    final emergency = _isEmergency(text);
    final specialties = found.map((s) => _specialties[s]).whereType<String>().toSet().take(2).toList();
    final duration = _extractDuration(text);
    return {'symptoms': found, 'urgency': emergency ? 'عاجل' : (found.length >= 3 ? 'يحتاج متابعة' : 'غير طارئ غالباً'), 'emergency': emergency, 'specialties': specialties, 'duration': duration, 'response': _buildResponse(found, emergency, specialties, duration)};
  }
  static bool _isEmergency(String text) {
    const redFlags = ['اختناق','ما اقدر اتنفس','ما اقدر أتنفس','ضيق تنفس شديد','الم صدر شديد','ألم صدر شديد','نزيف شديد','اغمى علي','اغمي علي','غيبوبه','غيبوبة','تشنج','شلل مفاجئ','فقدت الوعي','شفايفي زرق','زرقة'];
    return redFlags.any((x) => text.contains(_normalize(x)));
  }
  static String _buildResponse(List<String> symptoms, bool emergency, List<String> specialties, String? duration) {
    final b = StringBuffer()..writeln('فهمت عليك. أنت تصف: ' + symptoms.join('، ') + '.');
    if (duration != null) b.writeln('وذكرت أن الموضوع مستمر ' + duration + '.');
    if (emergency) b.writeln('\n🚨 الأعراض التي وصفتها قد تحتاج تقييماً عاجلاً. إذا كان ضيق النفس أو ألم الصدر شديداً، أو حدث إغماء/اختناق، توجّه للطوارئ فوراً ولا تعتمد على المساعد وحده.');
    else b.writeln('\nما أقدر أجزم بالسبب من الوصف وحده، لكن أقدر أساعدك نحدد الخطوة المناسبة والأسئلة المهمة للطبيب.');
    if (specialties.isNotEmpty) b.writeln('\nالتخصص الأقرب مبدئياً: ' + specialties.join(' أو ') + '.');
    b.write('\nإذا تحب، قل لي: متى بدأت الأعراض؟ هل تزداد؟ وهل عندك حرارة مقاسة أو أعراض أخرى؟'); return b.toString();
  }
  static String? _extractDuration(String text) {
    for (final p in [RegExp(r'(منذ|لي|صار لي|لي حوالي)\s*(\d+)\s*(يوم|ايام|أيام|اسبوع|اسابيع|أسابيع|شهر|اشهر|أشهر)'), RegExp(r'(من يومين|من يوم|من اسبوع|من أسبوع|من شهر)')]) { final m = p.firstMatch(text); if (m != null) return m.group(0); } return null;
  }
  static String _normalize(String value) => value.toLowerCase().trim().replaceAll('أ','ا').replaceAll('إ','ا').replaceAll('آ','ا').replaceAll('ة','ه').replaceAll('ى','ي').replaceAll(RegExp(r'[ًٌٍَُِّْـ]'),'');
  static String friendlyExample() => 'اشعر ب حمى وعندي غثيان';
}
