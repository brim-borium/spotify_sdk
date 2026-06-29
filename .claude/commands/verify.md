---
description: Run the full local verification loop (mirrors CI) and report pass/fail
allowed-tools: Bash(flutter pub get), Bash(dart format:*), Bash(flutter analyze:*), Bash(flutter test:*), Bash(flutter pub publish --dry-run), Bash(pana:*)
---

Run the canonical verification loop for this Flutter plugin, in order. This
mirrors `.github/workflows/pull_request.yml` so that local green == CI green.
Run each step; if one fails, **stop, show the failing output, and propose the
fix** rather than continuing.

1. `flutter pub get`
2. `dart format --set-exit-if-changed lib test example`
3. `flutter analyze lib test example --no-fatal-infos`
4. `flutter test`
5. `flutter pub publish --dry-run`
6. `pana . --no-warning` — confirm the score is still **perfect**; CI fails
   otherwise (see `.github/scripts/verify_pub_score.sh`).

If models were changed, the `.g.dart` files must already be regenerated — run
`/regen` first if unsure.

Finish with a concise PASS/FAIL summary per step.
