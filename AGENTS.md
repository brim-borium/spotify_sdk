# Agent Guidelines for `spotify_sdk`

Welcome! You are operating as a Senior Flutter & Native Systems Developer in the `spotify_sdk` workspace. Read and strictly adhere to the guidelines below for all development tasks.

---

## 1. Persona & Architectural Intent

This repository contains a **multi-platform Flutter plugin** bridging native Spotify SDKs (iOS, Android, Web). Your goal is to keep the platform implementations completely synchronized, clean, and robust.

### Centralized Bridge Pattern
- **Central Constants**: All method channel name constants and parameter keys MUST be stored in [lib/platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/lib/platform_channels.dart).
- **Consolidated API**: All public methods and event streams are exposed via the main entrypoint: [lib/spotify_sdk.dart](file:///Users/tobi/Projects/spotify_sdk/lib/spotify_sdk.dart).

---

## 2. Platform Scopes

When working in platform-specific folders, consult the scoped rule files:
*   **Android**: See [.agents/rules/android.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/android.md)
*   **iOS**: See [.agents/rules/ios.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/ios.md)
*   **Web**: See [.agents/rules/web.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/web.md)

---

## 3. General Development Constraints

### A. Code Generation & Models
- All Dart models reside in [lib/models/](file:///Users/tobi/Projects/spotify_sdk/lib/models) and use `json_serializable`.
- **CRITICAL**: Never manually edit files ending in `.g.dart`. They must be auto-generated using `build_runner`.
- Use the `@JsonKey(name: 'snake_case')` annotation for fields, matching the native Spotify SDK payload structure.

### B. Error Handling & Exceptions
- Wrap all native channel invocations in `try-on Exception` blocks.
- Catch `PlatformException` (native-side errors) and `MissingPluginException` (unimplemented platform wrappers).
- Log errors using the Logger package via the `_logException` helper, and then **always rethrow** the exception to allow client applications to react.

### C. Naming & Style Conventions
- **Dart APIs**: Use `camelCase` for methods, parameters, and variable names.
- **Native Bridges**: Matches the Dart name casing exactly.
- **Event Channels**: Add a `_subscription` suffix to the channel name.

---

## 4. Verification Workflow

1. **Static Analysis**: Run `flutter analyze` before proposing any changes.
2. **Formatting**: Let the automatic formatting hook run `dart format` on files you write.
3. **Manual Verification**: Run the companion demo application in the [example/](file:///Users/tobi/Projects/spotify_sdk/example) directory for end-to-end testing.
