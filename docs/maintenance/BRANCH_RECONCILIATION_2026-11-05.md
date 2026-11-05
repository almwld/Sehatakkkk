# Branch reconciliation audit — 2026-11-05

## Scope and safety
- Repository: `almwld/Sehatakkkk`
- Comparison base: `master` at `5f683de8674c1da9cd4103c37a6eb5c8cf9edc88`
- Enumerated refs: 27 total (master + 26 topic/backup branches).
- This is a read-only comparison inventory plus a reconciliation decision record.
- No existing branch was deleted, force-updated, merged, or rewritten. The approved Flutter 3.16.0/build baseline was not touched.
- Ahead/behind values are relative to the master SHA above; they are not a measure of feature completeness.

## Complete branch comparison

| Branch | Ahead | Behind | Status | Reconciliation decision |
|---|---:|---:|---|---|
| audit/flutter-3.16-compat | 10 | 72 | diverged | Do not merge build files wholesale; inspect each Gradle/workflow delta against the approved 3.16.0 baseline. |
| audit/release-size-apk-aab | 3 | 98 | diverged | Candidate: isolated release-size audit workflow only; inspect workflow and artifact assumptions before import. |
| backup/broken-build-2026-09-17 | 23 | 1370 | diverged | Backup only; contains stale broad app/backend changes and backup-file removals. Do not merge. |
| backup/pre-analyzer-fixes-2026-09-14 | 206 | 1513 | diverged | Backup only; historical app changes, not a merge candidate. |
| backup/pre-restore-20260913 | 86 | 1513 | diverged | Backup only; historical app changes, not a merge candidate. |
| backup-master-20260914 | 212 | 1513 | diverged | Backup only; overlaps the previous backup and broad historical work. |
| backup-message-listener | 0 | 1363 | behind | No unique commits; retain as historical reference only. |
| ci-test-31657e95 | 0 | 625 | behind | No unique commits; retain as historical reference only. |
| codex/fcm-p0-3 | 11 | 310 | diverged | Candidate: inspect FCM token, notification, Firestore rules and LiveKit server deltas individually; do not merge stale branch. |
| codex/fcm-p0-4 | 3 | 309 | diverged | Candidate: inspect notification-service changes against current master; do not merge stale branch. |
| feat/complete-english-localization | 883 | 98 | diverged | Major localization source branch; contains app_strings.dart (+3925 lines), locale controller and widespread screen edits, but also workflow, Firestore, main.dart, media and pharmacy changes. Extract localization-only changes; never merge whole branch. |
| feat/unified-sehatak-prompt | 94 | 1513 | diverged | Historical broad feature branch; overlaps backup branches. Do not merge wholesale. |
| feature/dental-eye-health | 7 | 1370 | diverged | Candidate feature source: dental/eye models, services, BLoCs, screens and seed script. Re-port only after checking current routes, rules and data schema. |
| fix/android-flutter-vibrate-agp8-manifest | 1 | 70 | diverged | One Android Gradle delta; do not import without checking against the fixed Flutter 3.16.0 build baseline. |
| fix/android-native-libs-apk-packaging | 1 | 72 | diverged | One Android app Gradle delta; do not import without checking the approved APK packaging baseline. |
| fix/call-busy-no-queue | 4 | 1688 | diverged | Candidate: call-service/registry/sound/call-screen logic; highly stale, inspect and port behavior selectively only. |
| fix/chat-voice-recording-reliability | 1 | 222 | diverged | Candidate: isolated chat_input_bar reliability patch; verify current record package/outbox APIs before port. |
| fix/chat-voice-recording-reliability-current | 4 | 72 | diverged | Candidate: chat_input_bar plus workflow edits; separate the Dart change from CI changes and preserve approved workflow keys. |
| fix/ci-vibrate-compile-sdk | 1 | 119 | diverged | Android Gradle-only candidate; do not merge without explicit baseline compatibility review. |
| fix/fcm-call-media-2026-09-17 | 0 | 1362 | behind | No unique commits; historical reference only. |
| fix/featured-products-labs-fallback | 3 | 98 | diverged | Candidate: imagekit/pharmacy fallback changes; compare with current pharmacy service before selective port. |
| fix/medication-syntax | 189 | 1513 | diverged | Historical broad branch; medication_screen contains a large delta but branch also bundles many unrelated old changes. Do not merge wholesale. |
| i18n/post-merge-localization-2026-11-05 | 12 | 3 | diverged | Current narrow localization candidate; 9 changed files including app_strings.dart and pregnancy, location, medicine, patient, pharmacy and shared widgets. PR #19 is draft and reports mergeable=false. |
| i18n/rebased-master-2026-11-05 | 205 | 4 | diverged | Broad localization rebase; dozens of screens changed plus 43 app_strings additions. Extract translation edits only; do not merge 205 commits as a unit. |
| investment/technical-due-diligence-v0.1 | 39 | 98 | diverged | Documentation-only candidate: diligence, baseline, release closure and marketing docs plus PDF workflow. Keep separate from app/runtime integration. |
| restore-12b5640 | 0 | 1513 | behind | No unique commits; historical reference only. |

