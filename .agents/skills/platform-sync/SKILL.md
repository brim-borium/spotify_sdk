---
name: platform-sync
description: Explains how to synchronize the Method Channels and Event Channels across Dart, Android (Kotlin), iOS (Swift), and Web platforms when implementing new features or modifying the API in spotify_sdk.
---

# Platform Channel Synchronization Skill for spotify_sdk

This plugin acts as a bridge to native iOS, Android, and Web Spotify SDKs. All APIs must be implemented consistently across platforms.

## Reference Directory Map
- **Dart API Surface**: [packages/spotify_sdk/lib/spotify_sdk.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk/lib/spotify_sdk.dart)
- **Central Constants**: [packages/spotify_sdk_platform_interface/lib/platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart)
- **iOS Wrapper**: [packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift)
- **Android Wrapper**: [packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt)
- **Web Wrapper**: [packages/spotify_sdk_web/lib/spotify_sdk_web.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_web/lib/spotify_sdk_web.dart)

## Synchronizing Platform Code

When adding a new API call:

### 1. Centralize Names
Add the method name or event channel name as a constant in `packages/spotify_sdk_platform_interface/lib/platform_channels.dart` inside the `MethodNames` class:
```dart
class MethodNames {
  static const String myNewMethod = 'myNewMethod';
}
```

### 2. Implement the Dart Interface
In `packages/spotify_sdk/lib/spotify_sdk.dart`, invoke the channel method using standard error logging and Exception re-throwing:
```dart
static Future<bool> myNewMethod() async {
  try {
    return await _channel.invokeMethod(MethodNames.myNewMethod);
  } on Exception catch (e) {
    _logException(MethodNames.myNewMethod, e);
    rethrow;
  }
}
```

### 3. Implement the iOS Swift Bridge
In `packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift`, add a case in the switch within the `handle` function:
```swift
case MethodNames.myNewMethod:
    // Call Spotify iOS SDK and return results via result(...)
```

### 4. Implement the Android Kotlin Bridge
In `packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt`, handle the new method name call:
```kotlin
MethodNames.myNewMethod -> {
    // Invoke Spotify App Remote SDK and call result.success(...) or result.error(...)
}
```

### 5. Implement the Web Bridge
In `packages/spotify_sdk_web/lib/spotify_sdk_web.dart`, implement the platform interface method to call the JS Spotify Web Playback SDK:
```dart
@override
Future<bool> myNewMethod() async {
  // Web specific code
}
```
