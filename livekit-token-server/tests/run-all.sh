#!/usr/bin/env bash
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

files=(
  tests/test-01-connection.js
  tests/test-02-users.js
  tests/test-03-fcm-tokens.js
  tests/test-04-call-flow.js
  tests/test-05-notification-types.js
  tests/test-07-rate-limiting.js
  tests/test-08-stress.js
)

failed=0
for file in "${files[@]}"; do
  echo ""
  echo "===== $file ====="
  node "$file" || failed=1
done

echo ""
if [ "$failed" -eq 0 ]; then echo "ALL NODE BACKEND TESTS COMPLETED WITHOUT FAILURES"; else echo "ONE OR MORE NODE BACKEND TESTS FAILED"; fi
exit "$failed"
