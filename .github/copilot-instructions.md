# Spotify SDK Flutter Plugin - AI Agent Instructions

## Project Overview

This is a **multi-platform Flutter plugin** that wraps native Spotify SDKs to control Spotify playback. The plugin bridges three native implementations:
- **iOS**: Swift wrapper around [SpotifyiOS SDK](https://github.com/spotify/ios-sdk)
- **Android**: Kotlin/Java wrapper around [spotify-app-remote SDK](https://github.com/spotify/android-sdk)
- **Web**: JavaScript integration with [Spotify Web Playback SDK](https://developer.spotify.com/documentation/web-playback-sdk/)

## Architecture & Code Organization

### Platform Communication Pattern
- **Method Channels**: One-way Dart → Native calls via `MethodChannel('spotify_sdk')`
- **Event Channels**: Native → Dart streams for subscriptions (player state, connection status, etc.)
- All channel/method/param names are **centralized constants** in [lib/platform_channels.dart](lib/platform_channels.dart)

### Directory Structure
```
lib/
  spotify_sdk.dart          # Main API, all public methods
  platform_channels.dart    # Channel/method/param name constants
  models/                   # json_serializable models (.dart + .g.dart pairs)
  enums/                    # Enums (RepeatMode, ImageDimension, etc.)
  extensions/               # Enum value converters
ios/Classes/                # Swift implementation + native bridge
android/src/main/          # Kotlin/Java implementation
example/                    # Full demo app for manual testing
bin/                        # Dart CLI scripts for Android SDK automation
```

## Critical Development Workflows

### Code Generation (Models)
All models in `lib/models/` use `json_serializable`. After modifying any model:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
- Models require `part 'model_name.g.dart';` directive
- Use `@JsonKey(name: 'snake_case')` for JSON field mapping
- Example: [lib/models/player_state.dart](lib/models/player_state.dart)

### Android SDK Setup
The Android SDK is **not checked into version control**. Use the automated setup script:
```bash
dart run spotify_sdk:android_setup
# Options: --sdk-version=X.X.X, --cleanup, --verbose
```
- Downloads `spotify-app-remote-*.aar` from GitHub releases
- Creates module at `android/spotify-app-remote/`
- Updates `android/settings.gradle` and module's `build.gradle`
- See: [bin/android_setup.dart](bin/android_setup.dart)

### Testing
- **No unit tests** for plugin code (requires native SDK mocking)
- **Manual testing only** via example app at `example/`
- Run example app: `cd example && flutter run`
- Must configure `.env` file with Spotify credentials (CLIENT_ID, REDIRECT_URL)

### Platform-Specific Implementation
When adding/modifying API methods:
1. Add method name constant to `MethodNames` in [lib/platform_channels.dart](lib/platform_channels.dart)
2. Implement in [lib/spotify_sdk.dart](lib/spotify_sdk.dart) (Dart API layer)
3. Implement native handlers:
   - iOS: `SwiftSpotifySdkPlugin.swift` switch case in `handle(_:result:)`
   - Android: Corresponding Kotlin handler
   - Web: `spotify_sdk_web.dart` for Web Playback SDK
4. Update example app to demonstrate usage

## Code Conventions & Patterns

### Error Handling
All public API methods follow this pattern:
```dart
static Future<T> methodName() async {
  try {
    return await _channel.invokeMethod(MethodNames.methodName);
  } on Exception catch (e) {
    _logException(MethodNames.methodName, e);
    rethrow;  // Always rethrow after logging
  }
}
```
- Expect `PlatformException` for native errors
- Expect `MissingPluginException` for unimplemented platforms
- Use centralized `_logException` helper with Logger package

### Subscription Streams
Event channels return transformed streams:
```dart
static Stream<PlayerState> subscribePlayerState() {
  return _playerStateChannel
    .receiveBroadcastStream()
    .asyncMap((json) => PlayerState.fromJson(jsonDecode(json.toString())));
}
```

### Platform-Specific Behavior
- **iOS-only parameters**: Mark with doc comment `/// iOS specific: ...`
  - Example: `accessToken` parameter for session persistence
  - Example: `spotifyUri` parameter on connect (iOS auto-plays)
- **Android-only features**: Document with `/// Android only: ...`
- Check [README.md](README.md) API compatibility table for platform support matrix

### Naming Conventions
- **Dart API**: camelCase, descriptive names (e.g., `connectToSpotifyRemote`)
- **Channel names**: snake_case with `_subscription` suffix for event channels
- **JSON keys**: snake_case (handled via `@JsonKey` annotations)
- **Native methods**: Match Dart method names exactly in platform implementations

## Common Pitfalls & Gotchas

1. **iOS Auto-Play Behavior**: Connecting to Spotify on iOS always starts playback. Pass invalid URI to work around (not officially supported).

2. **Web Token Refresh**: On web, only `getAccessToken()` or `connectToSpotifyRemote()` set the internal refresh token. Don't manually persist/swap tokens.

3. **Generated Files**: Never edit `*.g.dart` files manually - they're auto-generated by build_runner.

4. **Subscription Timing**: Only subscribe to PlayerState/PlayerContext **after** successful `connectToSpotifyRemote()` call.

5. **Android Module**: If Android build fails, run cleanup then setup: `dart run spotify_sdk:android_setup --cleanup`.

6. **Spotify Premium Required**: Web SDK only works with Spotify Premium accounts.

## Useful Commands

```bash
# Install dependencies
flutter pub get

# Generate model code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous generation
flutter pub run build_runner watch --delete-conflicting-outputs

# Analyze code
flutter analyze

# Format code (required before PR)
dartfmt -w .

# Setup Android SDK
dart run spotify_sdk:android_setup

# Run example app
cd example && flutter run
```

## Key Files to Reference

- [lib/spotify_sdk.dart](lib/spotify_sdk.dart) - Complete public API surface
- [example/lib/main.dart](example/lib/main.dart) - Usage examples for all features
- [lib/platform_channels.dart](lib/platform_channels.dart) - Single source of truth for channel/method names
- [README.md](README.md) - Platform compatibility matrix, setup instructions, API documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - PR guidelines, code formatting requirements

## External Dependencies

- **iOS**: Requires SpotifyiOS.xcframework (bundled in plugin)
- **Android**: Requires spotify-app-remote AAR (auto-downloaded via setup script)
- **Auth**: Uses spotify-auth library from Maven Central (Android only)
- **Dart packages**: logger, dio, json_annotation, crypto, synchronized
- **Dev packages**: build_runner, json_serializable, flutter_lints
