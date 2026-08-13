# iOS Platform Rules for `spotify_sdk`

Adhere to these rules when working in [packages/spotify_sdk_ios/ios/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios).

---

## 1. Project Organization
- Native iOS Swift logic lives in [SwiftSpotifySdkPlugin.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift).
- Method and channel names align with [SpotifySdkConstants.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SpotifySdkConstants.swift) and [platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart).
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
- Map native Swift errors to Dart `PlatformException` via `FlutterError`.

### Swift EventChannel Streams
- Implement `FlutterStreamHandler` across all 5 standard event streams:
  - `PlayerStateStreamHandler.swift` (`player_state_subscription`)
  - `PlayerContextStreamHandler.swift` (`player_context_subscription`)
  - `ConnectionStatusStreamHandler.swift` (`connection_status_subscription`)
  - `CapabilitiesHandler.swift` (`capabilities_subscription`, implements `SPTAppRemoteUserAPIDelegate`)
  - `UserStatusHandler.swift` (`user_status_subscription`)
- Serialize event payloads to JSON strings before calling `events(...)`.
- Prevent memory leaks by capturing `[weak self]` in completion handlers and delegates.
