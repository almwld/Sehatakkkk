#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "=== Sehatak incoming-call static verification ==="

files=(
  "lib/presentation/screens/call/call_screen.dart"
  "lib/presentation/screens/chat/incoming_call_screen.dart"
  "lib/core/services/notification_service.dart"
  "lib/core/services/fcm_token_service.dart"
  "lib/core/services/call_service.dart"
  "lib/core/services/call_sound_coordinator.dart"
  "lib/core/services/livekit_service.dart"
  "lib/main.dart"
  "android/app/src/main/AndroidManifest.xml"
  "android/app/google-services.json"
)

fail=0
for f in "${files[@]}"; do
  if [[ -f "$f" ]]; then echo "PASS file: $f ($(wc -l < "$f") lines)"; else echo "FAIL file: $f"; fail=1; fi
done

check() {
  local label="$1"; shift
  if grep -Rqs --exclude-dir=.git "$1" "${@:2}" 2>/dev/null; then echo "PASS $label"; else echo "FAIL $label"; fail=1; fi
}

check "FCM foreground onMessage" "FirebaseMessaging.onMessage" lib
check "FCM background handler" "onBackgroundMessage" lib
check "FCM opened-app handler" "onMessageOpenedApp" lib
check "FCM terminated handler" "getInitialMessage" lib
check "IncomingCallScreen" "class IncomingCallScreen" lib/presentation/screens/chat/incoming_call_screen.dart
check "Incoming coordinator" "class CallSoundCoordinator" lib/core/services/call_sound_coordinator.dart
check "Incoming dialog routing" "IncomingCallScreen" lib/core/services/call_sound_coordinator.dart
check "LiveKit room" "RoomOptions" lib/core/services/livekit_service.dart
check "Internet permission" "android.permission.INTERNET" android/app/src/main/AndroidManifest.xml
check "Microphone permission" "android.permission.RECORD_AUDIO" android/app/src/main/AndroidManifest.xml
check "Camera permission" "android.permission.CAMERA" android/app/src/main/AndroidManifest.xml
check "Notifications permission" "android.permission.POST_NOTIFICATIONS" android/app/src/main/AndroidManifest.xml
check "Wake lock" "android.permission.WAKE_LOCK" android/app/src/main/AndroidManifest.xml
check "Full-screen intent" "android.permission.USE_FULL_SCREEN_INTENT" android/app/src/main/AndroidManifest.xml
check "Firebase Messaging dependency" "firebase_messaging:" pubspec.yaml
check "LiveKit dependency" "livekit_client:" pubspec.yaml

if command -v flutter >/dev/null 2>&1; then
  echo "=== flutter analyze ==="
  flutter analyze --no-pub || fail=1
else
  echo "SKIP flutter analyze: Flutter SDK not installed in this environment"
fi

if (( fail == 0 )); then echo "STATIC RESULT: PASS"; else echo "STATIC RESULT: FAIL"; fi
exit "$fail"
