# Agent Guidelines for `spotify_sdk`

Multi-platform Flutter plugin bridging native Spotify SDKs (Android, iOS, Web). Keep platform implementations synchronized, clean, and robust.

---

## 1. Persona & Architectural Intent

### Centralized Bridge Pattern
- **Central Constants**: Store all method channel names and parameter keys in [packages/spotify_sdk_platform_interface/lib/platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart), mirrored natively in `SpotifySdkConstants.kt` (Android) and `SpotifySdkConstants.swift` (iOS).
- **Consolidated API**: Expose public methods and event streams through [packages/spotify_sdk/lib/spotify_sdk.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk/lib/spotify_sdk.dart).
- **Synchronized Channels**: Support all 5 standard event channels across all platforms (`player_state`, `player_context`, `connection_status`, `capabilities`, `user_status`).

---

## 2. Platform Scopes

Consult scoped rule files when touching platform-specific directories:
*   **Android**: See [.agents/rules/android.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/android.md)
*   **iOS**: See [.agents/rules/ios.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/ios.md)
*   **Web**: See [.agents/rules/web.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/web.md)
*   **E2E Testing**: See [.agents/rules/e2e_testing.md](file:///Users/tobi/Projects/spotify_sdk/.agents/rules/e2e_testing.md)

---

## 3. General Development Constraints

### A. Code Generation & Models
- Place Dart models in [packages/spotify_sdk_platform_interface/lib/models/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/models) using `json_serializable`.
- Auto-generate all `.g.dart` files via `build_runner` (do not edit `.g.dart` files manually).
- Annotate fields with `@JsonKey(name: 'snake_case')` matching native Spotify SDK payload structure.

### B. Error Handling & Exceptions
- Wrap native channel invocations in `try-on Exception` blocks.
- Catch `PlatformException` (native errors) and `MissingPluginException` (unimplemented wrappers).
- Log errors via `_logException` with the Logger package, mapping to typed `SpotifyException` domain instances.
- Re-export and maintain the `SpotifyException` hierarchy in `spotify_sdk_platform_interface`.

### C. Naming & Style Conventions
- **Dart APIs**: Use `camelCase` for methods, parameters, and variables.
- **Native Bridges**: Match Dart method casing exactly.
- **Event Channels**: Append `_subscription` suffix to event channel names.

---

## 4. Verification Workflow

1. **Static Analysis**: Run `flutter analyze` before finalizing changes.
2. **Formatting**: Format Dart files with `dart format`.
3. **Manual Verification**: Run the companion demo application in [example/](file:///Users/tobi/Projects/spotify_sdk/example) for end-to-end verification.

---

## Agent Skills

### Issue Tracker
GitHub issues house tasks and specs for this repository. See [docs/agents/issue-tracker.md](file:///Users/tobi/Projects/spotify_sdk/docs/agents/issue-tracker.md).

### Domain Docs
Single-context layout with [CONTEXT.md](file:///Users/tobi/Projects/spotify_sdk/CONTEXT.md) and [docs/adr/](file:///Users/tobi/Projects/spotify_sdk/docs/adr/) at repo root. See [docs/agents/domain.md](file:///Users/tobi/Projects/spotify_sdk/docs/agents/domain.md).
