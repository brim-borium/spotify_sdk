# iOS Platform Rules for `spotify_sdk`

Adhere to these rules when working in [packages/spotify_sdk_ios/ios/spotify_sdk_ios/Classes/](packages/spotify_sdk_ios/ios/spotify_sdk_ios/Classes).

---

## 1. Project Organization
- Native iOS Swift entry point lives in [SpotifySdkPlugin.swift](packages/spotify_sdk_ios/ios/spotify_sdk_ios/Classes/SpotifySdkPlugin.swift).
- Method and channel names reference [SpotifySdkConstants.swift](packages/spotify_sdk_ios/ios/spotify_sdk_ios/Classes/SpotifySdkConstants.swift), mirroring [platform_channels.dart](packages/spotify_sdk_platform_interface/lib/platform_channels.dart).
- Target minimum iOS deployment version is **13.0** (aligned across `spotify_sdk_ios.podspec`, `Package.swift`, and example `Podfile`).

---

## 2. iOS Specific Behaviors & Constraints

### A. Connection Auto-Play
- Spotify iOS SDK Remote automatically initiates playback upon connection.
- Pass a dummy URI (e.g., `"spotify:track:invalid"`) to establish connection without immediate track playback.

### B. Access Token Handling
- Require explicit `accessToken` argument on connection to verify session.

---

## 3. Implementation Patterns

### Swift MethodChannel Calls
- Extract arguments using Swift `guard` statements and type casting with constants from `SpotifySdkConstants`.
- Map native Swift errors to Dart `PlatformException` via `SpotifyErrorMapper` / `FlutterError`.

### Swift EventChannel Streams
- Subclass [StatusHandler.swift](packages/spotify_sdk_ios/ios/spotify_sdk_ios/Classes/StatusHandler.swift) (`FlutterStreamHandler`) for all 5 standard event channels (`player_state`, `player_context`, `connection_status`, `capabilities`, `user_status`).
- Register all 5 stream handlers eagerly inside `SpotifySdkPlugin.register(with:)`, and bind the active `SPTAppRemote` instance via `RemoteManager` upon connection.
- Serialize event payloads to JSON strings before calling `events(...)`.
- Prevent retain cycles by holding `weak var appRemote: SPTAppRemote?` and capturing `[weak self]` in completion handlers and delegates.
