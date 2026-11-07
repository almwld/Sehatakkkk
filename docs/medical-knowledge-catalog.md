# Sehatak Medical Knowledge Catalog

## Purpose and safety boundary

The local assistant uses a curated, offline, multilingual reference catalog in
`lib/core/services/local_ai/medical_knowledge_catalog.dart`. It currently has
14 topic records, each with Arabic, English, and French text, matching phrases,
a source URL, and a review-state marker.

This is public-health education and first-aid orientation only. It is not a
diagnostic engine, prescribing system, or substitute for an examination.
Medication doses and treatment changes are deliberately not supplied from
unreviewed bundled data. Emergency instructions tell users to contact local
emergency services rather than displaying an unverified country-specific number.

## Current topics

- Stroke warning signs
- New/severe chest pain
- Severe bleeding
- Burns
- Seizures
- Anaphylaxis
- Choking
- Suspected poisoning / overdose
- Severe breathing difficulty
- Suicidal thoughts / immediate self-harm risk
- Diabetes
- Hypertension
- Asthma
- Healthy diet

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
- World Health Organization, Healthy diet:
  https://www.who.int/en/news-room/fact-sheets/detail/healthy-diet
- World Health Organization, Asthma:
  https://www.who.int/news-room/fact-sheets/detail/asthma

## Review status — do not misrepresent

Source pages were checked during implementation and summaries were written
against them. This is not equivalent to clinical validation. Every entry is
marked `editorial_source_checked_clinician_review_pending`. A licensed
clinician/pharmacist must review the Arabic, English, and French wording,
local emergency pathways, and applicability to children, pregnancy, chronic
illness, and local care availability before production use.

## Next clinical-review workflow

1. Assign a clinician reviewer and a pharmacist for medication-related work.
2. Review each language independently; machine or editorial translation is
   not clinical approval.
3. Add reviewer identity/role, review date, source version, and expiry/review
   date to each record.
4. Require evidence and approval before adding doses, diagnostic thresholds,
   or treatment recommendations.
5. Add automated checks for missing language variants, missing sources,
   expired reviews, and accidental medication dosing text.