## Unique change groups to recover

1. **Localization (highest priority)**
   - Sources: `feat/complete-english-localization`, `i18n/rebased-master-2026-11-05`, `i18n/post-merge-localization-2026-11-05`.
   - Recover only translation resources and UI call-site changes. Do not import unrelated `.github/workflows`, `firestore.rules`, `main.dart`, media, or business-logic changes from the large source branch.
   - PR #19 currently has `mergeable=false`. Its diff includes at least one suspicious Dart expression: `const Text(_t(...))`, where `_t` is runtime/context-dependent and cannot be used as a const argument. Resolve this before integration.
   - Reconcile keys by Arabic source string and locale pair, preserve existing translations, and avoid duplicate dictionary keys.

2. **Voice recording reliability**
   - Sources: `fix/chat-voice-recording-reliability`, `fix/chat-voice-recording-reliability-current`.
   - Compare the changed `chat_input_bar.dart` against master and retain only permission/start/stop/outbox durability improvements that match current APIs. Do not import workflow changes bundled in the current branch.

3. **FCM and call handling**
   - Sources: `codex/fcm-p0-3`, `codex/fcm-p0-4`, `fix/call-busy-no-queue`.
   - Port only individually reviewed service/server changes after checking current Firestore rules, token lifecycle and LiveKit contract. The branches are hundreds to over a thousand commits behind.

4. **Pharmacy fallback**
   - Source: `fix/featured-products-labs-fallback`.
   - Review image fallback and pharmacy service changes against current product model and existing fallback behavior.

5. **Dental/eye specialty modules**
   - Source: `feature/dental-eye-health`.
   - Preserve as a feature candidate; route, Firestore rules/indexes, data seeding and screen integration require current-master review before porting.

6. **Release audit and investment documentation**
   - Sources: `audit/release-size-apk-aab`, `investment/technical-due-diligence-v0.1`.
   - Keep separate from runtime code. Release workflow changes require checking the existing AAB workflow and approved APK baseline.

## Safe closeout order
1. Reconcile localization first on a fresh branch from current master; fix compile-time issues and merge only the translation-scoped patch.
2. Port voice reliability as a separate focused change.
3. Review FCM/call and pharmacy deltas independently; no bulk merges.
4. Decide separately whether dental/eye modules are still product scope.
5. Keep backup refs until each unique change group is either recovered or explicitly rejected. Do not delete backups as part of this audit.

## Explicit exclusions
- No branch deletion.
- No force push.
- No bulk merge of divergent branches.
- No change to Flutter version, Gradle/AGP, APK/AAB workflow, signing secrets or approved release settings.
- No claim that translations are complete until all supported locales and user-visible strings are reconciled.
