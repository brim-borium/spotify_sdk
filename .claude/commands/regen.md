---
description: Regenerate json_serializable code (build_runner) after editing models, then format
allowed-tools: Bash(dart run build_runner:*), Bash(dart format:*)
---

Regenerate the generated `*.g.dart` files for this package. Use this after
editing anything under `lib/models/` (the `@JsonSerializable` source files) —
never hand-edit `.g.dart`.

1. `dart run build_runner build --delete-conflicting-outputs`
2. `dart format lib`

Then report which `.g.dart` files changed (`git status --short lib/models`) so
the diff can be reviewed.
