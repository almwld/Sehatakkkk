/// Curated, multilingual safety and first-aid knowledge for the local assistant.
/// Content is educational, not a diagnosis or a substitute for a clinician.
/// Every entry carries provenance and an explicit clinical-review status.
class MedicalKnowledgeCatalog {
  MedicalKnowledgeCatalog._();

  static const List<Map<String, dynamic>> entries = [
    {
      'id': 'stroke',
      'aliases': ['جلطة دماغية','سكتة دماغية','جلطة بالمخ','فمي مال','وجهي انحرف','يدي ضعفت فجأة','ثقل اللسان','stroke','face drooping','slurred speech','avc','visage affaissé','trouble de la parole'],
      'ar': 'علامات السكتة الدماغية: تدلّي مفاجئ في الوجه، ضعف في ذراع، أو اضطراب الكلام. اطلب الإسعاف فوراً وسجّل وقت بدء الأعراض. لا تقد السيارة بنفسك ولا تنتظر تحسّنها.',
      'en': 'Stroke warning signs include sudden facial drooping, arm weakness, or speech difficulty. Call local emergency services immediately and note when symptoms began. Do not drive yourself or wait for symptoms to improve.',
      'fr': 'Les signes d’AVC comprennent une asymétrie soudaine du visage, une faiblesse d’un bras ou des troubles de la parole. Appelez immédiatement les secours locaux et notez l’heure de début. Ne conduisez pas et n’attendez pas une amélioration.',
      'source': 'American Heart Association / American Red Cross — 2024 First Aid Guidelines',
      'url': 'https://cpr.heart.org/en/resuscitation-science/2024-first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'chest_pain',
      'aliases': ['ألم صدر','وجع صدري','ضغط على الصدر','قلبي يوجعني','chest pain','heart attack','douleur thoracique','crise cardiaque'],
      'ar': 'ألم الصدر الجديد أو الشديد، خصوصاً مع ضيق النفس أو التعرّق أو الغثيان أو ألم يمتد للذراع أو الفك، يستدعي الطوارئ فوراً. لا تنتظر ولا تقد بنفسك.',
      'en': 'New or severe chest pain—especially with breathlessness, sweating, nausea, or pain spreading to the arm or jaw—needs emergency assessment now. Do not wait or drive yourself.',
      'fr': 'Une douleur thoracique nouvelle ou intense, surtout avec essoufflement, sueurs, nausées ou douleur irradiant vers le bras ou la mâchoire, nécessite une aide médicale urgente. N’attendez pas et ne conduisez pas.',
      'source': 'American Heart Association / American Red Cross — 2024 First Aid Guidelines',
      'url': 'https://cpr.heart.org/en/resuscitation-science/2024-first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'severe_bleeding',
      'aliases': ['نزيف شديد','دم ما يوقف','جرح ينزف','نزف','bleeding','severe bleeding','hémorragie','saignement abondant'],
      'ar': 'للنزيف الشديد: اضغط مباشرة وبقوة على موضع النزيف بضماد أو قطعة قماش نظيفة، واطلب الطوارئ فوراً. لا ترفع الضماد لتفقد الجرح؛ إذا تشبّع، واصل الضغط وأضف طبقة فوقه. لا تنزع جسماً مغروساً.',
      'en': 'For severe bleeding, apply firm, direct pressure with a clean dressing or cloth and call emergency services. Do not lift the dressing to check; if blood soaks through, keep pressure and add another layer. Do not remove an embedded object.',
      'fr': 'En cas d’hémorragie importante, exercez une pression directe et ferme avec un pansement ou un tissu propre et appelez les secours. Ne soulevez pas le pansement pour vérifier ; s’il est imbibé, maintenez la pression et ajoutez une couche. Ne retirez pas un objet planté.',
      'source': 'American Heart Association / American Red Cross — 2024 First Aid Guidelines',
      'url': 'https://cpr.heart.org/en/resuscitation-science/2024-first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'burns',
      'aliases': ['حرق','حروق','انحرقت','حرقني','burn','burns','brûlure','brulure'],
      'ar': 'أبعد مصدر الحرارة بأمان، وبرّد الحرق بماء جارٍ بارد أو فاتر لمدة 20 دقيقة. انزع الخواتم والملابس غير الملتصقة، ولا تستخدم الثلج أو الزيوت أو معجون الأسنان ولا تفقأ الفقاعات. اطلب تقييماً عاجلاً للحروق الكبيرة أو العميقة أو في الوجه أو اليدين أو الأعضاء الحساسة.',
      'en': 'Move away from the heat source safely and cool the burn under cool or lukewarm running water for 20 minutes. Remove jewellery and loose clothing, but not anything stuck to the skin. Do not use ice, oils, toothpaste, or burst blisters. Seek urgent care for large, deep, facial, hand, or genital burns.',
      'fr': 'Éloignez-vous de la source de chaleur en sécurité et refroidissez la brûlure sous l’eau courante fraîche ou tiède pendant 20 minutes. Retirez bijoux et vêtements non collés, sans arracher ce qui adhère à la peau. N’utilisez ni glace, ni huile, ni dentifrice et ne percez pas les cloques. Consultez en urgence pour une brûlure étendue, profonde ou touchant le visage, les mains ou les organes génitaux.',
      'source': 'Resuscitation Council UK — 2025 First Aid Guidelines',
      'url': 'https://www.resus.org.uk/professional-library/2025-resuscitation-guidelines/first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'seizure',
      'aliases': ['تشنج','صرع','نوبة صرع','يرتعش ولا يستجيب','seizure','convulsion','crise épileptique','convulsion'],
      'ar': 'أبعد الأشياء الخطرة واحمِ الرأس بشيء لين، واحسب مدة النوبة. لا تثبّت الشخص ولا تضع شيئاً في فمه ولا تعطِه طعاماً أو شراباً. بعد توقف التشنج، ضعه على جانبه إذا كان يتنفس. اطلب الطوارئ إذا استمرت النوبة أكثر من 5 دقائق، أو تكررت، أو كانت الأولى، أو حدثت إصابة أو صعوبة تنفس.',
      'en': 'Move dangerous objects away, protect the head with something soft, and time the seizure. Do not restrain the person or put anything in their mouth; give no food or drink. When convulsions stop, place them on their side if breathing. Get emergency help if it lasts over 5 minutes, repeats, is a first seizure, or involves injury or breathing problems.',
      'fr': 'Éloignez les objets dangereux, protégez la tête avec un support souple et chronométrez la crise. Ne maintenez pas la personne et ne mettez rien dans sa bouche ; ne donnez ni nourriture ni boisson. Après les convulsions, placez-la sur le côté si elle respire. Appelez les secours si la crise dépasse 5 minutes, se répète, est la première, ou s’accompagne d’une blessure ou de difficultés respiratoires.',
      'source': 'American Heart Association / American Red Cross — 2024 First Aid Guidelines',
      'url': 'https://cpr.heart.org/en/resuscitation-science/2024-first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'anaphylaxis',
      'aliases': ['حساسية شديدة','حساسية مفرطة','تورم اللسان','تورم الحلق','anaphylaxis','severe allergic reaction','anaphylaxie','réaction allergique grave'],
      'ar': 'تورم اللسان أو الحلق، صعوبة التنفس، أو الإغماء بعد تعرض محتمل لمسبب حساسية قد يدل على تأق خطير. اطلب الطوارئ فوراً. إذا كان لدى الشخص قلم أدرينالين موصوف له، ساعده على استخدامه وفق تعليماته. لا تتركه وحده.',
      'en': 'Tongue or throat swelling, breathing difficulty, or collapse after possible allergen exposure may indicate life-threatening anaphylaxis. Call emergency services immediately. If the person has their prescribed adrenaline auto-injector, help them use it as directed. Stay with them.',
      'fr': 'Un gonflement de la langue ou de la gorge, une difficulté à respirer ou un malaise après une exposition possible à un allergène peut signaler une anaphylaxie grave. Appelez immédiatement les secours. Si la personne possède son auto-injecteur d’adrénaline prescrit, aidez-la à l’utiliser selon les instructions. Restez avec elle.',
      'source': 'Resuscitation Council UK — 2025 First Aid Guidelines',
      'url': 'https://www.resus.org.uk/professional-library/2025-resuscitation-guidelines/first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'choking',
      'aliases': ['اختناق','شرق','شيء عالق بالحلق','ما اقدر اتنفس','choking','airway obstruction','étouffement','obstruction des voies aériennes'],
      'ar': 'إذا كان الشخص لا يستطيع الكلام أو التنفس أو السعال بفاعلية، فهذه حالة طارئة. اطلب المساعدة فوراً واتبع تعليمات موظف الطوارئ أو إرشادات الإسعاف الأولي المعتمدة. لا تدخل أصابعك في الفم عشوائياً.',
      'en': 'If the person cannot speak, breathe, or cough effectively, treat it as an emergency. Call for help immediately and follow emergency-dispatch instructions or recognised first-aid training. Do not blindly sweep the mouth with your fingers.',
      'fr': 'Si la personne ne peut ni parler, ni respirer, ni tousser efficacement, il s’agit d’une urgence. Appelez immédiatement les secours et suivez les consignes du régulateur ou une formation reconnue aux premiers secours. N’effectuez pas de balayage aveugle avec les doigts dans la bouche.',
      'source': 'Resuscitation Council UK — 2025 First Aid Guidelines',
      'url': 'https://www.resus.org.uk/professional-library/2025-resuscitation-guidelines/first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'poisoning',
      'aliases': ['تسمم','شرب مادة سامة','بلع منظف','جرعة زائدة','poisoning','overdose','intoxication','empoisonnement'],
      'ar': 'اشتباه التسمم أو الجرعة الزائدة يستلزم التواصل العاجل مع الطوارئ أو مركز السموم إن توفر. لا تحاول إحداث القيء ولا تعطِ حليباً أو علاجاً منزلياً. احتفظ بعبوة المادة أو اسمها، واذكر الكمية والوقت إن عُرفا.',
      'en': 'Suspected poisoning or overdose needs urgent advice from emergency services or a poison centre if available. Do not induce vomiting or give milk or home remedies. Keep the container or product name and note the amount and time if known.',
      'fr': 'Une suspicion d’intoxication ou de surdosage nécessite un avis urgent des secours ou d’un centre antipoison s’il existe. Ne faites pas vomir et ne donnez ni lait ni remède maison. Gardez l’emballage ou le nom du produit et notez la quantité et l’heure si elles sont connues.',
      'source': 'MedlinePlus — Recognizing Medical Emergencies; Resuscitation Council UK — 2025 First Aid Guidelines',
      'url': 'https://medlineplus.gov/ency/article/001927.htm',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'breathing',
      'aliases': ['ضيق تنفس','صعوبة التنفس','نفسي مقطوع','اختناق بالصدر','shortness of breath','difficulty breathing','essoufflement','difficulté à respirer'],
      'ar': 'ضيق التنفس الشديد أو المفاجئ، أو المصحوب بزرقة أو ألم صدر أو ارتباك أو إغماء، يستدعي الطوارئ فوراً. أوقف المجهود واجلس في وضع مريح، ولا تؤخر طلب المساعدة.',
      'en': 'Severe or sudden breathlessness, or breathlessness with blue/grey lips, chest pain, confusion, or fainting, requires emergency help now. Stop exertion, sit comfortably, and do not delay calling for help.',
      'fr': 'Un essoufflement intense ou soudain, ou accompagné de lèvres bleutées/grisâtres, de douleur thoracique, de confusion ou d’évanouissement, nécessite une aide urgente. Arrêtez tout effort, installez-vous confortablement et n’attendez pas pour appeler les secours.',
      'source': 'MedlinePlus — Recognizing Medical Emergencies',
      'url': 'https://medlineplus.gov/ency/article/001927.htm',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'mental_crisis',
      'aliases': ['افكر انتحر','اريد ان انهي حياتي','بأذي نفسي','أؤذي نفسي','suicidal thoughts','self harm','idées suicidaires','me faire du mal'],
      'ar': 'أنا آسف أنك تمر بهذا. إذا كنت في خطر الآن أو قد تؤذي نفسك، ابتعد عن أي وسيلة قد تستخدمها، وابقَ مع شخص تثق به، واطلب مساعدة الطوارئ المحلية فوراً. أخبرني فقط: هل أنت في خطر مباشر الآن؟',
      'en': 'I’m sorry you’re going through this. If you may hurt yourself now, move away from anything you could use, stay with someone you trust, and contact local emergency help immediately. Just tell me: are you in immediate danger right now?',
      'fr': 'Je suis désolé que vous traversiez cela. Si vous risquez de vous faire du mal maintenant, éloignez-vous de tout moyen dangereux, restez avec une personne de confiance et contactez immédiatement les secours locaux. Dites-moi simplement : êtes-vous en danger immédiat ?',
      'source': 'Resuscitation Council UK — 2025 First Aid Guidelines (suicidal thoughts section)',
      'url': 'https://www.resus.org.uk/professional-library/2025-resuscitation-guidelines/first-aid-guidelines',
      'review': 'editorial_source_checked_clinician_review_pending'
    }
  ];

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[ًٌٍَُِّْـ]'), '')
      .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static Map<String, String>? answer(String input, String languageCode) {
    final query = normalize(input);
    if (query.isEmpty) return null;
    for (final entry in entries) {
      final aliases = (entry['aliases'] as List).cast<String>();
      if (!aliases.any((alias) => query.contains(normalize(alias)))) continue;
      final language = languageCode == 'fr' ? 'fr' : (languageCode == 'en' ? 'en' : 'ar');
      return {
        'response': entry[language] as String,
        'type': entry['id'] as String,
        'source': entry['source'] as String,
        'source_url': entry['url'] as String,
        'review_status': entry['review'] as String,
      };
    }
    return null;
  }
}
