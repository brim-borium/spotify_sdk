# Coding Standards for `spotify_sdk`

Guidelines and standards enforced during code review (via `/code-review`).

---

## 1. Architectural Patterns

### Centralized Bridge Pattern
- **Central Constants**: Store all method channel names and parameter keys in `packages/spotify_sdk_platform_interface/lib/platform_channels.dart`, mirrored natively in `SpotifySdkConstants.kt` (Android) and `SpotifySdkConstants.swift` (iOS).
- **Consolidated API**: Expose public methods and event streams through `packages/spotify_sdk/lib/spotify_sdk.dart`.
- **Synchronized Channels**: Support all 5 standard event channels across all platforms (`player_state`, `player_context`, `connection_status`, `capabilities`, `user_status`).

---

## 2. Models & Code Generation

- **Placement**: Place Dart models in `packages/spotify_sdk_platform_interface/lib/models/` using `json_serializable`.
- **Generation**: Auto-generate all `.g.dart` files via `melos run generate:all`. Never edit `.g.dart` files manually.
- **Serialization Keys**: Annotate fields with `@JsonKey(name: 'snake_case')` matching native Spotify SDK payload structure.

---

## 3. Error Handling & Exceptions

- **Defensive Channel Invocations**: Wrap native channel invocations in `try-on Exception` blocks.
- **Specific Exception Types**: Catch `PlatformException` (native errors) and `MissingPluginException` (unimplemented wrappers).
- **Structured Domain Exceptions**: Log errors via `_logException` with the Logger package, mapping to typed `SpotifyException` domain instances (`SpotifyAuthenticationException`, `SpotifyNotInstalledException`, `SpotifyConnectionException`, `SpotifyPlaybackException`, `SpotifyLibraryException`, `SpotifyImageException`, etc.).
- **Preserve Cause**: Always preserve the root `cause` and native error details when propagating domain exceptions.
- **Re-exports**: Re-export and maintain the `SpotifyException` hierarchy in `spotify_sdk_platform_interface`.

---

## 4. Naming & Style Conventions

- **Dart APIs**: Use `camelCase` for methods, parameters, and variables.
- **Native Bridges**: Match Dart method casing exactly across Kotlin, Swift, and JavaScript.
- **Event Channels**: Append `_subscription` suffix to all event channel names.
- **Formatting**: Adhere to standard `dart format` across all Dart code.

---

## 5. Platform-Specific Standards

Review against platform-scoped rules when modifying native implementations:
- **Android**: See `.agents/rules/android.md`.
- **iOS**: See `.agents/rules/ios.md`.
- **Web**: See `.agents/rules/web.md`.
- **E2E Testing**: See `.agents/rules/e2e_testing.md`.
