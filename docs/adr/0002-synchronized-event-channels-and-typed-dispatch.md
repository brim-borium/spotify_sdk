# 2. Synchronized Event Channels and Typed Web Dispatch

- **Status**: Accepted
- **Date**: 2026-08-13

## Context

The `spotify_sdk` federated plugin defines 5 standard event streams in `SpotifySdkPlatform`:
1. `subscribePlayerState`
2. `subscribePlayerContext`
3. `subscribeConnectionStatus`
4. `subscribeCapabilities`
5. `subscribeUserStatus`

Previously, native Android and iOS only implemented subsets of these event streams (iOS lacked `capabilities` and `user_status` handlers), and channel names were declared as string literals spread across Kotlin and Swift files. On the Web platform, `WebPlayerDispatcher` converted native JS playback events to Dart models, serialized them to JSON strings, emitted them into string streams, and `SpotifySdkPlugin` deserialized them back from JSON strings into Dart models on every playback tick.

## Decision

1. **Centralize Channel Constants**: Define all method and event channel names in `platform_channels.dart`, mirrored natively in `SpotifySdkConstants.kt` (Android) and `SpotifySdkConstants.swift` (iOS).
2. **Synchronize Native Event Channels**: Implement all 5 event channels across Android (Kotlin) and iOS (Swift) using dedicated stream handlers (`CapabilitiesHandler.swift`, `UserStatusHandler.swift`).
3. **Direct Typed Model Dispatch on Web**: Configure `WebPlayerDispatcher` and `SpotifySdkPlugin` to hold typed `StreamController<T>` instances (`PlayerState`, `PlayerContext`, `ConnectionStatus`, `Capabilities`, `UserStatus`), dispatching models directly without intermediate JSON string encoding/decoding.

## Consequences

- **Cross-Platform Parity**: All 5 event channels are reliably available on Android, iOS, and Web.
- **Web Performance**: Eliminates continuous GC pressure and CPU overhead from string serialization on every playback progress event in the browser.
- **Maintainability**: Channel names and parameter keys are refactored from a single source of truth on each platform.
