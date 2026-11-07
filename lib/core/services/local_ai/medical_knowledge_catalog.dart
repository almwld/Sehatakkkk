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
      'source': 'WHO — Suicide: questions and answers',
      'url': 'https://www.who.int/news-room/questions-and-answers/item/suicide',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'diabetes',
      'aliases': ['السكري','سكر الدم','عندي سكر','diabetes','blood sugar','diabète','glycémie'],
      'ar': 'السكري حالة مزمنة يرتفع فيها سكر الدم. قد تشمل علاماته العطش وكثرة التبول والتعب وتشوش الرؤية أو نقص الوزن غير المقصود. التشخيص يحتاج فحصاً مخبرياً؛ لا تغيّر دواءك أو جرعة الإنسولين اعتماداً على المحادثة. اطلب الطوارئ عند فقدان الوعي أو صعوبة التنفس أو التدهور الشديد.',
      'en': 'Diabetes is a chronic condition involving high blood glucose. Symptoms can include thirst, frequent urination, tiredness, blurred vision, or unexplained weight loss. Diagnosis requires laboratory testing. Do not change medicines or insulin doses based on this chat. Seek emergency help for loss of consciousness, breathing difficulty, or severe deterioration.',
      'fr': 'Le diabète est une maladie chronique caractérisée par une glycémie élevée. Les signes peuvent inclure soif, urines fréquentes, fatigue, vision trouble ou perte de poids inexpliquée. Le diagnostic nécessite des analyses. Ne modifiez pas vos médicaments ni votre insuline sur la base de cette conversation. Appelez les secours en cas de perte de connaissance, de difficulté respiratoire ou d’aggravation grave.',
      'source': 'World Health Organization — Diabetes fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/diabetes',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'hypertension',
      'aliases': ['ضغط الدم','ضغط مرتفع','ارتفاع الضغط','عندي ضغط','hypertension','high blood pressure','tension artérielle élevée'],
      'ar': 'ارتفاع ضغط الدم غالباً لا يسبب أعراضاً واضحة، ولا يمكن تأكيده من الشعور وحده؛ يلزم قياس صحيح ومتكرر وتقييم صحي. لا توقف دواء الضغط ولا تضاعف الجرعة بنفسك. ألم الصدر أو ضيق النفس أو ضعف مفاجئ أو اضطراب الكلام مع قراءة مرتفعة يستدعي الطوارئ.',
      'en': 'High blood pressure often causes no clear symptoms and cannot be confirmed by how you feel; it requires properly repeated measurements and clinical assessment. Do not stop or double your medicine yourself. Chest pain, breathlessness, sudden weakness, or speech problems with a high reading require emergency care.',
      'fr': 'L’hypertension ne provoque souvent aucun symptôme évident et ne peut pas être confirmée par les sensations seules ; elle nécessite des mesures répétées correctement et une évaluation médicale. N’arrêtez pas et ne doublez pas votre traitement vous-même. Une douleur thoracique, un essoufflement, une faiblesse soudaine ou des troubles de la parole avec une tension élevée nécessitent les urgences.',
      'source': 'World Health Organization — Hypertension fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/hypertension',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'asthma',
      'aliases': ['الربو','ازمة ربو','نوبة ربو','صفير الصدر','asthma','asthma attack','asthme','crise d’asthme'],
      'ar': 'الربو يسبب التهاباً وتضيّقاً متغيراً في الشعب الهوائية وقد يؤدي إلى صفير وسعال وضيق نفس. اتبع خطة الربو والبخاخ الموصوف لك فقط. صعوبة التنفس الشديدة أو عدم القدرة على الكلام بجمل أو ازرقاق الشفاه أو عدم التحسن بعد دواء الإنقاذ الموصوف تستدعي الطوارئ.',
      'en': 'Asthma causes variable inflammation and narrowing of the airways and may lead to wheezing, cough, and breathlessness. Follow your personal asthma action plan and use only your prescribed inhaler. Severe breathing difficulty, inability to speak in full sentences, blue lips, or failure to improve after your prescribed reliever needs emergency care.',
      'fr': 'L’asthme provoque une inflammation et un rétrécissement variables des voies respiratoires, avec parfois sifflements, toux et essoufflement. Suivez votre plan d’action et utilisez uniquement votre inhalateur prescrit. Une difficulté respiratoire sévère, l’impossibilité de parler en phrases complètes, des lèvres bleutées ou l’absence d’amélioration après le traitement de secours prescrit nécessitent les urgences.',
      'source': 'World Health Organization — Asthma fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/asthma',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'healthy_diet',
      'aliases': ['غذاء صحي','نظام غذائي','التغذية','اكل صحي','healthy diet','nutrition','alimentation saine','régime alimentaire'],
      'ar': 'اجعل طعامك متنوعاً ومتوازناً: خضروات وفواكه وبقولاً وحبوباً كاملة ومصادر بروتين مناسبة، وقلّل الملح والسكريات الحرة والدهون المتحولة. تختلف الاحتياجات باختلاف العمر والحمل والأمراض والأدوية؛ اطلب خطة من مختص إذا لديك حالة صحية أو حمية علاجية.',
      'en': 'Aim for a varied, balanced diet with vegetables, fruit, pulses, whole grains, and suitable protein sources; limit salt, free sugars, and trans fats. Needs differ with age, pregnancy, medical conditions, and medicines. Ask a qualified professional for an individual therapeutic diet.',
      'fr': 'Privilégiez une alimentation variée et équilibrée : légumes, fruits, légumineuses, céréales complètes et sources de protéines adaptées ; limitez le sel, les sucres libres et les acides gras trans. Les besoins varient selon l’âge, la grossesse, les maladies et les médicaments. Demandez conseil à un professionnel pour un régime thérapeutique personnalisé.',
      'source': 'World Health Organization — Healthy diet fact sheet',
      'url': 'https://www.who.int/en/news-room/fact-sheets/detail/healthy-diet',
      'review': 'editorial_source_checked_clinician_review_pending'
    },

    {
      'id': 'physical_activity',
      'aliases': ['النشاط البدني','الرياضة الصحية','كم امشي','الوقاية الصحية','المشي للصحة','physical activity','exercise','activite physique','exercice physique'],
      'ar': 'للبالغين، توصي منظمة الصحة العالمية عادةً بما لا يقل عن 150 دقيقة أسبوعياً من النشاط الهوائي المعتدل، أو 75 دقيقة من النشاط الشديد، مع تمارين تقوية العضلات يومين أو أكثر أسبوعياً. بعض النشاط أفضل من عدمه؛ ابدأ تدريجياً بما يناسب قدرتك. إذا كان لديك مرض مزمن أو أعراض مقلقة، استشر مختصاً بشأن النشاط المناسب.',
      'en': 'For adults, WHO recommends at least 150 minutes per week of moderate aerobic activity, or 75 minutes of vigorous activity, plus muscle-strengthening activity on two or more days. Some activity is better than none; start gradually at a level suited to your ability. If you have a chronic condition or concerning symptoms, ask a health professional what is appropriate.',
      'fr': 'Pour les adultes, l’OMS recommande au moins 150 minutes d’activité aérobie modérée par semaine, ou 75 minutes d’activité intense, ainsi que du renforcement musculaire au moins deux jours par semaine. Toute activité vaut mieux que l’inactivité ; commencez progressivement selon vos capacités. En cas de maladie chronique ou de symptômes préoccupants, demandez conseil à un professionnel.',
      'source': 'WHO — Physical activity',
      'url': 'https://www.who.int/initiatives/behealthy/physical-activity/',
      'review': 'editorial_source_checked_clinician_review_pending'
    },

    {
      'id': 'diarrhoea',
      'aliases': ['اسهال','إسهال','مغص واسهال','اسهال شديد','diarrhea','diarrhoea','loose stools','diarrhée'],
      'ar': 'الإسهال قد يسبب فقدان الماء والأملاح. استخدم محلول الإماهة الفموية الجاهز بعد تحضيره تماماً وفق تعليمات العبوة، واستمر في تناول الطعام المناسب والسوائل الآمنة. اطلب تقييماً عاجلاً عند وجود دم في البراز، أو خمول شديد، أو عدم القدرة على الشرب، أو علامات جفاف، أو استمرار الحالة.',
      'en': 'Diarrhoea can cause loss of water and salts. Use a prepared oral rehydration solution exactly as directed on its packet, and continue suitable food and safe fluids. Seek urgent assessment for blood in the stool, marked lethargy, inability to drink, signs of dehydration, or persistent illness.',
      'fr': 'La diarrhée peut entraîner une perte d’eau et de sels. Utilisez une solution de réhydratation orale en respectant exactement les instructions du sachet, et poursuivez une alimentation adaptée ainsi que des boissons sûres. Demandez rapidement un avis médical en cas de sang dans les selles, de grande somnolence, d’incapacité à boire, de signes de déshydratation ou de symptômes persistants.',
      'source': 'WHO — Diarrhoeal disease fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/diarrhoeal-disease',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'malaria',
      'aliases': ['ملاريا','حمى الملاريا','رعشة مع حرارة','malaria','paludisme'],
      'ar': 'قد تبدأ الملاريا بحمى وصداع وقشعريرة، لكن هذه الأعراض لا تكفي لتشخيصها. إذا ظهرت حمى بعد الإقامة في منطقة تنتشر فيها الملاريا، اطلب تقييماً وفحصاً تشخيصياً سريعاً؛ لا تبدأ علاجاً مضاداً للملاريا من نفسك. الارتباك أو التشنجات أو صعوبة التنفس أو الضعف الشديد تستدعي الطوارئ فوراً.',
      'en': 'Malaria may begin with fever, headache and chills, but these symptoms cannot confirm it. If fever develops after being in an area where malaria occurs, seek prompt clinical assessment and testing; do not start antimalarial treatment yourself. Confusion, seizures, breathing difficulty or extreme weakness require emergency care.',
      'fr': 'Le paludisme peut commencer par de la fièvre, des maux de tête et des frissons, mais ces signes ne suffisent pas au diagnostic. En cas de fièvre après un séjour dans une zone où le paludisme circule, demandez rapidement une évaluation et un test ; ne commencez pas vous-même un traitement antipaludique. Confusion, convulsions, difficultés respiratoires ou faiblesse extrême nécessitent des soins d’urgence.',
      'source': 'WHO — Malaria questions and answers',
      'url': 'https://www.who.int/news-room/questions-and-answers/item/malaria',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'child_pneumonia',
      'aliases': ['التهاب رئوي عند طفل','التهاب رئوي للاطفال','طفلي يتنفس بسرعة','تنفس سريع عند الطفل','pneumonia in child','child fast breathing','pneumonie chez enfant','respiration rapide enfant'],
      'ar': 'قد تظهر عدوى الرئة عند الطفل بسعال أو صعوبة تنفس، مع أو دون حمى. سرعة التنفس أو انكماش أسفل الصدر أثناء الشهيق من العلامات التي تستلزم تقييماً طبياً سريعاً. عدم القدرة على الرضاعة أو الشرب، أو فقدان الوعي، أو التشنجات، أو صعوبة التنفس الشديدة علامات طارئة.',
      'en': 'Pneumonia in a child may cause cough or difficult breathing, with or without fever. Fast breathing or the lower chest moving inward during inhalation needs prompt medical assessment. Inability to breastfeed or drink, unconsciousness, convulsions, or severe breathing difficulty are emergency signs.',
      'fr': 'La pneumonie chez l’enfant peut provoquer une toux ou une difficulté respiratoire, avec ou sans fièvre. Une respiration rapide ou un creusement de la partie inférieure du thorax à l’inspiration nécessite une évaluation médicale rapide. L’incapacité à téter ou boire, la perte de connaissance, les convulsions ou une difficulté respiratoire sévère sont des signes d’urgence.',
      'source': 'WHO — Pneumonia fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/pneumonia',
      'review': 'editorial_source_checked_clinician_review_pending'
    },

    {
      'id': 'influenza',
      'aliases': ['انفلونزا','إنفلونزا','الانفلونزا','الإنفلونزا','نزلة برد شديدة','flu','influenza','grippe','grippe saisonnière'],
      'ar': 'قد تبدأ الإنفلونزا فجأة بحمى وسعال وصداع وآلام عضلية وإرهاق والتهاب حلق أو سيلان الأنف. قد يتعافى كثيرون خلال نحو أسبوع، لكن الخطر أعلى لدى الحوامل والأطفال دون الخامسة وكبار السن ومن لديهم أمراض مزمنة أو ضعف مناعة. الراحة والسوائل الآمنة والحد من مخالطة الآخرين تساعد؛ اطلب الرعاية إذا ساءت الأعراض أو كانت شديدة. اللقاح الموسمي وسيلة الوقاية الأهم.',
      'en': 'Flu can begin suddenly with fever, cough, headache, muscle aches, fatigue, sore throat or a runny nose. Many people recover in about a week, but risk is higher during pregnancy, in children under five, older adults, and people with chronic illness or weakened immunity. Rest, safe fluids and limiting close contact can help; seek care if symptoms are severe or worsen. Seasonal vaccination is the key preventive measure.',
      'fr': 'La grippe débute souvent brutalement par de la fièvre, une toux, des maux de tête, des douleurs musculaires, de la fatigue, un mal de gorge ou un écoulement nasal. Beaucoup guérissent en environ une semaine, mais le risque est plus élevé pendant la grossesse, chez les enfants de moins de cinq ans, les personnes âgées et celles atteintes de maladies chroniques ou immunodéprimées. Repos, boissons sûres et limitation des contacts peuvent aider ; consultez si les symptômes sont sévères ou s’aggravent. La vaccination saisonnière est la principale mesure préventive.',
      'source': 'WHO — Influenza (seasonal) fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/influenza-(seasonal)',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'severe_headache',
      'aliases': ['صداع شديد مفاجئ','اسوأ صداع','أسوأ صداع','صداع كالصاعقة','صداع مع تيبس الرقبة','sudden severe headache','worst headache','thunderclap headache','céphalée brutale intense','pire mal de tête'],
      'ar': 'اطلب الطوارئ فوراً إذا بدأ الصداع فجأة وكان شديداً جداً، أو صاحبه ضعف أو خدر مفاجئ، أو اضطراب الكلام أو الرؤية أو التوازن، أو تشوش أو تشنجات، أو حمى شديدة مع تيبس الرقبة، أو حدث بعد إصابة في الرأس. لا تقد بنفسك.',
      'en': 'Seek emergency help immediately for a sudden, extremely severe headache, or headache with new weakness or numbness, speech, vision or balance problems, confusion, seizures, a high fever with a stiff neck, or a recent head injury. Do not drive yourself.',
      'fr': 'Demandez une aide d’urgence immédiate en cas de céphalée soudaine et extrêmement intense, ou accompagnée d’une faiblesse ou d’un engourdissement nouveau, de troubles de la parole, de la vision ou de l’équilibre, de confusion, de convulsions, d’une forte fièvre avec raideur de la nuque ou d’un traumatisme crânien récent. Ne conduisez pas vous-même.',
      'source': 'NHS — Headaches',
      'url': 'https://www.nhs.uk/symptoms/headaches/',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'cholera',
      'aliases': ['كوليرا','الكوليرا','اسهال مائي شديد','إسهال مائي شديد','براز مثل ماء الارز','براز مثل ماء الأرز','قيء واسهال شديد','cholera','severe watery diarrhoea','severe watery diarrhea','choléra','diarrhée aqueuse sévère'],
      'ar': 'قد تسبب الكوليرا إسهالاً مائياً غزيراً وقيئاً وتجفافاً سريعاً. ابدأ محلول الإماهة الفموية الجاهز وفق تعليمات العبوة، واذهب إلى أقرب مرفق صحي أو مركز إماهة بسرعة. اطلب مساعدة طارئة إذا تعذّر الشرب، أو ظهر خمول أو ارتباك أو ضعف شديد أو علامات تجفاف. لا تستخدم مضاداً حيوياً من نفسك.',
      'en': 'Cholera can cause profuse watery diarrhoea, vomiting and rapid dehydration. Start a correctly prepared oral rehydration solution sachet according to its instructions and go promptly to a health facility or rehydration point. Seek emergency help if the person cannot drink, becomes drowsy or confused, is very weak, or shows dehydration. Do not self-start antibiotics.',
      'fr': 'Le choléra peut provoquer une diarrhée aqueuse abondante, des vomissements et une déshydratation rapide. Commencez une solution de réhydratation orale préparée exactement selon la notice du sachet et rendez-vous rapidement dans un centre de santé ou un point de réhydratation. Demandez une aide urgente si la personne ne peut pas boire, devient somnolente ou confuse, est très faible ou présente des signes de déshydratation. Ne prenez pas d’antibiotiques sans avis médical.',
      'source': 'WHO — Cholera fact sheet and outbreak Q&A',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/cholera',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'dengue',
      'aliases': ['حمى الضنك','حمى دنجي','الضنك','dengue','dengue fever','dengue sévère','dengue severe'],
      'ar': 'قد تسبب حمى الضنك حمى وصداعاً وآلاماً بالجسم وغثياناً وطفحاً، ولا يمكن تأكيدها بالأعراض وحدها. اطلب الرعاية فوراً عند ألم شديد بالبطن أو قيء مستمر أو نزيف أو تنفس سريع أو خمول أو جلد شاحب وبارد، حتى لو انخفضت الحمى. لا تتناول الأسبرين أو الإيبوبروفين عند الاشتباه بالضنك إلا بتوجيه طبي؛ اطلب من مختص تحديد المسكن الآمن.',
      'en': 'Dengue may cause fever, headache, body aches, nausea and rash; symptoms alone cannot confirm it. Seek care immediately for severe abdominal pain, persistent vomiting, bleeding, rapid breathing, marked fatigue or pale, cold skin—even if the fever has fallen. If dengue is suspected, do not take aspirin or ibuprofen unless specifically directed by a clinician; ask a health professional about safe pain relief.',
      'fr': 'La dengue peut provoquer fièvre, maux de tête, douleurs corporelles, nausées et éruption ; les symptômes seuls ne suffisent pas à confirmer le diagnostic. Consultez immédiatement en cas de forte douleur abdominale, vomissements persistants, saignement, respiration rapide, grande fatigue ou peau pâle et froide, même si la fièvre a baissé. En cas de suspicion de dengue, ne prenez pas d’aspirine ni d’ibuprofène sauf indication médicale explicite ; demandez conseil à un professionnel pour un antalgique adapté.',
      'source': 'WHO — Dengue and severe dengue fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/dengue-and-severe-dengue',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'newborn_danger_signs',
      'aliases': ['علامات الخطر عند حديث الولادة','الطفل حديث الولادة لا يرضع','رضيع لا يرضع','حرارة الرضيع','برودة الرضيع','newborn danger signs','newborn not feeding','newborn fever','signes de danger nouveau né','nouveau-né ne tète pas'],
      'ar': 'عند حديث الولادة، عدم الرضاعة أو ضعفها، صعوبة التنفس، التشنجات، الخمول أو قلة الحركة، الحمى أو برودة الجسم، أو اليرقان خلال أول 24 ساعة أو اصفرار الكفين والقدمين علامات خطر. توجّه إلى أقرب مرفق صحي أو طوارئ فوراً؛ لا تنتظر موعد المتابعة.',
      'en': 'In a newborn, poor or absent feeding, difficult breathing, convulsions, unusual sleepiness or reduced movement, fever or feeling cold, jaundice in the first 24 hours, or yellow palms and soles are danger signs. Go to the nearest health facility or emergency department immediately; do not wait for a routine appointment.',
      'fr': 'Chez un nouveau-né, une alimentation faible ou absente, une difficulté respiratoire, des convulsions, une somnolence inhabituelle ou une diminution des mouvements, de la fièvre ou un corps froid, une jaunisse dans les premières 24 heures ou des paumes et plantes jaunes sont des signes de danger. Rendez-vous immédiatement dans un établissement de santé ou aux urgences ; n’attendez pas le prochain rendez-vous.',
      'source': 'WHO — Newborns: improving survival and well-being; WHO postnatal care recommendations',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/newborns-reducing-mortality/',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'pregnancy_danger_signs',
      'aliases': ['نزيف اثناء الحمل','نزيف بعد الولادة','صداع شديد للحامل','زغللة للحامل','تسمم الحمل','تشنجات الحامل','قلة حركة الجنين','pregnancy danger signs','bleeding during pregnancy','pre-eclampsia','preeclampsia','signes de danger grossesse','prééclampsie'],
      'ar': 'أثناء الحمل أو بعد الولادة، النزيف المهبلي أو التشنجات أو الصداع الشديد مع تشوش الرؤية أو ألم البطن الشديد أو صعوبة التنفس أو نقص حركة الجنين يستدعي تقييماً عاجلاً فوراً. لا تنتظر تحسن الأعراض ولا تعتمد على قياس منزلي وحده.',
      'en': 'During pregnancy or after birth, vaginal bleeding, seizures, severe headache with blurred vision, severe abdominal pain, breathing difficulty, or reduced fetal movement needs urgent medical assessment now. Do not wait for symptoms to improve or rely on a home reading alone.',
      'fr': 'Pendant la grossesse ou après l’accouchement, des saignements vaginaux, des convulsions, de forts maux de tête avec vision trouble, une douleur abdominale intense, une difficulté respiratoire ou une diminution des mouvements du bébé nécessitent une évaluation médicale urgente. N’attendez pas une amélioration et ne vous fiez pas uniquement à une mesure à domicile.',
      'source': 'WHO — Getting health services during pregnancy; WHO — Pre-eclampsia fact sheet',
      'url': 'https://www.who.int/tools/your-life-your-health/life-phase/pregnancy--birth-and-after-childbirth/getting-the-health-services-you-need-during-pregnancy',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'heatstroke',
      'aliases': ['ضربة شمس','ضربة حر','ضربة حرارة','حر شديد ودوخة','heatstroke','heat stroke','coup de chaleur','insolation'],
      'ar': 'ضربة الشمس طارئ طبي. اتصل بخدمات الطوارئ المحلية فوراً، وانقل المصاب إلى مكان بارد أو مظلل وابدأ تبريده بسرعة بقطعة قماش أو مناشف باردة ومبللة مع إزالة الملابس الزائدة. راقبه حتى وصول المساعدة. لا تعطِ فاقد الوعي شيئاً عن طريق الفم.',
      'en': 'Heatstroke is a medical emergency. Call local emergency services immediately, move the person to a cool or shaded place, and start rapid cooling with cold wet cloths or towels while removing excess clothing. Monitor them until help arrives. Do not give anything by mouth to an unconscious person.',
      'fr': 'Le coup de chaleur est une urgence médicale. Appelez immédiatement les secours locaux, placez la personne dans un endroit frais ou ombragé et commencez à la refroidir rapidement avec des linges froids et humides en retirant les vêtements superflus. Surveillez-la jusqu’à l’arrivée des secours. Ne donnez rien par la bouche à une personne inconsciente.',
      'source': 'WHO — Heatwaves: how to stay cool',
      'url': 'https://www.who.int/ar/news-room/questions-and-answers/item/heatwaves-how-to-stay-cool',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'sepsis',
      'aliases': ['تعفن الدم','تسمم الدم','انتان','إنتان','عدوى شديدة مع ارتباك','sepsis','blood poisoning','septicémie','sepsis infection'],
      'ar': 'الإنتان تفاعل خطير قد يحدث بسبب عدوى ويُعد حالة طبية طارئة. تشمل العلامات المحتملة الارتباك أو صعوبة التنفس أو الجلد البارد المتعرق أو الألم الشديد أو ضعف النبض أو قلة التبول أو الحمى أو انخفاض الحرارة. اطلب تقييماً طبياً فورياً ولا تنتظر اجتماع كل العلامات.',
      'en': 'Sepsis is a dangerous response to infection and a medical emergency. Possible signs include confusion, difficulty breathing, cold clammy skin, severe pain, a weak pulse, reduced urination, fever or low temperature. Seek immediate medical care; do not wait for all signs to appear.',
      'fr': 'Le sepsis est une réaction dangereuse à une infection et constitue une urgence médicale. Les signes possibles comprennent confusion, difficulté respiratoire, peau froide et moite, douleur intense, pouls faible, diminution des urines, fièvre ou température basse. Demandez immédiatement des soins médicaux ; n’attendez pas l’apparition de tous les signes.',
      'source': 'WHO — Sepsis fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/sepsis',
      'review': 'editorial_source_checked_clinician_review_pending'
    },

    {
      'id': 'tuberculosis',
      'aliases': ['السل','مرض السل','كحة مستمرة','سعال مستمر مع دم','تعرق ليلي مع سعال','tuberculosis','tb','persistent cough with blood','night sweats and weight loss','tuberculose','toux persistante avec sang'],
      'ar': 'قد يسبب السل سعالا مطولاً، وأحياناً دماً مع السعال، وألم الصدر، والحمى، والتعرق الليلي، والتعب أو نقص الوزن. هذه العلامات لا تؤكد التشخيص؛ يلزم تقييم وفحص مناسب. اطلب الفحص سريعاً إذا استمر السعال أو ظهرت هذه الأعراض، وغطِّ الفم عند السعال وحافظ على تهوية المكان.',
      'en': 'Tuberculosis may cause a prolonged cough, sometimes with blood, chest pain, fever, night sweats, fatigue or weight loss. These signs do not confirm TB; appropriate assessment and testing are needed. Seek testing promptly for a persistent cough or these symptoms, cover coughs and keep rooms well ventilated.',
      'fr': 'La tuberculose peut provoquer une toux prolongée, parfois avec du sang, des douleurs thoraciques, de la fièvre, des sueurs nocturnes, de la fatigue ou une perte de poids. Ces signes ne confirment pas le diagnostic ; une évaluation et des tests sont nécessaires. Faites-vous dépister rapidement en cas de toux persistante, couvrez-vous la bouche en toussant et aérez les pièces.',
      'source': 'WHO — Tuberculosis fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/tuberculosis',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'anaemia',
      'aliases': ['فقر الدم','انيميا','أنيميا','نقص الهيموجلوبين','شحوب وتعب ودوخة','anaemia','anemia','low haemoglobin','low hemoglobin','anémie'],
      'ar': 'قد يسبب فقر الدم التعب والدوخة وبرودة اليدين والقدمين والصداع وضيق النفس، لكن هذه الأعراض لها أسباب متعددة. تأكيد فقر الدم وتحديد سببه يحتاجان فحوص دم وتقييماً صحياً. لا تبدأ مكملات الحديد أو جرعات علاجية من نفسك؛ فليست كل أنواع فقر الدم بسبب نقص الحديد.',
      'en': 'Anaemia may cause tiredness, dizziness, cold hands and feet, headache and shortness of breath, but these symptoms have many possible causes. Confirming anaemia and identifying its cause require blood tests and clinical assessment. Do not start iron supplements or treatment doses on your own; not all anaemia is caused by iron deficiency.',
      'fr': 'L’anémie peut provoquer fatigue, vertiges, mains et pieds froids, maux de tête et essoufflement, mais ces symptômes ont de nombreuses causes possibles. La confirmation de l’anémie et l’identification de sa cause nécessitent des analyses sanguines et une évaluation médicale. Ne commencez pas de supplémentation en fer ni de dose thérapeutique sans avis médical ; toutes les anémies ne sont pas dues à une carence en fer.',
      'source': 'WHO — Anaemia fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/ANAEMIA',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'kidney_disease',
      'aliases': ['مرض الكلى','الكلى','قصور كلوي','فشل كلوي','تورم الساقين مع تعب','kidney disease','chronic kidney disease','kidney failure','maladie rénale','maladie rénale chronique','insuffisance rénale'],
      'ar': 'قد لا يسبب مرض الكلى أعراضاً في مراحله المبكرة. يزداد الخطر مع السكري وارتفاع ضغط الدم وبعض أمراض القلب. قد تشمل العلامات المتأخرة تورم الساقين والتعب والحكة والغثيان أو ضيق النفس. يحتاج التقييم إلى فحوص يحددها الطبيب؛ لا توقف دواءً موصوفاً ولا تستخدم مسكنات أو أعشاباً بانتظام دون استشارة.',
      'en': 'Kidney disease may cause no symptoms in its early stages. Risk is higher with diabetes, high blood pressure and some heart conditions. Later signs may include leg swelling, fatigue, itching, nausea or breathlessness. Assessment requires tests chosen by a clinician; do not stop prescribed medicines or regularly use painkillers or herbal products without advice.',
      'fr': 'La maladie rénale peut ne provoquer aucun symptôme à ses débuts. Le risque est plus élevé en cas de diabète, d’hypertension ou de certaines maladies cardiaques. À un stade avancé, des signes peuvent inclure gonflement des jambes, fatigue, démangeaisons, nausées ou essoufflement. L’évaluation nécessite des examens prescrits par un professionnel ; n’arrêtez pas un traitement et n’utilisez pas régulièrement des antalgiques ou des plantes sans avis médical.',
      'source': 'WHO — Kidney disease fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/kidney-disease',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'hepatitis_b',
      'aliases': ['التهاب الكبد ب','التهاب الكبد الوبائي ب','فيروس الكبد ب','hepatitis b','hbv','hépatite b','hepatite b'],
      'ar': 'التهاب الكبد B عدوى فيروسية تصيب الكبد وقد تصبح مزمنة من دون أعراض واضحة. لا يمكن تأكيدها بالأعراض؛ يلزم فحص دم. الوقاية تشمل التطعيم، وسلامة الدم والأدوات الحادة، وعدم مشاركة الإبر أو شفرات الحلاقة. الحوامل أو من خالطوا شخصاً مصاباً ينبغي أن يسألوا مقدم الرعاية عن الفحص والوقاية المناسبة.',
      'en': 'Hepatitis B is a viral infection of the liver and can become chronic without obvious symptoms. Symptoms cannot confirm it; a blood test is needed. Prevention includes vaccination, safe blood and sharp-instrument practices, and never sharing needles or razors. Pregnant people or close contacts of someone with hepatitis B should ask a health professional about testing and appropriate prevention.',
      'fr': 'L’hépatite B est une infection virale du foie qui peut devenir chronique sans symptômes évidents. Les symptômes ne suffisent pas au diagnostic ; une analyse sanguine est nécessaire. La prévention comprend la vaccination, la sécurité du sang et des instruments tranchants, et l’absence de partage d’aiguilles ou de rasoirs. Les femmes enceintes et les proches d’une personne infectée doivent demander conseil pour le dépistage et la prévention.',
      'source': 'WHO — Hepatitis B fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/hepatitis-B/',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'hiv',
      'aliases': ['فيروس نقص المناعة','الايدز','الإيدز','فحص hiv','hiv','aids','hiv test','dépistage vih','vih'],
      'ar': 'فيروس نقص المناعة البشرية يؤثر في جهاز المناعة، وقد لا تظهر أعراض واضحة في البداية. لا يمكن معرفة الحالة من المظهر أو الأعراض؛ الفحص هو الطريق لمعرفة ذلك. لا ينتقل الفيروس بالمصافحة أو العناق أو مشاركة الطعام. توجد وسائل فعالة للوقاية والعلاج؛ اطلب معلومات سرية من مقدم رعاية موثوق ولا توقف علاجاً موصوفاً.',
      'en': 'HIV affects the immune system and may cause no obvious early symptoms. A person’s status cannot be known from appearance or symptoms; testing is the way to know. HIV is not spread by handshakes, hugs or sharing food. Effective prevention and treatment are available; seek confidential advice from a trusted health service and do not stop prescribed treatment.',
      'fr': 'Le VIH affecte le système immunitaire et peut ne provoquer aucun symptôme évident au début. Le statut ne peut pas être déterminé par l’apparence ou les symptômes ; seul le dépistage permet de le connaître. Le VIH ne se transmet pas par une poignée de main, une accolade ou le partage de nourriture. Des moyens efficaces de prévention et de traitement existent ; demandez conseil en toute confidentialité à un service de santé fiable et n’interrompez pas un traitement prescrit.',
      'source': 'WHO — HIV and AIDS fact sheet',
      'url': 'https://www.who.int/en/news-room/fact-sheets/detail/hiv-aids',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'depression',
      'aliases': ['اكتئاب','مكتئب','حزن مستمر','فقدان الرغبة','ما عاد استمتع بشي','depression','depressed mood','loss of interest','dépression','perte d’intérêt'],
      'ar': 'قد يظهر الاكتئاب في صورة مزاج منخفض أو فقدان الاهتمام والمتعة معظم الأيام لمدة أسبوعين أو أكثر، مع اضطراب النوم أو الشهية أو التركيز أو الشعور باليأس. لا يمكن تشخيصه من رسالة واحدة، لكنه قابل للعلاج. تحدث مع مختص صحي أو شخص تثق به. إذا راودتك أفكار لإيذاء نفسك أو كنت في خطر مباشر، اطلب مساعدة الطوارئ المحلية الآن وابقَ مع شخص تثق به.',
      'en': 'Depression may involve low mood or loss of interest or pleasure most days for two weeks or more, alongside changes in sleep, appetite or concentration, or hopelessness. One message cannot diagnose it, but effective care is available. Speak with a health professional or someone you trust. If you may harm yourself or are in immediate danger, contact local emergency services now and stay with someone you trust.',
      'fr': 'La dépression peut se manifester par une humeur basse ou une perte d’intérêt ou de plaisir presque chaque jour pendant au moins deux semaines, avec des changements du sommeil, de l’appétit ou de la concentration, ou un sentiment de désespoir. Un message ne permet pas de poser un diagnostic, mais des soins efficaces existent. Parlez à un professionnel de santé ou à une personne de confiance. Si vous risquez de vous faire du mal ou êtes en danger immédiat, contactez les secours locaux maintenant et restez avec une personne de confiance.',
      'source': 'WHO — Depressive disorder (depression) fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/depression',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'oral_health',
      'aliases': ['صحة الفم','وجع الاسنان','وجع الأسنان','الم ضرس','ألم ضرس','نزيف اللثة','oral health','toothache','tooth pain','santé bucco-dentaire','mal de dents'],
      'ar': 'للعناية بصحة الفم، نظّف الأسنان مرتين يومياً بمعجون يحتوي على الفلورايد، وقلّل السكريات، وراجع طبيب الأسنان بانتظام. ألم الأسنان أو تورم اللثة يحتاج تقييماً لدى طبيب أسنان. تورم الوجه أو الرقبة المصحوب بصعوبة التنفس أو البلع حالة طارئة.',
      'en': 'For oral health, brush twice daily with fluoride toothpaste, limit free sugars and attend regular dental checks. Toothache or gum swelling needs dental assessment. Facial or neck swelling with difficulty breathing or swallowing is an emergency.',
      'fr': 'Pour préserver la santé bucco-dentaire, brossez-vous les dents deux fois par jour avec un dentifrice fluoré, limitez les sucres libres et consultez régulièrement un dentiste. Une douleur dentaire ou un gonflement des gencives nécessite un examen dentaire. Un gonflement du visage ou du cou accompagné de difficultés à respirer ou à avaler est une urgence.',
      'source': 'WHO — Oral health fact sheet',
      'url': 'https://www.who.int/news-room/fact-sheets/detail/oral-health',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
    {
      'id': 'child_malnutrition',
      'aliases': ['سوء تغذية الطفل','هزال الطفل','طفل نحيف جدا','تورم قدمي الطفل','سوء التغذية','child malnutrition','child wasting','nutritional oedema','malnutrition infantile','malnutrition de l’enfant'],
      'ar': 'قد يشير الهزال الواضح أو ضعف زيادة الوزن أو تورم القدمين لدى الطفل إلى سوء تغذية يحتاج تقييماً سريعاً. لا تعتمد على الشكل وحده ولا تبدأ حمية أو مكملات علاجية من نفسك. اطلب فحصاً لدى مرفق صحي، وبشكل عاجل إذا كان الطفل لا يستطيع الأكل أو الشرب، أو خاملاً بشدة، أو يعاني صعوبة التنفس أو الجفاف.',
      'en': 'Visible wasting, poor weight gain or swelling of a child’s feet may indicate malnutrition and needs prompt assessment. Appearance alone cannot establish the diagnosis; do not start a restrictive diet or therapeutic supplements yourself. Seek assessment at a health facility, urgently if the child cannot eat or drink, is very lethargic, has breathing difficulty or dehydration.',
      'fr': 'Un amaigrissement visible, une faible prise de poids ou un gonflement des pieds chez un enfant peuvent signaler une malnutrition nécessitant une évaluation rapide. L’apparence seule ne permet pas de poser le diagnostic ; ne commencez pas de régime restrictif ni de supplément thérapeutique sans avis. Consultez un établissement de santé, en urgence si l’enfant ne peut ni manger ni boire, est très léthargique, respire difficilement ou présente une déshydratation.',
      'source': 'WHO — Malnutrition fact sheet; WHO/UNICEF 2026 wasting and nutritional oedema guidance',
      'url': 'https://www.who.int/en/news-room/fact-sheets/detail/malnutrition',
      'review': 'editorial_source_checked_clinician_review_pending'
    },
  ];

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[àáâäãå]'), 'a')
      .replaceAll(RegExp(r'[èéêë]'), 'e')
      .replaceAll(RegExp(r'[ìíîï]'), 'i')
      .replaceAll(RegExp(r'[òóôöõ]'), 'o')
      .replaceAll(RegExp(r'[ùúûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll('œ', 'oe')
      .replaceAll('æ', 'ae')
      .replaceAll('’', ' ')
      .replaceAll("'", ' ')
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

    Map<String, dynamic>? bestEntry;
    var bestAliasLength = 0;
    for (final entry in entries) {
      final aliases = (entry['aliases'] as List).cast<String>();
      for (final alias in aliases) {
        final normalizedAlias = normalize(alias);
        if (normalizedAlias.isEmpty || !query.contains(normalizedAlias)) continue;
        if (normalizedAlias.length > bestAliasLength) {
          bestEntry = entry;
          bestAliasLength = normalizedAlias.length;
        }
      }
    }

    if (bestEntry == null) return null;
    final language = languageCode == 'fr' ? 'fr' : (languageCode == 'en' ? 'en' : 'ar');
    return {
      'response': bestEntry[language] as String,
      'type': bestEntry['id'] as String,
      'source': bestEntry['source'] as String,
      'source_url': bestEntry['url'] as String,
      'review_status': bestEntry['review'] as String,
    };
  }
}
