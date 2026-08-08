---
name: build-runner
description: Generate Dart JSON models and *.g.dart files using build_runner.
---

# Build Runner (`build-runner`)

Run `build_runner` to generate serialization models in [packages/spotify_sdk_platform_interface/lib/models/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/models).

## Invocation

Run from repo root:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

> [!NOTE]
> Pass `--delete-conflicting-outputs` to replace stale generated code automatically.

## Rules

- Auto-generate `*.g.dart` files via `build_runner` (do not edit `.g.dart` manually).
- Ensure model files carry matching `part` directives (e.g. `part 'track.g.dart';`).
- Annotate fields with `@JsonKey(name: 'snake_case')` for Spotify SDK JSON payloads.

