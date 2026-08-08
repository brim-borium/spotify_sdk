# Android Platform Rules for `spotify_sdk`

Adhere to these rules when working in [packages/spotify_sdk_android/android/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android).

---

## 1. Project Organization
- Native Android logic is written in Kotlin located in [SpotifySdkPlugin.kt](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt).
- Method channel callbacks must match exact names in `MethodNames` inside [platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart).

---

## 2. Dependencies & Build Configuration

- Download Spotify App Remote AAR dynamically; exclude the binary from version control.
- Verify module definitions at `packages/spotify_sdk_android/android/spotify-app-remote/build.gradle` and imports in `packages/spotify_sdk_android/android/build.gradle.kts`.
- Resolve dependency errors using the [`android-setup`](file:///Users/tobi/Projects/spotify_sdk/.agents/skills/android-setup/SKILL.md) skill (`dart run spotify_sdk:android_setup --cleanup`).

---

## 3. Implementation Patterns

### MethodChannel Communication
- Extract method arguments using safe Kotlin type casting (e.g. `call.argument<String>("uri")`).
- Return Spotify SDK errors via `result.error("code", "message", "details")`.
- Protect the host activity from crashes by wrapping SDK connection calls in `try-catch` blocks.

### EventChannel Subscriptions
- Implement `EventChannel.StreamHandler` for state subscriptions (player state, connection status).
- Emit JSON strings for consistent cross-platform parsing on Dart side.
- Clean up connections and nullify references inside `onCancel`.

