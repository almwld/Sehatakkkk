/// Curated, source-attributed public-health guidance for the offline assistant.
///
/// Content is translated for Arabic, English and French. It is based on the
/// public sources listed per entry; it has NOT been reviewed by a licensed
/// clinician. It must not be presented as diagnosis or individualized care.
class CuratedMedicalKnowledge {
  static const String reviewStatus = 'public_source_translated_pending_clinician_review';

  static const List<Map<String, dynamic>> entries = [
    {
      'id': 'hypertension',
      'keywords': ['ضغط الدم', 'ارتفاع الضغط', 'ضغط مرتفع', 'hypertension', 'high blood pressure', 'tension arterielle', 'hypertension arterielle'],
      'arTitle': 'ارتفاع ضغط الدم',
      'enTitle': 'High blood pressure',
      'frTitle': 'Hypertension artérielle',
      'ar': 'قد لا يسبب ارتفاع ضغط الدم أعراضاً واضحة؛ القياس المنتظم هو الطريقة لمعرفة ذلك. قد يزيد خطره مع كثرة الملح، وقلة الحركة، والتدخين، وزيادة الوزن.\n\nقلّل الملح، وتناول الخضروات والفواكه، وتحرك بانتظام، ولا توقف دواءً موصوفاً دون مراجعة الطبيب. يلزم تقييم صحي لتأكيد التشخيص وتحديد العلاج.',
      'en': 'High blood pressure often has no obvious symptoms; measurement is the way to detect it. Risk can increase with excess salt, inactivity, tobacco use and excess weight.\n\nLimit salt, eat vegetables and fruit, stay physically active, and do not stop prescribed medicine without medical advice. A health professional must confirm the diagnosis and decide on treatment.',
      'fr': 'L’hypertension ne provoque souvent aucun symptôme évident ; seule la mesure permet de la détecter. Le risque augmente notamment avec l’excès de sel, l’inactivité, le tabac et le surpoids.\n\nLimitez le sel, mangez des légumes et des fruits, bougez régulièrement et n’arrêtez pas un traitement prescrit sans avis médical. Un professionnel de santé doit confirmer le diagnostic et définir le traitement.',
      'source': 'WHO — Hypertension fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/hypertension',
      'emergency': false,
    },
    {
      'id': 'diabetes',
      'keywords': ['السكري', 'مرض السكر', 'داء السكري', 'سكر الدم', 'diabetes', 'blood sugar', 'diabete', 'glycemie'],
      'arTitle': 'داء السكري',
      'enTitle': 'Diabetes',
      'frTitle': 'Diabète',
      'ar': 'قد تشمل العلامات العطش الشديد، وكثرة التبول، والتعب، وتشوش الرؤية، أو فقدان الوزن دون قصد. وقد تكون أعراض النوع الثاني خفيفة أو لا تُلاحظ مبكراً.\n\nلا يكفي الشعور بالأعراض للتشخيص؛ يلزم فحص مخبري وتقييم طبي. اتبع خطة الرعاية المقررة ولا تغيّر الأدوية أو جرعاتها بنفسك.',
      'en': 'Possible symptoms include unusual thirst, frequent urination, tiredness, blurred vision, or unintended weight loss. Type 2 diabetes may cause mild or unnoticed symptoms early on.\n\nSymptoms alone cannot confirm diabetes; laboratory testing and clinical assessment are needed. Follow your care plan and do not change medicines or doses yourself.',
      'fr': 'Les signes possibles comprennent une soif inhabituelle, des urines fréquentes, de la fatigue, une vision trouble ou une perte de poids involontaire. Le diabète de type 2 peut provoquer des symptômes légers ou passer inaperçu au début.\n\nLes symptômes seuls ne permettent pas de confirmer le diagnostic ; des analyses et une évaluation médicale sont nécessaires. Suivez votre plan de soins et ne modifiez pas vous-même vos médicaments ou leurs doses.',
      'source': 'WHO — Diabetes fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/diabetes',
      'emergency': false,
    },
    {
      'id': 'burns',
      'keywords': ['حرق', 'حروق', 'انحرقت', 'burn', 'burns', 'brulure', 'brulures'],
      'arTitle': 'الإسعاف الأولي للحروق',
      'enTitle': 'Burn first aid',
      'frTitle': 'Premiers secours en cas de brûlure',
      'ar': 'أبعد المصاب عن مصدر الحرارة مع التأكد من سلامتك. برّد الحرق بماء جارٍ بارد أو فاتر لمدة تقارب 20 دقيقة إن أمكن، وانزع الخواتم أو الأشياء الضيقة مبكراً، ثم غطّه بضماد نظيف غير لاصق.\n\nلا تستخدم الثلج أو الزيت أو معجون الأسنان، ولا تنزع الملابس الملتصقة أو تفقأ الفقاعات. اطلب رعاية عاجلة للحروق الكبيرة أو العميقة، أو حروق الوجه واليدين والقدمين والأعضاء التناسلية، أو الحروق الكيميائية والكهربائية.',
      'en': 'Move away from the heat source while keeping yourself safe. Cool the burn under cool or lukewarm running water for about 20 minutes if possible. Remove rings or tight items early, then cover it with a clean non-stick dressing.\n\nDo not use ice, oil or toothpaste; do not remove clothing stuck to the burn or break blisters. Seek urgent care for large or deep burns, burns to the face, hands, feet or genitals, and chemical or electrical burns.',
      'fr': 'Éloignez la personne de la source de chaleur sans vous mettre en danger. Refroidissez la brûlure sous l’eau courante fraîche ou tiède pendant environ 20 minutes si possible. Retirez rapidement bagues et objets serrés, puis couvrez avec un pansement propre non adhérent.\n\nN’utilisez ni glace, ni huile, ni dentifrice ; n’arrachez pas les vêtements collés et ne percez pas les cloques. Demandez des soins urgents pour les brûlures étendues ou profondes, du visage, des mains, des pieds ou des organes génitaux, ainsi que les brûlures chimiques ou électriques.',
      'source': 'WHO — Burns fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/burns',
      'emergency': false,
    },
    {
      'id': 'stroke',
      'keywords': ['جلطة دماغية', 'سكتة دماغية', 'شلل مفاجئ', 'ثقل اللسان', 'وجه مائل', 'stroke', 'facial droop', 'slurred speech', 'avc', 'accident vasculaire cerebral'],
      'arTitle': 'علامات السكتة الدماغية',
      'enTitle': 'Stroke warning signs',
      'frTitle': 'Signes d’alerte d’un AVC',
      'ar': 'انتبه لظهور مفاجئ لتدلّي الوجه، أو ضعف الذراع، أو اضطراب الكلام؛ وقد يظهر أيضاً فقدان التوازن أو الرؤية.\n\nهذه حالة طارئة: اطلب الإسعاف فوراً وسجّل وقت بدء الأعراض. لا تنتظر تحسنها، حتى لو اختفت.',
      'en': 'Watch for sudden facial drooping, arm weakness, or speech difficulty; sudden loss of balance or vision can also occur.\n\nThis is an emergency: call local emergency services immediately and note when symptoms began. Do not wait for improvement, even if symptoms disappear.',
      'fr': 'Surveillez l’apparition soudaine d’une asymétrie du visage, d’une faiblesse du bras ou de troubles de la parole ; une perte soudaine d’équilibre ou de vision est également possible.\n\nC’est une urgence : appelez immédiatement les services d’urgence locaux et notez l’heure de début des symptômes. N’attendez pas une amélioration, même si les signes disparaissent.',
      'source': 'WHO — Stroke fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/stroke',
      'emergency': true,
    },
    {
      'id': 'severe_bleeding',
      'keywords': ['نزيف شديد', 'نزيف قوي', 'جرح ينزف', 'دم كثير', 'severe bleeding', 'heavy bleeding', 'saignement abondant', 'hemorragie'],
      'arTitle': 'النزيف الشديد',
      'enTitle': 'Severe bleeding',
      'frTitle': 'Hémorragie',
      'ar': 'اطلب الإسعاف فوراً. إذا كان ذلك آمناً، اضغط بقوة وباستمرار مباشرة على موضع النزيف بقطعة قماش أو ضماد نظيف حتى وصول المساعدة.\n\nلا تنزع جسماً مغروساً في الجرح؛ اضغط حوله. اتبع تعليمات موظف الطوارئ ولا ترفع الضغط لمعاينة الجرح.',
      'en': 'Call local emergency services immediately. If it is safe, apply firm, continuous direct pressure to the bleeding site with a clean cloth or dressing until help arrives.\n\nDo not remove an embedded object; apply pressure around it. Follow the emergency call handler’s instructions and do not lift pressure to inspect the wound.',
      'fr': 'Appelez immédiatement les services d’urgence locaux. Si cela ne présente pas de danger, exercez une pression directe, ferme et continue sur la plaie avec un tissu ou un pansement propre jusqu’à l’arrivée des secours.\n\nNe retirez pas un objet planté dans la plaie ; exercez la pression autour. Suivez les instructions du régulateur et ne relâchez pas la pression pour examiner la plaie.',
      'source': 'London Ambulance Service — Emergency trauma advice',
      'url': 'https://www.londonambulance.nhs.uk/our-services/emergency-care/emergency-care-advice/emergency-trauma-care/',
      'emergency': true,
    },
    {
      'id': 'anaphylaxis',
      'keywords': ['حساسية شديدة', 'حساسية مفرطة', 'تورم اللسان', 'تورم الحلق', 'اختناق بعد حساسية', 'anaphylaxis', 'severe allergic reaction', 'anaphylaxie', 'reaction allergique severe'],
      'arTitle': 'الحساسية المفرطة',
      'enTitle': 'Anaphylaxis',
      'frTitle': 'Anaphylaxie',
      'ar': 'قد تشمل العلامات تورم اللسان أو الحلق، وصعوبة التنفس أو البلع، والدوخة أو الإغماء بعد التعرض لمسبب حساسية.\n\nهذه حالة مهددة للحياة: اتصل بالإسعاف المحلي فوراً. إذا كان لدى المصاب قلم أدرينالين موصوف له، فليستخدمه وفق تعليمات جهازه وخطته الطبية، ولا تؤخر طلب الإسعاف.',
      'en': 'Signs can include swelling of the tongue or throat, difficulty breathing or swallowing, dizziness, or fainting after exposure to an allergen.\n\nThis is life-threatening: call local emergency services immediately. If the person has their own prescribed adrenaline auto-injector, use it according to its instructions and their care plan; do not delay emergency help.',
      'fr': 'Les signes peuvent inclure un gonflement de la langue ou de la gorge, des difficultés à respirer ou à avaler, des vertiges ou un évanouissement après exposition à un allergène.\n\nC’est une urgence vitale : appelez immédiatement les services d’urgence locaux. Si la personne possède son propre auto-injecteur d’adrénaline prescrit, utilisez-le conformément à sa notice et à son plan de soins ; ne retardez pas l’appel aux secours.',
      'source': 'NHS — Anaphylaxis',
      'url': 'https://www.nhs.uk/conditions/anaphylaxis/',
      'emergency': true,
    },
    {
      'id': 'heart_attack',
      'keywords': ['جلطة قلبية', 'نوبة قلبية', 'ألم صدر شديد', 'ضغط في الصدر', 'heart attack', 'chest pressure', 'crise cardiaque', 'douleur thoracique'],
      'arTitle': 'علامات النوبة القلبية',
      'enTitle': 'Heart attack warning signs',
      'frTitle': 'Signes d’infarctus',
      'ar': 'قد تشمل العلامات ألماً أو ضغطاً في وسط الصدر، أو ألماً يمتد إلى الذراع أو الكتف أو الفك أو الظهر، مع ضيق التنفس أو الغثيان أو التعرق أو الدوار.\n\nاطلب الإسعاف فوراً ولا تقد السيارة بنفسك. قد تختلف الأعراض بين الأشخاص.',
      'en': 'Signs may include pain or pressure in the centre of the chest, or pain spreading to an arm, shoulder, jaw or back, with breathlessness, nausea, sweating or dizziness.\n\nCall local emergency services immediately and do not drive yourself. Symptoms can vary between people.',
      'fr': 'Les signes peuvent inclure une douleur ou une pression au centre de la poitrine, ou une douleur irradiant vers un bras, une épaule, la mâchoire ou le dos, avec essoufflement, nausées, sueurs ou vertiges.\n\nAppelez immédiatement les services d’urgence locaux et ne conduisez pas vous-même. Les symptômes peuvent varier selon les personnes.',
      'source': 'WHO — Cardiovascular diseases fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/cardiovascular-diseases-(cvds)',
      'emergency': true,
    },
    {
      'id': 'healthy_activity',
      'keywords': ['النشاط البدني', 'الرياضة الصحية', 'كم امشي', 'الوقاية الصحية', 'physical activity', 'exercise health', 'activite physique', 'exercice physique'],
      'arTitle': 'النشاط البدني والوقاية',
      'enTitle': 'Physical activity and prevention',
      'frTitle': 'Activité physique et prévention',
      'ar': 'النشاط البدني المنتظم مفيد للصحة. توصي منظمة الصحة العالمية البالغين عادةً بما لا يقل عن 150 دقيقة أسبوعياً من النشاط الهوائي المعتدل، مع تمارين تقوية العضلات يومين أو أكثر أسبوعياً.\n\nابدأ تدريجياً بما يناسب قدرتك وحالتك الصحية، واستشر مختصاً قبل تغيير النشاط إذا كان لديك مرض مزمن أو أعراض مقلقة.',
      'en': 'Regular physical activity supports health. WHO generally recommends adults do at least 150 minutes of moderate-intensity aerobic activity per week, plus muscle-strengthening activity on two or more days.\n\nStart gradually at a level suited to your ability and health. Seek professional advice before changing activity if you have a chronic condition or concerning symptoms.',
      'fr': 'Une activité physique régulière favorise la santé. L’OMS recommande généralement aux adultes au moins 150 minutes d’activité aérobie d’intensité modérée par semaine, ainsi que des exercices de renforcement musculaire au moins deux jours.\n\nCommencez progressivement selon vos capacités et votre état de santé. Demandez conseil à un professionnel avant de modifier votre activité en cas de maladie chronique ou de symptômes préoccupants.',
      'source': 'WHO — Hypertension fact sheet (physical activity guidance)',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/hypertension',
      'emergency': false,
    },
  ];

