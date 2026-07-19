# Android Platform Rules for `spotify_sdk`

Adhere to these rules when working in the [packages/spotify_sdk_android/android/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android) directory.

---

## 1. Project Organization
- Native Android logic is written in Kotlin and located in [packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt).
- Central method-channel callbacks must match the names defined in `MethodNames` inside [packages/spotify_sdk_platform_interface/lib/platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart) exactly.

---

## 2. Dependencies & Build Configuration

- The Spotify App Remote AAR file is downloaded locally. Do not hardcode or commit this file.
- Always verify the module definition at `packages/spotify_sdk_android/android/spotify-app-remote/build.gradle` and import references inside the main `packages/spotify_sdk_android/android/build.gradle.kts` file.
- If dependency errors occur, consult the `android-setup` skill to trigger `dart run spotify_sdk:android_setup --cleanup` followed by setup.

---

## 3. Implementation Patterns

### MethodChannel Communication
- Map method arguments using safe type casting (e.g. `call.argument<String>("uri")`).
- Always handle exceptions safely:
  - If a Spotify error occurs, return `result.error("code", "message", "details")`.
  - Avoid crashing the plugin host activity by wrapping SDK connections in try/catch blocks.

### EventChannel Subscriptions
- Use Kotlin `EventChannel.StreamHandler` for event subscriptions (e.g. player state, connection status).
- Emit JSON strings as values to the event stream so they can be parsed consistently on the Dart side.
- Make sure to clean up resources, close connections, or nullify references in `onCancel`.
