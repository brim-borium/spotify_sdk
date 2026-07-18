---
name: build-runner
description: Generates JSON serialization code and models using build_runner in the spotify_sdk package. Use this skill when modifying files in lib/models/ or when there are missing or outdated *.g.dart files.
---

# Build Runner Skill for spotify_sdk

This skill assists the agent in running `build_runner` to generate serialization models.

## When to Use
- When you add or modify a Dart model class in the [lib/models/](file:///Users/tobi/Projects/spotify_sdk/lib/models) directory.
- When compilation errors suggest that `*.g.dart` files (e.g., [player_state.g.dart](file:///Users/tobi/Projects/spotify_sdk/lib/models/player_state.g.dart)) are missing or out of sync.
- When cleaning up conflicts in generated files.

## Workflow

### 1. Generating Files
To build the model files, run the following command from the repository root:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

> [!NOTE]
> Always use `--delete-conflicting-outputs` to ensure that old or conflicting generated code is replaced automatically without prompt blockages.

### 2. Continuous Development (Watch Mode)
If you are doing extensive refactoring of models, you can run the generator in watch mode:
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Guidelines
- **DO NOT** edit the `*.g.dart` files directly. They are auto-generated.
- Ensure that the model file contains the correct `part` directive. For example, `track.dart` must have:
  ```dart
  part 'track.g.dart';
  ```
- Use the `@JsonKey` annotations for snake_case JSON field mapping, as the native Spotify SDKs return keys in snake_case.