  static Map<String, dynamic>? answerFor(String message, String languageCode) {
    final normalized = _normalize(message);
    final lang = languageCode == 'en' || languageCode == 'fr' ? languageCode : 'ar';
    final sorted = [...entries]..sort((a, b) {
      final aLength = (a['keywords'] as List<String>).fold<int>(0, (n, k) => n > k.length ? n : k.length);
      final bLength = (b['keywords'] as List<String>).fold<int>(0, (n, k) => n > k.length ? n : k.length);
      return bLength.compareTo(aLength);
    });
    for (final entry in sorted) {
      final matched = (entry['keywords'] as List<String>).any((keyword) => normalized.contains(_normalize(keyword)));
      if (!matched) continue;
      final title = entry['${lang}Title'] as String;
      final body = entry[lang] as String;
      final emergency = entry['emergency'] == true;
      final source = entry['source'] as String;
      final url = entry['url'] as String;
      final sourceLabel = lang == 'fr' ? 'Source' : (lang == 'en' ? 'Source' : 'المصدر');
      final reviewNote = lang == 'fr'
          ? 'Information générale fondée sur une source publique ; validation clinique locale en attente.'
          : (lang == 'en'
              ? 'General public-source guidance; local clinical review is pending.'
              : 'معلومة عامة من مصدر صحي منشور؛ لم تعتمد بعد بمراجعة سريرية محلية.');
      return {
        'response': '$title\n\n$body\n\n$sourceLabel: $source\n$url\n$reviewNote',
        'type': emergency ? 'emergency' : 'medical_reference',
        'category': 'curated_public_health',
        'knowledgeId': entry['id'],
        'source': source,
        'sourceUrl': url,
        'reviewStatus': reviewStatus,
      };
    }
    return null;
  }

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll('ة', 'ه')
      .replaceAll('ى', 'ي')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}
