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
      '4': [
'''Sehatak provides a comprehensive range of digital healthcare services designed to meet users’ needs at every stage of care:

**Service 1: Medical appointment booking**
- Book appointments with doctors across more than 30 medical specialties.
- Choose a suitable doctor based on specialty, rating, location, and availability.
- View each doctor’s available working hours.
- Receive appointment reminders through app notifications and email.
- Easily cancel or reschedule appointments.
- View a complete history of past and upcoming appointments.
- Rate doctors after each appointment.
- Share appointments with family members.

**Service 2: Remote medical consultations**
- Medical consultations through high-quality video calls.
- Voice and text consultations with doctors.
- Share medical files and images with the doctor.
- Receive electronic prescriptions.
- Regularly follow up on your health condition.
- Obtain immediate consultations for non-emergency cases.
- Access specialist consultations across medical fields.
- Request a second medical opinion.

**Service 3: Ordering medicines from pharmacies**
- Browse medicines available at nearby pharmacies.
- Search by medicine name, active ingredient, or category.
- Easily order medicines through the app.
- Have medicines delivered to your home in less than two hours.
- Receive reminders about medicine-taking times.
- Manage your personal medicine list.
- Check medicine availability before ordering.
- View available alternatives when a medicine is unavailable.

**Service 4: Personal health-record management**
- Store the user’s complete medical history.
- Track tests and laboratory results.
- Manage current and previous medicines and treatments.
- Easily share the health record with doctors.
- Add daily health notes.
- Track weight, blood pressure, blood glucose, and other indicators.
- Receive periodic health reports.
- Export the health record in multiple formats.

**Service 5: Medical laboratories**
- Book laboratory tests at accredited laboratories.
- Receive test results through the app as soon as they are available.
- Track test status in real time.
- Compare results with previous tests.
- Have results interpreted by specialist doctors.
- Receive reminders for required routine tests.
- Request home sample collection.

**Service 6: Delivery services**
- Deliver medicines and medical supplies to your home.
- Transport laboratory samples to and from your home.
- Track order status in real time.
- Receive notifications when delivery starts and when it arrives.
- Rate the delivery service.
- Track the courier’s location on a map.

**Service 7: Digital wallet**
- Pay medical-service bills electronically.
- Manage payments and subscriptions.
- Track financial transactions.
- Add multiple credit cards.
- Access special discounts and offers.
- Manage your healthcare budget.

**Service 8: Health education**
- Read reliable health articles from approved sources.
- Receive daily health-care tips.
- Watch educational videos by specialist doctors.
- Get disease-prevention guidance.
- Find information about medicines and treatments.
- Explore regularly updated health topics.

**Service 9: Health community**
- Participate in forums for user discussions.
- Exchange healthcare experiences.
- Provide social support among patients.
- Join support groups for chronic conditions.
- Share health achievements.
- Receive advice from health experts.

**Service 10: Customer service**
- Technical support around the clock.
- Prompt resolution of problems and enquiries.
- Help with using the platform.
- Receive complaints and suggestions.
- Follow up on cases until they are resolved.
- Communicate through multiple channels.''',
'''Sehatak propose une gamme complète de services de santé numériques conçus pour répondre aux besoins des utilisateurs à chaque étape des soins.

**Service 1 : Prise de rendez-vous médicaux**
- Prendre rendez-vous avec des médecins dans plus de 30 spécialités.
- Choisir un médecin selon sa spécialité, son évaluation, sa localisation et ses disponibilités.
- Consulter les horaires de travail disponibles de chaque médecin.
- Recevoir des rappels par notifications de l’application et par e-mail.
- Annuler ou modifier facilement les rendez-vous.
- Consulter l’historique complet des rendez-vous passés et à venir.
- Évaluer les médecins après chaque rendez-vous.
- Partager les rendez-vous avec les membres de la famille.

**Service 2 : Consultations médicales à distance**
- Consultations médicales par appels vidéo de haute qualité.
- Consultations vocales et textuelles avec les médecins.
- Partager des dossiers et images médicaux avec le médecin.
- Recevoir des prescriptions électroniques.
- Assurer un suivi régulier de son état de santé.
- Obtenir des consultations rapides pour les situations non urgentes.
- Accéder à des consultations spécialisées dans tous les domaines.
- Demander un deuxième avis médical.

**Service 3 : Commande de médicaments auprès des pharmacies**
- Parcourir les médicaments disponibles dans les pharmacies proches.
- Rechercher par nom, principe actif ou catégorie.
- Commander facilement des médicaments via l’application.
- Faire livrer les médicaments à domicile en moins de deux heures.
- Recevoir des rappels concernant les prises de médicaments.
- Gérer sa liste personnelle de médicaments.
- Vérifier la disponibilité avant de commander.
- Consulter les alternatives disponibles lorsqu’un médicament est indisponible.

**Service 4 : Gestion du dossier de santé personnel**
- Enregistrer l’historique médical complet de l’utilisateur.
- Suivre les examens et les résultats de laboratoire.
- Gérer les médicaments et traitements actuels et antérieurs.
- Partager facilement le dossier de santé avec les médecins.
- Ajouter des notes de santé quotidiennes.
- Suivre le poids, la tension artérielle, la glycémie et d’autres indicateurs.
- Recevoir des rapports de santé périodiques.
- Exporter le dossier de santé dans plusieurs formats.

**Service 5 : Laboratoires médicaux**
- Réserver des examens dans des laboratoires agréés.
- Recevoir les résultats dans l’application dès leur disponibilité.
- Suivre l’état des examens en temps réel.
- Comparer les résultats avec les examens précédents.
- Faire interpréter les résultats par des médecins spécialistes.
- Recevoir des rappels pour les examens périodiques nécessaires.
- Demander le prélèvement d’échantillons à domicile.

**Service 6 : Services de livraison**
- Faire livrer à domicile des médicaments et fournitures médicales.
- Transporter les échantillons de laboratoire depuis et vers le domicile.
- Suivre l’état de la commande en temps réel.
- Recevoir des notifications au départ de la livraison et à son arrivée.
- Évaluer le service de livraison.
- Suivre la position du livreur sur une carte.

**Service 7 : Portefeuille numérique**
- Payer électroniquement les factures de services médicaux.
- Gérer les paiements et les abonnements.
- Suivre les transactions financières.
- Ajouter plusieurs cartes de crédit.
- Bénéficier de réductions et d’offres spéciales.
- Gérer son budget de santé.

**Service 8 : Éducation à la santé**
- Lire des articles de santé fiables provenant de sources agréées.
- Recevoir des conseils quotidiens pour prendre soin de sa santé.
- Regarder des vidéos éducatives réalisées par des médecins spécialistes.
- Consulter des conseils de prévention des maladies.
- Trouver des informations sur les médicaments et les traitements.
- Découvrir des sujets de santé régulièrement actualisés.

**Service 9 : Communauté de santé**
- Participer à des forums de discussion entre utilisateurs.
- Échanger des expériences en matière de santé.
- Bénéficier d’un soutien social entre patients.
- Rejoindre des groupes de soutien pour les maladies chroniques.
- Partager des réussites liées à la santé.
- Obtenir des conseils d’experts de la santé.

**Service 10 : Service clientèle**
- Assistance technique 24 heures sur 24.
- Résolution rapide des problèmes et demandes.
- Aide à l’utilisation de la plateforme.
- Réception des réclamations et suggestions.
- Suivi des dossiers jusqu’à leur résolution.
- Plusieurs canaux de communication.'''],
      '5': [
'''**Creating an account:**
To use Sehatak’s services, you must create a personal account. By creating your account, you agree to the following:

1. **Eligibility:**
   - You must be at least 18 years old.
   - If you are under 18, you must obtain parental or guardian consent.
   - You must have the legal capacity to enter into contracts.

2. **Information provided:**
   - Provide accurate and complete information during registration.
   - Update your information periodically to keep it accurate.
   - Do not impersonate others or use false information.
   - Provide a valid email address and telephone number.

3. **Login credentials:**
   - Choose a strong password of at least 8 characters.
   - Do not share your password with anyone.
   - Change your password periodically (preferably every 90 days).
   - Use two-factor authentication (2FA) to protect your account.

4. **Consent to communications:**
   - Agree to receive email messages and notifications.
   - Agree to receive marketing messages (you may opt out).
   - Provide a valid telephone number to receive text messages.

**Account management:**

1. **Updating information:**
   - You may update your personal information at any time.
   - You must notify us of any change to your contact details.
   - We reserve the right to request verification of the information provided.

2. **Privacy:**
   - You can control your privacy settings.
   - You can choose who can see your personal information.
   - You can hide your health information from other users.

3. **Security:**
   - You are responsible for all activity carried out through your account.
   - You must notify us immediately of any unauthorized use.
   - If account compromise is suspected, the account will be suspended immediately.

4. **Multiple accounts:**
   - One person may not create more than one account.
   - Multiple accounts may result in the suspension of all accounts.
   - Multiple accounts may be approved in special circumstances.

**Account cancellation:**

1. **Request:**
   - You may cancel your account at any time.
   - The account is cancelled immediately after confirmation.
   - The account may be restored within 30 days.

2. **Data after cancellation:**
   - Your data will be deleted within 30 days.
   - We may retain certain data for legal purposes.
   - You may request a copy of your data before cancellation.

3. **Consequences:**
   - All future appointments will be cancelled.
   - All active subscriptions will be terminated.
   - All rewards and loyalty points will be forfeited.
   - Services will no longer be accessible.

**Account suspension:**

1. **Reasons:**
   - Violation of the terms and conditions.
   - Suspicious or unlawful activity.
   - Failure to pay for services provided.
   - A request from a legal authority.

2. **Procedure:**
   - You will be notified before suspension, except in emergencies.
   - You may appeal the suspension decision.
   - The case will be investigated within 48 hours.

3. **Restoration:**
   - The account may be restored after the issue is resolved.
   - Restoration may require an additional fee.
   - All data will be restored where possible.''',
'''**Création d’un compte :**
Pour bénéficier des services de Sehatak, vous devez créer un compte personnel. En créant votre compte, vous acceptez ce qui suit :

1. **Éligibilité :**
   - Vous devez avoir au moins 18 ans.
   - Si vous avez moins de 18 ans, vous devez obtenir l’autorisation d’un parent ou tuteur.
   - Vous devez avoir la capacité juridique de conclure des contrats.

2. **Informations fournies :**
   - Fournir des informations exactes et complètes lors de l’inscription.
   - Mettre régulièrement vos informations à jour afin d’en garantir l’exactitude.
   - Ne pas usurper l’identité d’autrui ni utiliser de fausses informations.
   - Fournir une adresse e-mail et un numéro de téléphone valides.

3. **Identifiants de connexion :**
   - Choisir un mot de passe robuste d’au moins 8 caractères.
   - Ne communiquer votre mot de passe à personne.
   - Modifier régulièrement votre mot de passe (de préférence tous les 90 jours).
   - Utiliser l’authentification à deux facteurs (2FA) pour protéger votre compte.

4. **Consentement aux communications :**
   - Accepter de recevoir des e-mails et des notifications.
   - Accepter de recevoir des messages marketing (vous pouvez vous désabonner).
   - Fournir un numéro de téléphone valide pour recevoir des SMS.

**Gestion du compte :**

1. **Mise à jour des informations :**
   - Vous pouvez mettre à jour vos informations personnelles à tout moment.
   - Vous devez nous informer de tout changement de vos coordonnées.
   - Nous nous réservons le droit de demander la vérification des informations fournies.

2. **Confidentialité :**
   - Vous pouvez contrôler vos paramètres de confidentialité.
   - Vous pouvez choisir qui peut voir vos informations personnelles.
   - Vous pouvez masquer vos informations de santé aux autres utilisateurs.

3. **Sécurité :**
   - Vous êtes responsable de toutes les activités effectuées depuis votre compte.
   - Vous devez nous informer immédiatement de toute utilisation non autorisée.
   - En cas de suspicion de compromission, le compte sera immédiatement suspendu.

4. **Comptes multiples :**
   - Une même personne ne peut pas créer plusieurs comptes.
   - La création de plusieurs comptes peut entraîner leur suspension à tous.
   - Plusieurs comptes peuvent être autorisés dans des circonstances particulières.

**Clôture du compte :**

1. **Demande :**
   - Vous pouvez clôturer votre compte à tout moment.
   - Le compte est clôturé immédiatement après confirmation.
   - Le compte peut être restauré dans un délai de 30 jours.

2. **Données après la clôture :**
   - Vos données seront supprimées dans un délai de 30 jours.
   - Nous pouvons conserver certaines données à des fins légales.
   - Vous pouvez demander une copie de vos données avant la clôture.

3. **Conséquences :**
   - Tous les rendez-vous futurs seront annulés.
   - Tous les abonnements actifs seront résiliés.
   - Toutes les récompenses et tous les points de fidélité seront perdus.
   - Les services ne seront plus accessibles.

**Suspension du compte :**

1. **Motifs :**
   - Violation des conditions générales.
   - Activités suspectes ou illégales.
   - Non-paiement des services fournis.
   - Demande d’une autorité judiciaire.

2. **Procédure :**
   - Vous serez informé avant la suspension, sauf en cas d’urgence.
   - Vous pouvez contester la décision de suspension.
   - Le dossier fera l’objet d’une enquête dans les 48 heures.

3. **Rétablissement :**
   - Le compte peut être rétabli après résolution du problème.
   - Le rétablissement peut nécessiter des frais supplémentaires.
   - Toutes les données seront restaurées dans la mesure du possible.'''],
      '6': [
'''**Important warning:** The information and services provided on Sehatak are for educational and informational purposes only and are not a substitute for consultation with a qualified doctor.

**1. No replacement for in-person medical care:**
- Remote consultations do not replace a direct clinical examination.
- A definitive diagnosis requires a physical examination, laboratory tests, and imaging.
- You must visit a doctor in emergencies and for serious illnesses.
- Do not rely on the application in situations requiring immediate medical intervention.

**2. Accuracy of information:**
- The information provided is for awareness and educational purposes only.
- It may not be suitable for your individual health condition.
- Always consult your doctor before making any health decision.
- Information may contain errors or may not be up to date.

**3. Prescriptions:**
- Electronic prescriptions are preliminary recommendations only.
- Obtain an original prescription from your doctor before purchasing medicines.
- Some medicines require a paper prescription bearing the doctor’s stamp.
- We are not responsible for medicine side effects.

**4. Emergencies:**
- In an emergency, call the local emergency number (199).
- Do not rely on the application in emergency situations.
- Go to the nearest hospital in critical cases.
- Use the application only for non-emergency cases.

**5. Personal responsibility:**
- You alone are responsible for your healthcare decisions.
- The platform accepts no responsibility for damage resulting from use of the information.
- Always consult a specialist before making a health decision.
- You must follow up on your health condition with your treating doctor.

**6. Special circumstances:**
- Pregnant women, children, and older adults require special care.
- Do not use the application for critical or complex conditions.
- Chronic diseases require regular medical follow-up.
- Psychiatric medicines require a special prescription.

**7. Vaccinations:**
- Vaccine information is provided for awareness purposes.
- Consult your doctor about vaccines suitable for you.
- Some vaccines have specific contraindications.
- Follow Ministry of Health instructions regarding vaccines.

**8. Alternative and complementary medicine:**
- We do not recommend using alternative medicine instead of conventional medicine.
- Consult your doctor before using any alternative treatment.
- Some alternative treatments may interact with medicines.
- Be cautious of unverified information.

**9. Self-diagnosis:**
- Do not diagnose yourself using the application.
- Self-diagnosis may lead to serious errors.
- Consult your doctor to diagnose your condition.
- Some symptoms may indicate serious diseases.

**10. Reliance on others:**
- Do not rely on the application to diagnose or treat other people.
- Every person has an individual health condition.
- What is suitable for one person may not be suitable for another.
- Consult a doctor for each individual case.''',
'''**Avertissement très important :** Les informations et services proposés sur Sehatak sont exclusivement destinés à l’éducation et à l’information. Ils ne remplacent pas une consultation auprès d’un médecin qualifié.

**1. Les consultations à distance ne remplacent pas les soins en personne :**
- Les consultations à distance ne remplacent pas un examen clinique direct.
- Un diagnostic définitif nécessite un examen physique, des analyses de laboratoire et de l’imagerie.
- Vous devez consulter un médecin en cas d’urgence ou de maladie grave.
- Ne vous fiez pas à l’application dans les situations nécessitant une intervention médicale immédiate.

**2. Exactitude des informations :**
- Les informations fournies sont uniquement destinées à la sensibilisation et à l’éducation.
- Elles peuvent ne pas convenir à votre état de santé particulier.
- Consultez toujours votre médecin avant toute décision concernant votre santé.
- Les informations peuvent contenir des erreurs ou ne pas être à jour.

**3. Prescriptions médicales :**
- Les prescriptions électroniques ne sont que des recommandations préliminaires.
- Obtenez une ordonnance originale de votre médecin avant d’acheter des médicaments.
- Certains médicaments nécessitent une ordonnance papier portant le cachet du médecin.
- Nous ne sommes pas responsables des effets secondaires des médicaments.

**4. Urgences :**
- En cas d’urgence, appelez le numéro d’urgence local (199).
- Ne vous fiez pas à l’application en situation d’urgence.
- Rendez-vous à l’hôpital le plus proche dans les cas critiques.
- Utilisez l’application uniquement pour les situations non urgentes.

**5. Responsabilité personnelle :**
- Vous êtes seul responsable de vos décisions en matière de santé.
- La plateforme décline toute responsabilité pour les dommages résultant de l’utilisation des informations.
- Consultez toujours un spécialiste avant toute décision de santé.
- Vous devez assurer le suivi de votre état de santé avec votre médecin traitant.

**6. Situations particulières :**
- Les femmes enceintes, les enfants et les personnes âgées nécessitent des soins particuliers.
- N’utilisez pas l’application pour les situations critiques ou complexes.
- Les maladies chroniques nécessitent un suivi médical régulier.
- Les médicaments psychiatriques nécessitent une prescription spéciale.

**7. Vaccinations :**
- Les informations sur les vaccins sont fournies à des fins de sensibilisation.
- Consultez votre médecin au sujet des vaccins qui vous conviennent.
- Certains vaccins présentent des contre-indications particulières.
- Suivez les instructions du ministère de la Santé concernant les vaccins.

**8. Médecines alternatives et complémentaires :**
- Nous ne recommandons pas de remplacer la médecine conventionnelle par la médecine alternative.
- Consultez votre médecin avant tout traitement alternatif.
- Certains traitements alternatifs peuvent interagir avec des médicaments.
- Méfiez-vous des informations non vérifiées.

**9. Autodiagnostic :**
- Ne vous diagnostiquez pas à l’aide de l’application.
- L’autodiagnostic peut entraîner de graves erreurs.
- Consultez votre médecin pour faire diagnostiquer votre état.
- Certains symptômes peuvent être le signe de maladies graves.

**10. Conseils concernant autrui :**
- Ne vous fiez pas à l’application pour diagnostiquer ou traiter d’autres personnes.
- Chaque personne présente un état de santé qui lui est propre.
- Ce qui convient à une personne peut ne pas convenir à une autre.
- Consultez un médecin pour chaque cas individuellement.'''],
      '7': [
'''Doctors and service providers on Sehatak provide their services in good faith and with a high level of professionalism, subject to the following:

**1. Professional responsibility:**
- Doctors alone are responsible for their diagnoses and medical recommendations.
- The application is not responsible for medical errors or misdiagnosis.
- Each doctor bears full responsibility for their consultations.
- The application acts only as an intermediary and does not assume medical responsibility.

**2. Doctors’ obligations:**
- Comply with medical professional ethics.
- Provide patients with accurate and complete information.
- Respect the confidentiality of medical information.
- Continuously update their medical knowledge.

**3. Service quality:**
- Provide high-quality medical services.
- Listen attentively to patients’ concerns.
- Provide clear and understandable recommendations.
- Follow up on the patient’s condition after the consultation.

**4. Service-provider responsibility:**
- Pharmacies are responsible for the correctness of the medicines supplied.
- Laboratories are responsible for the accuracy of test results.
- Hospitals are responsible for the quality of services provided.
- Imaging centres are responsible for the accuracy of scans.

**5. Medical insurance:**
- Service providers are responsible for their professional insurance.
- The platform is not responsible for insurance compensation.
- Service providers must maintain valid professional insurance.
- Insurance covers medical errors and malpractice.

**6. Ratings and complaints:**
- You may rate doctors and service providers.
- You may submit a complaint if you are dissatisfied.
- Complaints are investigated seriously and promptly.
- You will be informed of the investigation outcome.

**7. Sanctions:**
- The platform may suspend any service provider who violates the standards.
- Legal action may be taken against non-compliant providers.
- Sanctions include financial penalties, suspension, or a ban.

**8. Professional conflicts:**
- Doctors must avoid professional conflicts.
- They must disclose any conflict of interest.
- They must preserve the independence of their medical opinions.
- They must not accept gifts that influence their medical decisions.

**9. Communication with patients:**
- Communicate in language the patient can understand.
- Explain the condition and treatment clearly.
- Listen to the patient’s concerns.
- Allow sufficient time for the consultation.

**10. Medical follow-up:**
- Follow up on the patient’s condition after treatment.
- Provide follow-up recommendations.
- Ensure that the patient understands the instructions.
- Contact the patient when necessary.''',
'''Les médecins et prestataires de services de Sehatak fournissent leurs services de bonne foi et avec un haut niveau de professionnalisme, sous réserve des éléments suivants :

**1. Responsabilité professionnelle :**
- Les médecins sont seuls responsables de leurs diagnostics et recommandations médicales.
- L’application n’est pas responsable des erreurs médicales ni des diagnostics erronés.
- Chaque médecin assume l’entière responsabilité de ses consultations.
- L’application agit uniquement comme intermédiaire et n’assume aucune responsabilité médicale.

**2. Obligations des médecins :**
- Respecter la déontologie médicale.
- Fournir aux patients des informations exactes et complètes.
- Respecter la confidentialité des informations médicales.
- Actualiser continuellement leurs connaissances médicales.

**3. Qualité des services :**
- Fournir des services médicaux de haute qualité.
- Écouter attentivement les problèmes du patient.
- Formuler des recommandations claires et compréhensibles.
- Assurer le suivi de l’état du patient après la consultation.

**4. Responsabilité des prestataires :**
- Les pharmacies sont responsables de la conformité des médicaments fournis.
- Les laboratoires sont responsables de l’exactitude des résultats.
- Les hôpitaux sont responsables de la qualité des services fournis.
- Les centres d’imagerie sont responsables de l’exactitude des examens.

**5. Assurance médicale :**
- Les prestataires sont responsables de leur assurance professionnelle.
- La plateforme n’est pas responsable des indemnisations d’assurance.
- Les prestataires doivent disposer d’une assurance professionnelle valide.
- L’assurance couvre les erreurs médicales et les fautes professionnelles.

**6. Évaluations et réclamations :**
- Vous pouvez évaluer les médecins et les prestataires.
- Vous pouvez déposer une réclamation si vous n’êtes pas satisfait.
- Les réclamations font l’objet d’un examen sérieux et rapide.
- Le résultat de l’enquête vous sera communiqué.

**7. Sanctions :**
- La plateforme peut suspendre le compte de tout prestataire qui enfreint les normes.
- Des mesures judiciaires peuvent être prises contre les prestataires en infraction.
- Les sanctions comprennent des amendes, une suspension ou une interdiction.

**8. Conflits professionnels :**
- Les médecins doivent éviter les conflits professionnels.
- Ils doivent déclarer tout conflit d’intérêts.
- Ils doivent préserver l’indépendance de leur avis médical.
- Ils ne doivent pas accepter de cadeaux susceptibles d’influencer leurs décisions médicales.

**9. Communication avec le patient :**
- Communiquer dans une langue compréhensible pour le patient.
- Expliquer clairement l’état de santé et le traitement.
- Être à l’écoute des préoccupations du patient.
- Accorder suffisamment de temps à la consultation.

**10. Suivi médical :**
- Assurer le suivi de l’état du patient après le traitement.
- Fournir des recommandations de suivi.
- Vérifier que le patient comprend les instructions.
- Communiquer avec le patient si nécessaire.'''],
      '8': [
'''Sehatak is committed to protecting your privacy and collects the following data:

**1. Types of data collected**

**A. Personal data:**
- Full name, date of birth, and gender.
- Address, city, and area.
- Telephone number and email address.
- Profile photographs.
- Social-media details, if you choose to link them.

**B. Health data:**
- Complete medical history, including past and current conditions.
- Allergies and medicines that cause allergic reactions.
- Current medicines and dosages.
- Previous tests and results.
- Previous surgical procedures and family health history.
- Health habits, including smoking, drinking, and exercise.
- Vital indicators, including weight, height, blood pressure, and blood glucose.

**C. Usage data:**
- How you use the application and the pages you visit.
- Time spent using the application.
- Features you use most.
- Errors you encounter and your service ratings.

**D. Device data:**
- Device type (iOS / Android) and operating-system version.
- Unique device identifier (UDID).
- IP address.
- Connection type (Wi-Fi / mobile data).

**E. Location data:**
- Geographic location, with your consent.
- Cities and villages you visit.
- Places near you.

**F. Payment data:**
- Preferred payment method.
- Financial transaction details, kept confidential.
- Purchase history and active subscriptions.

**2. How data is used**

**A. Providing services:**
- Providing requested services, booking and managing appointments.
- Reminding you about appointments and medicines.
- Providing remote medical consultations.

**B. Improving services:**
- Analysing application usage.
- Developing new features and fixing technical problems.
- Improving the user experience.

**C. Personalization:**
- Personalizing content and recommendations based on your interests.
- Showing relevant offers and discounts.
- Adapting the interface to your needs.

**D. Communication:**
- Sending notifications, reminders, and service updates.
- Responding to enquiries and complaints.
- Contacting you in emergencies.

**E. Security:**
- Preventing fraud and unlawful activities.
- Protecting your data and verifying your identity when necessary.
- Complying with laws and regulations.

**F. Research and development:**
- Analysing data for research.
- Developing technologies and improving service quality.
- Contributing to health research.

**3. Data sharing**

**A. With service providers:**
- We share data with providers you choose.
- Only the minimum necessary data is shared.
- Providers are required to keep data confidential.

**B. With external entities:**
- We may share data with trusted delivery, payment, and analytics providers.
- We request your consent before sharing data for another purpose.

**C. With legal authorities:**
- We share data when legally requested.
- We comply with applicable laws and protect users’ rights.

**4. Data retention:**
- We retain your data while your account is active.
- Certain data may be retained for legal purposes after cancellation.
- You may request deletion at any time.
- Data is deleted within 30 days of the request.''',
'''Sehatak s’engage à protéger votre vie privée et collecte les données suivantes :

**1. Types de données collectées**

**A. Données personnelles :**
- Nom complet, date de naissance et sexe.
- Adresse, ville et région.
- Numéro de téléphone et adresse e-mail.
- Photos de profil.
- Données de réseaux sociaux, si vous choisissez de les associer.

**B. Données de santé :**
- Historique médical complet, y compris les maladies passées et actuelles.
- Allergies et médicaments provoquant des réactions allergiques.
- Médicaments actuels et dosages.
- Examens antérieurs et résultats.
- Interventions chirurgicales antérieures et antécédents médicaux familiaux.
- Habitudes de santé, notamment tabac, alcool et activité physique.
- Indicateurs vitaux : poids, taille, tension artérielle et glycémie.

**C. Données d’utilisation :**
- Votre utilisation de l’application et les pages consultées.
- Temps passé sur l’application.
- Fonctionnalités les plus utilisées.
- Erreurs rencontrées et évaluations des services.

**D. Données de l’appareil :**
- Type d’appareil (iOS / Android) et version du système.
- Identifiant unique de l’appareil (UDID).
- Adresse IP.
- Type de connexion (Wi-Fi / données mobiles).

**E. Données de localisation :**
- Position géographique, avec votre consentement.
- Villes et villages que vous visitez.
- Lieux situés à proximité.

**F. Données de paiement :**
- Moyen de paiement préféré.
- Détails des transactions financières, conservés de manière confidentielle.
- Historique des achats et abonnements actifs.

**2. Utilisation des données**

**A. Fourniture des services :**
- Fournir les services demandés et gérer les rendez-vous.
- Vous rappeler les rendez-vous et prises de médicaments.
- Fournir des consultations médicales à distance.

**B. Amélioration des services :**
- Analyser l’utilisation de l’application.
- Développer de nouvelles fonctionnalités et corriger les problèmes techniques.
- Améliorer l’expérience utilisateur.

**C. Personnalisation :**
- Personnaliser le contenu et les recommandations selon vos centres d’intérêt.
- Présenter des offres et réductions pertinentes.
- Adapter l’interface à vos besoins.

**D. Communication :**
- Envoyer des notifications, rappels et mises à jour des services.
- Répondre à vos demandes et réclamations.
- Vous contacter en cas d’urgence.

**E. Sécurité :**
- Prévenir la fraude et les activités illégales.
- Protéger vos données et vérifier votre identité si nécessaire.
- Respecter les lois et règlements.

**F. Recherche et développement :**
- Analyser les données à des fins de recherche.
- Développer des technologies et améliorer la qualité des services.
- Contribuer à la recherche en santé.

**3. Partage des données**

**A. Avec les prestataires :**
- Nous partageons les données avec les prestataires que vous choisissez.
- Seules les données nécessaires sont partagées.
- Les prestataires doivent préserver leur confidentialité.

**B. Avec des entités externes :**
- Nous pouvons partager des données avec des prestataires fiables de livraison, de paiement et d’analyse.
- Nous demandons votre consentement avant tout autre partage.

**C. Avec les autorités judiciaires :**
- Nous partageons les données lorsqu’une demande légale l’exige.
- Nous respectons les lois applicables et protégeons les droits des utilisateurs.

**4. Conservation des données :**
- Nous conservons vos données tant que votre compte est actif.
- Certaines données peuvent être conservées à des fins légales après la clôture du compte.
- Vous pouvez demander leur suppression à tout moment.
- Les données sont supprimées dans les 30 jours suivant la demande.'''],
      '9': [
'''Sehatak gives data security the highest priority and applies the following measures:

**1. Encryption:**
- Data in transit is encrypted using TLS 1.3.
- Stored data is encrypted using AES-256.
- Passwords are stored using secure hashing algorithms (bcrypt).
- Encryption keys are stored securely.

**2. Access control:**
- Access is restricted to authorized employees.
- Employees receive regular security training.
- Data access is monitored and logged.
- The principle of least privilege is applied.

**3. Authentication:**
- Two-factor authentication (2FA) is supported.
- Fingerprint and facial recognition may be used.
- Sensitive operations require additional confirmation.
- Sessions expire after inactivity.

**4. Backups:**
- Data is backed up regularly (daily).
- Backups are stored securely and encrypted.
- Recovery is provided for emergencies and tested periodically.

**5. Intrusion monitoring:**
- Suspicious activities are monitored continuously.
- An intrusion detection system (IDS) is used.
- Breaches trigger immediate notification.
- An emergency incident-response team is available.

**6. Vulnerability management:**
- Systems receive regular security updates.
- Periodic penetration tests identify vulnerabilities.
- A dedicated security team monitors threats.
- Vulnerabilities are corrected when discovered.

**7. Reporting policy:**
- Report vulnerabilities to support@sehatak.com.
- Reports are investigated promptly.
- Security contributors are acknowledged.
- Vulnerabilities are disclosed after correction.

**8. Employee training:**
- Employees are trained in information security.
- Training covers emerging threats and simulated phishing.
- A culture of security is promoted.

**9. Standards compliance:**
- Compliance with international security standards (ISO 27001).
- Security best practices and periodic reviews.
- Recognized security certifications.

**10. Privacy protection:**
- Privacy is built into system design.
- Data collection is limited to what is necessary.
- Sensitive data is masked when displayed.
- Users can control their data.''',
'''Sehatak accorde la priorité absolue à la sécurité des données et applique les mesures suivantes :

**1. Chiffrement :**
- Les données en transit sont chiffrées avec TLS 1.3.
- Les données stockées sont chiffrées avec AES-256.
- Les mots de passe sont stockés au moyen d’algorithmes de hachage sécurisés (bcrypt).
- Les clés de chiffrement sont conservées en lieu sûr.

**2. Contrôle des accès :**
- L’accès est réservé aux employés autorisés.
- Les employés suivent régulièrement des formations à la sécurité.
- Les accès aux données sont surveillés et enregistrés.
- Le principe du moindre privilège est appliqué.

**3. Authentification :**
- L’authentification à deux facteurs (2FA) est prise en charge.
- L’empreinte digitale et la reconnaissance faciale peuvent être utilisées.
- Les opérations sensibles exigent une confirmation supplémentaire.
- Les sessions expirent après une période d’inactivité.

**4. Sauvegardes :**
- Les données sont sauvegardées régulièrement (quotidiennement).
- Les sauvegardes sont conservées en lieu sûr et chiffrées.
- La récupération est prévue en cas d’urgence et testée périodiquement.

**5. Surveillance des intrusions :**
- Les activités suspectes font l’objet d’une surveillance continue.
- Un système de détection d’intrusion (IDS) est utilisé.
- Toute violation détectée entraîne une notification immédiate.
- Une équipe d’intervention d’urgence est disponible.

**6. Gestion des vulnérabilités :**
- Les systèmes reçoivent des mises à jour de sécurité régulières.
- Des tests d’intrusion périodiques détectent les vulnérabilités.
- Une équipe spécialisée surveille les menaces.
- Les vulnérabilités sont corrigées dès leur découverte.

**7. Signalement :**
- Les vulnérabilités peuvent être signalées à support@sehatak.com.
- Les signalements sont rapidement examinés.
- Les contributeurs à la sécurité sont reconnus.
- Les vulnérabilités sont divulguées après correction.

**8. Formation du personnel :**
- Les employés sont formés à la sécurité de l’information.
- La formation porte sur les nouvelles menaces et les simulations d’hameçonnage.
- Une culture de sécurité est encouragée.

**9. Conformité aux normes :**
- Respect des normes internationales de sécurité (ISO 27001).
- Application des bonnes pratiques et examens périodiques.
- Certifications de sécurité reconnues.

**10. Protection de la confidentialité :**
- La confidentialité est intégrée dès la conception du système.
- La collecte est limitée aux données nécessaires.
- Les données sensibles sont masquées à l’affichage.
- Les utilisateurs peuvent contrôler leurs données.'''],
      '10': [
'''Users of Sehatak have the following rights:

**1. Right of access:**
- Access your personal data at any time.
- Correct inaccurate data.
- Download a readable copy of your data.
- Learn how your data is used.

**2. Right to rectification:**
- Request correction of inaccurate data.
- Update personal information easily.
- Correction requests are processed within 48 hours.
- You are notified when corrections are completed.

**3. Right to erasure:**
- Request deletion of your account and data.
- Data is deleted within 30 days.
- Certain data may be retained for legal purposes.
- You may restore your account within 30 days.

**4. Right to object:**
- Object to processing of your data.
- Opt out of marketing messages.
- Restrict certain types of processing.
- Your request is considered within 30 days.

**5. Right to data portability:**
- Request transfer of your data to another platform.
- Data is provided in a readable format (JSON or CSV).
- Data is transferred securely within 30 days.
- The platform is not responsible for your data after transfer.

**6. Right to complain:**
- Complain about how your data is processed.
- Complaints are investigated and outcomes communicated.
- You may refer the matter to legal authorities if necessary.

**7. Right to privacy:**
- Your health information is kept private.
- Information is not shared without your consent.
- You control who can see your information.
- You may hide your information from others.

**8. Right to fair treatment:**
- All users are treated fairly without discrimination based on race, religion, gender, or age.
- Laws are applied fairly.
- All parties are heard in disputes.

**9. Right to accountability:**
- Hold the platform accountable for data violations.
- Violations are investigated and appropriate action is taken.
- You are informed of the investigation results.

**10. Right to information:**
- Know how your data is collected and used.
- Know with whom your data is shared.
- Know how long your data is retained.
- Know which security measures are applied.

**11. Right to education:**
- Receive information about your rights.
- Understand how to use the platform.
- Receive support in using the platform.
- Access educational resources.

**12. Right to participate:**
- Participate in platform development.
- Submit suggestions and feedback.
- Participate in studies and research.
- Join the health community.''',
'''Les utilisateurs de Sehatak disposent des droits suivants :

**1. Droit d’accès :**
- Accéder à vos données personnelles à tout moment.
- Corriger les données inexactes.
- Télécharger une copie lisible de vos données.
- Savoir comment vos données sont utilisées.

**2. Droit de rectification :**
- Demander la correction de données inexactes.
- Mettre facilement à jour vos informations personnelles.
- Les demandes sont traitées dans les 48 heures.
- Vous êtes informé lorsque les corrections sont effectuées.

**3. Droit à l’effacement :**
- Demander la suppression de votre compte et de vos données.
- Les données sont supprimées dans les 30 jours.
- Certaines données peuvent être conservées à des fins légales.
- Vous pouvez restaurer votre compte dans les 30 jours.

**4. Droit d’opposition :**
- Vous opposer au traitement de vos données.
- Vous désabonner des messages marketing.
- Limiter certains types de traitement.
- Votre demande est examinée dans les 30 jours.

**5. Droit à la portabilité :**
- Demander le transfert de vos données vers une autre plateforme.
- Les données sont fournies dans un format lisible (JSON ou CSV).
- Le transfert est effectué de manière sécurisée dans les 30 jours.
- La plateforme n’est pas responsable de vos données après leur transfert.

**6. Droit de réclamation :**
- Déposer une réclamation concernant le traitement de vos données.
- Les réclamations sont examinées et les résultats communiqués.
- Vous pouvez saisir les autorités compétentes si nécessaire.

**7. Droit à la confidentialité :**
- Vos informations de santé restent confidentielles.
- Les informations ne sont pas partagées sans votre consentement.
- Vous contrôlez qui peut consulter vos informations.
- Vous pouvez masquer vos informations aux autres.

**8. Droit à un traitement équitable :**
- Tous les utilisateurs sont traités équitablement, sans discrimination fondée sur la race, la religion, le sexe ou l’âge.
- Les lois sont appliquées équitablement.
- Toutes les parties sont entendues en cas de litige.

**9. Droit à la responsabilité :**
- Demander des comptes à la plateforme en cas de violation des données.
- Les violations font l’objet d’une enquête et de mesures appropriées.
- Vous êtes informé des résultats de l’enquête.

**10. Droit à l’information :**
- Savoir comment vos données sont collectées et utilisées.
- Connaître les entités avec lesquelles vos données sont partagées.
- Connaître la durée de conservation de vos données.
- Connaître les mesures de sécurité appliquées.

**11. Droit à l’éducation :**
- Recevoir des informations sur vos droits.
- Comprendre comment utiliser la plateforme.
- Obtenir de l’aide pour utiliser la plateforme.
- Accéder aux ressources éducatives.

**12. Droit à la participation :**
- Participer au développement de la plateforme.
- Soumettre des suggestions et commentaires.
- Participer à des études et recherches.
- Rejoindre la communauté de santé.'''],
      '11': [
'''By using Sehatak, you undertake to:

**1. Accurate information:**
- Provide correct and complete information when registering.
- Update your information regularly.
- Do not impersonate others or use false or misleading information.

**2. Responsible use:**
- Use the platform only for lawful purposes.
- Do not publish harmful or offensive content.
- Do not harass or disturb other users.
- Do not exploit the platform for unlawful purposes.

**3. Security:**
- Keep your password confidential.
- Immediately report any suspected breach.
- Use secure methods to access the platform.
- Do not share login credentials.

**4. Legal compliance:**
- Comply with applicable laws and regulations.
- Do not use the platform for unlawful activities.
- Respect intellectual-property rights and the rights of others.

**5. Communication:**
- Communicate politely and respectfully.
- Do not use abusive or violent language.
- Respect other users’ opinions.
- Provide constructive feedback.

**6. Payments:**
- Pay fees and subscriptions on time.
- Provide accurate payment information.
- Accept responsibility for additional fees.
- Report payment problems to the platform.

**7. Social responsibility:**
- Help build a positive health community.
- Share useful information and avoid misleading content.
- Support other users.

**8. Reporting problems:**
- Report technical errors and problems.
- Report content that violates the rules.
- Cooperate with support and provide complete details.

**9. Application updates:**
- Install updates regularly.
- Use supported application versions.
- Report update problems.
- Update your operating system when necessary.

**10. Protecting reputation:**
- Do not damage the platform’s reputation.
- Do not publish false information about the platform.
- Report misleading information.

**11. Respect:**
- Respect others’ privacy, opinions, and beliefs.
- Do not share another person’s information without consent.
- Treat all users kindly.

**12. Integrity:**
- Be honest in all dealings.
- Do not commit fraud or deception.
- Report suspicious activity.
- Preserve the integrity of the platform.''',
'''En utilisant Sehatak, vous vous engagez à respecter les obligations suivantes :

**1. Exactitude des informations :**
- Fournir des informations exactes et complètes lors de l’inscription.
- Mettre régulièrement vos informations à jour.
- Ne pas usurper l’identité d’autrui ni utiliser d’informations fausses ou trompeuses.

**2. Utilisation responsable :**
- Utiliser la plateforme uniquement à des fins licites.
- Ne pas publier de contenu nuisible ou offensant.
- Ne pas harceler ni importuner les autres utilisateurs.
- Ne pas exploiter la plateforme à des fins illégales.

**3. Sécurité :**
- Garder votre mot de passe confidentiel.
- Signaler immédiatement toute violation présumée.
- Utiliser des moyens sécurisés pour accéder à la plateforme.
- Ne pas partager vos identifiants de connexion.

**4. Respect de la loi :**
- Respecter les lois et règlements applicables.
- Ne pas utiliser la plateforme pour des activités illégales.
- Respecter les droits de propriété intellectuelle et les droits d’autrui.

**5. Communication :**
- Communiquer poliment et avec respect.
- Ne pas utiliser de langage injurieux ou violent.
- Respecter les opinions des autres utilisateurs.
- Fournir des commentaires constructifs.

**6. Paiements :**
- Régler les frais et abonnements dans les délais.
- Fournir des informations de paiement exactes.
- Assumer les frais supplémentaires.
- Signaler tout problème de paiement à la plateforme.

**7. Responsabilité sociale :**
- Contribuer à bâtir une communauté de santé positive.
- Partager des informations utiles et éviter les contenus trompeurs.
- Soutenir les autres utilisateurs.

**8. Signalement des problèmes :**
- Signaler les erreurs et problèmes techniques.
- Signaler les contenus non conformes.
- Coopérer avec l’assistance et fournir des détails complets.

**9. Mises à jour de l’application :**
- Installer régulièrement les mises à jour.
- Utiliser les versions prises en charge.
- Signaler les problèmes liés aux mises à jour.
- Mettre à jour le système d’exploitation si nécessaire.

**10. Préservation de la réputation :**
- Ne pas nuire à la réputation de la plateforme.
- Ne pas publier de fausses informations sur la plateforme.
- Signaler les informations trompeuses.

**11. Respect :**
- Respecter la vie privée, les opinions et les convictions d’autrui.
- Ne pas partager les informations d’une autre personne sans son consentement.
- Traiter tous les utilisateurs avec bienveillance.

**12. Intégrité :**
- Faire preuve d’honnêteté dans toutes les transactions.
- Ne pas commettre de fraude ni de tromperie.
- Signaler toute activité suspecte.
- Préserver l’intégrité de la plateforme.'''],
      '12': [
'''All content on Sehatak is protected by intellectual-property laws.

**1. Ownership:**
- Content is owned by the platform or licensed from third parties.
- Content may not be copied or distributed without prior permission.
- Trademarks and logos are protected by law.
- Copyright is reserved by the platform.

**2. User-published content:**
- User content does not represent the platform’s views.
- The platform is not responsible for user content.
- The platform may remove content that violates the rules.
- Users are responsible for their own content.

**3. Fair use:**
- Content may be used for personal, non-commercial purposes.
- Commercial use requires prior permission.
- The source must be credited.
- Fair use is subject to local laws.

**4. Reporting infringement:**
- Copyright violations may be reported.
- All reports are investigated.
- Infringing content is removed promptly.
- Legal action may be taken against violators.

**5. Automatically generated content:**
- Some content may be generated by artificial intelligence.
- Such content is reviewed for accuracy.
- Generated content may contain errors.
- The platform is not responsible for errors in generated content.

**6. Third-party content:**
- We may display third-party content.
- We are not responsible for its accuracy.
- External links do not constitute endorsement.
- Third-party content should be verified.

**7. User rights:**
- Users retain rights to their content.
- Users grant the platform a licence to use their content.
- Users may delete their content at any time.
- User content is not used commercially without consent.

**8. Trademarks:**
- The Sehatak trademark is protected.
- It may not be used without permission.
- The logo and icons are protected by copyright.
- Trademark infringement may result in legal liability.

**9. Software:**
- Platform software is protected by copyright.
- Software may not be copied or modified.
- Reverse engineering is prohibited.
- Software use is limited to personal use.

**10. Design:**
- The platform design is protected by copyright.
- It may not be copied or imitated.
- The user interface is protected by law.
- The design is the platform’s intellectual property.''',
'''Tous les contenus de Sehatak sont protégés par les lois relatives à la propriété intellectuelle.

**1. Propriété :**
- Les contenus appartiennent à la plateforme ou sont utilisés sous licence de tiers.
- Il est interdit de les copier ou de les distribuer sans autorisation préalable.
- Les marques et logos sont protégés par la loi.
- Les droits d’auteur sont réservés à la plateforme.

**2. Contenus publiés par les utilisateurs :**
- Les contenus des utilisateurs ne représentent pas l’opinion de la plateforme.
- La plateforme n’est pas responsable de ces contenus.
- La plateforme peut supprimer tout contenu non conforme.
- Les utilisateurs sont responsables de leurs propres contenus.

**3. Usage équitable :**
- Les contenus peuvent être utilisés à des fins personnelles et non commerciales.
- Toute utilisation commerciale nécessite une autorisation préalable.
- La source doit être mentionnée.
- L’usage équitable est soumis aux lois locales.

**4. Signalement des atteintes :**
- Les violations des droits d’auteur peuvent être signalées.
- Tous les signalements font l’objet d’une enquête.
- Les contenus en infraction sont rapidement supprimés.
- Des poursuites peuvent être engagées contre les contrevenants.

**5. Contenus générés automatiquement :**
- Certains contenus peuvent être générés par l’intelligence artificielle.
- Ces contenus sont examinés afin d’en vérifier l’exactitude.
- Les contenus générés peuvent comporter des erreurs.
- La plateforme n’est pas responsable de ces erreurs.

**6. Contenus de tiers :**
- Nous pouvons afficher des contenus provenant de tiers.
- Nous ne sommes pas responsables de leur exactitude.
- Les liens externes ne constituent pas une approbation.
- Les contenus de tiers doivent être vérifiés.

**7. Droits des utilisateurs :**
- Les utilisateurs conservent les droits sur leurs contenus.
- Ils accordent à la plateforme une licence d’utilisation.
- Ils peuvent supprimer leurs contenus à tout moment.
- Les contenus ne sont pas utilisés à des fins commerciales sans consentement.

**8. Marques :**
- La marque Sehatak est protégée.
- Elle ne peut être utilisée sans autorisation.
- Le logo et les icônes sont protégés par le droit d’auteur.
- Toute atteinte à une marque peut engager la responsabilité juridique.

**9. Logiciels :**
- Les logiciels de la plateforme sont protégés par le droit d’auteur.
- Il est interdit de les copier ou de les modifier.
- L’ingénierie inverse est interdite.
- Leur utilisation est limitée à un usage personnel.

**10. Design :**
- Le design de la plateforme est protégé par le droit d’auteur.
- Il est interdit de le copier ou de l’imiter.
- L’interface utilisateur est protégée par la loi.
- Le design constitue la propriété intellectuelle de la plateforme.'''],
      '13': [
'''Payments and subscriptions on Sehatak are governed by these rules:

**1. Payment methods:**
- Credit and debit cards (Visa, Mastercard).
- Digital wallets (Google Pay, Apple Pay, STC Pay).
- Bank transfer for large amounts.
- Cash on delivery for selected services.
- Loyalty and reward points.

**2. Subscriptions:**
- Monthly, annual, and family plans are offered.
- You may choose a plan that suits your needs.
- Subscriptions renew automatically unless cancelled.
- You may cancel at any time.

**3. Fees:**
- Fees are charged in the local currency (Yemeni riyal).
- Additional fees may apply depending on the service.
- Taxes and government charges are included in the price.
- Prices may change with prior notice.

**4. Refunds:**
- Refunds may be requested for specified cases, such as technical errors or services not provided.
- Requests are assessed individually.
- Refund decisions are subject to the platform’s discretion.
- Processing may take up to 14 days.

**5. Billing:**
- Electronic invoices are sent by email.
- Invoices may be downloaded from your account.
- You should retain invoice copies.
- Invoices are available for 3 years.

**6. Suspended accounts:**
- An account may be suspended for non-payment.
- You will be notified before suspension.
- The account may be restored after outstanding payments are settled.
- Late-payment charges may apply.

**7. Prices:**
- Prices may change with 30 days’ prior notice.
- The applicable price is the price in effect at payment.
- Prices do not include additional taxes and fees.
- Offers and discounts are subject to special terms.

**8. Financial security:**
- Transactions are securely encrypted.
- Credit-card details are not stored.
- We comply with PCI DSS payment-security standards.
- We use secure, approved payment gateways.

**9. Electronic invoices:**
- Electronic invoices are legally recognized.
- They may be used for tax purposes.
- Invoices are saved in your account.
- Paper invoices may be requested.

**10. Donations:**
- You may donate to support the platform.
- Donations are voluntary and non-refundable.
- Donations are used to develop the platform.
- Donors may be thanked if they wish.''',
'''Les paiements et abonnements sur Sehatak sont régis par les règles suivantes :

**1. Moyens de paiement :**
- Cartes de crédit et de débit (Visa, Mastercard).
- Portefeuilles numériques (Google Pay, Apple Pay, STC Pay).
- Virement bancaire pour les montants importants.
- Paiement à la livraison pour certains services.
- Points de fidélité et de récompense.

**2. Abonnements :**
- Des formules mensuelles, annuelles et familiales sont proposées.
- Vous pouvez choisir la formule adaptée à vos besoins.
- Les abonnements sont renouvelés automatiquement sauf résiliation.
- Vous pouvez résilier à tout moment.

**3. Frais :**
- Les frais sont facturés dans la monnaie locale (rial yéménite).
- Des frais supplémentaires peuvent s’appliquer selon le service.
- Les taxes et frais gouvernementaux sont inclus dans le prix.
- Les prix peuvent être modifiés moyennant un préavis.

**4. Remboursements :**
- Un remboursement peut être demandé dans certains cas, notamment en cas d’erreur technique ou de service non fourni.
- Les demandes sont examinées individuellement.
- Les décisions relèvent de l’appréciation de la plateforme.
- Le traitement peut prendre jusqu’à 14 jours.

**5. Facturation :**
- Les factures électroniques sont envoyées par e-mail.
- Elles peuvent être téléchargées depuis votre compte.
- Vous devez conserver des copies des factures.
- Les factures sont disponibles pendant 3 ans.

**6. Comptes suspendus :**
- Un compte peut être suspendu en cas de non-paiement.
- Vous serez informé avant la suspension.
- Le compte peut être rétabli après règlement des sommes dues.
- Des pénalités de retard peuvent s’appliquer.

**7. Prix :**
- Les prix peuvent être modifiés moyennant un préavis de 30 jours.
- Le prix applicable est celui en vigueur au moment du paiement.
- Les prix n’incluent pas les taxes et frais supplémentaires.
- Les offres et réductions sont soumises à des conditions particulières.

**8. Sécurité financière :**
- Les transactions sont chiffrées de manière sécurisée.
- Les données des cartes de crédit ne sont pas stockées.
- Nous respectons les normes de sécurité des paiements PCI DSS.
- Nous utilisons des passerelles de paiement sécurisées et agréées.

**9. Factures électroniques :**
- Les factures électroniques sont légalement reconnues.
- Elles peuvent être utilisées à des fins fiscales.
- Elles sont conservées dans votre compte.
- Des factures papier peuvent être demandées.

**10. Dons :**
- Vous pouvez faire un don pour soutenir la plateforme.
- Les dons sont volontaires et non remboursables.
- Ils servent au développement de la plateforme.
- Les donateurs peuvent être remerciés s’ils le souhaitent.'''],
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
