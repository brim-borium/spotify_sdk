# 3. Structured Domain Exceptions and Error Mapping

- **Status**: Accepted
- **Date**: 2026-08-13

## Context

Prior to this decision, errors from native platform channels were propagated as untyped `PlatformException`s containing platform-specific string error codes (`authenticationTokenError`, `spotifyNotInstalled`, `errorConnecting`, `playError`, etc.). Consuming Flutter applications were forced to inspect raw string codes with fragile string matching to determine failure reasons.

## Decision

1. **Structured Domain Exception Hierarchy**: Introduce `SpotifyException` as a public domain exception base class in `spotify_sdk_platform_interface`, exported via `package:spotify_sdk/spotify_sdk.dart`.
2. **Specialized Domain Subtypes**: Provide specific exception subclasses representing domain failure categories:
   - `SpotifyAuthenticationException`
   - `SpotifyNotInstalledException`
   - `SpotifyConnectionException`
   - `SpotifyPlaybackException`
   - `SpotifyLibraryException`
   - `SpotifyImageException`
   - `SpotifyUnimplementedException`
   - `SpotifyGeneralException`
3. **Smart Mapping Factory**: Implement `SpotifyException.fromPlatformException` and `SpotifyException.fromException` to map native platform error codes into typed instances while preserving the underlying `cause` and diagnostic `details`.

## Consequences

- **Type-Safe Error Handling**: Applications can write idiomatic `on SpotifyNotInstalledException catch (e)` or `on SpotifyAuthenticationException catch (e)` blocks.
- **Diagnostics**: Retains full stack traces and original native `PlatformException` objects in the `cause` field.
- **Backward Compatibility**: `SpotifyException` implements Dart's `Exception` interface, and `PlatformException` can still be caught if needed.
