# Firestore user-data security audit and migration plan

**Audited source:** `almwld/Sehatakkkk` branch `master`  
**Audited commit:** `d286c9ffd8b1375d6d68b189710c06de70f40b7d`  
**Firebase project configured in source:** `sehatak-platform`  
**Status:** source-level findings confirmed; deployed rules and live data have not been inspected.

## Executive summary

The current source rules contain two high-priority authorization defects in `match /users/{userId}`:

1. `allow read: if isSignedIn();` lets every authenticated account read every user's complete parent document. The document is not field-filtered by Firestore rules. Source consumers show that the document can contain email, phone, blood type, profile details, and current vitals.
2. `allow create` checks that the document belongs to the caller, but does not constrain the initial `role` to a safe self-assignable role. A caller can satisfy the shown rule while setting a privileged role such as `admin` or `superAdmin`. The admin helper then trusts the role stored in that same user document. This is a potential privilege-escalation path and must be treated as P0 until disproved by deployed rules and a rules-emulator test.

These are findings in the checked-in rules source. They do **not** establish that this exact rules version is currently deployed to Firebase production.

## Confirmed source evidence

### Parent user document exposure

- `firestore.rules`: `match /users/{userId}` grants parent-document reads to any signed-in user.
- `lib/core/services/vitals_service.dart`: reads and writes `users/{uid}.vitals`.
- `lib/presentation/screens/patient/patient_profile.dart`: loads `users/{profileId}` for both own and other-user profiles, then displays public profile fields; email is rendered only for the owner, but the full document is still fetched by the client.
- `lib/presentation/screens/records/share_record_screen.dart`: searches `users` by email to resolve a record recipient.
- `lib/core/services/report_service.dart`: queries the users collection for reports.
- `lib/presentation/screens/dashboard/role_based_dashboard_screen.dart`: reads the current user's role from their own user document.
- `lib/core/services/preload_service.dart`: reads and updates the current user's own document.
- `lib/core/services/symptom_service.dart` and `lib/core/services/health_tracking_service.dart`: access health data under the current user's document/subcollections.

### Potential self-assigned privileged role

The current create condition is equivalent to:

```text
isSelf(userId)
&& request.resource.data.uid == request.auth.uid
&& (request.resource.data.role != 'doctor'
    || request.resource.data.doctorId == request.auth.uid)
```

It does not limit `role` to `user`/ `patient` or another approved self-registration role. The helper `isAdmin()` reads the caller's own user document and treats `role == 'admin'` or `role == 'superAdmin'` as administrative authority. The registration screens create Firebase Auth users, so the rules must independently enforce safe initial roles; client-side UI restrictions are not an authorization boundary.

## Required target data boundaries

### Private `users/{uid}` document

Owner-only client read. Keep account and private application data here, including (as applicable):

- email, phone, contact and identity fields;
- blood type and other private health/profile fields;
- current vitals and private preferences;
- notification counters and private account state;
- fields used only by trusted backend/admin operations.

A narrowly authorized administrative read must be based on trusted authorization (prefer Firebase custom claims or a server-side callable), not a role value a user can self-assign.

### Public `public_profiles/{uid}` document

Create a separate, explicitly allowlisted projection. Candidate fields require product/privacy approval before implementation:

- display name;
- avatar/photo URL;
- short public bio;
- approved professional/public role and verified public badge;
- public counters if needed.

Do not copy email, phone, blood type, vitals, medical records, private account flags, tokens, or private relationship data. Do not make online status public by default; decide separately whether it is necessary and disclose it to users.

## Migration order — do not skip gates

1. **P0: prove and close role self-assignment.** Add emulator tests for self-creating a normal user, self-creating an admin, self-creating a superAdmin, and creating a doctor without the required trusted approval. Make privileged roles assignable only by trusted backend/admin authorization. Review existing user provisioning paths before selecting the exact allowed role enum.
2. **Build public-profile projection.** Define a strict field allowlist and trusted write path (Cloud Function/Admin SDK or a carefully constrained owner update rule). Never let clients write verification/admin fields.
3. **Migrate cross-user readers.** Move patient public profile views and profile identity resolution to `public_profiles`. Preserve follower/following behavior without exposing the parent user document.
4. **Replace email-based user search.** Replace client-side `users.where('email', ...)` with an authenticated callable that resolves a recipient on the server and creates a pending share request. Avoid revealing whether an arbitrary email has an account.
5. **Replace broad admin/report queries.** Move admin user listing and aggregate reporting to server-authorized callable endpoints; do not grant all signed-in clients collection-wide access.
6. **Keep owner health access.** Keep vitals, symptoms, child records, medications, and medical history under owner-only paths. Verify nested collection rules separately; parent-document restrictions do not automatically prove every nested path safe.
7. **Tighten parent rules.** Only after steps 1–6 and passing tests, change `users/{userId}` reads to owner-only plus a narrowly trusted admin path. Do not rely on client route visibility or a user-editable role field.
8. **Deploy with a rollback plan.** Deploy to a staging Firebase project first, run the cross-role matrix, then schedule production deployment. Capture the currently deployed rules before changing them.

## Required Firestore Emulator test matrix

Use synthetic users only (patient A, patient B, doctor, pharmacy/lab partner, admin, superAdmin, unauthenticated):

- unauthenticated user cannot read any private user document;
- patient A can read/write their own permitted private fields;
- patient A cannot read or write patient B's private document, vitals, symptoms, children, or vital history;
- patient A cannot create an `admin` or `superAdmin` user document for themselves;
- patient A cannot modify role, verification, permission, or admin fields after creation;
- doctor/partner cannot read another patient's private account or health data;
- approved public profile can be read without exposing private fields;
- public-profile writes cannot set privileged roles or verification status;
- admin-only operations reject ordinary users and accept only trusted admin identity;
- record sharing resolves recipients through the trusted server path and enforces recipient consent/authorization;
- followers/following and chat/call recipient display continue to work using approved public fields.

## Deployment verification boundary

The web repository's `firebase.json` configures Hosting only; it does not point to a Firestore rules file. The mobile repository's `.firebaserc` names `sehatak-platform`, and its `firebase.json` points Firestore rules to `firestore.rules`. This configuration is not proof of the deployed rules revision.

No production rules read/deployment or live authorization test was performed in this audit. Do not deploy rules based only on this document. First obtain an authorized Firebase CLI/console view of the currently deployed rules and use a staging project plus emulator tests. Never put service-account credentials or patient data in GitHub or chat.

## Acceptance criteria

- No ordinary user can self-assign a privileged role.
- No unrelated signed-in user can read another user's private parent document or health data.
- Approved public profile reads return only allowlisted public fields.
- Admin and partner actions are enforced by trusted server authorization.
- All emulator tests pass; Flutter/backend CI remains green.
- Deployed production rules are compared with the reviewed source and the exact deployment is recorded.
