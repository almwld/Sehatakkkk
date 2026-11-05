import 'package:flutter/widgets.dart';

/// Human-reviewed translations of the legal terms. Arabic remains the source.
class TermsTranslations {
  static String body(String title, String arabic, Locale locale) {
    if (locale.languageCode == 'ar') return arabic;
    final language = locale.languageCode;
    final section = title.split('.').first;
    final translations = <String, List<String>>{
      '1': [
'''Welcome to Sehatak, the leading digital healthcare platform in the Republic of Yemen.

**Our vision:**
We aim to become Yemen’s most trusted and widely used digital health platform by providing innovative, accessible healthcare solutions that meet the needs of all members of society.

**Our mission:**
To empower everyone in Yemen to access high-quality healthcare services easily through an integrated digital platform that brings together the latest technologies and the best medical professionals.

**Our values:**
- Trust: We build relationships with users on trust and transparency.
- Quality: We are committed to the highest quality standards across all our services.
- Innovation: We adopt the latest technologies to continuously improve our services.
- Humanity: People are at the heart of everything we provide.
- Inclusiveness: We serve all segments of society without discrimination.

**Who we are:**
Sehatak is a Yemeni national project that aims to develop Yemen’s healthcare sector through digitalization and connect patients with healthcare providers in innovative and effective ways. The platform was founded by a team of healthcare and technology experts to bridge the gap between demand for healthcare services and their availability.

**Our commitment to users:**
- We are committed to providing reliable and safe healthcare services.
- We are committed to protecting the privacy of your health data.
- We are committed to transparency in all our dealings.
- We are committed to responding promptly to your needs and enquiries.
- We are committed to continuously improving our services.

By using this platform, you agree to comply with all terms and conditions in this document, which are designed to protect the rights of all parties and ensure the provision of excellent and safe services.

These terms cover all aspects of using the platform, including account creation, appointment booking, telemedicine consultations, medicine orders, health-record management, communication with providers, financial transactions, and participation in the health community.

We recommend that you read these terms carefully before using the platform. If you have any questions, please contact our support team.''',
'''Bienvenue sur Sehatak, la principale plateforme numérique de soins de santé de la République du Yémen.

**Notre vision :**
Nous aspirons à devenir la plateforme de santé numérique la plus fiable et la plus utilisée au Yémen, en proposant des solutions de soins innovantes et accessibles qui répondent aux besoins de tous.

**Notre mission :**
Permettre à chacun au Yémen d’accéder facilement à des services de santé de haute qualité grâce à une plateforme numérique intégrée réunissant les technologies les plus récentes et les meilleurs professionnels de santé.

**Nos valeurs :**
- Confiance : nous fondons nos relations avec les utilisateurs sur la confiance et la transparence.
- Qualité : nous nous engageons à respecter les normes de qualité les plus élevées dans tous nos services.
- Innovation : nous adoptons les technologies les plus récentes pour améliorer continuellement nos services.
- Humanité : l’être humain est au cœur de tout ce que nous proposons.
- Inclusion : nous servons toutes les catégories de la société sans discrimination.

**Qui sommes-nous ?**
Sehatak est un projet national yéménite visant à développer le secteur de la santé au Yémen grâce à la numérisation et à relier les patients aux prestataires de soins de manière innovante et efficace. La plateforme a été fondée par une équipe d’experts en santé et en technologie afin de réduire l’écart entre la demande de services de santé et leur disponibilité.

**Notre engagement envers les utilisateurs :**
- Nous nous engageons à fournir des services de santé fiables et sûrs.
- Nous nous engageons à protéger la confidentialité de vos données de santé.
- Nous nous engageons à faire preuve de transparence dans toutes nos transactions.
- Nous nous engageons à répondre rapidement à vos besoins et demandes.
- Nous nous engageons à améliorer continuellement nos services.

En utilisant cette plateforme, vous acceptez de respecter l’ensemble des présentes conditions, conçues pour protéger les droits de toutes les parties et garantir des services de qualité et sûrs.

Ces conditions couvrent tous les aspects de l’utilisation de la plateforme, notamment la création de compte, la prise de rendez-vous, les consultations médicales à distance, les commandes de médicaments, la gestion du dossier de santé, les échanges avec les prestataires, les transactions financières et la participation à la communauté de santé.

Nous vous recommandons de lire attentivement ces conditions avant d’utiliser la plateforme. Pour toute question, veuillez contacter notre équipe d’assistance.'''
      ],
      '2': [
'''In these Terms and Conditions, the following words and expressions have the meanings set out below.

**Core terms:**
“Platform”, “Application” or “Sehatak”: the Sehatak digital platform, including its mobile application (iOS and Android), website, and all related services and functions.

“User”: any natural or legal person who uses the platform in any way, whether registered as a member or browsing as a visitor.

“Patient”: a user who requests healthcare services through the platform, either for themselves or on behalf of a family member.

“Service Provider”: a doctor, nurse, pharmacist, laboratory, hospital, health centre, or other healthcare entity providing services through the platform.

“Account”: the user’s profile on the platform, containing personal and health information and contact details.

“Medical Consultation”: an interaction between a patient and a service provider through the platform for the purpose of providing medical advice, diagnosis, or treatment recommendations.

“Personal Data”: any information relating to an identified or identifiable user, such as name, address, telephone number, email address, photographs, and voice recordings.

“Health Information”: any data relating to a user’s physical or mental health, including medical history, test results, diagnoses, treatments, and medicines.

“Content”: all materials published on the platform, including text, images, videos, audio files, and graphics.

“Services”: all services provided through the platform, including appointment booking, medical consultations, medicine orders, health-record management, and laboratory services.

“Third Party”: any person or entity that is not a party to the agreement between the user and the platform.

“Applicable Laws”: all laws and regulations in force in the Republic of Yemen, including data-protection and privacy laws.

**Technical terms:**
“Mobile Application”: the Sehatak application for iOS and Android.
“Website”: the platform’s official website on the internet.
“User Interface”: the design and interactive elements that enable users to interact with the platform.
“Artificial Intelligence”: technologies used by the platform to analyse data and provide recommendations.
“Machine Learning”: technologies used to improve platform performance based on data.
“Encryption”: techniques for protecting data using mathematical algorithms.
“Authentication”: the process of verifying a user’s identity.
“Authorization”: the process of defining a user’s permissions within the platform.

**Legal terms:**
“Consent”: a user’s express or implied agreement to the processing of their data.
“Disclosure”: making information available to authorized entities.
“Confidentiality”: the platform’s obligation not to disclose user information.
“Liability”: the obligation to compensate for damage arising from the platform’s services.
“Compensation”: monetary compensation for damage suffered by a user.
“Arbitration”: a mechanism for resolving disputes outside the courts.
“Jurisdiction”: the courts competent to hear disputes.

**Financial terms:**
“Subscription”: a paid plan for accessing platform services.
“Fees”: amounts payable for services.
“Financial Transaction”: any payment or money transfer made through the platform.
“Digital Wallet”: an electronic wallet for storing funds and making transactions.
“Invoices”: documents detailing financial transactions.
“Refund”: repayment of an amount paid in specified circumstances.

**Service terms:**
“Appointment”: a booking to receive a healthcare service at a specified time and place.
“Prescription”: written medical instructions issued by a licensed doctor specifying a medicine or treatment.
“Telemedicine”: the provision of medical services remotely using communication technologies.
“Health Community”: a group of users interacting to exchange healthcare experiences and information.
“Health Forum”: a digital space where users discuss health topics.
“Rating”: a user’s assessment of the services provided.
“Review”: written feedback from users about their experiences.

**Reporting terms:**
“Medical Reports”: documents describing a patient’s health condition.
“Test Results”: results of laboratory tests and medical imaging.
“Medical History”: a complete record of a patient’s health condition.
“Health Record”: a comprehensive file containing all of a patient’s health information.''',
'''Dans les présentes conditions générales, les mots et expressions suivants ont les significations indiquées ci-dessous.

**Termes essentiels :**
« Plateforme », « Application » ou « Sehatak » : la plateforme numérique Sehatak, y compris son application mobile (iOS et Android), son site web et tous les services et fonctionnalités associés.

« Utilisateur » : toute personne physique ou morale qui utilise la plateforme, qu’elle soit inscrite comme membre ou qu’elle la consulte en tant que visiteur.

« Patient » : l’utilisateur qui demande des services de santé par l’intermédiaire de la plateforme, pour lui-même ou pour un membre de sa famille.

« Prestataire de services » : médecin, infirmier, pharmacien, laboratoire, hôpital, centre de santé ou toute autre entité de santé fournissant des services par l’intermédiaire de la plateforme.

« Compte » : le profil de l’utilisateur sur la plateforme, qui comprend ses informations personnelles et de santé ainsi que ses coordonnées.

« Consultation médicale » : interaction entre un patient et un prestataire par l’intermédiaire de la plateforme afin de fournir un avis médical, un diagnostic ou une recommandation de traitement.

« Données personnelles » : toute information relative à un utilisateur identifié ou identifiable, telle que son nom, son adresse, son numéro de téléphone, son adresse e-mail, ses photographies et sa voix.

« Informations de santé » : toute donnée relative à la santé physique ou mentale de l’utilisateur, notamment ses antécédents médicaux, résultats d’examens, diagnostics, traitements et médicaments.

« Contenu » : tous les éléments publiés sur la plateforme, notamment les textes, images, vidéos, fichiers audio et graphiques.

« Services » : tous les services fournis par l’intermédiaire de la plateforme, notamment la prise de rendez-vous, les consultations médicales, les commandes de médicaments, la gestion du dossier de santé et les services de laboratoire.

« Tiers » : toute personne ou entité qui n’est pas partie à l’accord entre l’utilisateur et la plateforme.

« Lois applicables » : l’ensemble des lois et règlements en vigueur en République du Yémen, y compris les lois relatives à la protection des données et à la confidentialité.

**Termes techniques :**
« Application mobile » : l’application Sehatak pour iOS et Android.
« Site web » : le site officiel de la plateforme sur Internet.
« Interface utilisateur » : la conception et les éléments interactifs permettant à l’utilisateur d’interagir avec la plateforme.
« Intelligence artificielle » : les technologies utilisées par la plateforme pour analyser les données et formuler des recommandations.
« Apprentissage automatique » : les technologies utilisées pour améliorer les performances de la plateforme à partir des données.
« Chiffrement » : les techniques de protection des données au moyen d’algorithmes mathématiques.
« Authentification » : le processus de vérification de l’identité de l’utilisateur.
« Autorisation » : le processus de définition des droits de l’utilisateur au sein de la plateforme.

**Termes juridiques :**
« Consentement » : accord exprès ou implicite de l’utilisateur au traitement de ses données.
« Divulgation » : communication d’informations aux entités autorisées.
« Confidentialité » : obligation de la plateforme de ne pas divulguer les informations de l’utilisateur.
« Responsabilité » : obligation d’indemniser les dommages résultant des services de la plateforme.
« Indemnisation » : compensation financière des dommages subis par l’utilisateur.
« Arbitrage » : mécanisme de règlement des différends en dehors des tribunaux.
« Compétence juridictionnelle » : tribunaux compétents pour connaître des litiges.

**Termes financiers :**
« Abonnement » : formule payante permettant d’accéder aux services de la plateforme.
« Frais » : sommes dues en contrepartie des services.
« Transaction financière » : toute opération de paiement ou de transfert d’argent effectuée par l’intermédiaire de la plateforme.
« Portefeuille numérique » : portefeuille électronique permettant de conserver des fonds et d’effectuer des transactions.
« Factures » : documents détaillant les transactions financières.
« Remboursement » : restitution d’un montant payé dans certains cas.

**Termes relatifs aux services :**
« Rendez-vous » : réservation d’un service de santé à une date, une heure et un lieu déterminés.
« Prescription médicale » : instructions médicales écrites par un médecin agréé indiquant un médicament ou un traitement.
« Télémédecine » : prestation de services médicaux à distance au moyen de technologies de communication.
« Communauté de santé » : groupe d’utilisateurs qui échangent des expériences et des informations sur la santé.
« Forum de santé » : espace numérique de discussion entre utilisateurs sur des sujets de santé.
« Évaluation » : appréciation des services fournis par les utilisateurs.
« Avis » : commentaire écrit des utilisateurs sur leurs expériences.

**Termes relatifs aux rapports :**
« Rapports médicaux » : documents décrivant l’état de santé du patient.
« Résultats d’examens » : résultats d’analyses de laboratoire et d’imagerie médicale.
« Antécédents médicaux » : dossier complet de l’état de santé du patient.
« Dossier de santé » : dossier complet contenant toutes les informations de santé du patient.'''
      ],
      '3': [
'''These Terms and Conditions constitute a legally binding agreement between you and the Sehatak platform. By using the platform, you fully and unconditionally agree to comply with all provisions of this document.

**Express consent:**
- When you create an account, you expressly agree to these terms.
- When you use any platform service, you confirm your agreement to these terms.
- We may request additional consent for certain specific services.

**Implied consent:**
- Continuing to use the platform constitutes implied acceptance of all terms.
- Failure to object to any provision within 30 days of notification is considered acceptance.
- Using the platform for any purpose constitutes acceptance of the terms.

**Additional terms:**
- Certain services may be subject to additional terms.
- Additional terms form part of this agreement.
- In the event of a conflict, the additional terms prevail.

**Updates to the terms:**
- We reserve the right to update these terms at any time.
- You will be notified of material changes 30 days before they take effect.
- Minor changes may be implemented without prior notice.

**Acceptance of updates:**
- Continuing to use the platform after an update constitutes acceptance.
- You may close your account if you do not agree to the updates.
- You will have 30 days to object to updates.

**Severability:**
- If any provision is unlawful, it will be excluded.
- The remaining provisions will remain in effect.
- The unlawful provision will be amended to make it lawful.

**Waiver of rights:**
- Failure to enforce a right does not constitute a waiver of that right.
- Any waiver must be made in writing.
- A partial waiver does not constitute a complete waiver.

**Legal capacity:**
- You must be at least 18 years old to use the platform.
- If you are under 18, parental or guardian consent is required.
- We verify users’ eligibility when necessary.

**Expected conduct:**
- Use the platform responsibly and ethically.
- Respect the rights of other users.
- Comply with applicable laws and regulations.
- Do not use the platform for unlawful purposes.''',
'''Les présentes conditions générales constituent un accord juridiquement contraignant entre vous et la plateforme Sehatak. En utilisant la plateforme, vous acceptez pleinement et sans réserve de respecter toutes les dispositions du présent document.

**Consentement exprès :**
- Lors de la création d’un compte, vous acceptez expressément les présentes conditions.
- Lorsque vous utilisez un service de la plateforme, vous confirmez votre acceptation de ces conditions.
- Nous pouvons demander un consentement supplémentaire pour certains services spécifiques.

**Consentement implicite :**
- La poursuite de l’utilisation de la plateforme vaut acceptation implicite de toutes les conditions.
- L’absence d’objection à une disposition dans les 30 jours suivant la notification vaut acceptation.
- Toute utilisation de la plateforme vaut acceptation des conditions.

**Conditions supplémentaires :**
- Certains services peuvent être soumis à des conditions supplémentaires.
- Ces conditions supplémentaires font partie du présent accord.
- En cas de contradiction, les conditions supplémentaires prévalent.

**Mise à jour des conditions :**
- Nous nous réservons le droit de mettre à jour ces conditions à tout moment.
- Vous serez informé de toute modification importante 30 jours avant son entrée en vigueur.
- Les modifications mineures peuvent être appliquées sans préavis.

**Acceptation des mises à jour :**
- La poursuite de l’utilisation de la plateforme après une mise à jour vaut acceptation.
- Vous pouvez clôturer votre compte si vous n’acceptez pas les mises à jour.
- Vous disposerez de 30 jours pour vous opposer aux mises à jour.

**Divisibilité :**
- Toute disposition illégale sera écartée.
- Les autres dispositions resteront en vigueur.
- La disposition illégale sera modifiée afin de devenir conforme à la loi.

**Renonciation aux droits :**
- Le fait de ne pas exercer un droit ne vaut pas renonciation à ce droit.
- Toute renonciation doit être faite par écrit.
- Une renonciation partielle ne vaut pas renonciation totale.

**Capacité juridique :**
- Vous devez avoir au moins 18 ans pour utiliser la plateforme.
- Si vous avez moins de 18 ans, l’autorisation d’un parent ou tuteur est requise.
- Nous vérifions l’éligibilité des utilisateurs lorsque cela est nécessaire.

**Comportement attendu :**
- Utiliser la plateforme de manière responsable et éthique.
- Respecter les droits des autres utilisateurs.
- Respecter les lois et règlements applicables.
- Ne pas utiliser la plateforme à des fins illégales.'''
      ]
    };
    final pair = translations[section];
    if (pair == null || language == 'ar') return arabic;
    return language == 'fr' ? pair[1] : pair[0];
  }
}
