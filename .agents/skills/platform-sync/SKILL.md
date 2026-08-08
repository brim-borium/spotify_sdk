---
name: platform-sync
description: Synchronize method channels and event streams across Dart, Android (Kotlin), iOS (Swift), and Web.
---

# Platform Channel Synchronization (`platform-sync`)

All APIs must be synchronized across Dart, Android, iOS, and Web.

## Reference Map
- **Dart API**: [packages/spotify_sdk/lib/spotify_sdk.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk/lib/spotify_sdk.dart)
- **Central Constants**: [packages/spotify_sdk_platform_interface/lib/platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart)
- **iOS Wrapper**: [packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift)
- **Android Wrapper**: [packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt)
- **Web Wrapper**: [packages/spotify_sdk_web/lib/spotify_sdk_web.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_web/lib/spotify_sdk_web.dart)

## Synchronization Workflow

1. **Constants**: Declare method name in `MethodNames` inside [platform_channels.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_platform_interface/lib/platform_channels.dart).
2. **Dart Interface**: Invoke channel method in [spotify_sdk.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk/lib/spotify_sdk.dart); catch, log via `_logException`, and rethrow.
3. **iOS Swift**: Implement method case in [SwiftSpotifySdkPlugin.swift](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_ios/ios/Classes/SwiftSpotifySdkPlugin.swift).
4. **Android Kotlin**: Implement method branch in [SpotifySdkPlugin.kt](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_android/android/src/main/kotlin/de/minimalme/spotify_sdk/SpotifySdkPlugin.kt).
5. **Web Interop**: Implement platform override in [spotify_sdk_web.dart](file:///Users/tobi/Projects/spotify_sdk/packages/spotify_sdk_web/lib/spotify_sdk_web.dart).

