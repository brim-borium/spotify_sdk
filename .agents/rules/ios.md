# iOS Platform Rules for `spotify_sdk`

Adhere to these rules when working in the [packages/spotify_sdk_ios/ios/](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios) directory.

---

## 1. Project Organization
- Native iOS Swift logic is written in [packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift).
- Method naming and channel names must align with `MethodNames` defined in [packages/spotify_sdk_platform_interface/lib/platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart).

---

## 2. iOS Specific Behaviors & Constraints

### A. Connection Auto-Play
- Unlike Android, connecting to the Spotify iOS SDK Remote automatically starts playback.
- If you need to establish a connection without starting playback immediately, you must pass an invalid or dummy URI (e.g., `"spotify:track:invalid"`), though this is an unofficial workaround.

### B. Access Token Handling
- iOS requires manual passing of the `accessToken` argument on connection to verify the session.

---

## 3. Implementation Patterns

### Swift MethodChannel Calls
- Extract arguments using Swift guard statements and appropriate type casting:
  ```swift
  guard let args = call.arguments as? [String: Any],
        let clientID = args["clientId"] as? String else {
      result(FlutterError(code: "invalid_arguments", message: "Missing client ID", details: nil))
      return
  }
  ```
- Return errors back to Flutter using `FlutterError` to ensure they map to `PlatformException` in Dart.

### Swift EventChannel Streams
- Implement `FlutterStreamHandler` for state subscriptions.
- Ensure event payloads are serialized to JSON strings prior to calling `events(...)`.
- Guard against memory leaks by capturing `self` weakly where appropriate within completion handlers.
