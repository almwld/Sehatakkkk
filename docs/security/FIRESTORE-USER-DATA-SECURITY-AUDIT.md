# Firestore user-data security audit and remediation record

**Repository:** `almwld/Sehatakkkk`  
**Branch:** `master`  
**Firebase project configured in source:** `sehatak-platform`  
**Audit boundary:** source review + synthetic Firestore Emulator tests added; no production data accessed and no production rules deployment performed.

## Executive status

The source-level privacy and self-assigned-role risks identified in the original audit have been mitigated in the checked-in source:

- Self-registration cannot create `admin` or `superAdmin` accounts.
- Self-registration cannot assign privileged permissions or mark an account verified.
- A user can read their own private `users/{uid}` document; unrelated users cannot. Trusted admins retain access for the existing admin dashboards.
- Cross-user profile reads use a server-written `public_profiles/{uid}` projection with a strict allowlist.
- Chat presence is stored under each chat at `chats/{chatId}/presence/{uid}` and is readable only by chat participants.
- Record sharing recipient resolution runs in the authenticated Cloud Function, not through a client query against the users collection.

**Important:** source remediation does not prove that the same rules have been deployed to Firebase. Production deployment status remains unverified.

## Findings and remediation

### 1. Private user document reads

**Original issue:** `allow read: if isSignedIn()` allowed every authenticated account to fetch every user's complete parent document. That document can include email, phone, blood type, vitals, account preferences, and other private data.

**Current source rule:** `users/{userId}` reads are restricted to the document owner or an admin recognized by the rules helper. New Firestore Emulator tests verify that patient A cannot read patient B's document and that owner/admin reads remain allowed.

### 2. Self-assigned administrative roles

**Original issue:** the create rule checked document ownership but did not restrict the initial role. The admin helper trusts the role in the caller's user document, creating a possible privilege-escalation route.

**Current mitigation:** create rules allow only the supported self-registration role list, reject admin/superAdmin and privileged permission fields, and allow only unverified initial states. The public registration UI no longer offers the admin role. Existing role changes remain protected from self-service updates.

### 3. Public profile projection

`functions/public_profile_projection.js` maps a user document into a deliberately limited profile containing only:
- uid, display name, photo/avatar URL, bio;
- role, specialty, facility/location and approved profile text;
- doctor and verification display flags derived from protected account fields.

It excludes email, phone, blood type, vitals, medical history, FCM tokens, notification state, moderation flags, and private messaging preferences. Only trusted Cloud Functions can write `public_profiles`; authenticated clients can read them.

A Firestore trigger synchronizes changes. A dry-run-first Admin SDK backfill script exists at `functions/scripts/backfill_public_profiles.js`. It has **not** been executed against production. Existing public profile pages may not show legacy accounts until this backfill is run in an authorized environment.

### 4. Chat presence

Presence is scoped per chat at `chats/{chatId}/presence/{uid}`. Rules require the caller to be a participant in that chat, and writes must target the caller's own presence document with only the allowed presence fields. This avoids publishing global online status.

### 5. Medical record sharing

The client calls `shareMedicalRecordByEmail`. The trusted function checks that the caller owns the medical record, resolves the recipient by email on the server, and creates a pending share request. The rules restrict shared-record reads to sender/recipient and block direct client creation.

### 6. Consultation prescriptions and private medication data

Medication and medication-history subcollections are now explicitly owner-only. The doctor prescription flow calls `prescribeConsultationMedication`; the trusted function verifies that the caller is the assigned, verified doctor, then updates the consultation and writes the patient's medication plan using Admin SDK. The client no longer writes directly into another user's medication collection.

### 7. Admin dashboards and reports

The existing admin dashboards still query user documents directly. These reads are permitted only for callers whose own user document has an admin/superAdmin role. The source create/update rules now prevent ordinary users from self-assigning those roles going forward. However, existing admin/superAdmin accounts have not yet been audited against an authoritative administrator list. Until that audit is completed, the legacy role-based admin check remains a residual risk. Migration to Firebase custom claims is recommended but not yet implemented.

Owner-scoped health services continue to read their own user document and nested health collections. Each nested collection still requires independent review; restricting the parent document does not automatically prove every nested rule safe.

## Tests added

- `security-tests/firestore.rules.test.js`: synthetic tests for normal registration, rejected admin/superAdmin self-registration, verification-field rejection, role promotion denial, owner read, cross-user denial, admin read, public profile read/write boundaries, shared-record participant access, medication owner isolation, shared-record participant access, and chat presence participant boundaries.
- `functions/public_profile_projection.test.js`: verifies that the public projection contains only allowlisted fields and excludes private account/health data.
- `.github/workflows/firestore-security.yml`: runs Firestore Emulator tests, Cloud Functions syntax checks, and Functions unit tests on relevant changes.

The expanded security workflow passed on commit `3f04cce579de92a0e31c37ddd9b20d5b80c4de30` (run `42304113028`): Firestore Emulator 23/23 tests passed; Functions unit tests 5/5 passed; all Cloud Functions syntax checks passed. This is source/emulator validation only, not a live Firebase deployment test.

## Backfill and deployment gates

1. Run the backfill script first without `--apply` in an authorized Firebase environment and review the scanned count.
2. Confirm the target project is the intended staging project, then run with `--apply` only after approval.
3. Verify the generated public profiles contain no private fields using synthetic test accounts and carefully selected non-sensitive test records.
4. Inspect the currently deployed production rules in Firebase Console/CLI and save a rollback copy.
5. Deploy the reviewed rules to staging, run the cross-account authorization matrix, and test profile, chat, admin, and record-sharing workflows.
6. Deploy to production only after staging acceptance and explicit release approval.
7. Record the deployed rules revision and verify it matches the reviewed source.

No production rules read, production backfill, production deployment, or live patient-account authorization test has been performed in this audit. Never use real patient records in emulator tests or place service-account credentials in GitHub or chat.

## Acceptance criteria

- Ordinary users cannot self-assign admin/superAdmin roles or verification.
- A user cannot read another user's private parent document or health data.
- Public profile documents contain only the approved allowlist.
- Chat presence is available only to participants in that chat.
- Medical record sharing is authorized server-side and readable only by its participants.
- Firestore Emulator and Functions unit tests pass on the latest commit.
- The Flutter 3.16.0 APK workflow remains pinned to 3.16.0 and its configuration was not changed by the security fixes. The current APK validation run `42304069010` is still in progress; do not mark APK build green until it completes.
- Production rules and profile backfill are deployed only after staging validation and explicit approval.
