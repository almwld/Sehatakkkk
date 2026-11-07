# Sehatak Medical Knowledge Catalog

## Purpose and safety boundary

The local assistant uses a curated, offline, multilingual reference catalog in
`lib/core/services/local_ai/medical_knowledge_catalog.dart`. It contains
20 topic records. Every record has Arabic, English, and French content,
matching phrases, a source URL, and an explicit review-state marker.

This is public-health education and first-aid orientation only. It is not a
diagnostic engine, prescribing system, or substitute for an examination.
Medication doses and treatment changes are deliberately not supplied from
unreviewed bundled data. Emergency instructions direct users to local
emergency services rather than displaying an unverified country-specific number.

## Current topics

1. Stroke warning signs
2. New or severe chest pain
3. Severe bleeding
4. Burns
5. Seizures
6. Anaphylaxis
7. Choking
8. Suspected poisoning or overdose
9. Severe breathing difficulty
10. Suicidal thoughts or immediate self-harm risk
11. Diabetes
12. Hypertension
13. Asthma
14. Healthy diet
15. Physical activity
16. Diarrhoeal disease and dehydration warnings
17. Malaria warning signs and need for prompt testing
18. Pneumonia warning signs in children
19. Seasonal influenza
20. Severe headache warning signs

## Source register

- American Heart Association and American Red Cross, 2024 First Aid Guidelines:
  https://cpr.heart.org/en/resuscitation-science/2024-first-aid-guidelines
- Resuscitation Council UK, 2025 First Aid Guidelines:
  https://www.resus.org.uk/professional-library/2025-resuscitation-guidelines/first-aid-guidelines
- U.S. National Library of Medicine, MedlinePlus, Recognizing Medical Emergencies:
  https://medlineplus.gov/ency/article/001927.htm
- World Health Organization, Diabetes:
  https://www.who.int/news-room/fact-sheets/detail/diabetes
- World Health Organization, Hypertension:
  https://www.who.int/news-room/fact-sheets/detail/hypertension
- World Health Organization, Asthma:
  https://www.who.int/news-room/fact-sheets/detail/asthma
- World Health Organization, Healthy diet:
  https://www.who.int/en/news-room/fact-sheets/detail/healthy-diet
- World Health Organization, Physical activity:
  https://www.who.int/initiatives/behealthy/physical-activity/
- World Health Organization, Diarrhoeal disease:
  https://www.who.int/news-room/fact-sheets/detail/diarrhoeal-disease
- World Health Organization, Malaria questions and answers:
  https://www.who.int/news-room/questions-and-answers/item/malaria
- World Health Organization, Pneumonia:
  https://www.who.int/news-room/fact-sheets/detail/pneumonia
- World Health Organization, Seasonal influenza:
  https://www.who.int/news-room/fact-sheets/detail/influenza-(seasonal)
- World Health Organization, Suicide questions and answers:
  https://www.who.int/news-room/questions-and-answers/item/suicide
- NHS, Headaches:
  https://www.nhs.uk/symptoms/headaches/

## Review status — do not misrepresent

Source pages were checked during implementation and summaries were written
against them. This is not equivalent to clinical validation. Every entry is
marked `editorial_source_checked_clinician_review_pending`. A licensed
clinician/pharmacist must review the Arabic, English, and French wording,
local emergency pathways, and applicability to children, pregnancy, chronic
illness, and local care availability before production use.

## Next clinical-review workflow

1. Assign a clinician reviewer and a pharmacist for medication-related work.
2. Review each language independently; editorial translation is not clinical approval.
3. Add reviewer identity/role, review date, source version, and expiry/review date.
4. Require evidence and approval before adding doses, diagnostic thresholds,
   or treatment recommendations.
5. Add automated checks for missing language variants, missing sources,
   expired reviews, and accidental medication dosing text.
