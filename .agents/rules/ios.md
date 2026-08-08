# iOS Platform Rules for `spotify_sdk`

Adhere to these rules when working in [packages/spotify_sdk_ios/ios/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios).

---

## 1. Project Organization
- Native iOS Swift logic lives in [SwiftSpotifySdkPlugin.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift).
- Method and channel names align with `MethodNames` in [platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart).

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
- Extract arguments using Swift `guard` statements and type casting:
  ```swift
  guard let args = call.arguments as? [String: Any],
        let clientID = args["clientId"] as? String else {
      result(FlutterError(code: "invalid_arguments", message: "Missing client ID", details: nil))
      return
  }
  ```
- Map native Swift errors to Dart `PlatformException` via `FlutterError`.

### Swift EventChannel Streams
- Implement `FlutterStreamHandler` for state stream subscriptions.
- Serialize event payloads to JSON strings before calling `events(...)`.
- Prevent memory leaks by capturing `[weak self]` in completion handlers.

